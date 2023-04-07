import 'package:flutter/material.dart';

class ElevatedContainer extends StatelessWidget {
  final Widget child;
  final double? height;
  final double? width;
  final Color? color;

  const ElevatedContainer(
      {Key? key, required this.child, this.height, this.width, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      clipBehavior: Clip.none,
      decoration: BoxDecoration(
        color: color ?? Colors.orange,
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 5.0, // soften the shadow
            // spreadRadius: 7.0, //extend the shadow
            offset: Offset(-4.0, 4.0),
          )
        ],
      ),
      child: child,
    );
  }
}
