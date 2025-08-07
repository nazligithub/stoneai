import 'package:flutter/material.dart';

class AppShadows {
  // Elevated shadow for cards and containers
  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];

  // Soft shadow for subtle elevation
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  // Strong shadow for prominent elements
  static List<BoxShadow> strongShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.25),
      blurRadius: 30,
      offset: const Offset(0, 15),
    ),
  ];
}