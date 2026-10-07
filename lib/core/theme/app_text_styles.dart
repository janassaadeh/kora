import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static final headingLarge =  GoogleFonts.notoSerif(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static final headingMedium =  GoogleFonts.notoSerif(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static final headingSmall = GoogleFonts.notoSerif(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static final body =  GoogleFonts.notoSerif(
    fontSize: 16,
    color: AppColors.textSecondary,
  );

    static final button =  GoogleFonts.notoSerif(
      fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}