import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  bool is12h;
  String selectedM;
  int numberOfM = 13;
  bool fajrAlarm;
  bool dhuhrAlarm;
  bool asrAlarm;
  bool maghribAlarm;
  bool ishaAlarm;
  String selected;
  int number = 0;

  SettingsProvider({
    required this.is12h,
    required this.selectedM,
    required this.fajrAlarm,
    required this.dhuhrAlarm,
    required this.asrAlarm,
    required this.maghribAlarm,
    required this.ishaAlarm,
    required this.selected,
  }) {
    _loadCMethod();
  }

  void _loadCMethod() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    is12h = prefs.getBool('HourData') ?? true;

    numberOfM = prefs.getInt('CData') ?? 13;

    log(numberOfM.toString());
    numberOfM == 99 ? numberOfM = 6 : numberOfM = numberOfM;

    fajrAlarm = prefs.getBool('fajrAlarm') ?? true;
    dhuhrAlarm = prefs.getBool('dhuhrAlarm') ?? true;
    asrAlarm = prefs.getBool('asrAlarm') ?? true;
    maghribAlarm = prefs.getBool('maghribAlarm') ?? true;
    ishaAlarm = prefs.getBool('ishaAlarm') ?? true;
    number = prefs.getInt('SData') ?? 0;

    notifyListeners();
  }

  void changeCMethod({
    required String newCMethod,
    required List<String> list,
  }) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      int index = list.indexOf(newCMethod);
      if (index == 6) {
        numberOfM == 99;
        await prefs.setInt('CData', 99);
      } else {
        numberOfM = index;
        await prefs.setInt('CData', index);
      }
      selectedM = newCMethod;
      notifyListeners();
      log(numberOfM.toString());
    } catch (e) {
      // Handle errors if necessary
      log('Error saving theme mode: $e');
    }
  }

  void changeSound({
    required String newCMethod,
    required List<String> list,
  }) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      int index = list.indexOf(newCMethod);

      number = index;
      await prefs.setInt('SData', index);

      selected = newCMethod;
      notifyListeners();
      log(number.toString());
    } catch (e) {
      // Handle errors if necessary
      log('Error saving theme mode: $e');
    }
  }

  void changefajrAlarm({required bool newValue, required String name}) async {
    // Obtain shared preferences.
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    log("$newValue  $name");

    prefs.setBool(name, newValue);
    fajrAlarm = newValue;
    notifyListeners();
  }

  void changeDhuhrAlarm({required bool newValue, required String name}) async {
    // Obtain shared preferences.
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    log("$newValue  $name");

    prefs.setBool(name, newValue);
    dhuhrAlarm = newValue;
    notifyListeners();
  }

  void changeAsrAlarm({required bool newValue, required String name}) async {
    // Obtain shared preferences.
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    log("$newValue  $name");

    prefs.setBool(name, newValue);
    asrAlarm = newValue;
    notifyListeners();
  }

  void changeMaghribAlarm({
    required bool newValue,
    required String name,
  }) async {
    // Obtain shared preferences.
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    log("$newValue  $name");

    prefs.setBool(name, newValue);
    maghribAlarm = newValue;
    notifyListeners();
  }

  void changeIshaAlarm({required bool newValue, required String name}) async {
    // Obtain shared preferences.
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    log("$newValue  $name");

    prefs.setBool(name, newValue);
    ishaAlarm = newValue;
    notifyListeners();
  }

  void change24h({required bool newData}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("HourData", newData);
    is12h = newData;
    notifyListeners();

    // Handle errors if necessary
  }
}
