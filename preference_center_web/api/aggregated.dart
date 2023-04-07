import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:preference_center_web/api/category.dart';
import 'package:preference_center_web/api/preferences.dart';
import 'package:preference_center_web/api/recommendations.dart';
import 'package:preference_center_web/models.dart';
import 'package:preference_center_web/models/builder.dart';

class PreferenceModelsRepository {
  Preferences table;
  Recommendations graph;
  Categories categories;

  PreferenceModelsRepository(this.table, this.graph, this.categories);
}

Future<PreferenceModelsRepository> getPreferences() async {
  Preferences table = await getAllPreferences();
  Recommendations graph = await getRecommendations(table);
  Categories categories = await getAllCategories();

  return PreferenceModelsRepository(table, graph, categories);
}

Future<PreferencesJsonFileParser> loadJsonFiles() async {
  PreferencesJsonFileParser parser = PreferencesJsonFileParser(
    preferencesJson:
        json.decode((await fetchAsset('assets/json/all_preferences.json'))!),
    recommendationsJson:
        json.decode((await fetchAsset('assets/json/recommendations.json'))!),
    categoriesJson:
        json.decode((await fetchAsset('assets/json/categories.json'))!),
  );
  return parser;
}

/// parses a local file in the assets folder
Future<String?> fetchAsset(String url) async =>
    await rootBundle.loadString(url);

Future<String?> fetchNetworkFile(String url) async {
  final http.Response response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    return response.body;
  } else
    throw Exception('Could not load file $url');
}
