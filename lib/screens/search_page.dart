import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:prayer_flow/models/city.dart';
import 'package:prayer_flow/screens/searched_page.dart';
import 'package:prayer_flow/services/city_databse.dart';

class SearchBarPage extends StatefulWidget {
  const SearchBarPage({super.key});

  @override
  _SearchBarPageState createState() => _SearchBarPageState();
}

class _SearchBarPageState extends State<SearchBarPage> {
  late Future<List<City>> cities;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    cities = loadCities();
    // Delay the focus request to after the frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('City Search')),
      body: FutureBuilder<List<City>>(
        future: cities,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading cities'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No cities found'));
          } else {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: TypeAheadField<City>(
                focusNode: _focusNode,
                suggestionsCallback: (pattern) {
                  return snapshot.data!
                      .where(
                        (city) =>
                            city.name.toLowerCase().startsWith(
                              pattern.toLowerCase(),
                            ) ||
                            city.country.toLowerCase().startsWith(
                              pattern.toLowerCase(),
                            ),
                      )
                      .toList();
                },
                itemBuilder: (context, City suggestion) {
                  return ListTile(
                    title: Text(suggestion.name),
                    subtitle: Text('${suggestion.country} '),
                  );
                },
                onSelected: (City suggestion) {
                  // Handle city selection
                  log('Selected city: ${suggestion.name}');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PrayerTimesSearchedPage(city: suggestion),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
