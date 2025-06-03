import 'dart:convert';
import 'dart:developer' as loging;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';
import 'package:prayer_flow/models/city.dart';
import 'package:prayer_flow/services/location.dart';

class CityName {
  final String city;
  final String country;

  CityName({required this.city, required this.country});
}

Future<CityName> getCityName(
  BuildContext context,
  double? lat,
  double? lon,
) async {
  // If lat/lon not provided, get from device
  if (lat == null || lon == null) {
    final result = await LocationService.requestLocationPermissionSafely(
      context,
    );
    if (result.isGranted) {
      Position position = await Geolocator.getCurrentPosition();
      lat = position.latitude;
      lon = position.longitude;
    } else if (result.isPermanentlyDenied) {
      // Show manual location entry
    }
  }

  try {
    final data = await rootBundle.loadString('assets/cities500.txt');
    final lines = const LineSplitter().convert(data);

    double minDistance = double.infinity;
    String? nearestCity;
    String? nearestCountry;

    for (final line in lines) {
      final parts = line.split('\t');
      if (parts.length < 9) continue;

      final cityName = parts[1];
      final latCity = double.tryParse(parts[4]) ?? 0.0;
      final lonCity = double.tryParse(parts[5]) ?? 0.0;
      final country = parts[8];

      final dist = _haversine(lat!, lon!, latCity, lonCity);

      if (dist < minDistance) {
        minDistance = dist;
        nearestCity = cityName;
        nearestCountry = country;
      }
    }

    if (nearestCity != null && nearestCountry != null) {
      loging.log("Done");
      return CityName(city: nearestCity, country: nearestCountry);
    } else {
      throw Exception("No city found nearby");
    }
  } catch (e) {
    throw Exception("Offline city lookup failed: $e");
  }
}

double _haversine(double lat1, double lon1, double lat2, double lon2) {
  const R = 6371; // Earth radius in km
  final dLat = _degToRad(lat2 - lat1);
  final dLon = _degToRad(lon2 - lon1);
  final a =
      sin(dLat / 2) * sin(dLat / 2) +
      cos(_degToRad(lat1)) *
          cos(_degToRad(lat2)) *
          sin(dLon / 2) *
          sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return R * c;
}

double _degToRad(double deg) => deg * pi / 180;






Future<List<City>> loadCities() async {
  final data = await rootBundle.loadString('assets/cities500.txt');
  final lines = data.split('\n');
  List<City> cities = [];

  for (var line in lines) {
    if (line.trim().isEmpty) continue;
    final parts = line.split('\t');

    if (parts.length > 17) {
      final name = parts[1];
      final latitude = double.tryParse(parts[4]) ?? 0.0;
      final longitude = double.tryParse(parts[5]) ?? 0.0;
      final country = parts[8];
      final population = int.tryParse(parts[14]) ?? 0;
      final timezone = parts[17];

      cities.add(
        City(
          name: name,
          latitude: latitude,
          longitude: longitude,
          population: population,
          country: country,
          timezone: timezone,
        ),
      );
    }
  }
  return cities;
}
