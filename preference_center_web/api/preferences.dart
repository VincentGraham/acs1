import 'dart:convert' show json, jsonDecode;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' show FileReader, FileUploadInputElement;

import 'package:flutter/services.dart' show rootBundle;
import 'package:preference_center_web/models.dart';
import 'package:preference_center_web/state/view_models.dart';

Future<Preferences> getAllPreferences({String? url}) async {
  // use the local file in assets to initialize the app
  if (url == null) url = 'assets/json/all_preferences.json';

  List<Map<String, dynamic>> _preferencesJson = List<Map<String, dynamic>>.from(
      json.decode(await rootBundle.loadString(url)));

  // install and then import the http package
  // var url = Uri.parse('https://acs.org/{name removed}.json');
  // await http.read(url);
  // List<Map<String, dynamic>> _preferencesJson = List<Map<String, dynamic>>.from(json.decode(await http.read(url)));

  return Preferences.fromJson(_preferencesJson);
}

//TODO Add a make sure you want to leave the page on refresh or browser close
// or put a red notice somewhere

//TODO Image toggle or async load on expanding the widget
// or dummy image for svgs to improve performance

// route = preference/$Code
// return all the recommendedby and recommendations in side by side

/// all customer facing preferences have images and internal ones might not

Future uploadPreferences(PreferenceCenterModel state) async {
  final inputElement = FileUploadInputElement()
    ..accept = '.json'
    ..multiple = true
    ..click();

  inputElement.onChange.listen((event) {
    final files = inputElement.files;
    if (files != null && files.length > 0) {}
    final file = files![0];
    final reader = FileReader();
    reader.onLoadEnd.listen((e) {
      state.preferences =
          Preferences.fromJson(List.from(jsonDecode(reader.result as String)));
      state.refresh();
    });
    reader.readAsText(file);
  });

  inputElement.remove();
}
