import 'package:flutter/material.dart';

class MyDebugWidget extends StatelessWidget {
  final _DebugWidget widget = _DebugWidget(
    onLoad: () => print('hi'),
  );

  @override
  Widget build(BuildContext context) {
    return widget;
  }
}

class _DebugWidget extends StatelessWidget {
  final VoidCallback onLoad;

  const _DebugWidget({Key? key, required this.onLoad}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(0),
      child: Builder(
        builder: (context) => Container(
          child: Builder(
            builder: (context) {
              onLoad();
              return Container();
            },
          ),
        ),
      ),
    );
  }
}
