import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:preference_center_web/routes/preferences_grid_configuration.dart';
import 'package:preference_center_web/state/actions.dart';
import 'package:preference_center_web/state/view_models.dart';

class PreferencesGridBackButtonHandler extends RootBackButtonDispatcher {
  final PreferencesGridRouterDelegate delegate;
  PreferencesGridBackButtonHandler(this.delegate);
  @override
  Future<bool> didPopRoute() {
    return delegate.popRoute();
  }
}

class PreferencesGridRouterDelegate extends RouterDelegate<RouteConfiguration>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteConfiguration> {
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  /// the history stored only in configurations
  final List<RouteConfiguration> _configurationHistory = [
    RouteConfiguration.allPreferencesPageConfiguration,
  ];

  final Widget home;

  /// the configuration of the page being displayed
  /// when a [push] is detected, disable the forwards button
  /// and delete the tail of the history
  int _currentConfigurationIndex = 0;

  // the overall state of the app
  final PreferenceCenterModel state;

  // the screen to display preferences
  late final Widget gridView;

  PreferencesGridRouterDelegate(
    this.state, {
    required this.home,
  }) : navigatorKey = GlobalKey() {
    state.addListener(() {
      notifyListeners();
    });
  }

  @override
  RouteConfiguration get currentConfiguration {
    return _configurationHistory[_currentConfigurationIndex];
  }

  @override
  Widget build(BuildContext context) {
    return Overlay(
      initialEntries: [OverlayEntry(builder: (context) => this.home)],
    );
  }

  void goForwards() {
    if (_hasNextPage) {
      final nextConfiguration =
          _configurationHistory[_currentConfigurationIndex + 1];
      state.setState(
          code: nextConfiguration.code, action: nextConfiguration.action);
      _currentConfigurationIndex++;
    }
  }

  void goBack() {
    if (_hasPreviousPage) {
      final previousConfiguration =
          _configurationHistory[_currentConfigurationIndex - 1];
      state.setState(
          code: previousConfiguration.code,
          action: previousConfiguration.action);
      _currentConfigurationIndex--;
    }
  }

  void goToPage({
    String? code,
    PageAction? action,
    RouteConfiguration? configuration,
  }) {
    RouteConfiguration? _configuration = configuration;

    /// if [configuration] is provided then ignore the code and action
    if (_configuration == null) {
      if (action == PageAction.getRecommendations) {
        if (code == null) {
          _configuration = RouteConfiguration.allPreferencesPageConfiguration;
        } else {
          _configuration =
              RouteConfiguration.recommendationsPageConfiguration(code);
        }
      } else if (action == PageAction.getRecommendedBy) {
        if (code == null) {
          _configuration = RouteConfiguration.allPreferencesPageConfiguration;
        } else {
          _configuration =
              RouteConfiguration.recommendedByPageConfiguration(code);
        }
      } else if (action == PageAction.edit) {
        if (code == null) {
          _configuration = RouteConfiguration.allPreferencesPageConfiguration;
        } else {
          _configuration =
              RouteConfiguration.editPreferencePageConfiguration(code);
        }
      } else {
        _configuration = RouteConfiguration.allPreferencesPageConfiguration;
      }
    }

    if (_hasNextPage) {
      _configurationHistory.removeRange(
          _currentConfigurationIndex + 1, _configurationHistory.length);

      _configurationHistory.add(_configuration);
      _currentConfigurationIndex = _configurationHistory.length - 1;
    }
    state.setState(
      code: _configurationHistory[_currentConfigurationIndex].code,
      action: _configurationHistory[_currentConfigurationIndex].action,
    );
  }

  // can we navigate forwards?
  bool get _hasNextPage =>
      _configurationHistory.length >= _currentConfigurationIndex + 1;

  // shadows the _canPop method
  bool get _hasPreviousPage => _currentConfigurationIndex > 1;

  // used for the system backbutton
  @override
  Future<bool> popRoute() {
    if (_hasPreviousPage) {
      goBack();
      return Future<bool>.value(true);
    }
    return Future<bool>.value(false);
  }

  void pushEditPage(String? code) {
    _configurationHistory.add(
      RouteConfiguration.editPreferencePageConfiguration(code),
    );
    // state.code = code;
  }

  // when the url bar changes
  @override
  Future<void> setNewRoutePath(RouteConfiguration configuration) {
    goToPage(configuration: configuration);
    return SynchronousFuture(null);
  }
}
