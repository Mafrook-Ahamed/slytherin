import 'package:flutter/material.dart';

import '../constants/app_breakpoints.dart';
import '../constants/app_spacing.dart';

/// Screen-size helpers. Keeps every `MediaQuery` check in one place so screens
/// never hard-code device dimensions.
class Responsive {
  const Responsive._();

  static Size sizeOf(BuildContext context) => MediaQuery.sizeOf(context);

  static double widthOf(BuildContext context) => sizeOf(context).width;

  static double heightOf(BuildContext context) => sizeOf(context).height;

  /// Very small Android phones.
  static bool isCompact(BuildContext context) =>
      widthOf(context) < AppBreakpoints.compact + 40;

  /// Tablets in portrait and above.
  static bool isTablet(BuildContext context) =>
      widthOf(context) >= AppBreakpoints.tablet;

  /// Tablets in landscape / desktop windows.
  static bool isDesktop(BuildContext context) =>
      widthOf(context) >= AppBreakpoints.desktop;

  /// Any layout that has enough room for a two column dashboard.
  static bool hasTwoColumns(BuildContext context) =>
      widthOf(context) >= AppBreakpoints.largePhone;

  /// Landscape phones: used to compact vertical spacing.
  static bool isShort(BuildContext context) =>
      heightOf(context) < AppBreakpoints.shortScreen;

  /// Page gutter that grows with the window.
  static double pagePadding(BuildContext context) {
    if (isDesktop(context)) return AppSpacing.xxl;
    if (isTablet(context)) return AppSpacing.xl;
    return AppSpacing.pageHorizontal;
  }

  /// Centre the content and cap the width so text never becomes unreadable on
  /// tablets. Use this instead of hard-coding a max width.
  static Widget constrain(
    BuildContext context, {
    required Widget child,
    double maxWidth = 760,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }

  /// Number of grid columns for the current width.
  static int gridColumns(BuildContext context, {int min = 1, int max = 3}) {
    final width = widthOf(context);
    final columns = width >= 1200
        ? 3
        : width >= AppBreakpoints.desktop
            ? 2
            : width >= AppBreakpoints.largePhone
                ? 2
                : 1;
    return columns.clamp(min, max);
  }

  /// Card width when laying a list out as a responsive grid.
  static double gridItemWidth(BuildContext context, {int crossAxisCount = 2}) {
    final total = widthOf(context) - (pagePadding(context) * 2);
    return (total / crossAxisCount) - (AppSpacing.sm * (crossAxisCount - 1) / 2);
  }

  /// Hides the bottom navigation on very short screens when scrolling content
  /// so the primary actions stay reachable.
  static bool shouldUseBottomBar(BuildContext context) =>
      !isDesktop(context);
}
