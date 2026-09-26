import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Ergonomic accessors used across every feature screen.
extension ContextX on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get scheme => Theme.of(this).colorScheme;

  AppColors get colors => AppColors.of(this);

  TextTheme get text => Theme.of(this).textTheme;

  AppTextStyles get styles => AppTextStyles.fromContext(this);

  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  bool get isTablet => MediaQuery.sizeOf(this).width >= 700;

  bool get isDesktop => MediaQuery.sizeOf(this).width >= 1000;

  EdgeInsets get safePadding => MediaQuery.paddingOf(this);

  /// True when the software keyboard covers part of the screen.
  bool get isKeyboardOpen => MediaQuery.viewInsetsOf(this).bottom > 0;

  /// Hides the keyboard. Safe to call from any context.
  void dismissKeyboard() => FocusScope.of(this).unfocus();

  /// Shows a themed snackbar. Returns the controller so callers can await.
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showToast(
    String message, {
    IconData? icon,
    Color? backgroundColor,
  }) {
    final scheme = this.scheme;
    return ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 18, color: Colors.white),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  message,
                  style: this.text.bodyMedium?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: backgroundColor ?? scheme.onSurface,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
        ),
      );
  }
}
