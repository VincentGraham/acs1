// ignore: avoid_web_libraries_in_flutter
import 'dart:html'
    show AnchorElement, Blob, FileReader, FileUploadInputElement, Url;
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:preference_center_web/models.dart';
import 'package:preference_center_web/state/view_models.dart';

Future<dynamic> getRecommendations(Preferences preferences) async {
  // loaded the json file stored in assets
  var json = jsonDecode(
      await rootBundle.loadString('assets/json/recommendations.json'));

  // import http package to use an existing json at some url
  // var url =
  //     Uri.parse('https://acs.org/{address removed}/recommendations.json');
  // await http.read(url);

  // List<Map<String, dynamic>> json =
  //     List<Map<String, dynamic>>.from(jsonDecode(await http.read(url)));
  return Recommendations.fromJson(List.from(json), preferences: preferences);
}

void exportRecommendations(Recommendations graph) {
  var jsonEncoder = JsonEncoder.withIndent('  ');
  var toEncode = graph.toJson();

  toEncode.sort((a, b) => a['recommendations']
      .split(',')
      .length
      .compareTo(b['recommendations'].split(',').length));
  final blob = Blob([jsonEncoder.convert(toEncode)], 'applications/json');
  AnchorElement(href: Url.createObjectUrlFromBlob(blob).toString())
    ..setAttribute(
      "download",
      "recommendations.json",
    )
    ..click();
}

/// overwrites the existing data
Future uploadRecommendations(PreferenceCenterModel state) async {
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
      state.recommendations = Recommendations.fromJson(
          List.from(jsonDecode(reader.result as String)),
          preferences: state.preferences);
      state.refresh();
    });
    reader.readAsText(file);
  });

  inputElement.remove();
}
