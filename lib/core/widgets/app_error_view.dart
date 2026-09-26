import 'package:flutter/material.dart';

import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../extensions/context_extensions.dart';
import 'app_button.dart';

/// The one error widget used across the app.
///
/// Covers every required failure: no internet, generic error, document
/// processing failed, AI unavailable and quiz generation failed. Always offer a
/// retry when the action is idempotent.
class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.onRetry,
    this.retryLabel = 'Retry',
    this.secondaryLabel,
    this.onSecondary,
    this.compact = false,
  });

  final String title;
  final String message;
  final IconData? icon;
  final VoidCallback? onRetry;
  final String retryLabel;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final bool compact;

  factory AppErrorView.noInternet({VoidCallback? onRetry}) => AppErrorView(
        title: 'No Internet Connection',
        message:
            'You appear to be offline. Reconnect to the internet and try again.',
        icon: Icons.wifi_off_rounded,
        onRetry: onRetry,
      );

  factory AppErrorView.generic({
    String message = 'Something went wrong. Please try again.',
    VoidCallback? onRetry,
  }) =>
      AppErrorView(
        title: 'Something went wrong',
        message: message,
        icon: Icons.error_outline_rounded,
        onRetry: onRetry,
      );

  factory AppErrorView.documentProcessing({
    VoidCallback? onRetry,
    String message =
        'We could not process this PDF. It may be password protected or damaged.',
  }) =>
      AppErrorView(
        title: 'Document processing failed',
        message: message,
        icon: Icons.picture_as_pdf_rounded,
        onRetry: onRetry,
      );

  factory AppErrorView.aiUnavailable({VoidCallback? onRetry}) => AppErrorView(
        title: 'AI response unavailable',
        message:
            'The assistant could not answer right now. Please try again in a moment.',
        icon: Icons.psychology_rounded,
        onRetry: onRetry,
      );

  factory AppErrorView.quizGeneration({VoidCallback? onRetry}) => AppErrorView(
        title: 'Quiz generation failed',
        message:
            'We could not build a quiz from this document. Try a different document or fewer questions.',
        icon: Icons.quiz_rounded,
        onRetry: onRetry,
      );

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final colors = context.colors;
    final color = scheme.error;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? AppSpacing.lg : AppSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                height: compact ? 56 : 72,
                width: compact ? 56 : 72,
                decoration: BoxDecoration(
                  color: scheme.errorContainer,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: Icon(
                  icon ?? Icons.error_outline_rounded,
                  size: compact ? 26 : 32,
                  color: scheme.onErrorContainer,
                ),
              ),
              SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
              Text(
                title,
                style: context.text.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                message,
                style: context.text.caption,
                textAlign: TextAlign.center,
              ),
              if (onRetry != null || onSecondary != null) ...<Widget>[
                SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  alignment: WrapAlignment.center,
                  children: <Widget>[
                    if (onRetry != null)
                      AppButton(
                        label: retryLabel,
                        icon: Icons.refresh_rounded,
                        onPressed: onRetry,
                        isExpanded: false,
                        size: AppButtonSize.medium,
                      ),
                    if (onSecondary != null)
                      AppButton(
                        label: secondaryLabel ?? 'Go back',
                        variant: AppButtonVariant.ghost,
                        onPressed: onSecondary,
                        isExpanded: false,
                      ),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.xs),
              Text(
                'EduForge AI · Mock data layer',
                style: context.text.meta?.copyWith(color: colors.outlineSoft),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Inline banner used inside a screen when only part of the content failed.
class AppErrorBanner extends StatelessWidget {
  const AppErrorBanner({
    super.key,
    required this.message,
    this.title,
    this.onRetry,
    this.icon = Icons.wifi_off_rounded,
  });

  final String message;
  final String? title;
  final VoidCallback? onRetry;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 20, color: scheme.onErrorContainer),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (title != null) ...<Widget>[
                  Text(
                    title!,
                    style: context.text.label?.copyWith(
                      color: scheme.onErrorContainer,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  message,
                  style: context.text.caption?.copyWith(
                    color: scheme.onErrorContainer,
                  ),
                ),
              ],
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: scheme.onErrorContainer,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                minimumSize: const Size(0, 32),
              ),
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }
}
