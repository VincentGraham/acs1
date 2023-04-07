import 'package:flutter/material.dart';

const BackgroundGradient = BoxDecoration(
  backgroundBlendMode: BlendMode.overlay,
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF00a3e0),
      Color(0xFF00bfb3),
    ],
  ),
  color: Colors.white,
);
