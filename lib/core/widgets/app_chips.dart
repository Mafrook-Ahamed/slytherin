import 'package:flutter/material.dart';

import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../extensions/context_extensions.dart';

/// Semantic status pill (document processing status, quiz status, plan badges).
class AppStatusChip extends StatelessWidget {
  const AppStatusChip({
    super.key,
    required this.label,
    this.icon,
    this.foreground,
    this.background,
    this.showDot = false,
    this.isBusy = false,
    this.dense = false,
  });

  final String label;
  final IconData? icon;
  final Color? foreground;
  final Color? background;
  final bool showDot;
  final bool isBusy;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final fg = foreground ?? scheme.primary;
    final bg = background ?? scheme.primaryContainer;
    final textStyle = context.text.meta?.copyWith(
      color: fg,
      fontWeight: FontWeight.w700,
    );

    return Semantics(
      label: 'Status: $label',
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: dense ? AppSpacing.xs : AppSpacing.sm,
          vertical: dense ? 3 : 5,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (isBusy)
              SizedBox(
                width: 10,
                height: 10,
                child: CircularProgressIndicator(
                  strokeWidth: 1.6,
                  valueColor: AlwaysStoppedAnimation<Color>(fg),
                ),
              )
            else if (showDot)
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
              )
            else if (icon != null)
              Icon(icon, size: dense ? 12 : 14, color: fg),
            SizedBox(width: dense ? 4 : 6),
            Text(label, style: textStyle),
          ],
        ),
      ),
    );
  }
}

/// Neutral pill used for tags, subjects and quick filters.
class AppTag extends StatelessWidget {
  const AppTag({
    super.key,
    required this.label,
    this.icon,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final colors = context.colors;

    final fg = selected ? scheme.onPrimary : colors.onSurfaceMuted;
    final bg = selected ? scheme.primary : colors.surfaceMuted;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: selected ? scheme.primary : colors.outlineSoft,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 14, color: fg),
                const SizedBox(width: 5),
              ],
              Text(label, style: context.text.label?.copyWith(color: fg)),
            ],
          ),
        ),
      ),
    );
  }
}
