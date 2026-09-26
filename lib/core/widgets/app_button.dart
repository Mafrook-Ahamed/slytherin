import 'package:flutter/material.dart';

import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../extensions/context_extensions.dart';

enum AppButtonVariant { primary, tonal, secondary, outline, ghost, danger }

enum AppButtonSize { small, medium, large }

/// The single button used by the whole app.
///
/// Guarantees consistent height, radius, typography and loading feedback so no
/// screen has to re-implement button styling.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    this.label,
    this.icon,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isExpanded = true,
    this.trailingIcon,
    this.color,
    this.tooltip,
    this.semanticLabel,
  });

  /// Icon-only variant: a square, tappable button with an optional tooltip.
  const AppButton.icon({
    super.key,
    required this.icon,
    this.onPressed,
    this.variant = AppButtonVariant.ghost,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isExpanded = false,
    this.label,
    this.trailingIcon,
    this.color,
    this.tooltip,
    this.semanticLabel,
  });

  final String? label;
  final IconData? icon;
  final IconData? trailingIcon;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool isExpanded;
  final Color? color;
  final String? tooltip;
  final String? semanticLabel;

  bool get _isIconOnly => (label == null || label!.isEmpty) && icon != null;

  double get _height {
    switch (size) {
      case AppButtonSize.small:
        return 40;
      case AppButtonSize.medium:
        return 50;
      case AppButtonSize.large:
        return 58;
    }
  }

  double get _horizontalPadding {
    switch (size) {
      case AppButtonSize.small:
        return AppRadius.md;
      case AppButtonSize.medium:
        return AppRadius.lg;
      case AppButtonSize.large:
        return AppRadius.xl;
    }
  }

  double get _fontSize {
    switch (size) {
      case AppButtonSize.small:
        return 13;
      case AppButtonSize.medium:
        return 15;
      case AppButtonSize.large:
        return 16;
    }
  }

  double get _iconSize {
    switch (size) {
      case AppButtonSize.small:
        return 16;
      case AppButtonSize.medium:
        return 19;
      case AppButtonSize.large:
        return 21;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final colors = context.colors;

    Color? background;
    Color? foreground;
    Color? borderColor;

    switch (variant) {
      case AppButtonVariant.primary:
        background = color ?? scheme.primary;
        foreground = color == null ? scheme.onPrimary : Colors.white;
      case AppButtonVariant.tonal:
        background = color ?? scheme.primaryContainer;
        foreground =
            color == null ? scheme.onPrimaryContainer : Colors.white;
      case AppButtonVariant.secondary:
        background = color ?? scheme.secondaryContainer;
        foreground =
            color == null ? scheme.onSecondaryContainer : Colors.white;
      case AppButtonVariant.outline:
        foreground = color ?? scheme.onSurface;
        borderColor = color ?? colors.outlineSoft;
      case AppButtonVariant.ghost:
        foreground = color ?? scheme.primary;
      case AppButtonVariant.danger:
        background = color ?? scheme.errorContainer;
        foreground = color == null ? scheme.onErrorContainer : Colors.white;
    }

    final radius = BorderRadius.circular(AppRadius.md);
    final gap = _horizontalPadding * 0.45;

    final labelStyle = TextStyle(
      color: foreground,
      fontSize: _fontSize,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.1,
    );

    final row = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (icon != null) ...<Widget>[
          Icon(icon, size: _iconSize, color: foreground),
          if (!_isIconOnly) SizedBox(width: gap),
        ],
        if (!_isIconOnly)
          Flexible(
            child: Text(
              label!,
              style: labelStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        if (trailingIcon != null) ...<Widget>[
          if (!_isIconOnly) SizedBox(width: gap),
          Icon(trailingIcon, size: _iconSize, color: foreground),
        ],
      ],
    );

    final padding = _isIconOnly
        ? EdgeInsets.zero
        : EdgeInsets.symmetric(
            horizontal: icon != null || trailingIcon != null
                ? _horizontalPadding - 2
                : _horizontalPadding,
          );

    final style = ButtonStyle(
      backgroundColor: background == null
          ? null
          : WidgetStatePropertyAll<Color?>(background),
      foregroundColor: foreground == null
          ? null
          : WidgetStatePropertyAll<Color?>(foreground),
      minimumSize: WidgetStatePropertyAll<Size>(Size(0, _height)),
      padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(padding),
      shape: WidgetStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(
          borderRadius: radius,
          side: borderColor == null
              ? BorderSide.none
              : BorderSide(color: borderColor, width: 1.4),
        ),
      ),
      textStyle: WidgetStatePropertyAll<TextStyle>(labelStyle),
      elevation: const WidgetStatePropertyAll<double>(0),
    );

    Widget button;
    if (variant == AppButtonVariant.outline) {
      button = OutlinedButton(
        onPressed: onPressed,
        style: style,
        child: row,
      );
    } else if (variant == AppButtonVariant.ghost) {
      button = TextButton(
        onPressed: onPressed,
        style: style,
        child: row,
      );
    } else {
      button = FilledButton(
        onPressed: onPressed,
        style: style,
        child: row,
      );
    }

    if (_isIconOnly) {
      button = SizedBox(width: _height, height: _height, child: button);
    } else if (isExpanded) {
      button = SizedBox(width: double.infinity, child: button);
    }

    if (isLoading) {
      button = Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Opacity(opacity: 0, child: button),
          SizedBox(
            width: _iconSize + 4,
            height: _iconSize + 4,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(
                foreground ?? scheme.primary,
              ),
            ),
          ),
        ],
      );
      button = AbsorbPointer(absorbing: true, child: button);
    }

    if (_isIconOnly) {
      button = Semantics(
        button: true,
        label: semanticLabel ?? tooltip ?? label,
        child: button,
      );
      if (tooltip != null) {
        button = Tooltip(message: tooltip!, child: button);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: button,
    );
  }
}
