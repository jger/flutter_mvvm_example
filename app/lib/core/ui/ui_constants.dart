import 'package:flutter/material.dart';

/// Central UI tokens (spacing, radii, layout bounds).
abstract final class UiConstants {
  static const double spacingXs = 8;
  static const double spacingSm = 12;
  static const double spacingMd = 16;
  static const double spacingLg = 24;

  static const double radiusSm = 8;
  static const double radiusMd = 12;

  static const double maxContentWidth = 600;

  /// Scroll-to-end padding (px) before requesting the next todos page.
  static const double todoListLoadMoreThreshold = 120;

  static const Color seedColor = Colors.indigoAccent;
}
