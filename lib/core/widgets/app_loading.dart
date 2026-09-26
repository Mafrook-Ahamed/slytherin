import 'package:flutter/material.dart';

import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../extensions/context_extensions.dart';

/// Compact inline spinner + label. Used inside cards and bottom sheets.
class AppLoading extends StatelessWidget {
  const AppLoading({
    super.key,
    this.message,
    this.size = 20,
    this.axis = Axis.horizontal,
  });

  final String? message;
  final double size;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    final spinner = SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2.4,
        valueColor: AlwaysStoppedAnimation<Color>(context.scheme.primary),
      ),
    );

    if (message == null) {
      return Center(child: spinner);
    }

    final text = Text(
      message!,
      style: context.text.body,
      textAlign: TextAlign.center,
    );

    if (axis == Axis.horizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          spinner,
          const SizedBox(width: AppSpacing.sm),
          Flexible(child: text),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        spinner,
        const SizedBox(height: AppSpacing.md),
        text,
      ],
    );
  }
}

/// Full page loading state. Always provide a message so the screen is never
/// blank while data loads.
class AppLoadingView extends StatelessWidget {
  const AppLoadingView({
    super.key,
    this.message = 'Loading…',
    this.detail,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
  });

  final String message;
  final String? detail;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const AppLoading(size: 34),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              style: context.text.titleSmall,
              textAlign: TextAlign.center,
            ),
            if (detail != null) ...<Widget>[
              const SizedBox(height: AppSpacing.xs),
              Text(
                detail!,
                style: context.text.caption,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Blocks interaction while a long running action runs, but keeps the previous
/// content visible underneath (login, upload, quiz submission).
class AppLoadingOverlay extends StatelessWidget {
  const AppLoadingOverlay({
    super.key,
    required this.isBusy,
    required this.child,
    this.message,
  });

  final bool isBusy;
  final Widget child;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        child,
        if (isBusy)
          Positioned.fill(
            child: AbsorbPointer(
              child: Container(
                color: Color.lerp(
                  context.colors.surfaceMuted,
                  context.isDark ? Colors.black : Colors.white,
                  0.35,
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.lg,
                    ),
                    decoration: BoxDecoration(
                      color: context.scheme.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: context.colors.outlineSoft),
                    ),
                    child: AppLoading(
                      message: message ?? 'Please wait…',
                      axis: Axis.horizontal,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Pulsing placeholder block. A shimmer effect is deliberately avoided to keep
/// the UI calm and cheap to render on low-end Android devices.
class AppSkeleton extends StatefulWidget {
  const AppSkeleton({
    super.key,
    this.width,
    this.height = 14,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
  });

  final double? width;
  final double height;
  final double? borderRadius;
  final BoxShape shape;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        final t = Curves.easeInOut.transform(_controller.value);
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Color.lerp(
              colors.skeletonBase,
              colors.skeletonHighlight,
              t,
            ),
            shape: widget.shape,
            borderRadius: widget.shape == BoxShape.circle
                ? null
                : BorderRadius.circular(widget.borderRadius ?? AppRadius.sm),
          ),
        );
      },
    );
  }
}

/// Skeleton placeholder for a document row.
class AppSkeletonList extends StatelessWidget {
  const AppSkeletonList({super.key, this.itemCount = 4, this.padding});

  final int itemCount;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      itemCount: itemCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (BuildContext context, int index) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: context.scheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: context.colors.outlineSoft),
          ),
          child: Row(
            children: <Widget>[
              const AppSkeleton(width: 44, height: 44, borderRadius: 12),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AppSkeleton(width: 180, height: 12),
                    const SizedBox(height: AppSpacing.xs),
                    const AppSkeleton(width: 110, height: 10),
                  ],
                ),
              ),
              const AppSkeleton(width: 62, height: 20, borderRadius: 999),
            ],
          ),
        );
      },
    );
  }
}

/// Three-dot typing indicator shown while the assistant is answering.
class AppTypingIndicator extends StatefulWidget {
  const AppTypingIndicator({super.key, this.color});

  final Color? color;

  @override
  State<AppTypingIndicator> createState() => _AppTypingIndicatorState();
}

class _AppTypingIndicatorState extends State<AppTypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? context.colors.onSurfaceMuted;

    return Semantics(
      label: 'Assistant is typing',
      child: SizedBox(
        height: 22,
        width: 46,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List<Widget>.generate(3, (int index) {
                final phase = (_controller.value * 3 - index).clamp(-1.0, 1.0);
                final lift = (1 - phase.abs()) * 6;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Transform.translate(
                    offset: Offset(0, -lift),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Color.lerp(color, context.scheme.primary, 0.4),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

/// Long-running task loader with rotating status copy. Used for PDF processing
/// and quiz generation so the user always knows what is happening.
class AppTaskLoader extends StatefulWidget {
  const AppTaskLoader({
    super.key,
    required this.steps,
    this.title = 'Working…',
    this.icon,
  });

  final List<String> steps;
  final String title;
  final IconData? icon;

  @override
  State<AppTaskLoader> createState() => _AppTaskLoaderState();
}

class _AppTaskLoaderState extends State<AppTaskLoader>
    with SingleTickerProviderStateMixin {
  int _index = 0;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        if (!mounted) return;
        setState(() {
          _index = (_index + 1) % widget.steps.length;
        });
        _controller.repeat();
      }
    });

  @override
  void initState() {
    super.initState();
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final colors = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                width: 64,
                height: 64,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    RotationTransition(
                      turns: _controller,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colors.outlineSoft,
                            width: 4,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(scheme.primary),
                      ),
                    ),
                    if (widget.icon != null)
                      Icon(widget.icon, size: 22, color: scheme.primary),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                widget.title,
                style: context.text.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                child: Text(
                  widget.steps[_index],
                  key: ValueKey<int>(_index),
                  style: context.text.caption,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: LinearProgressIndicator(
                  minHeight: 6,
                  backgroundColor: colors.surfaceAlt,
                  valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
