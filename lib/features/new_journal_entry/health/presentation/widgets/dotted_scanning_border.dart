import 'dart:math';
import 'package:flutter/material.dart';
import 'package:kora/core/theme/app_colors.dart';

class DottedScanningBorder extends StatefulWidget {
  final bool scanning;
  final double size;
  final double strokeWidth;
  final double dotLength;
  final double gapLength;

  const DottedScanningBorder({
    super.key,
    required this.scanning,
    this.size = 208,
    this.strokeWidth = 1.5,
    this.dotLength = 12,
    this.gapLength = 10,
  });

  @override
  State<DottedScanningBorder> createState() => _DottedScanningBorderState();
}

class _DottedScanningBorderState extends State<DottedScanningBorder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    if (widget.scanning) _ctrl.repeat();
  }

  @override
  void didUpdateWidget(DottedScanningBorder old) {
    super.didUpdateWidget(old);
    if (widget.scanning && !_ctrl.isAnimating) {
      _ctrl.repeat();
    } else if (!widget.scanning && _ctrl.isAnimating) {
      _ctrl.stop();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _DottedCirclePainter(
          progress: _ctrl.value,
          scanning: widget.scanning,
          color: AppColors.textSecondary,
          strokeWidth: widget.strokeWidth,
          dotLength: widget.dotLength,
          gapLength: widget.gapLength,
        ),
      ),
    );
  }
}

class _DottedCirclePainter extends CustomPainter {
  final double progress;
  final bool scanning;
  final Color color;
  final double strokeWidth;
  final double dotLength;
  final double gapLength;

  const _DottedCirclePainter({
    required this.progress,
    required this.scanning,
    required this.color,
    required this.strokeWidth,
    required this.dotLength,
    required this.gapLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(scanning ? 0.7 : 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final circumference = 2 * pi * radius;
    final dashTotal = dotLength + gapLength;
    final dashCount = (circumference / dashTotal).floor();
    final anglePerDash = (2 * pi) / dashCount;
    final dotAngle = anglePerDash * (dotLength / dashTotal);
    final offset = 2 * pi * progress; // rotation offset

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * anglePerDash - pi / 2 + offset;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        dotAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DottedCirclePainter old) =>
      old.progress != progress || old.scanning != scanning;
}