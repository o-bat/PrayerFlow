import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:prayer_flow/screens/home_page.dart';
import 'package:prayer_flow/screens/splash_screen.dart';
import 'package:prayer_flow/services/settings_provider.dart';
import 'package:prayer_flow/services/stats_provider.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>(
          create: (context) => SettingsProvider(
            is12h: true,
            selectedM: "Diyanet İşleri Başkanligi, Turkey",
            fajrAlarm: true,
            dhuhrAlarm: true,
            asrAlarm: true,
            maghribAlarm: true,
            ishaAlarm: true,
            selected: "Notification Sound",
          ),
        ),
        ChangeNotifierProvider<StatsProvider>(
          create: (context) => StatsProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) => MaterialApp(
        theme: ThemeData(
          colorSchemeSeed: lightDynamic?.primary,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          colorSchemeSeed: darkDynamic?.primary,
          brightness: Brightness.dark,
        ),
        home: SplashScreen(),
      ),
    );
  }
}
