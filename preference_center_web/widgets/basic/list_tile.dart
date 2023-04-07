import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ListTileItem extends StatelessWidget {
  final double width;
  final double? height;
  final Widget child;
  final Alignment alignment;

  const ListTileItem({
    Key? key,
    required this.width,
    this.height,
    required this.child,
    this.alignment = Alignment.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width <= 1 ? 1 : width,
      height: height,
      child: FittedBox(
        fit: BoxFit.none,
        clipBehavior: Clip.hardEdge,
        child: child,
      ),
    );
  }
}
