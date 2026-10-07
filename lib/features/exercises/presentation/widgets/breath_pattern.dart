import 'package:flutter/material.dart';
import 'package:kora/core/theme/app_colors.dart';

// ── Data model ────────────────────────────────────────────────────────────────

class BreathPattern {
  final String name;
  final String tagline;
  final IconData icon;
  final int inhaleSeconds;
  final int holdSeconds;
  final int exhaleSeconds;
  final int holdOutSeconds;
  final Color accentColor;

  const BreathPattern({
    required this.name,
    required this.tagline,
    required this.icon,
    required this.inhaleSeconds,
    required this.holdSeconds,
    required this.exhaleSeconds,
    required this.holdOutSeconds,
    required this.accentColor,
  });

  int get cycleDuration =>
      inhaleSeconds + holdSeconds + exhaleSeconds + holdOutSeconds;

  String get ratioLabel {
    final parts = <int>[inhaleSeconds];
    if (holdSeconds > 0) parts.add(holdSeconds);
    parts.add(exhaleSeconds);
    if (holdOutSeconds > 0) parts.add(holdOutSeconds);
    return parts.join('-');
  }
}

// ── Breathing phase ───────────────────────────────────────────────────────────

enum BreathPhase { idle, inhale, holdIn, exhale, holdOut }

// ── Pre-defined patterns ──────────────────────────────────────────────────────

const kForestAir = BreathPattern(
  name: 'Forest Air',
  tagline: 'Box breathing for deep calm',
  icon: Icons.forest_rounded,
  inhaleSeconds: 4,
  holdSeconds: 3,
  exhaleSeconds: 8,
  holdOutSeconds: 0,
  accentColor: AppColors.card, // soft forest green
);

const kTidalFlow = BreathPattern(
  name: 'Tidal Flow',
  tagline: 'Oceanic rhythm',
  icon: Icons.water_rounded,
  inhaleSeconds: 4,
  holdSeconds: 0,
  exhaleSeconds: 6,
  holdOutSeconds: 0,
  accentColor: AppColors.card, // soft forest green
);

const kEveningDew = BreathPattern(
  name: 'Evening Dew',
  tagline: 'Calm 4-7-4 method',
  icon: Icons.nights_stay_rounded,
  inhaleSeconds: 4,
  holdSeconds: 7,
  exhaleSeconds: 4,
  holdOutSeconds: 0,
  accentColor: AppColors.card, // soft forest green
);

const kMountainBreath = BreathPattern(
  name: 'Mountain Breath',
  tagline: 'High altitude clarity',
  icon: Icons.landscape_rounded,
  inhaleSeconds: 5,
  holdSeconds: 2,
  exhaleSeconds: 5,
  holdOutSeconds: 2,
  accentColor: AppColors.card, // soft forest green
);