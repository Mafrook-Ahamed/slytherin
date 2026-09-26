import 'package:flutter/material.dart';

import '../constants/app_radius.dart';

/// Brand palette + every semantic colour the UI needs that is not covered by
/// the Material [ColorScheme].
///
/// Registered on [ThemeData] as a [ThemeExtension] so widgets can simply do:
/// `context.colors.primary` and automatically get the right value in light and
/// dark mode.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.brightness,
    required this.onSurfaceMuted,
    required this.surfaceMuted,
    required this.surfaceAlt,
    required this.outlineSoft,
    required this.success,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.info,
    required this.infoContainer,
    required this.onInfoContainer,
    required this.brandGradientStart,
    required this.brandGradientEnd,
    required this.gradientOn,
    required this.aiBubble,
    required this.aiBubbleBorder,
    required this.userBubble,
    required this.onUserBubble,
    required this.shadow,
    required this.skeletonBase,
    required this.skeletonHighlight,
  });

  final Brightness brightness;

  /// Secondary text colour that still passes contrast on [surface].
  final Color onSurfaceMuted;

  /// Very light background used for grouped content.
  final Color surfaceMuted;

  /// Slightly stronger background used for input fields / chips.
  final Color surfaceAlt;

  /// Hairline border colour.
  final Color outlineSoft;

  final Color success;
  final Color successContainer;
  final Color onSuccessContainer;

  final Color warning;
  final Color warningContainer;
  final Color onWarningContainer;

  final Color info;
  final Color infoContainer;
  final Color onInfoContainer;

  final Color brandGradientStart;
  final Color brandGradientEnd;

  /// Foreground colour to use on top of the brand gradient.
  final Color gradientOn;

  final Color aiBubble;
  final Color aiBubbleBorder;
  final Color userBubble;
  final Color onUserBubble;

  final Color shadow;

  final Color skeletonBase;
  final Color skeletonHighlight;

  static const AppColors light = AppColors(
    brightness: Brightness.light,
    onSurfaceMuted: Color(0xFF5B6478),
    surfaceMuted: Color(0xFFF5F6FB),
    surfaceAlt: Color(0xFFEDEFF7),
    outlineSoft: Color(0xFFE2E6F0),
    success: Color(0xFF15803D),
    successContainer: Color(0xFFDCFCE7),
    onSuccessContainer: Color(0xFF14532D),
    warning: Color(0xFFB45309),
    warningContainer: Color(0xFFFEF3C7),
    onWarningContainer: Color(0xFF78350F),
    info: Color(0xFF0369A1),
    infoContainer: Color(0xFFE0F2FE),
    onInfoContainer: Color(0xFF0C4A6E),
    brandGradientStart: Color(0xFF4F46E5),
    brandGradientEnd: Color(0xFF0EA5E9),
    gradientOn: Color(0xFFFFFFFF),
    aiBubble: Color(0xFFFFFFFF),
    aiBubbleBorder: Color(0xFFE2E6F0),
    userBubble: Color(0xFF4F46E5),
    onUserBubble: Color(0xFFFFFFFF),
    shadow: Color(0x141F2A44),
    skeletonBase: Color(0xFFE9ECF4),
    skeletonHighlight: Color(0xFFF6F8FC),
  );

  static const AppColors dark = AppColors(
    brightness: Brightness.dark,
    onSurfaceMuted: Color(0xFFA2ACC2),
    surfaceMuted: Color(0xFF0F1729),
    surfaceAlt: Color(0xFF1A2337),
    outlineSoft: Color(0xFF24304A),
    success: Color(0xFF4ADE80),
    successContainer: Color(0xFF14351F),
    onSuccessContainer: Color(0xFFBBF7D0),
    warning: Color(0xFFFBBF24),
    warningContainer: Color(0xFF3A2B0C),
    onWarningContainer: Color(0xFFFDE68A),
    info: Color(0xFF38BDF8),
    infoContainer: Color(0xFF0B2C3F),
    onInfoContainer: Color(0xFFBAE6FD),
    brandGradientStart: Color(0xFF6366F1),
    brandGradientEnd: Color(0xFF0EA5E9),
    gradientOn: Color(0xFF06121F),
    aiBubble: Color(0xFF16203A),
    aiBubbleBorder: Color(0xFF24304A),
    userBubble: Color(0xFF6366F1),
    onUserBubble: Color(0xFF0B1120),
    shadow: Color(0x40000000),
    skeletonBase: Color(0xFF1C2740),
    skeletonHighlight: Color(0xFF27334F),
  );

  static AppColors of(BuildContext context) {
    final extension = Theme.of(context).extension<AppColors>();
    if (extension != null) return extension;
    return Brightness.of(context) == Brightness.dark ? dark : light;
  }

  /// The brand gradient, reused by the splash, onboarding and empty states.
  LinearGradient get brandGradient => LinearGradient(
        colors: <Color>[brandGradientStart, brandGradientEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Softer gradient used behind headers so it never competes with content.
  LinearGradient get brandGradientSoft => LinearGradient(
        colors: <Color>[brandGradientStart, brandGradientEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Decorative gradient for circles / illustrations.
  LinearGradient get decorativeGradient => LinearGradient(
        colors: <Color>[brandGradientStart, brandGradientEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Soft shadow matching the current brightness.
  List<BoxShadow> get softShadow => <BoxShadow>[
        BoxShadow(
          color: shadow,
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  List<BoxShadow> get subtleShadow => <BoxShadow>[
        BoxShadow(
          color: shadow,
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  /// Rounded gradient container used for the brand mark and primary art.
  BorderRadius get brandRadius => BorderRadius.circular(AppRadius.xl);

  @override
  AppColors copyWith({
    Brightness? brightness,
    Color? onSurfaceMuted,
    Color? surfaceMuted,
    Color? surfaceAlt,
    Color? outlineSoft,
    Color? success,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warning,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? info,
    Color? infoContainer,
    Color? onInfoContainer,
    Color? brandGradientStart,
    Color? brandGradientEnd,
    Color? gradientOn,
    Color? aiBubble,
    Color? aiBubbleBorder,
    Color? userBubble,
    Color? onUserBubble,
    Color? shadow,
    Color? skeletonBase,
    Color? skeletonHighlight,
  }) {
    return AppColors(
      brightness: brightness ?? this.brightness,
      onSurfaceMuted: onSurfaceMuted ?? this.onSurfaceMuted,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      outlineSoft: outlineSoft ?? this.outlineSoft,
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      info: info ?? this.info,
      infoContainer: infoContainer ?? this.infoContainer,
      onInfoContainer: onInfoContainer ?? this.onInfoContainer,
      brandGradientStart: brandGradientStart ?? this.brandGradientStart,
      brandGradientEnd: brandGradientEnd ?? this.brandGradientEnd,
      gradientOn: gradientOn ?? this.gradientOn,
      aiBubble: aiBubble ?? this.aiBubble,
      aiBubbleBorder: aiBubbleBorder ?? this.aiBubbleBorder,
      userBubble: userBubble ?? this.userBubble,
      onUserBubble: onUserBubble ?? this.onUserBubble,
      shadow: shadow ?? this.shadow,
      skeletonBase: skeletonBase ?? this.skeletonBase,
      skeletonHighlight: skeletonHighlight ?? this.skeletonHighlight,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      brightness: t < 0.5 ? brightness : other.brightness,
      onSurfaceMuted: Color.lerp(onSurfaceMuted, other.onSurfaceMuted, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      outlineSoft: Color.lerp(outlineSoft, other.outlineSoft, t)!,
      success: Color.lerp(success, other.success, t)!,
      successContainer: Color.lerp(successContainer, other.successContainer, t)!,
      onSuccessContainer:
          Color.lerp(onSuccessContainer, other.onSuccessContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t)!,
      onWarningContainer:
          Color.lerp(onWarningContainer, other.onWarningContainer, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      onInfoContainer: Color.lerp(onInfoContainer, other.onInfoContainer, t)!,
      brandGradientStart:
          Color.lerp(brandGradientStart, other.brandGradientStart, t)!,
      brandGradientEnd: Color.lerp(brandGradientEnd, other.brandGradientEnd, t)!,
      gradientOn: Color.lerp(gradientOn, other.gradientOn, t)!,
      aiBubble: Color.lerp(aiBubble, other.aiBubble, t)!,
      aiBubbleBorder: Color.lerp(aiBubbleBorder, other.aiBubbleBorder, t)!,
      userBubble: Color.lerp(userBubble, other.userBubble, t)!,
      onUserBubble: Color.lerp(onUserBubble, other.onUserBubble, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      skeletonBase: Color.lerp(skeletonBase, other.skeletonBase, t)!,
      skeletonHighlight:
          Color.lerp(skeletonHighlight, other.skeletonHighlight, t)!,
    );
  }
}
