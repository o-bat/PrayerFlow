import 'package:flutter/material.dart';
import 'package:prayer_flow/screens/home_page.dart';
import 'package:prayer_flow/services/city_databse.dart';
import 'package:prayer_flow/services/daily_api.dart';

import 'package:prayer_flow/services/network_access.dart';

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
