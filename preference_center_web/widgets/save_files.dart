import 'package:flutter/material.dart';
import 'package:preference_center_web/models/recommendation.dart';
import 'package:preference_center_web/api/recommendations.dart';

class RecommendationExportPage extends Page {
  final Recommendations graph;
  RecommendationExportPage(this.graph);

  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
      settings: this,
      pageBuilder: (context, animation, secondaryAnimation) {
        return build(context);
      },
      transitionDuration: const Duration(microseconds: 0),
    );
  }

  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 150.0, vertical: 100),
        child: Card(
          elevation: 3,
          color: Colors.white,
          shadowColor: Colors.black38,
          child: IconButton(
            icon: Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Export",
                    style: const TextStyle(fontSize: 24),
                  ),
                  Icon(
                    Icons.save,
                  )
                ],
              ),
            ),
            onPressed: () => exportRecommendations(graph),
            iconSize: 44,
          ),
        ),
      ),
    );
  }
}
