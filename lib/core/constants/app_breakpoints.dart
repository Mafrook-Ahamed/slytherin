/// Layout breakpoints used by [Responsive] to switch between phone, large
/// phone and tablet layouts.
class AppBreakpoints {
  const AppBreakpoints._();

  /// Very small devices (older Android phones).
  static const double compact = 360.0;

  /// Large phones / small foldables.
  static const double largePhone = 600.0;

  /// Tablets in portrait.
  static const double tablet = 700.0;

  /// Tablets in landscape and desktop sized windows.
  static const double desktop = 1000.0;

  /// Short screens need extra care so bottom bars never cover content.
  static const double shortScreen = 620.0;
}
