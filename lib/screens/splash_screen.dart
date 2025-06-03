import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:prayer_flow/models/daily_model.dart';
import 'package:prayer_flow/screens/home_page.dart';
import 'package:prayer_flow/services/city_databse.dart';
import 'package:prayer_flow/services/daily_api.dart';

import 'package:prayer_flow/services/network_access.dart';
import 'package:prayer_flow/services/notifications.dart';
import 'package:prayer_flow/services/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

Future<List<dynamic>> _initData(BuildContext context) async {
  if (!context.mounted) {
    return Future.error(Exception("Error loading BuildConetxt"));
  }

  final dailyData = await getDailyOnline(context, null, null);

  if (!context.mounted) {
    return Future.error(Exception("Error loading BuildConetxt"));
  }
  final cityData = await getCityName(context, null, null);
  if (!context.mounted) {
    return Future.error(Exception("Error loading BuildConetxt"));
  }
  //initAlarms(dailyData, Provider.of<SettingsProvider>(context));

  return [dailyData, cityData];
}

class _SplashScreenState extends State<SplashScreen> {
  late Future<List<dynamic>> _initFuture;
  @override
  void initState() {
    super.initState();
    _initFuture = _initData(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: FutureBuilder(
        future: checkConnectivity(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data == false) {
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(flex: 3),
                  Transform.scale(
                    scale: 6,
                    child: Icon(
                      Icons.signal_wifi_off,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Spacer(flex: 1),
                  Text(
                    "Oops! Looks like you don't have Internet connection.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Spacer(flex: 3),
                ],
              ),
            );
          }

          if (snapshot.hasData && snapshot.data == true) {
            return FutureBuilder(
              future: _initFuture,
              builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(120),
                      child: Image.asset("assets/ic_launcher.png"),
                    ),
                  );
                } else if (snapshot.hasData) {
                  return HomePage(snapshot: snapshot);
                } else {
                  return Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(120),
                      child: Image.asset("assets/ic_launcher.png"),
                    ),
                  );
                }
              },
            );
          } else {
            return Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(120),
                child: Image.asset("assets/ic_launcher.png"),
              ),
            );
          }
        },
      ),
    );
  }
}



/*

  Future<void> initAlarms(
    DailyOnline snapshot,
    SettingsProvider provider,
  ) async {
    try {
      log('initAlarms started');

      final timings = snapshot.data?.timings;
      if (timings == null) {
        log('No prayer timings available, skipping alarms');
        return;
      }

      log('Setting up individual prayer alarms...');

      if (provider.fajrAlarm == true && timings.fajr != null) {
        log('Scheduling Fajr alarm...');
        await _scheduleNotification(
          timings.fajr.toString(),
          1,
          "Fajr Alarm",
          "It is time for Fajr",
        );
      }
      if (provider.dhuhrAlarm == true && timings.dhuhr != null) {
        log('Scheduling Dhuhr alarm...');
        await _scheduleNotification(
          timings.dhuhr.toString(),
          2,
          "Dhuhr Alarm",
          "It is time for Dhuhr",
        );
      }
      if (provider.asrAlarm == true && timings.asr != null) {
        log('Scheduling Asr alarm...');
        await _scheduleNotification(
          timings.asr.toString(),
          3,
          "Asr Alarm",
          "It is time for Asr",
        );
      }
      if (provider.maghribAlarm == true && timings.maghrib != null) {
        log('Scheduling Maghrib alarm...');
        await _scheduleNotification(
          timings.maghrib.toString(),
          4,
          "Maghrib Alarm",
          "It is time for Maghrib",
        );
      }
      if (provider.ishaAlarm == true && timings.isha != null) {
        log('Scheduling Isha alarm...');
        await _scheduleNotification(
          timings.isha.toString(),
          5,
          "Isha Alarm",
          "It is time for Isha",
        );
      }

      log('All alarms scheduled successfully');
    } catch (e, stackTrace) {
      log('Error in initAlarms: $e');
      log('Stack trace: $stackTrace');
      // Don't rethrow - continue app startup even if alarms fail
    }
  }

  Future<void> _scheduleNotification(
    String time,
    int id,
    String title,
    String body,
  ) async {
    try {
      log('Scheduling notification: $title for time: $time');
      final scheduledDate = getTime(time);
      await NotificationService().showNotification(
        scheduledDate: scheduledDate,
        id: id,
        title: title,
        body: body,
      );
      log('Successfully scheduled: $title at $scheduledDate');
    } catch (e) {
      log('Error scheduling notification $title: $e');
    }
  }

  tz.TZDateTime getTime(String time) {
    try {
      log('Converting time: $time');
      final location = tz.getLocation("Europe/Berlin");
      final now = tz.TZDateTime.now(location);

      final parts = time.split(":");
      if (parts.length != 2) {
        throw FormatException('Invalid time format: $time');
      }

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      var scheduledDate = tz.TZDateTime(
        location,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // If the time has already passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      log('Scheduled time: $scheduledDate');
      return scheduledDate;
    } catch (e) {
      log('Error in getTime(): $e');
      // Return a fallback time (1 minute from now)
      final location = tz.getLocation(tz.local.name);
      final fallback = tz.TZDateTime.now(
        location,
      ).add(const Duration(minutes: 1));
      log('Using fallback time: $fallback');
      return fallback;
    }
  }

*/