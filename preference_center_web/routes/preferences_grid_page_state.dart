import 'dart:async' show StreamController;

import 'package:flutter/foundation.dart';
import 'package:preference_center_web/models.dart';
import 'package:preference_center_web/models/preference.dart';

class PreferencesGridState extends ChangeNotifier {
  String? _code;

  String _recommendationDirection = "recommends";

  Recommendations graph;
  Preferences table;

  PreferencesGridState({required this.graph, required this.table});

  final StreamController<Map<String, dynamic>> controller =
      StreamController.broadcast();

  String? get code => _code;
  set code(String? code) {
    _code = code;
    controller.sink.add({'code': code, 'direction': _recommendationDirection});
    notifyListeners();
  }

  String get direction => _recommendationDirection;

  set direction(String dir) {
    _recommendationDirection = dir;
    controller.sink.add({'code': code, 'direction': _recommendationDirection});
    notifyListeners();
  }

  void setState({String? code, required String direction}) {
    _code = code;
    _recommendationDirection = direction;
    controller.sink.add({'code': _code, 'direction': _recommendationDirection});
    notifyListeners();
  }

  @override
  void dispose() {
    controller.close();
    super.dispose();
  }
}
