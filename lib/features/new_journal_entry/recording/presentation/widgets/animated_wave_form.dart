import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kora/core/theme/app_colors.dart';

class AnimatedWaveform extends StatelessWidget {
  final AnimationController controller;
  final List<double> barHeights;
  final bool isActive;

  const AnimatedWaveform({
    super.key,
    required this.controller,
    required this.barHeights,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => CustomPaint(
        size: const Size(120, 112),
        painter: _WaveformPainter(
          t: controller.value,
          barHeights: barHeights,
          isActive: isActive,
        ),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final double t;
  final List<double> barHeights;
  final bool isActive;

  const _WaveformPainter({
    required this.t,
    required this.barHeights,
    required this.isActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const Color centerColor = AppColors.primary; // dark green (center)
    const Color edgeColor =AppColors.primaryDark;   // muted grey-green (edges)

    final n = barHeights.length;
    final barW = (size.width - (n - 1) * 3.0) / n;
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < n; i++) {
      final x = i * (barW + 3.0);

      double h;
      if (isActive) {
        final phase = (i / n) + t;
        final wave = math.sin(phase * math.pi * 2);
        h = barHeights[i] * size.height * (0.25 + 0.75 * ((wave + 1) / 2));
      } else {
        h = barHeights[i] * size.height * 0.18;
      }

      final maxH = size.height;
      final y = (maxH - h) / 2;

      // 0.0 = center bar, 1.0 = outermost bar
      final centerDist = ((i / (n - 1)) - 0.5).abs() * 2.0;

      paint.color = isActive
          ? Color.lerp(centerColor, edgeColor, centerDist)!
          : edgeColor.withOpacity(0.5);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barW, h.clamp(3.0, maxH)),
          const Radius.circular(10),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter old) =>
      old.t != t || old.isActive != isActive;
}