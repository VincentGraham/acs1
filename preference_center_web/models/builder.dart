import 'package:preference_center_web/models.dart';

typedef Json = List<Map<String, dynamic>>;

class PreferencesJsonFileParser {
  late Preferences preferences;
  late Categories categories;
  late Recommendations recommendations;

  PreferencesJsonFileParser({
    Json? recommendationsJson,
    Json? preferencesJson,
    Json? categoriesJson,
  }) {
    // attempt to parse all the json files
    // fromJson(null) will return an empty version of the Model
    recommendations = Recommendations.fromJson(recommendationsJson);
    categories = Categories.fromJson(categoriesJson);
    preferences = Preferences.fromJson(preferencesJson, makeSchema: true);

    // update prefereces with categories
    // if preferencesJson is null then nothing happens
    // categories is checked first because only [Preferences] depend on it
    // recommendations do not reference categories directly
    if (categoriesJson != null) {
      preferences = Preferences.fromJson(preferencesJson,
          categories: categories, makeSchema: true);
    }

    // preferences were loaded, reparse recommendations to link to
    // the known preferences
    // *also modifies this.preferences with new  codes in recommendationsJson
    // if recommendationsJson is null, then nothing happens
    if (preferencesJson != null) {
      recommendations = Recommendations.fromJson(recommendationsJson,
          preferences: preferences);
    }

    // must change the preferences if new codes are found here
    // recommendationsJson is checked last because it depends on Preferences
    // which depend on Categories
    //
    // preferencesJson == null avoids reparsing recommendations
    // if it was done above
    if (recommendationsJson != null && preferencesJson == null) {
      recommendations = Recommendations.fromJson(recommendationsJson,
          preferences: preferences);
    }
  }
}
