import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:prayer_flow/models/daily_model.dart';
import 'package:prayer_flow/services/location.dart';

Future<DailyOnline> getDailyOnline(
  BuildContext context,
  double? lat,
  double? lon,
) async {
  String url = "";

  if (lat != null && lon != null) {
    // If lat and lon are provided, use them
    log('Using provided coordinates: lat: $lat, lon: $lon');
    DateTime now = DateTime.now();

    url =
        'https://api.aladhan.com/v1/timings/${now.day}-${now.month}-${now.year}?latitude=$lat&longitude=$lon&method=13';
  } else {
    // If lat and lon are not provided, use the device's location
    log('Using device location');

    final result = await LocationService.requestLocationPermissionSafely(
      context,
    );
    if (result.isGranted) {
      // Get the user's location
      Position position = await Geolocator.getCurrentPosition();

      double deviceLat = position.latitude;
      double deviceLon = position.longitude;

      DateTime now = DateTime.now();

      url =
          'https://api.aladhan.com/v1/timings/${now.day}-${now.month}-${now.year}?latitude=$deviceLat&longitude=$deviceLon&method=13';
    } else if (result.isPermanentlyDenied) {
      //TODO Show manual location entry
    }
  }



  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    return dailyOnlineFromJson(response.body);
  } else {
    throw Exception(
      'Failed to load prayer times. Status: ${response.statusCode}',
    );
  }
}
