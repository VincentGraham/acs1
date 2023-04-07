import 'package:flutter/material.dart';
import 'package:preference_center_web/api/local_storage.dart';
import 'package:preference_center_web/models.dart';
import 'package:preference_center_web/state/actions.dart';

import 'list_filters.dart';

class PreferenceViewModel extends ChangeNotifier {
  /// the preference being recommended
  final Preference? rawPreference;

  bool get isEmpty => rawPreference == null;

  String get name => rawPreference?.name ?? "Unknown name";
  String get code => rawPreference?.code ?? "Unknown code";
  String get type => rawPreference?.type ?? "Unknown";

  String get shortName => rawPreference?.code?.substring(0, 5) ?? "preference";

  bool get hasLogo => rawPreference?.hasLogo ?? false;
  String get logo => rawPreference?.logo ?? 'https://via.placeholder.com/150';

  bool get hasImages => rawPreference?.hasImages ?? false;
  List<String> get images => rawPreference?.images ?? [];

  bool get hasCategories => rawPreference?.hasCategories ?? false;
  List<Category> get categories => rawPreference?.resolvedCategories ?? [];

  bool get hasText => rawPreference?.hasText ?? false;
  String get text => rawPreference?.text ?? "No text provided";

  bool _isRecommended;
  bool _isRecommending;

  /// if [rawPreference] is recommended by [_preference] in [PreferenceCenterModel]
  bool get isRecommended => _isRecommended;

  /// if [rawPreference] recommends the [_preference] in [PreferenceCenterModel]
  bool get isRecommending => _isRecommending;

  set isRecommended(value) {
    _isRecommended = value;
    notifyListeners();
  }

  set isRecommending(value) {
    _isRecommending = value;
    notifyListeners();
  }

  String get info => "$name - $code ($type)";

  /// does not store a reference to which preference recommends it
  /// [isRecommended] is true if the current preference recommends this
  /// [isRecommending] is true if the current preference is recommended by
  /// [rawPreference]
  PreferenceViewModel({
    this.rawPreference,
    isRecommended = false,
    isRecommending = false,
  })  : _isRecommended = isRecommended,
        _isRecommending = isRecommending;
}

class PreferenceCenterModel extends ChangeNotifier {
  Preferences preferences;
  Recommendations recommendations;
  Categories categories;

  List<PreferenceViewModel> unfilteredResults = [];
  List<PreferenceViewModel> get results => unfilteredResults;
  List<PreferenceViewModel> filteredResults = [];

  /// a place to store the data in the browser or load from built in
  /// assets/json files
  /// can also be used to query json s from a web source
  final LocalRepository? repository;

  bool shouldNotify = false;

  /// is the future for loading in progress
  bool isLoading = true;

  ErrorFilter _errorFilter = ErrorFilter.noErrors;
  ErrorFilter get errorFilter => _errorFilter;
  set errorFilter(ErrorFilter errorFilter) {
    _errorFilter = errorFilter;
    getResults(filterOnly: true);
    notifyListeners();
  }

  TypeFilter _typeFilter = TypeFilter.all;
  TypeFilter get typeFilter => _typeFilter;
  set typeFilter(TypeFilter typeFilter) {
    _typeFilter = typeFilter;
    getResults(filterOnly: true);
  }

  RelationFilter _relationFilter = RelationFilter.all;
  RelationFilter get relationFilter => _relationFilter;
  set relationFilter(RelationFilter relationFilter) {
    _relationFilter = relationFilter;
    getResults(filterOnly: true);
  }

  /// if this constructor is used, [loadPreferences] will do nothing
  PreferenceCenterModel.from({
    this.repository,
    required this.preferences,
    required this.recommendations,
    required this.categories,
  }) : isLoading = true;

  PreferenceCenterModel({required this.repository})
      : preferences = Preferences.empty(),
        recommendations = Recommendations.empty(),
        categories = Categories.empty();

  /// can not be used if [repository] is null
  Future<void> loadPreferences() {
    assert(this.repository != null, 'repository must not be null');
    // can be used to show a loading widget such as progress indicators
    isLoading = true;
    notifyListeners();

    return repository!.loadPreferences().then((data) {
      isLoading = true;
      notifyListeners();
      this.preferences = data.preferences;
      this.recommendations = data.recommendations;
      this.categories = data.categories;
      isLoading = false;
      getResults();
    }).catchError((e) {
      print(e);
      print(e.stackTrace);
      isLoading = true;
    });
  }

  /// the current selected preference
  /// if null, then recommended/by will return all preferences
  Preference? _preference;

  /// returns the selected preference
  PreferenceViewModel get preference =>
      PreferenceViewModel(rawPreference: _preference);

  /// the current action type
  PageAction action = PageAction.view;

  /// return the recommendations for the current preference
  List<PreferenceViewModel> get _rawRecommendedPreferences => List.of(
      recommendations.getRecommendations(_preference ?? Preference.empty()).map(
          (e) => PreferenceViewModel(rawPreference: e, isRecommended: true)));

  /// preference which recommend the current preference
  List<PreferenceViewModel> get _rawRecommendingPreferences => List.of(
      recommendations.getRecommendedBy(_preference ?? Preference.empty()).map(
          (e) => PreferenceViewModel(rawPreference: e, isRecommending: true)));

  /// both recommended and recommendedBy relationshsips
  List<PreferenceViewModel> get allRecommendations {
    List<PreferenceViewModel> recs = _rawRecommendingPreferences;

    List<Preference> recsAsPreferences =
        _rawRecommendingPreferences.map((e) => e.rawPreference!).toList();

    // iterate through the other half
    for (var rp in _rawRecommendedPreferences) {
      int i = recsAsPreferences.indexOf(rp.rawPreference!);
      // modify both relationship th true if both lists contain the preference
      if (i >= 0) {
        recs[i].isRecommended = true;
        // otherwise add it to the list without modifying the bool values
      } else
        recs.add(rp);
    }
    return recs;
  }

  // need to have status of both recommended and recommended by visible to ui
  List<PreferenceViewModel> get recommendingPreferences =>
      List.of(allRecommendations.where((p) => p.isRecommending));

  List<PreferenceViewModel> get recommendedPreferences =>
      List.of(allRecommendations.where((p) => p.isRecommended));

  List<PreferenceViewModel> get allPreferences => List.of(
      preferences.all.map((e) => PreferenceViewModel(rawPreference: e)));

  /// sets the current preference and page actions
  void setState({Preference? preference, String? code, PageAction? action}) {
    this.action = action ?? PageAction.view;
    if (code == null && preference == null) {
      _preference = null;
    } else {
      _preference = preference ?? preferences.get(code!);
    }
    shouldNotify = !shouldNotify;
    getResults();
    notifyListeners();
  }

  void refresh() {
    _preference = _preference;
    notifyListeners();
  }

  bool get isHomePage => preference.rawPreference == null;

  String get title {
    if (preference.rawPreference == null) return 'All Preferences';

    return preference.rawPreference!.name ??
        preference.rawPreference!.code ??
        'Unknown Preference';
  }

  List<PreferenceViewModel> getResults({filterOnly = false}) {
    if (!filterOnly) {
      switch (action) {
        case PageAction.getRecommendations:
          unfilteredResults = recommendedPreferences;
          break;
        case PageAction.getRecommendedBy:
          unfilteredResults = recommendingPreferences;
          break;
        case PageAction.edit:
          unfilteredResults = allRecommendations;
          break;
        case PageAction.view:
          unfilteredResults = allPreferences;
          break;
        // defaults to returning all preferences
        default:
          unfilteredResults = allPreferences;
          break;
      }
      unfilteredResults.sort((p1, p2) {
        if (p1.type.compareTo(p2.type) == 0) return p1.name.compareTo(p2.name);
        return p1.type.compareTo(p2.type);
      });
    }

    final filteredLists = [
      typeFilteredResults,
      relationFilteredResults,
      errorFilteredResults
    ];

    filteredResults = filteredLists
        .fold<Set<PreferenceViewModel>>(
            filteredLists.first.toSet(),
            (Set<PreferenceViewModel> a, List<PreferenceViewModel> b) =>
                a.intersection(b.toSet()))
        .toList();
    notifyListeners();
    return filteredResults;
  }

  List<PreferenceViewModel> get typeFilteredResults {
    return unfilteredResults.where((preference) {
      /// never include fully null preferences
      if (preference.rawPreference == null) return false;

      final pref = preference.rawPreference!;
      switch (typeFilter) {
        case TypeFilter.audience:
          return pref.type == 'audience';
        case TypeFilter.journal:
          return pref.type == 'journal';
        case TypeFilter.interest:
          return pref.type == 'interest';
        case TypeFilter.service:
          return pref.type == 'service';
        case TypeFilter.news:
          return pref.type == 'news';
        case TypeFilter.other:
          return pref.type != 'audience' &&
              pref.type != 'journal' &&
              pref.type != 'interest' &&
              pref.type != 'service' &&
              pref.type != 'news';
        case TypeFilter.unknown:
          return pref.type == null;

        case TypeFilter.all:
          return true;
        default:
          return true;
      }
    }).toList();
  }

  List<PreferenceViewModel> get relationFilteredResults {
    return unfilteredResults.where((preference) {
      if (preference.rawPreference == null) return false;

      switch (relationFilter) {
        case RelationFilter.both:
          return preference.isRecommended || preference.isRecommending;
        case RelationFilter.recommendationOf:
          return preference.isRecommended;
        case RelationFilter.recommendedBy:
          return preference.isRecommending;
        case RelationFilter.all:
        default:
          return true;
      }
    }).toList();
  }

  /// will not alter results unless a [schema] is found
  List<PreferenceViewModel> get errorFilteredResults {
    return unfilteredResults.where((preference) {
      if (preference.rawPreference == null) return false;

      // non-null helper vars
      final pref = preference.rawPreference!;
      // print(preferences.validate(pref).first);

      switch (errorFilter) {
        case ErrorFilter.all:
          return true;
        case ErrorFilter.missingData:
          return preferences
              .validate(pref)
              .where((e) => e.type == SchemaErrorType.missingData)
              .isNotEmpty;
        case ErrorFilter.textFormat:
          var z = preferences
              .validate(pref)
              .where((e) => e.type == SchemaErrorType.textFormat)
              .isNotEmpty;
          return z;
        case ErrorFilter.noCode:
          return preferences
              .validate(pref)
              .where((e) => e.type == SchemaErrorType.noCode)
              .isNotEmpty;
        case ErrorFilter.missingValue:
          return preferences
              .validate(pref)
              .where((e) => e.type == SchemaErrorType.missingValue)
              .isNotEmpty;
        case ErrorFilter.noErrors:
          return preferences.validate(pref).isEmpty;
        case ErrorFilter.onlyErrors:
          return preferences.validate(pref).isNotEmpty;
        default:
          return true;
      }
    }).toList();
  }

  /// adds [recommendation] to the list of recommended preferences for
  /// [preference] or the preference with [code].
  /// if both are given, then it will use [preference]
  /// [preference] must contain a non-null [Preference]
  void addRecommendationOfCurrent({
    PreferenceViewModel? recommendation,
    String? recommendationCode,
  }) {
    assert(recommendation != null || recommendationCode != null,
        'must provide atleast one of either recommendation or recommendationCode');
    recommendations.addRecommendation(preference.rawPreference!,
        recommendation?.rawPreference ?? preferences.get(recommendationCode!));
    recommendation?.isRecommended = true;
    notifyListeners();

    repository?.writeLocalEntry(
      recommendations.toJsonEntry(
        preference: recommendation?.rawPreference ??
            preferences.get(recommendationCode!),
      ),
      type: 'recommendation',
    );
  }

  /// add [preference] as a recommendation of [recommendedBy]
  void addCurrentToRecommendations(
      {PreferenceViewModel? recommendedBy, String? recommendedByCode}) {
    assert(recommendedBy != null || recommendedByCode != null,
        'must provide atleast one of either recommendedby or code');

    recommendations.addRecommendation(
        recommendedBy?.rawPreference ?? preferences.get(recommendedByCode!),
        preference.rawPreference!);

    recommendedBy?.isRecommending = true;
    notifyListeners();

    // commit the changes to browser storage
    repository?.writeLocalEntry(
      recommendations.toJsonEntry(
        preference:
            recommendedBy?.rawPreference ?? preferences.get(recommendedByCode!),
      ),
      type: 'recommendation',
    );
  }

  void deleteRecommendationOfCurrent(
      {PreferenceViewModel? recommendation, String? recommendationCode}) {
    assert(recommendation != null || recommendationCode != null);
    recommendations.removeRecommendation(preference.rawPreference!,
        recommendation?.rawPreference ?? preferences.get(recommendationCode!));
    recommendation?.isRecommended = false;
    notifyListeners();
    repository?.writeLocalEntry(
      recommendations.toJsonEntry(preference: preference.rawPreference!),
      type: 'recommendation',
    );
  }

  void deleteCurrentFromRecommendations(
      {PreferenceViewModel? recommendedBy, String? recommendedByCode}) {
    assert(recommendedBy != null || recommendedByCode != null,
        'must provide atleast one of either recommendedby or code');
    recommendations.removeRecommendation(
        recommendedBy?.rawPreference ?? preferences.get(recommendedByCode!),
        preference.rawPreference!);
    recommendedBy?.isRecommending = false;

    notifyListeners();
    repository?.writeLocalEntry(
      recommendations.toJsonEntry(
        preference:
            recommendedBy?.rawPreference ?? preferences.get(recommendedByCode!),
      ),
      type: 'recommendation',
    );
  }

  void toggleIsRecommendationOfCurrent({
    PreferenceViewModel? recommendation,
    String? recommendationCode,
    notify = true,
  }) {
    assert(recommendation != null || recommendationCode != null);

    // if preference recommends recommendation then delete it
    if (recommendations.recommends(
        preference.rawPreference!,
        recommendation?.rawPreference ??
            preferences.get(recommendationCode!))) {
      deleteRecommendationOfCurrent(
          recommendation: recommendation,
          recommendationCode: recommendationCode);
    } else {
      addRecommendationOfCurrent(
          recommendation: recommendation,
          recommendationCode: recommendationCode);
    }

    notifyListeners();
  }

  void toggleCurrentIsRecommendation({
    PreferenceViewModel? recommendedBy,
    String? recommendedByCode,
  }) {
    assert(recommendedBy != null || recommendedByCode != null,
        'must provide atleast one of either recommendedby or code');
    if (recommendations.recommends(
        recommendedBy?.rawPreference ?? preferences.get(recommendedByCode!),
        preference.rawPreference!)) {
      deleteCurrentFromRecommendations(
          recommendedBy: recommendedBy, recommendedByCode: recommendedByCode);
    } else {
      addCurrentToRecommendations(
          recommendedBy: recommendedBy, recommendedByCode: recommendedByCode);
    }

    notifyListeners();
  }
}
