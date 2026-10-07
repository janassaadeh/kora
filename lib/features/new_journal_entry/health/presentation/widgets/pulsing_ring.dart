import 'package:flutter/material.dart';
import 'package:kora/core/theme/app_colors.dart';

class PulsingRing extends StatefulWidget {
  final bool scanning;
  const PulsingRing({required this.scanning});

  @override
  State<PulsingRing> createState() => _PulsingRingState();
}

class _PulsingRingState extends State<PulsingRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _scale = Tween(begin: 1.0, end: 1.6).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _opacity = Tween(begin: 0.5, end: 0.0).animate(_ctrl);

    if (widget.scanning) _ctrl.repeat();
  }

  @override
  void didUpdateWidget(PulsingRing old) {
    super.didUpdateWidget(old);
    if (widget.scanning && !_ctrl.isAnimating) {
      _ctrl.repeat();
    } else if (!widget.scanning) {
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
      builder: (_, __) => Container(
        width: 80 * _scale.value,
        height: 80 * _scale.value,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.accent.withOpacity(_opacity.value),
        ),
      ),
    );
  }
}
