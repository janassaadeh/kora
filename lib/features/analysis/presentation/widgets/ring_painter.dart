import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:kora/core/theme/app_colors.dart';

class RingPainter extends CustomPainter {
  final double progress;
  const RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 10;

    // Track
    canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 9
          ..color = AppColors.primaryDark.withOpacity(0.28));

    // Arc
    canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 9
          ..strokeCap = StrokeCap.round
          ..color = AppColors.primary);
  }

  @override
  bool shouldRepaint(RingPainter old) => old.progress != progress;
}