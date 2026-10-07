
import 'package:flutter/material.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_text_styles.dart';

class PausePlayBtn extends StatefulWidget {
  final bool isPaused;
  final VoidCallback onTap;
  const PausePlayBtn({super.key, required this.isPaused, required this.onTap});

  @override
  State<PausePlayBtn> createState() => PausePlayBtnState();
}

class PausePlayBtnState extends State<PausePlayBtn>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1, end: 0.9).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Column(
          children: [
            Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 18,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: anim,
                  child: child,
                ),
                child: Icon(
                  widget.isPaused ? Icons.play_arrow_outlined : Icons.pause_outlined,
                  key: ValueKey(widget.isPaused),
                  color: AppColors.card,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.isPaused ? 'RESUME' : 'PAUSE',
              style: AppTextStyles.headingSmall.copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}