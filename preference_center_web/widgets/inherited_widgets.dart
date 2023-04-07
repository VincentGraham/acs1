import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:preference_center_web/models/preference.dart';
import 'package:preference_center_web/state/view_models.dart';

// stores a single preference model to be passed to the list tile items

class InheritedPreference extends InheritedWidget {
  final Preference? preference;
  const InheritedPreference({
    Key? key,
    this.preference,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedPreference oldWidget) =>
      preference != oldWidget.preference;

  static InheritedPreference of(BuildContext context) {
    final InheritedPreference? result =
        context.dependOnInheritedWidgetOfExactType<InheritedPreference>();
    assert(result != null, 'No PreferenceInformation in the build context');
    return result!;
  }
}

class PreferencesInformation extends InheritedWidget {
  final Preferences preferences;
  const PreferencesInformation({
    Key? key,
    required this.preferences,
    required Widget child,
  }) : super(key: key, child: child);

  bool updateShouldNotify(PreferencesInformation oldWidget) =>
      preferences != oldWidget.preferences;

  static PreferencesInformation of(BuildContext context) {
    final PreferencesInformation? result =
        context.dependOnInheritedWidgetOfExactType<PreferencesInformation>();
    assert(result != null, 'no PreferencesInformation in the build context');
    return result!;
  }
}

class AppStateProvider extends InheritedNotifier<PreferenceCenterModel> {
  AppStateProvider({
    Key? key,
    required PreferenceCenterModel notifier,
    required Widget child,
    // required this.itemsChanged,
  }) : super(key: key, notifier: notifier, child: child);

  static PreferenceCenterModel of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AppStateProvider>()!
        .notifier!;
  }

  @override
  bool updateShouldNotify(AppStateProvider old) {
    return notifier!.preference != old.notifier!.preference ||
        !listEquals(notifier!.recommendedPreferences,
            old.notifier!.recommendedPreferences) ||
        !listEquals(notifier!.recommendingPreferences,
            old.notifier!.recommendingPreferences) ||
        notifier!.shouldNotify != old.notifier!.shouldNotify;
  }
}
