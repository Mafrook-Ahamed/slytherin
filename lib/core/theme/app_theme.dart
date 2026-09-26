import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_durations.dart';
import '../constants/app_radius.dart';
import 'app_colors.dart';

/// Material 3 themes for EduForge AI.
///
/// Both themes are generated from a single brand seed and then tuned with the
/// semantic palette from [AppColors], which keeps light and dark perfectly in
/// sync.
class AppTheme {
  const AppTheme._();

  static const Color _seed = Color(0xFF4F46E5);

  static ColorScheme _schemeFor(Brightness brightness) {
    final base = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );

    if (brightness == Brightness.light) {
      return base.copyWith(
        primary: AppColors.light.brandGradientStart,
        onPrimary: AppColors.light.gradientOn,
        primaryContainer: const Color(0xFFE3E6FF),
        onPrimaryContainer: const Color(0xFF2B2773),
        secondary: const Color(0xFF0EA5E9),
        onSecondary: const Color(0xFFFFFFFF),
        secondaryContainer: const Color(0xFFE0F2FE),
        onSecondaryContainer: const Color(0xFF0B4A6B),
        tertiary: const Color(0xFFF59E0B),
        onTertiary: const Color(0xFFFFFFFF),
        tertiaryContainer: const Color(0xFFFEF3C7),
        onTertiaryContainer: const Color(0xFF78350F),
        error: const Color(0xFFDC2626),
        onError: const Color(0xFFFFFFFF),
        errorContainer: const Color(0xFFFEE2E2),
        onErrorContainer: const Color(0xFF7F1D1D),
        surface: const Color(0xFFFFFFFF),
        onSurface: const Color(0xFF101828),
        onSurfaceVariant: AppColors.light.onSurfaceMuted,
        outline: const Color(0xFF98A2B3),
        outlineVariant: AppColors.light.outlineSoft,
        inverseSurface: const Color(0xFF1D2939),
        onInverseSurface: const Color(0xFFF8FAFC),
        inversePrimary: const Color(0xFFA5B4FC),
      );
    }

    return base.copyWith(
      primary: AppColors.dark.brandGradientStart,
      onPrimary: const Color(0xFF0B1120),
      primaryContainer: const Color(0xFF2E2A7A),
      onPrimaryContainer: const Color(0xFFE0E7FF),
      secondary: const Color(0xFF38BDF8),
      onSecondary: const Color(0xFF06283D),
      secondaryContainer: const Color(0xFF0B3B54),
      onSecondaryContainer: const Color(0xFFBAE6FD),
      tertiary: const Color(0xFFFBBF24),
      onTertiary: const Color(0xFF3A2B0C),
      tertiaryContainer: const Color(0xFF4A3608),
      onTertiaryContainer: const Color(0xFFFDE68A),
      error: const Color(0xFFF87171),
      onError: const Color(0xFF3B0A0A),
      errorContainer: const Color(0xFF451A1A),
      onErrorContainer: const Color(0xFFFECACA),
      surface: const Color(0xFF0B1120),
      onSurface: const Color(0xFFE7EBF3),
      onSurfaceVariant: AppColors.dark.onSurfaceMuted,
      outline: const Color(0xFF475569),
      outlineVariant: AppColors.dark.outlineSoft,
      inverseSurface: const Color(0xFFE7EBF3),
      onInverseSurface: const Color(0xFF0B1120),
      inversePrimary: const Color(0xFF4F46E5),
    );
  }

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = _schemeFor(brightness);
    final colors = isDark ? AppColors.dark : AppColors.light;

    final scaffold = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
    );
    final baseText = scaffold.textTheme;

    final textTheme = baseText.copyWith(
      displaySmall: baseText.displaySmall!.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        height: 1.12,
      ),
      displayMedium: baseText.displayMedium!.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -1.2,
      ),
      headlineSmall: baseText.headlineSmall!.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      headlineMedium: baseText.headlineMedium!.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      titleLarge: baseText.titleLarge!.copyWith(fontWeight: FontWeight.w700),
      titleMedium: baseText.titleMedium!.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
      ),
      titleSmall: baseText.titleSmall!.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.35,
      ),
      bodyLarge: baseText.bodyLarge!.copyWith(height: 1.5),
      bodyMedium: baseText.bodyMedium!.copyWith(height: 1.45),
      bodySmall: baseText.bodySmall!.copyWith(
        height: 1.4,
        color: colors.onSurfaceMuted,
      ),
      labelLarge: baseText.labelLarge!.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
      ),
      labelMedium: baseText.labelMedium!.copyWith(
        fontWeight: FontWeight.w600,
      ),
      labelSmall: baseText.labelSmall!.copyWith(
        color: colors.onSurfaceMuted,
        letterSpacing: 0.2,
      ),
    );

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: colors.outlineSoft),
    );
    final inputBorderFocused = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: scheme.primary, width: 1.6),
    );
    final inputBorderError = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: scheme.error, width: 1.4),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF080D18) : const Color(0xFFF7F8FC),
      canvasColor: isDark ? const Color(0xFF080D18) : const Color(0xFFF7F8FC),
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      extensions: <ThemeExtension<dynamic>>[colors],
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF080D18) : const Color(0xFFF7F8FC),
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? colors.surfaceAlt : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppRadius.md,
          vertical: AppRadius.md,
        ),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorderFocused,
        errorBorder: inputBorderError,
        focusedErrorBorder: inputBorderError,
        labelStyle: TextStyle(color: colors.onSurfaceMuted),
        floatingLabelStyle: TextStyle(color: scheme.primary),
        hintStyle: TextStyle(
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.w400,
        ),
        errorStyle: textTheme.bodySmall!.copyWith(
          color: scheme.error,
          fontWeight: FontWeight.w600,
        ),
        prefixIconColor: colors.onSurfaceMuted,
        suffixIconColor: colors.onSurfaceMuted,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, AppRadius.xl + 8),
          padding: const EdgeInsets.symmetric(horizontal: AppRadius.xl),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, AppRadius.xl + 8),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: AppRadius.xl),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, AppRadius.xl + 8),
          padding: const EdgeInsets.symmetric(horizontal: AppRadius.xl),
          side: BorderSide(color: colors.outlineSoft),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, AppRadius.xl),
          padding: const EdgeInsets.symmetric(horizontal: AppRadius.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: scheme.onSurface,
          minimumSize: const Size(AppRadius.xl + 8, AppRadius.xl + 8),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? const Color(0xFF0C1322) : Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        elevation: 0,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStatePropertyAll<TextStyle>(
          textTheme.labelSmall!.copyWith(fontWeight: FontWeight.w600),
        ),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
          (Set<WidgetState> states) {
            return IconThemeData(
              size: 24,
              color: states.contains(WidgetState.selected)
                  ? scheme.onSurface
                  : colors.onSurfaceMuted,
            );
          },
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: isDark ? const Color(0xFF0C1322) : Colors.white,
        indicatorColor: scheme.primaryContainer,
        selectedIconTheme: IconThemeData(color: scheme.onSurface, size: 24),
        unselectedIconTheme: IconThemeData(
          color: colors.onSurfaceMuted,
          size: 24,
        ),
        selectedLabelTextStyle: textTheme.labelMedium,
        unselectedLabelTextStyle:
            textTheme.labelMedium!.copyWith(color: colors.onSurfaceMuted),
      ),
      dividerTheme: DividerThemeData(
        color: colors.outlineSoft,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppRadius.md),
        titleTextStyle: textTheme.titleSmall,
        subtitleTextStyle: textTheme.bodySmall,
        iconColor: colors.onSurfaceMuted,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: colors.surfaceAlt,
        circularTrackColor: colors.surfaceAlt,
        linearMinHeight: 8,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: colors.outlineSoft,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xxl),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFF1D2939),
        contentTextStyle: textTheme.bodyMedium!.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  /// Standard horizontal page padding, aware of the available width.
  static EdgeInsets pagePadding(Size size) => EdgeInsets.symmetric(
        horizontal: size.width >= 600 ? 28 : 18,
      );

  /// Shared page transition duration.
  static const Duration transitionDuration = AppDurations.normal;
}
