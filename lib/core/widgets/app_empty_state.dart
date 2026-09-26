import 'package:flutter/material.dart';

import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../extensions/context_extensions.dart';
import 'app_button.dart';

/// The one empty-state widget used across the app.
///
/// Every empty state ships an illustration, a short explanation and the single
/// action that fixes it, so the user is never stuck on a blank screen.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_rounded,
    this.actionLabel,
    this.onAction,
    this.secondaryLabel,
    this.onSecondary,
    this.compact = false,
    this.accentColor,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final bool compact;
  final Color? accentColor;

  factory AppEmptyState.noDocuments({
    VoidCallback? onUpload,
    bool compact = false,
  }) =>
      AppEmptyState(
        title: 'No documents yet',
        message:
            'Upload your first PDF and EduForge AI will turn it into summaries, chat answers and quizzes.',
        icon: Icons.picture_as_pdf_rounded,
        actionLabel: 'Upload PDF',
        onAction: onUpload,
        compact: compact,
      );

  factory AppEmptyState.noQuizHistory({VoidCallback? onStart, bool compact = false}) =>
      AppEmptyState(
        title: 'No quiz history',
        message:
            'Generate your first quiz from a document and your scores will appear here.',
        icon: Icons.fact_check_rounded,
        actionLabel: 'Generate a quiz',
        onAction: onStart,
        compact: compact,
      );

  factory AppEmptyState.noRecommendations({VoidCallback? onRefresh, bool compact = false}) =>
      AppEmptyState(
        title: 'No recommendations',
        message:
            'Take a quiz and we will start suggesting what to study next.',
        icon: Icons.lightbulb_rounded,
        actionLabel: 'Refresh',
        onAction: onRefresh,
        compact: compact,
      );

  factory AppEmptyState.noChatHistory({VoidCallback? onAsk, bool compact = false}) =>
      AppEmptyState(
        title: 'No chat history',
        message:
            'Ask a question about any of your documents to start a conversation.',
        icon: Icons.chat_bubble_rounded,
        actionLabel: 'Ask a question',
        onAction: onAsk,
        compact: compact,
      );

  factory AppEmptyState.noSearchResults({required String query, VoidCallback? onClear}) =>
      AppEmptyState(
        title: 'No matches',
        message: 'Nothing matched "$query". Try a different keyword.',
        icon: Icons.search_off_rounded,
        actionLabel: 'Clear search',
        onAction: onClear,
        compact: true,
      );

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final accent = accentColor ?? scheme.primary;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? AppSpacing.lg : AppSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _Illustration(
                icon: icon,
                accent: accent,
                size: compact ? 60 : 92,
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
              if (onAction != null && actionLabel != null) ...<Widget>[
                SizedBox(height: compact ? AppSpacing.md : AppSpacing.xl),
                AppButton(
                  label: actionLabel,
                  onPressed: onAction,
                  isExpanded: false,
                ),
              ],
              if (onSecondary != null && secondaryLabel != null) ...<Widget>[
                const SizedBox(height: AppSpacing.xxs),
                AppButton(
                  label: secondaryLabel,
                  variant: AppButtonVariant.ghost,
                  onPressed: onSecondary,
                  isExpanded: false,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Illustration extends StatelessWidget {
  const _Illustration({
    required this.icon,
    required this.accent,
    required this.size,
  });

  final IconData icon;
  final Color accent;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      width: size * 1.75,
      height: size * 1.55,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            left: 0,
            top: size * 0.25,
            child: _Blob(size: size * 0.7, color: colors.surfaceAlt),
          ),
          Positioned(
            right: 0,
            bottom: size * 0.1,
            child: _Blob(size: size * 0.5, color: colors.surfaceAlt),
          ),
          Container(
            height: size,
            width: size,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[accent, Color.lerp(accent, context.scheme.secondary, 0.7)!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: colors.softShadow,
            ),
            child: Icon(icon, size: size * 0.48, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
