import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constants/app_radius.dart';
import '../extensions/context_extensions.dart';

/// Circular percentage ring used on the quiz result and dashboard progress.
class AppProgressRing extends StatelessWidget {
  const AppProgressRing({
    super.key,
    required this.progress,
    this.size = 120,
    this.strokeWidth = 10,
    this.label,
    this.caption,
    this.color,
    this.trackColor,
    this.animate = true,
  });

  /// 0.0 – 1.0
  final double progress;
  final double size;
  final double strokeWidth;
  final String? label;
  final String? caption;
  final Color? color;
  final Color? trackColor;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final colors = context.colors;
    final ringColor = color ?? scheme.primary;
    final clamped = progress.clamp(0.0, 1.0);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: animate ? 0 : clamped, end: clamped),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double value, Widget? child) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              CustomPaint(
                size: Size.square(size),
                painter: _RingPainter(
                  progress: value,
                  strokeWidth: strokeWidth,
                  color: ringColor,
                  trackColor: trackColor ?? colors.surfaceAlt,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (label != null)
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        label!,
                        style: context.text.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                  if (caption != null)
                    Text(
                      caption!,
                      style: context.text.meta?.copyWith(
                        color: colors.onSurfaceMuted,
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
    required this.trackColor,
  });

  final double progress;
  final double strokeWidth;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = trackColor;
    canvas.drawCircle(centre, radius, track);

    if (progress <= 0) return;

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: <Color>[Color.lerp(color, Colors.white, 0.2)!, color],
      ).createShader(Rect.fromCircle(center: centre, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: centre, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.strokeWidth != strokeWidth;
}

/// Thin animated progress bar used for uploads and document processing.
class AppLinearProgress extends StatelessWidget {
  const AppLinearProgress({
    super.key,
    required this.progress,
    this.height = 8,
    this.color,
    this.backgroundColor,
    this.showLabel = false,
    this.label,
  });

  /// 0.0 – 1.0
  final double progress;
  final double height;
  final Color? color;
  final Color? backgroundColor;
  final bool showLabel;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final scheme = context.scheme;
    final value = progress.isNaN ? 0.0 : progress.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: value),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOut,
            builder: (BuildContext context, double v, Widget? child) {
              return LinearProgressIndicator(
                value: v,
                minHeight: height,
                backgroundColor: backgroundColor ?? colors.surfaceAlt,
                valueColor: AlwaysStoppedAnimation<Color>(
                  color ?? scheme.primary,
                ),
              );
            },
          ),
        ),
        if (showLabel) ...<Widget>[
          const SizedBox(height: 6),
          Text(
            label ?? '${(value * 100).round()}%',
            style: context.text.meta,
          ),
        ],
      ],
    );
  }
}
