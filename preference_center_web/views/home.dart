import 'package:flutter/material.dart';
import 'package:preference_center_web/state/actions.dart';
import 'package:preference_center_web/config/theme/background.dart';
import 'package:preference_center_web/state/view_models.dart';
import 'package:preference_center_web/views/preferences_list.dart';
import 'package:provider/provider.dart';

/// wrap this in a provider somewhere higher in the tree
/// maybe in the router delegate?
class PreferenceCenterWithProviders extends StatelessWidget {
  final void Function(String?, PageAction) onTapped;
  // final PreferencesListPageState pageState;
  final PreferenceCenterModel state;

  PreferenceCenterWithProviders({
    required this.onTapped,
    required this.state,
  }) {
    // state..loadPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PreferenceCenterModel>.value(
      value: state,
      child: Container(
        decoration: BackgroundGradient,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: StatefulPreferencesList(
            items: [],
            onTapped: onTapped,
          ),
        ),
      ),
    );
  }
}
