import 'package:flutter/material.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_radius.dart';
import 'package:kora/core/theme/app_text_styles.dart';
import 'package:kora/features/exercises/presentation/screens/exercise_detail_screen.dart';
import 'package:kora/features/exercises/presentation/widgets/breath_pattern.dart';

class QuickResetCard extends StatelessWidget {
  final BreathPattern pattern;
  final int sessionMinutes;
  final String imageUrl;
  const QuickResetCard({
    super.key,
    required this.pattern,
    this.sessionMinutes = 3,
    required this.imageUrl
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => ExerciseDetailScreen(
            pattern: pattern,
            sessionMinutes: sessionMinutes,
            imageUrl: imageUrl,

          ),
          transitionsBuilder: (_, animation, __, child) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                  parent: animation, curve: Curves.easeOut)),
              child: child,
            ),
          ),
          transitionDuration: const Duration(milliseconds: 320),
        ),
      ),
      child: Container(
        // padding: const EdgeInsets.all(35),
        decoration: BoxDecoration(
          color: AppColors.textSecondary.withOpacity(0.00),
          borderRadius: AppRadius.radius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Rounded image ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28,vertical: 15),
              child: ClipRRect(
                borderRadius: AppRadius.radius,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: AppColors.accent.withOpacity(0.2),
                      );
                    },
                  ),
                ),
              ),
            ),

            // const SizedBox(height: 20),

            // ── Text ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pattern.name,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  // const SizedBox(height: 2),
                  // Text(
                  //   pattern.tagline,
                  //   style: AppTextStyles.headingSmall.copyWith(
                  //     color: AppColors.textSecondary,
                  //     fontSize: 11,
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}