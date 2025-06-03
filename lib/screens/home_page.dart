import 'package:flutter/material.dart';
import 'dart:isolate';
import 'package:prayer_flow/models/daily_model.dart';
import 'package:prayer_flow/screens/search_page.dart';
import 'package:prayer_flow/screens/settings.dart';
import 'package:prayer_flow/screens/stats.dart';
import 'package:prayer_flow/services/city_databse.dart';

class HomePage extends StatefulWidget {
  final AsyncSnapshot<List<dynamic>> snapshot;

  const HomePage({super.key, required this.snapshot});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final DailyOnline dailyOnlineData;
  late final CityName cityNameData;
  late final Future<List<Map<String, String>>> prayerTimesFuture;

  @override
  void initState() {
    super.initState();
    dailyOnlineData = widget.snapshot.data![0];
    cityNameData = widget.snapshot.data![1];
    prayerTimesFuture = _computePrayerTimes(dailyOnlineData);
  }

  Stream<DateTime> get _timeStream =>
      Stream.periodic(const Duration(milliseconds: 100), (_) => DateTime.now());

  static Future<List<Map<String, String>>> _computePrayerTimes(
    DailyOnline data,
  ) async {
    final p = ReceivePort();
    await Isolate.spawn(_isolateEntry, [p.sendPort, data]);
    return await p.first as List<Map<String, String>>;
  }

  static void _isolateEntry(List<dynamic> args) {
    final SendPort sendPort = args[0];
    final DailyOnline data = args[1];

    final timings = data.data!.timings!;
    final List<Map<String, String>> prayers = [
      {"name": "Fajr", "time": timings.fajr ?? ""},
      {"name": "Sunrise", "time": timings.sunrise ?? ""},
      {"name": "Dhuhr", "time": timings.dhuhr ?? ""},
      {"name": "Asr", "time": timings.asr ?? ""},
      {"name": "Maghrib", "time": timings.maghrib ?? ""},
      {"name": "Isha", "time": timings.isha ?? ""},
    ];
    sendPort.send(prayers);
  }

  int _currentPage = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchBarPage()),
              );
            },
            icon: Icon(Icons.search),
          ),
        ],
      ),

      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (value) {
          setState(() {
            _currentPage = value;
          });
        },
        selectedIndex: _currentPage,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.leaderboard_outlined),
            label: "Stats",
            selectedIcon: Icon(Icons.leaderboard),
          ),
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: "Home",
            selectedIcon: Icon(Icons.home),
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: "Settings",
            selectedIcon: Icon(Icons.settings),
          ),
        ],
      ),
      body: _currentPage == 0
          ? SafeArea(child: Stats())
          : _currentPage == 1
          ? SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    floating: true,
                    pinned: true,
                    expandedHeight: 100,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${cityNameData.city}, ${cityNameData.country}",
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          StreamBuilder<DateTime>(
                            stream: _timeStream,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final now = snapshot.data!;
                                return Text(
                                  "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}",
                                );
                              }
                              return const Text("--:--:--");
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate([
                      _buildSunriseSunsetCard(context),
                      FutureBuilder<List<Map<String, String>>>(
                        future: prayerTimesFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState !=
                              ConnectionState.done) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final prayers = snapshot.data ?? [];
                          return _buildPrayerTimesCard(context, prayers);
                        },
                      ),
                    ]),
                  ),
                ],
              ),
            )
          : SafeArea(child: Settings()),
    );
  }

  Widget _buildSunriseSunsetCard(BuildContext context) {
    return Card.filled(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: StreamBuilder<DateTime>(
          stream: _timeStream,
          builder: (context, snapshot) {
            final now = snapshot.data ?? DateTime.now();
            final currentTime =
                now.hour + (now.minute / 60) + (now.second / 3600);

            DateTime parseTime(String timeString) {
              final parts = timeString.split(':');
              return DateTime(
                now.year,
                now.month,
                now.day,
                int.parse(parts[0]),
                int.parse(parts[1]),
              );
            }

            final sunrise = parseTime(
              dailyOnlineData.data!.timings!.sunrise ?? "00:00",
            );
            final sunset = parseTime(
              dailyOnlineData.data!.timings!.sunset ?? "00:00",
            );

            final sunriseHour = sunrise.hour + (sunrise.minute / 60);
            final sunsetHour = sunset.hour + (sunset.minute / 60);

            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;

                return Stack(
                  children: [
                    LinearProgressIndicator(
                      minHeight: 12,
                      value: currentTime / 24,
                      backgroundColor: Theme.of(context).disabledColor,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                    for (var entry in [
                      {'icon': Icons.wb_sunny_outlined, 'hour': sunriseHour},
                      {'icon': Icons.nightlight_outlined, 'hour': sunsetHour},
                    ])
                      Positioned(
                        left: width * (entry['hour'] as double) / 24 - 8,
                        top: 15,
                        child: Icon(
                          entry['icon'] as IconData,
                          size: 20,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    for (var hour in [sunriseHour, sunsetHour])
                      Positioned(
                        left: width * hour / 24,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 4,
                          color: Theme.of(
                            context,
                          ).colorScheme.secondaryContainer,
                        ),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildPrayerTimesCard(
    BuildContext context,
    List<Map<String, String>> prayers,
  ) {
    return Card.filled(
      child: StreamBuilder<DateTime>(
        stream: _timeStream,
        builder: (context, snapshot) {
          final now = snapshot.data ?? DateTime.now();
          final currentTime =
              "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

          return Column(
            children: [
              for (int i = 0; i < prayers.length; i++)
                _buildPrayerTimeCard(
                  context,
                  prayers[i]["name"]!,
                  prayers[i]["time"]!,
                  currentTime,
                  i < prayers.length - 1 ? prayers[i + 1]["time"]! : "23:59",
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPrayerTimeCard(
    BuildContext context,
    String title,
    String time,
    String currentTime,
    String nextTime,
  ) {
    final isActive =
        currentTime.compareTo(time) >= 0 && currentTime.compareTo(nextTime) < 0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).colorScheme.surface
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        title: Text(title),
        trailing: Text(time, style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}
