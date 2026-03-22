import 'package:flutter/material.dart';

/// Central UI tokens (spacing, radii, layout bounds).
abstract final class UiConstants {
  /// Extra-small spacing (dp).
  static const double spacingXs = 8;

  /// Small spacing (dp).
  static const double spacingSm = 12;

  /// Medium spacing (dp).
  static const double spacingMd = 16;

  /// Large spacing (dp).
  static const double spacingLg = 24;

  /// Small corner radius (dp).
  static const double radiusSm = 8;
  
  /// Medium corner radius (dp).
  static const double radiusMd = 12;

  /// Max width for centered content (dp).
  static const double maxContentWidth = 600;

  /// Scroll-to-end padding (px) before requesting the next todos page.
  static const double todoListLoadMoreThreshold = 120;

  /// Material seed color for light/dark themes.
  static const Color seedColor = Colors.indigoAccent;
}
