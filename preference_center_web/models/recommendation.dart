import 'package:preference_center_web/math/matrix.dart';
import 'package:preference_center_web/models/category.dart';
import 'package:preference_center_web/models/preference.dart';

class Recommendations {
  Matrix _edges;

  /// if no preferences.json has been loaded then all [Preference]s will be
  Map<Preference, int> _preferenceToIndex;

  Preferences _preferences;

  Recommendations._internal(
      this._edges, this._preferenceToIndex, this._preferences);

  Recommendations.empty()
      : _preferenceToIndex = {},
        _preferences = Preferences.empty(),
        _edges = Matrix.empty(rows: 2, columns: 2);

  /// pass [preferences] to use loaded data from preferences.json
  /// *modifies [preferences] to include any new codes found only in
  /// recommendations.json
  factory Recommendations.fromJson(
    List<Map<String, dynamic>>? json, {
    Preferences? preferences,
  }) {
    Map<Preference, int> preferenceIndices = Map();
    int index = 0;

    if (json == null)
      // return empty recommendations or a matrix of zeros from with dimensions equal to
      // the amount of known preferences
      return Recommendations._internal(
        Matrix.empty(
          rows: preferences?.all.length ?? preferences?.all.length ?? 0,
          columns: 0,
        ),
        {},
        preferences ?? Preferences.empty(),
      );

    // put all the [PreferenceModel]s that are known into the map
    // or intiialize an empty Preferences object
    if (preferences != null) {
      for (var preference in preferences.all) {
        preferenceIndices[preference] = index++;
      }
    } else {
      preferences = Preferences.empty();
    }

    //TODO trim the codes
    // some codes do not recommend anything so much be checked
    for (var entry in json) {
      // if (entry['code'].toString().trim().isEmpty) continue;

      var key = preferences.getNullable(entry['code']);

      /// add a new prefernce if its not already known
      if (key == null) {
        preferences.set(
            code: entry['code'], preference: Preference.unknown(entry['code']));
      }
      key = preferences.get(entry['code']);

      /// its possible that codes will appear more than once
      if (!preferenceIndices.containsKey(key)) {
        preferenceIndices[key] = index++;
      }

      for (var code in entry['recommendations'].split(',')) {
        // some issues here

        // TODO : replace this with a better fix for codes
        // that only appear in the recommendation file
        if (preferences.getNullable(code) == null) {
          preferences.set(code: code, preference: Preference.unknown(code));
        }

        final recommendationKey = preferences.get(code);

        if (!preferenceIndices.containsKey(recommendationKey)) {
          preferenceIndices[recommendationKey] = index++;
        }
      }
    }

    // allocate 3 extra slots to avoid resizing on the first new preference
    Matrix edges = Matrix.zeros(
        columns: preferenceIndices.length + 3,
        rows: preferenceIndices.length + 3);

    // second pass to create the graph
    for (var entry in json) {
      final key = preferences.get(entry['code']);
      int row = preferenceIndices[key]!;
      for (var code in entry['recommendations'].split(',')) {
        final recommendationKey = preferences.get(code);
        edges.set(row, preferenceIndices[recommendationKey]!, 1);
      }
    }

    return Recommendations._internal(edges, preferenceIndices, preferences);
  }

  /// export the recommendation file by finding all edges and nodes
  /// do not write a recommendation with code: ""
  List<Map<String, dynamic>> toJson() {
    return _preferenceToIndex.keys.map((Preference element) {
      return element.code?.trim().isNotEmpty ?? false
          ? {
              'code': element.code,
              'recommendations': getRecommendations(element)
                  .map((Preference element) => element.code ?? "")
                  .toList()
                  .join(','),
            }
          : <String, dynamic>{};
    }).toList()
      ..removeWhere((e) => e.isEmpty || e['code'].isEmpty);
  }

  /// export a single recommendation for 1 [Preference]
  Map<String, dynamic> toJsonEntry({required Preference preference}) {
    return (preference.code)!.trim().isNotEmpty
        ? {
            'code': preference.code,
            'recommendations': getRecommendations(preference)
                .map((Preference element) => element.code ?? "")
                .toList()
                .join(','),
          }
        : <String, dynamic>{};
  }

  /// if [code] recommends [recommendationCode]
  bool recommends(Preference code, Preference recommendation) {
    if (!_preferenceToIndex.containsKey(code) ||
        !_preferenceToIndex.containsKey(recommendation)) return false;
    return _edges.get(
            _preferenceToIndex[code]!, _preferenceToIndex[recommendation]!) >
        0;
  }

  /// if [code] is recommend by [recommender]
  bool isRecommendedBy(String code, String recommender) {
    if (!_preferenceToIndex.containsKey(code) ||
        !_preferenceToIndex.containsKey(recommender)) return false;
    return _edges.get(
            _preferenceToIndex[recommender]!, _preferenceToIndex[code]!) >
        0;
  }

  /// returns what [preference] recommends
  List<Preference> getRecommendations(Preference preference) {
    if (!_preferenceToIndex.containsKey(preference)) return [];

    List<Preference> recommendations = [];
    for (Preference key in _preferenceToIndex.keys) {
      if (_edges.get(
              _preferenceToIndex[preference]!, _preferenceToIndex[key]!) >
          0) recommendations.add(key);
    }
    return recommendations;
  }

  /// return all the preferences that recommend [preference]
  List<Preference> getRecommendedBy(Preference preference) {
    if (preference == Preference.empty()) return preferences;
    if (!_preferenceToIndex.containsKey(preference)) return [];

    List<Preference> recommendedBy = [];
    for (Preference key in _preferenceToIndex.keys) {
      if (_edges.get(
              _preferenceToIndex[key]!, _preferenceToIndex[preference]!) >
          0) {
        recommendedBy.add(key);
      }
    }
    return recommendedBy;
  }

  /// add [recommendation] to the list that [preference] recommends
  void addRecommendation(Preference preference, Preference recommendation) {
    print('added ${recommendation.code} to ${preference.code}');
    if (!_preferenceToIndex.containsKey(preference)) return;

    int x = _preferenceToIndex[preference]!;
    int y = _preferenceToIndex[recommendation]!;

    _edges.set(x, y, 1);
  }

  /// remove [recommendation] to the list that [preference] recommends
  void removeRecommendation(Preference preference, Preference recommendation) {
    print('removed ${recommendation.code} from ${preference.code}');
    if (!_preferenceToIndex.containsKey(preference)) return;

    _edges.set(_preferenceToIndex[preference]!,
        _preferenceToIndex[recommendation]!, 0);
  }

  int get size => _preferenceToIndex.length;
  List<Preference> get preferences => _preferenceToIndex.keys.toList();

  double get density => _edges.count(1.0) / (_edges.columns * _edges.rows);
}
