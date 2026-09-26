/// Consistent spacing scale used across the whole application.
///
/// Every layout should reference these tokens instead of hard-coded numbers so
/// that rhythm stays identical on phones, large phones and tablets.
class AppSpacing {
  const AppSpacing._();

  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 40.0;
  static const double huge = 56.0;

  /// Horizontal padding used by every scrollable page.
  static const double pageHorizontal = 20.0;

  /// Vertical gap between two stacked sections.
  static const double sectionGap = 24.0;

  /// Minimum touch target recommended by the Material accessibility guide.
  static const double minTapTarget = 48.0;
}
