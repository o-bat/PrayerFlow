import 'package:flutter/material.dart';
import 'package:prayer_flow/models/city.dart';
import 'package:prayer_flow/services/daily_api.dart';

import 'dart:developer';

import 'package:timezone/timezone.dart' as tz;

class PrayerTimesSearchedPage extends StatefulWidget {
  City city;
  PrayerTimesSearchedPage({super.key, required this.city});

  @override
  State<PrayerTimesSearchedPage> createState() => _PrayerTimesPageState();
}

class _PrayerTimesPageState extends State<PrayerTimesSearchedPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getDailyOnline(
        context,
        widget.city.latitude,
        widget.city.longitude,
      ),
      initialData: null,

      builder: (context, snapshot1) {
        if (snapshot1.hasError) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.primaryFixedDim,
            appBar: AppBar(title: const Text("Prayer Times")),
            body: Center(child: Text("Error: ${snapshot1.error}")),
          );
        }
        if (snapshot1.hasData) {
          return Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  title: IconButton(onPressed: () {}, icon: Icon(Icons.search)),
                  titleSpacing: MediaQuery.of(context).size.width - 50,
                  floating: true,
                  pinned: true,
                  expandedHeight: 200,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${widget.city.name}, ${widget.city.country}",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        StreamBuilder<DateTime>(
                          stream: Stream.periodic(
                            const Duration(milliseconds: 100),
                            (_) {
                              final location = tz.getLocation(
                                widget.city.timezone,
                              );
                              return tz.TZDateTime.now(location);
                            },
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Text(
                                "${snapshot.data!.hour.toString().padLeft(2, '0')}:${snapshot.data!.minute.toString().padLeft(2, '0')}:${snapshot.data!.second.toString().padLeft(2, '0')}",
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
                    Card.filled(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 20.0,
                          left: 20.0,
                          right: 20.0,
                          bottom: 30.0,
                        ),
                        child: StreamBuilder<DateTime>(
                          stream: Stream.periodic(
                            const Duration(milliseconds: 1000),
                            (_) {
                              final location = tz.getLocation(
                                widget.city.timezone,
                              );
                              return tz.TZDateTime.now(location);
                            },
                          ),
                          builder: (context, snapshot) {
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    // Current time calculation
                                    final now = snapshot.data ?? DateTime.now();
                                    final currentTime =
                                        now.hour +
                                        (now.minute / 60) +
                                        (now.second / 3600);

                                    log(currentTime.toString());

                                    // Parse sunrise and sunset times from strings
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

                                    // Example usage (replace with your actual input)
                                    final sunriseTime = parseTime(
                                      snapshot1.data?.data?.timings?.sunrise ??
                                          "",
                                    ); // Example sunrise time
                                    final sunsetTime = parseTime(
                                      snapshot1.data?.data?.timings?.sunset ??
                                          "",
                                    ); // Example sunset time

                                    // Calculate positions for sunrise and sunset
                                    final sunriseHour =
                                        sunriseTime.hour +
                                        (sunriseTime.minute / 60);
                                    final sunsetHour =
                                        sunsetTime.hour +
                                        (sunsetTime.minute / 60);

                                    return Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        LinearProgressIndicator(
                                          minHeight: 12,
                                          value: currentTime / 24,
                                          backgroundColor: Theme.of(
                                            context,
                                          ).disabledColor,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Theme.of(context).primaryColor,
                                              ),
                                        ),
                                        // Sunrise marker
                                        Positioned(
                                          left:
                                              constraints.maxWidth *
                                                  (sunriseHour / 24) -
                                              8, // Adjust to center
                                          top:
                                              15, // Move above the progress bar
                                          child: Icon(
                                            Icons.wb_sunny_outlined,
                                            size: 20,
                                            color: Theme.of(
                                              context,
                                            ).primaryColor,
                                          ),
                                        ),
                                        Positioned(
                                          left:
                                              constraints.maxWidth *
                                              (sunriseHour / 24),
                                          top: 0,
                                          bottom: 0,
                                          child: Container(
                                            width: 4,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.secondaryContainer,
                                          ),
                                        ),
                                        // Sunset marker
                                        Positioned(
                                          left:
                                              constraints.maxWidth *
                                                  (sunsetHour / 24) -
                                              8, // Adjust to center
                                          top:
                                              15, // Move above the progress bar
                                          child: Icon(
                                            Icons.nightlight_outlined,
                                            size: 20,
                                            color: Theme.of(
                                              context,
                                            ).primaryColor,
                                          ),
                                        ),
                                        Positioned(
                                          left:
                                              constraints.maxWidth *
                                              (sunsetHour / 24),
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
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),

                    Card.filled(
                      child: Column(
                        children: [
                          StreamBuilder<DateTime>(
                            stream: Stream.periodic(
                              const Duration(milliseconds: 100),
                              (_) {
                                final location = tz.getLocation(
                                  widget.city.timezone,
                                );
                                return tz.TZDateTime.now(location);
                              },
                            ),
                            builder: (context, snapshot) {
                              final now = snapshot.data ?? DateTime.now();
                              final currentTime =
                                  "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

                              final fajrTime =
                                  snapshot1.data?.data?.timings?.fajr ?? "";
                              final sunriseTime =
                                  snapshot1.data?.data?.timings?.sunrise ?? "";
                              final dhuhrTime =
                                  snapshot1.data?.data?.timings?.dhuhr ?? "";
                              final asrTime =
                                  snapshot1.data?.data?.timings?.asr ?? "";
                              final maghribTime =
                                  snapshot1.data?.data?.timings?.maghrib ?? "";
                              final ishaTime =
                                  snapshot1.data?.data?.timings?.isha ?? "";

                              return Card.filled(
                                child: Column(
                                  children: [
                                    _buildPrayerTimeCard(
                                      context,
                                      "Fajr",
                                      fajrTime,
                                      currentTime,
                                      sunriseTime,
                                    ),
                                    _buildPrayerTimeCard(
                                      context,
                                      "Sunrise",
                                      sunriseTime,
                                      currentTime,
                                      dhuhrTime,
                                    ),
                                    _buildPrayerTimeCard(
                                      context,
                                      "Dhuhr",
                                      dhuhrTime,
                                      currentTime,
                                      asrTime,
                                    ),
                                    _buildPrayerTimeCard(
                                      context,
                                      "Asr",
                                      asrTime,
                                      currentTime,
                                      maghribTime,
                                    ),
                                    _buildPrayerTimeCard(
                                      context,
                                      "Maghrib",
                                      maghribTime,
                                      currentTime,
                                      ishaTime,
                                    ),
                                    _buildPrayerTimeCard(
                                      context,
                                      "Isha",
                                      ishaTime,
                                      currentTime,
                                      "23:59", // End of the day
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          );
        }

        return CircularProgressIndicator();
      },
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
      margin: const EdgeInsets.symmetric(vertical: 4.0), // Optional spacing
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).colorScheme.surface
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.0), // Added radius
      ),
      child: ListTile(
        title: Text(title),
        trailing: Text(time, style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}
