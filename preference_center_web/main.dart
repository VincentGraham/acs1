import 'package:flutter/material.dart';
import 'package:preference_center_web/api/aggregated.dart';
import 'package:preference_center_web/api/local_storage.dart';

import 'package:preference_center_web/config/theme.dart';
import 'package:preference_center_web/models/builder.dart';
import 'package:preference_center_web/routes/preferences_grid_configuration.dart';
import 'package:preference_center_web/routes/preferences_grid_router_delegate.dart';
import 'package:preference_center_web/state/actions.dart';
import 'package:preference_center_web/state/view_models.dart';
import 'package:preference_center_web/views/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'routes/route_information_parser.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    late PreferencesGridRouterDelegate delegate;
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          final state = PreferenceCenterModel(
              repository: LocalRepository(localData: snapshot.data!))
            ..loadPreferences();
          delegate = PreferencesGridRouterDelegate(
            state,
            home: PreferenceCenterWithProviders(
              state: state,
              onTapped: (String? a, PageAction b) {},
            ),
          );
          delegate.setNewRoutePath(
              RouteConfiguration.allPreferencesPageConfiguration);
          return RouterWidget(delegate: delegate);
        } else {
          return Container(
            decoration: BackgroundGradient,
            child: Center(
              heightFactor: 0.2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 80),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      "No Data found",
                      style: TextStyle(fontSize: 24),
                    ),
                  )
                ],
              ),
            ),
          );
        }
      },
    );
  }
}

class RouterWidget extends StatelessWidget {
  const RouterWidget({
    Key? key,
    required this.delegate,
  }) : super(key: key);

  final PreferencesGridRouterDelegate delegate;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      color: Colors.white,
      theme: ThemeData(
        iconTheme: IconThemeData(color: Colors.white),
        colorScheme: ColorScheme.highContrastLight(),
        primaryColor: Colors.white,
        buttonTheme: ButtonThemeData(buttonColor: Colors.red),
        // accentIconTheme: IconThemeData(color: Colors.red),
        // buttonColor: Colors.orange,
        textTheme: TextTheme().copyWith(
          displayLarge: TextStyle(
            color: Colors.white,
            fontFamily: "roboto, sans-serif",
            fontWeight: FontWeight.w700,
            letterSpacing: 3.6,
            fontSize: 12,
          ),
        ),

        // colorScheme: ColorScheme.fromSwatch(
        //     backgroundColor: Colors.white,
        //     primarySwatch: MaterialColor(0xFFFFFFFF, {})),
      ),
      title: "Preference Center",
      routerDelegate: delegate,
      routeInformationParser: new PreferencesGridRouteParser(),
      backButtonDispatcher: PreferencesGridBackButtonHandler(delegate),
    );
  }
}
