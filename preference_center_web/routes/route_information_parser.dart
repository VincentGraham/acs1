import 'package:flutter/material.dart';
import 'package:preference_center_web/routes/preferences_grid_configuration.dart';

class PreferencesGridRouteParser
    extends RouteInformationParser<RouteConfiguration> {
  @override
  Future<RouteConfiguration> parseRouteInformation(
      RouteInformation routeInformation) async {
    final Uri uri = Uri.parse(routeInformation.location!);

    // handle '/'
    if (uri.pathSegments.isEmpty || uri.pathSegments.length == 1) {
      return RouteConfiguration.allPreferencesPageConfiguration;
    }

    // handle '/preference/$code/*'
    if (uri.pathSegments.length == 3) {
      final code = uri.pathSegments[1];
      final recommendationType = uri.pathSegments[2];
      if (recommendationType == 'recommendations') {
        return RouteConfiguration.recommendationsPageConfiguration(code);
      } else if (recommendationType == 'recommended-by') {
        return RouteConfiguration.recommendedByPageConfiguration(code);
      }
    }
    // handles '/preference/$code'
    // and bulk editing recommendations and recommended by
    else if (uri.pathSegments.length == 2) {
      final code = uri.pathSegments[1];
      return RouteConfiguration.editPreferencePageConfiguration(code);
    }
    return RouteConfiguration.allPreferencesPageConfiguration;
  }

  @override
  RouteInformation restoreRouteInformation(RouteConfiguration configuration) {
    switch (configuration.page) {
      case PreferencesGridPages.unknown:
        return const RouteInformation(location: '/preferences');
      case PreferencesGridPages.listPreferences:
        return const RouteInformation(location: '/preferences');
      case PreferencesGridPages.listRecommendations:
        return RouteInformation(
            location: '/preference/${configuration.code}/recommendations');
      case PreferencesGridPages.listRecommendedBy:
        return RouteInformation(
            location: '/preference/${configuration.code}/recommended-by');
      case PreferencesGridPages.editPreference:
        return RouteInformation(location: '/preference/${configuration.code}');
      // unused
      case PreferencesGridPages.viewPreference:
        return const RouteInformation(location: '/preferences');
    }
  }
}
