import 'package:preference_center_web/state/actions.dart';

enum PreferencesGridPages {
  unknown,
  listPreferences,
  listRecommendations,
  listRecommendedBy,
  viewPreference,
  editPreference
}

class RouteConfiguration {
  final String? key;
  final String path;
  final PreferencesGridPages page;
  // final String direction;
  final PageAction action;

  String? get code => key == null ? key : key!.substring(7);

  RouteConfiguration({
    required this.key,
    required this.path,
    required this.page,
    required this.action,
  });

  static RouteConfiguration recommendationsPageConfiguration(String code) =>
      RouteConfiguration(
          key: 'recsof_$code',
          path: '/preference/$code/recommendations',
          page: PreferencesGridPages.listRecommendations,
          action: PageAction.getRecommendations);

  static RouteConfiguration recommendedByPageConfiguration(String code) =>
      RouteConfiguration(
          key: 'recsby_$code',
          path: '/preference/$code/recommended-by',
          page: PreferencesGridPages.listRecommendedBy,
          action: PageAction.getRecommendedBy);

  static RouteConfiguration allPreferencesPageConfiguration =
      RouteConfiguration(
          key: null,
          path: '/preferences',
          page: PreferencesGridPages.listPreferences,
          action: PageAction.view);

  static RouteConfiguration editPreferencePageConfiguration(String? code) =>
      RouteConfiguration(
          key: 'editpf_$code',
          path: '/preference/${code ?? "new"}/edit',
          page: PreferencesGridPages.editPreference,
          action: PageAction.edit);
}
