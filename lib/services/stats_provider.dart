import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StatsProvider extends ChangeNotifier {
  int _total =
      0; // Renamed to avoid conflict with getter if any, and make private
  Map<DateTime, int> _data = <DateTime, int>{}; // Renamed to make private

  // Getter for total
  int get total => _total;

  // Getter for data (provides a copy to prevent direct modification from outside)
  Map<DateTime, int> get data => Map.unmodifiable(_data);

  StatsProvider() {
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      _total = prefs.getInt('total') ?? 0;
      String? jsonData = prefs.getString('data') ?? "";
      if (jsonData != null && jsonData.isNotEmpty) {
        try {
          Map<String, dynamic> decodedData = json.decode(jsonData);
          _data = decodedData.map((key, value) {
            return MapEntry(DateTime.parse(key), value as int);
          });
        } catch (e) {
          debugPrint("Error parsing stats data: $e");
          _data = <DateTime, int>{};
        }
      } else {
        _data = <DateTime, int>{};
      }
    } catch (e) {
      debugPrint("Error accessing SharedPreferences: $e");
      // Set default values when SharedPreferences is not accessible
      _total = 0;
      _data = <DateTime, int>{};
    }
    notifyListeners();
  }

  Future<void> _saveData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      Map<String, int> storableData = _data.map((key, value) {
        return MapEntry(key.toIso8601String(), value);
      });

      await Future.wait([
        prefs.setString('data', json.encode(storableData)),
        prefs.setInt('total', _total),
      ]).catchError((error) {
        debugPrint("Error saving data: $error");
        throw error; // Re-throw to be caught by outer try-catch
      });
    } catch (e) {
      debugPrint("Error accessing SharedPreferences: $e");
      // Consider showing a user-facing error message here
    }
  }

  /// Gets the data for a specific DateTime from the in-memory cache.
  /// Returns 0 if no data is found for the given DateTime.
  int getDataForDateTime(DateTime now) {
    // Normalize DateTime to ensure consistent key format if necessary,
    // e.g., if you only care about the date part:
    // DateTime dateOnly = DateTime(now.year, now.month, now.day);
    // return _data[dateOnly] ?? 0;
    // For now, assuming 'now' is used as is:
    return _data[now] ?? 0;
  }

  /// Sets or updates the data for a specific DateTime.
  Future<void> setData(DateTime now, int value) async {
    // Normalize DateTime key if necessary (consistent with getDataForDateTime)
    // DateTime dateOnly = DateTime(now.year, now.month, now.day);
    // _data[dateOnly] = value;
    // For now, assuming 'now' is used as is:
    _data[now] = value;
    // If 'total' needs to be updated based on this new data, do it here.
    // For example, if 'total' is a sum:
    // _total = _data.values.fold(0, (sum, item) => sum + item);
    await _saveData(); // Save both data and total
    notifyListeners();
  }

  Future<void> deleteData(DateTime now) async {
    // Normalize DateTime key if necessary (consistent with getDataForDateTime)
    // DateTime dateOnly = DateTime(now.year, now.month, now.day);
    // _data[dateOnly] = value;
    // For now, assuming 'now' is used as is:
    _data.remove(now);
    // If 'total' needs to be updated based on this new data, do it here.
    // For example, if 'total' is a sum:
    // _total = _data.values.fold(0, (sum, item) => sum + item);
    await _saveData(); // Save both data and total
    notifyListeners();
  }

  /// Example of how you might want to update the total
  Future<void> updateTotal(int newTotal) async {
    _total = newTotal;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('total', _total);
    notifyListeners();
  }
}
