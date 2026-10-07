import 'package:flutter/material.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_radius.dart';
import 'package:kora/core/theme/app_text_styles.dart';
import 'package:kora/features/analysis/presentation/widgets/live_badge.dart';

class VoiceAnalysisCard extends StatelessWidget {
  final Animation<double> chartProgress;
  final List<double> heights ;
  final String emotion ;


  const VoiceAnalysisCard({required this.chartProgress,required this.heights ,required this.emotion, super.key});

  static const _heights = [0.8, 0.65, 0.48, 1.0, 0.58, 0.82, 0.44, 0.72, 0.56];
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius:AppRadius.radius,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.3),
            blurRadius: 50,
            offset: const Offset(20, 20),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Voice Analysis', style: AppTextStyles.headingMedium.copyWith(color: AppColors.textPrimary,fontWeight: FontWeight.w800)),
            // LiveBadge(),
          ],
        ),
        // const SizedBox(height: 50),
        // // Animated bar chart
        // AnimatedBuilder(
        //   animation: chartProgress,
        //   builder: (_, __) => SizedBox(
        //     height: 76,
        //     child: Row(
        //       crossAxisAlignment: CrossAxisAlignment.end,
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       children: heights.asMap().entries.map((e) {
        //         final h = 76.0 * e.value * chartProgress.value;
        //         return AnimatedContainer(
        //           duration: Duration(milliseconds: 350 + e.key * 35),
        //           width: 30,
        //           height: h.clamp(3.0, 76.0),
        //           decoration: BoxDecoration(
        //           color: e.value > 0.79
        //               ? AppColors.primary.withOpacity(0.95)      
        //               : e.value > 0.52
        //                   ? AppColors.primaryDark.withOpacity(0.8)  
        //                   : AppColors.accent.withOpacity(0.7),      
        //           borderRadius: const BorderRadius.only(
        //             topLeft: Radius.circular(99999),
        //             topRight: Radius.circular(99999),
        //           ),
        //         ),
        //         );
        //       }).toList(),
        //     ),
        //   ),
        // ),
        const SizedBox(height: 25),
        Center(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.primaryDark.withOpacity(0.15),
              borderRadius: AppRadius.radius
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    shape: BoxShape.circle,
                  ),
                   child: Icon(Icons.graphic_eq,
                      size: 22, color: AppColors.primary),
                 ),
                const SizedBox(width: 18),
                Expanded(
                  child: Text(
                    getEmotionInsight(emotion),
                    style: AppTextStyles.body.copyWith(color: AppColors.textSecondary,height: 1.4,fontSize:14),
                  ),
                ),

              ],
            ),
          ),
        ),
      ]),
    );
  }
}
String getEmotionInsight(String emotion) {
  switch (emotion) {
    case 'angry':
      return '"Elevated vocal intensity suggests heightened emotional arousal and reduced impulse control."';
      case 'fearful':
        return '"Instability in speech patterns indicates elevated stress response and heightened threat sensitivity."';
    case 'happy':
      return '"Steady tonal rhythm and balanced resonance indicate positive affect and emotional stability."';
    case 'neutral':
      return '"Even speech modulation suggests a regulated emotional state with low affective volatility."';
    case 'sad':
      return '"Lower energy resonance reflects reduced emotional activation and possible cognitive fatigue."';
    default:
      return '"Speech patterns indicate a mixed or unclear emotional state."';
  }
}