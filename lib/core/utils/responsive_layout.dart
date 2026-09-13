import 'package:flutter/material.dart';

/// Shared breakpoints for layouts that are comfortable on phones and iPads.
abstract final class ResponsiveLayout {
  static const double tabletBreakpoint = 600;

  static bool isTablet(BuildContext context) {
    return isTabletSize(MediaQuery.sizeOf(context));
  }

  static bool isTabletSize(Size size) {
    return size.shortestSide >= tabletBreakpoint;
  }

  static int gridColumns(BuildContext context) {
    return gridColumnsFor(MediaQuery.sizeOf(context));
  }

  static int gridColumnsFor(Size size) {
    if (!isTabletSize(size)) return 2;
    return size.width > size.height ? 4 : 3;
  }

  static EdgeInsets gridPadding(BuildContext context) {
    return isTablet(context)
        ? const EdgeInsets.all(24)
        : const EdgeInsets.all(16);
  }
}
