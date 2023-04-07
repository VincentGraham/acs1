import 'dart:convert';

import 'package:preference_center_web/api/aggregated.dart';
import 'package:preference_center_web/models/builder.dart';
import 'package:preference_center_web/models/preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalRepository {
  final SharedPreferences localData;

  const LocalRepository({required this.localData});

  /// returns a stored entry of a specific [Preference],
  /// [Recommendation], or [Category] in its json format
  Map<String, dynamic> readLocalEntry(String key) {
    final preference = localData.getString('$key');

    if (preference == null) return {};

    return Map<String, dynamic>.from(json.decode(preference));
  }

  Future writeLocalEntry(Map<String, dynamic> item,
      {String type = 'preference'}) {
    return Future.wait(
            [localData.setString('$type-${item["code"]}', json.encode(item))])
        .then((e) => print("done!"));
  }

  /// attempt to load preferences from local storage (from a browser)
  /// or load the built in data
  Future<PreferencesJsonFileParser> loadPreferences() async {
    List<String> preferenceKeys = [];
    List<String> recommendationKeys = [];
    List<String> categoryKeys = [];

    /// some information is stored in the browser
    var keys = localData.getKeys();
    if (keys.isNotEmpty) {
      preferenceKeys = keys.where((key) => key.contains('preference')).toList();
      recommendationKeys =
          keys.where((key) => key.contains('recommendation')).toList();
      categoryKeys = keys.where((key) => key.contains('category')).toList();

      List<Map<String, dynamic>>? prefs;
      if (preferenceKeys.isNotEmpty) {
        prefs = [];
        for (final String key in preferenceKeys) {
          prefs.add(readLocalEntry(key));
        }
      }

      List<Map<String, dynamic>>? recs;
      if (recommendationKeys.isNotEmpty) {
        recs = [];
        for (final String key in recommendationKeys) {
          recs.add(readLocalEntry(key));
        }
      }

      List<Map<String, dynamic>>? cats;
      if (categoryKeys.isNotEmpty) {
        cats = [];
        for (final String key in categoryKeys) {
          cats.add(readLocalEntry(key));
        }
      }

      return PreferencesJsonFileParser(
        preferencesJson: prefs,
        recommendationsJson: recs,
        categoriesJson: cats,
      );
    }

// no data found in the browser so load from assets folder
    final List<Map<String, dynamic>> preferences;
    final List<Map<String, dynamic>> recommendations;
    final List<Map<String, dynamic>> categories;

    final assetsPreferences =
        (await fetchAsset('assets/json/all_preferences.json'))!;
    preferences =
        List<Map<String, dynamic>>.from(json.decode(assetsPreferences));

    for (final preference in preferences) {
      writeLocalEntry(preference, type: 'preference');
    }

    final assetsRecommendations =
        (await fetchAsset('assets/json/recommendations.json'))!;
    recommendations =
        List<Map<String, dynamic>>.from(json.decode(assetsRecommendations));
    for (final recommendation in recommendations) {
      writeLocalEntry(recommendation, type: 'recommendation');
    }

    final assetsCategories = (await fetchAsset('assets/json/categories.json'))!;
    categories = List<Map<String, dynamic>>.from(json.decode(assetsCategories));
    for (final category in categories) {
      writeLocalEntry(category, type: 'category');
    }

    return PreferencesJsonFileParser(
        preferencesJson: preferences,
        recommendationsJson: recommendations,
        categoriesJson: categories);
  }

  Future<PreferencesJsonFileParser> loadDefault() async {
    return await loadJsonFiles();
  }

  Future saveData(preferences, recommendations, categories) {
    return Future.wait<dynamic>([
      localData.setString('preferences', jsonEncode(preferences)),
      localData.setString('recommendations', jsonEncode(recommendations)),
      localData.setString('categories', jsonEncode(categories)),
    ], eagerError: true);
  }
}
