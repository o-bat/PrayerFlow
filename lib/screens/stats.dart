import 'dart:developer';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:prayer_flow/services/stats_provider.dart';

import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class Stats extends StatefulWidget {
  const Stats({super.key});

  @override
  State<Stats> createState() => _StatsState();
}

class PrayerTimes {
  static const List<String> names = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

  static const Map<String, int> notificationIds = {
    'Fajr': 1,
    'Dhuhr': 2,
    'Asr': 3,
    'Maghrib': 4,
    'Isha': 5,
  };
}

class _StatsState extends State<Stats> {
  final Duration animDuration = const Duration(milliseconds: 250);
  int touchedIndex = -1;
  DateTime selectedDate = DateTime.now();
  Map<String, bool> prayerStatus = Map.fromIterable(
    PrayerTimes.names,
    key: (item) => item as String,
    value: (_) => false,
  );

  List<double> getWeeklyData(Map<DateTime, int> dataMap) {
    List<double> weeklyData = List.filled(7, 0.0);
    DateTime today = DateTime.now();
    DateTime monday = today.subtract(Duration(days: today.weekday - 1));

    for (int i = 0; i < 7; i++) {
      DateTime targetDate = monday.add(Duration(days: i));
      DateTime dateKey = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
      );
      int? value = _findDataForDate(dataMap, dateKey);
      weeklyData[i] = (value ?? 0).toDouble();
    }
    return weeklyData;
  }

  int? _findDataForDate(Map<DateTime, int> dataMap, DateTime targetDate) {
    if (dataMap.containsKey(targetDate)) return dataMap[targetDate];
    for (DateTime key in dataMap.keys) {
      DateTime keyDate = DateTime(key.year, key.month, key.day);
      if (keyDate.isAtSameMomentAs(targetDate)) return dataMap[key];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDataBottomSheet(),
        label: const Text('Add Prayer Data'),
        icon: const Icon(Icons.add),
      ),
      body: Consumer<StatsProvider>(
        builder: (context, stats, _) => Column(
          children: <Widget>[
            Text(
              'Prayer Times Stats',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 38),
            Expanded(flex: 4, child: BarChart(mainBarData())),
            Spacer(flex: 1),
            Expanded(
              flex: 4,
              child: Consumer<StatsProvider>(
                builder: (context, statsProvider, _) {
                  final dataList = statsProvider.data.entries.toList()
                    ..sort((a, b) => b.key.compareTo(a.key));
                  return ListView.builder(
                    itemCount: dataList.length,
                    itemBuilder: (context, index) {
                      final entry = dataList[index];
                      final formattedDate = DateFormat(
                        'MMM dd, yyyy',
                      ).format(entry.key);
                      return Card.filled(
                        child: Dismissible(
                          secondaryBackground: Container(
                            color: Theme.of(context).colorScheme.error,
                            child: Icon(Icons.delete),
                          ),
                          onDismissed: (direction) {
                            Provider.of<StatsProvider>(
                              listen: false,
                              context,
                            ).deleteData(entry.key);
                          },
                          key: Key(entry.key.toString()),
                          background: Container(
                            color: Theme.of(context).colorScheme.error,
                            child: Icon(Icons.delete),
                          ),
                          child: ListTile(
                            title: Text(formattedDate),
                            trailing: Text('${entry.value} prayers'),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _resetBottomSheetState() {
    setState(() {
      selectedDate = DateTime.now();
      prayerStatus = {
        'Fajr': false,
        'Dhuhr': false,
        'Asr': false,
        'Maghrib': false,
        'Isha': false,
      };
    });
  }

  void _showAddDataBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outline,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    'Add Prayer Data',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          setModalState(() {
                            selectedDate = selectedDate.subtract(
                              Duration(days: 1),
                            );
                          });
                        },
                        icon: Icon(Icons.arrow_left),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null && picked != selectedDate) {
                            setModalState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            DateFormat('MMM dd, yyyy').format(selectedDate),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed:
                            selectedDate.isBefore(
                              DateTime.now().subtract(Duration(hours: 23)),
                            )
                            ? () {
                                setModalState(() {
                                  selectedDate = selectedDate.add(
                                    Duration(days: 1),
                                  );
                                });
                              }
                            : null,
                        icon: Icon(Icons.arrow_right),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Text(
                    'Select completed prayers:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: prayerStatus.keys.map((prayer) {
                      return _buildPrayerCheckbox(prayer, setModalState);
                    }).toList(),
                  ),
                  Spacer(),
                  SizedBox(
                    child: OutlinedButton(
                      onPressed: () {
                        _saveData();
                        Navigator.pop(context);
                        _resetBottomSheetState();
                      },
                      style: Theme.of(context).outlinedButtonTheme.style,
                      child: Text(
                        'Save Data',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPrayerCheckbox(String prayer, StateSetter setModalState) {
    final isSelected = prayerStatus[prayer]!;
    return GestureDetector(
      onTap: () {
        setModalState(() {
          prayerStatus[prayer] = !isSelected;
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.25,
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                prayer,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              SizedBox(height: 8),
              Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveData() {
    int completedPrayers = prayerStatus.values
        .where((completed) => completed)
        .length;
    DateTime dateKey = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    Provider.of<StatsProvider>(
      context,
      listen: false,
    ).setData(dateKey, completedPrayers);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Saved $completedPrayers prayers for ${DateFormat('MMM dd, yyyy').format(selectedDate)}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  BarChartData mainBarData() {
    var statsProvider = Provider.of<StatsProvider>(context);
    var dataMap = statsProvider.data.isEmpty
        ? <DateTime, int>{DateTime.now(): 0}
        : statsProvider.data;
    List<double> weeklyData = getWeeklyData(dataMap);

    return BarChartData(
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: getTitles,
            reservedSize: 38,
          ),
        ),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(show: false),
      barGroups: _buildBarGroups(weeklyData),
      gridData: const FlGridData(show: false),
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            String weekDay = _getWeekDayName(group.x);
            return BarTooltipItem(
              '$weekDay\n',
              TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: '${rod.toY.round()} prayers',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                barTouchResponse == null ||
                barTouchResponse.spot == null) {
              touchedIndex = -1;
              return;
            }
            touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          });
        },
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(List<double> weeklyData) {
    return List.generate(7, (index) {
      return makeGroupData(
        index,
        weeklyData[index],
        isTouched: touchedIndex == index,
        barColor: touchedIndex == index
            ? Theme.of(context).colorScheme.secondary
            : Theme.of(context).colorScheme.primary,
        showTooltips: touchedIndex == index ? [0] : [],
      );
    });
  }

  String _getWeekDayName(int index) {
    const weekDays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return weekDays[index];
  }

  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 12);
    String text = _getWeekDayName(value.toInt());
    return SideTitleWidget(
      meta: meta,
      space: 16,
      child: Text(text.substring(0, 3), style: style),
    );
  }

  BarChartGroupData makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    Color? barColor,
    double width = 22,
    List<int> showTooltips = const [],
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: isTouched ? y : y,
          color: barColor,
          width: width,
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 5,
            color: Theme.of(context).colorScheme.surfaceVariant,
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }
}
