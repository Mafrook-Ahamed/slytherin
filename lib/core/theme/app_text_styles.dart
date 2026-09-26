import 'package:flutter/material.dart';

/// Thin semantic wrapper around the Material [TextTheme].
///
/// It exists so screens reference intent (`AppTextStyles.of(context).sectionTitle`)
/// instead of raw sizes, which makes a typography refresh a one-file change.
@immutable
class AppTextStyles {
  const AppTextStyles(this.textTheme);

  final TextTheme textTheme;

  factory AppTextStyles.fromContext(BuildContext context) =>
      AppTextStyles(Theme.of(context).textTheme);

  /// Big marketing / hero copy (splash, onboarding titles, empty states).
  TextStyle get hero => textTheme.displaySmall!;

  /// Screen level title.
  TextStyle get pageTitle => textTheme.headlineSmall!;

  /// Bottom sheet / dialog title.
  TextStyle get sheetTitle => textTheme.titleLarge!;

  /// Section header on the dashboard.
  TextStyle get sectionTitle => textTheme.titleMedium!;

  /// Card headline.
  TextStyle get cardTitle => textTheme.titleSmall!;

  /// Default body copy.
  TextStyle get body => textTheme.bodyMedium!;

  /// Long form reading copy (document summary, explanations).
  TextStyle get bodyLarge => textTheme.bodyLarge!;

  /// Supporting / helper copy.
  TextStyle get caption => textTheme.bodySmall!;

  /// Smallest metadata line (dates, sizes, counts).
  TextStyle get meta => textTheme.labelSmall!;

  /// Chips, filters, small badges.
  TextStyle get label => textTheme.labelMedium!;

  /// Buttons and prominent actions.
  TextStyle get button => textTheme.labelLarge!;

  /// Big numeric readouts such as score and percentage.
  TextStyle get metric => textTheme.displayMedium!;

  TextStyle bold(TextStyle style) => style.copyWith(fontWeight: FontWeight.w700);
}
