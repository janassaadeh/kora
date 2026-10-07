import 'package:flutter/material.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_text_styles.dart';

class TrendLineChart extends StatelessWidget {
  final Animation<double> animation;
  final List<double> moodValues;
  final List<double> heartRateValues;
  final List<double> activityValues;
  final List<String> dayLabels;

  const TrendLineChart({
    super.key,
    required this.animation,
    required this.moodValues,
    required this.heartRateValues,
    required this.activityValues,
    required this.dayLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          _Dot(color: AppColors.primary, label: 'Voice Mood'),
          const SizedBox(width: 14),
          _Dot(color:  AppColors.error, label: 'Heart Rate'),
          const SizedBox(width: 14),
          _Dot(color:AppColors.accent, label: 'Activity'),
        ]),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: AnimatedBuilder(
            animation: animation,
            builder: (_, __) => CustomPaint(
              painter: _Painter(
                progress: animation.value,
                moodValues: moodValues,
                heartRateValues: heartRateValues,
                activityValues: activityValues,
                moodColor: AppColors.primary,
                heartColor:AppColors.error,
                activityColor:AppColors.accent,
              ),
              size: Size.infinite,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: dayLabels
              .map((d) => Text(d,
                  style: AppTextStyles.headingSmall
                      .copyWith(color: AppColors.textSecondary)))
              .toList(),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  final String label;
  const _Dot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label, style: AppTextStyles.headingSmall.copyWith(color: AppColors.textSecondary)),
      ]);
}

class _Painter extends CustomPainter {
  final double progress;
  final List<double> moodValues, heartRateValues, activityValues;
  final Color moodColor, heartColor, activityColor;

  _Painter({
    required this.progress,
    required this.moodValues,
    required this.heartRateValues,
    required this.activityValues,
    required this.moodColor,
    required this.heartColor,
    required this.activityColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()..color = Colors.white.withOpacity(0.06)..strokeWidth = 1;
    for (int i = 1; i <= 3; i++) {
      final y = size.height * (1 - i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    _draw(canvas, size, moodValues, moodColor);
    _draw(canvas, size, heartRateValues, heartColor);
    _draw(canvas, size, activityValues, activityColor);
  }

  void _draw(Canvas canvas, Size size, List<double> vals, Color color) {
    if (vals.length < 2) return;
    final n = vals.length;
    final paint = Paint()
      ..color = color..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final dot = Paint()..color = color..style = PaintingStyle.fill;

    Offset pt(int i) => Offset(
      size.width * i / (n - 1),
      size.height * (1 - vals[i].clamp(0.0, 1.0)),
    );

    final total = (n - 1).toDouble();
    final drawn = progress * total;
    final full = drawn.floor();
    final partial = drawn - full;

    final path = Path()..moveTo(pt(0).dx, pt(0).dy);
    for (int i = 0; i < full && i < n - 1; i++) {
      final cpX = (pt(i).dx + pt(i + 1).dx) / 2;
      path.cubicTo(cpX, pt(i).dy, cpX, pt(i + 1).dy, pt(i + 1).dx, pt(i + 1).dy);
    }
    if (full < n - 1 && partial > 0) {
      final endX = pt(full).dx + (pt(full + 1).dx - pt(full).dx) * partial;
      final endY = pt(full).dy + (pt(full + 1).dy - pt(full).dy) * partial;
      final cpX = (pt(full).dx + endX) / 2;
      path.cubicTo(cpX, pt(full).dy, cpX, endY, endX, endY);
    }
    canvas.drawPath(path, paint);

    for (int i = 0; i <= full && i < n; i++) {
      canvas.drawCircle(pt(i), 3.5, dot);
      canvas.drawCircle(pt(i), 3.5,
          Paint()..color = Colors.black.withOpacity(0.25)..style = PaintingStyle.stroke..strokeWidth = 1);
    }
  }

  @override
  bool shouldRepaint(_Painter old) => old.progress != progress;
}