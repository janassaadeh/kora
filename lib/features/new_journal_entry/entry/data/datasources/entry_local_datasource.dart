import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/entry_draft.dart';

class EntryLocalDataSource {
  static const _keyExists = 'entry_draft_exists';
  static const _keyStep = 'entry_draft_step';
  static const _keyReasonNote = 'entry_draft_reason_note';
  static const _keyContextText = 'entry_draft_context_text';
  static const _keyReasons = 'entry_draft_reasons';
  static const _keyHeartRate = 'entry_draft_heart_rate';
  static const _keyActivity = 'entry_draft_activity';

  Future<void> saveDraft(EntryDraft draft) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_keyStep, draft.stepIndex);
    await prefs.setString(_keyReasonNote, draft.reasonNote);
    await prefs.setString(_keyContextText, draft.contextText);

    if (draft.selectedReasons.isNotEmpty) {
      await prefs.setStringList(
        _keyReasons,
        draft.selectedReasons.toList(),
      );
    } else {
      await prefs.remove(_keyReasons);
    }

    if (draft.heartRate != null) {
      await prefs.setInt(_keyHeartRate, draft.heartRate!);
    } else {
      await prefs.remove(_keyHeartRate);
    }

    if (draft.activityData != null) {
      await prefs.setString(
        _keyActivity,
        jsonEncode(draft.activityData),
      );
    } else {
      await prefs.remove(_keyActivity);
    }

    await prefs.setBool(_keyExists, true);
  }

  Future<EntryDraft?> loadDraft() async {
    final prefs = await SharedPreferences.getInstance();

    if (!(prefs.getBool(_keyExists) ?? false)) {
      return null;
    }

    Map<String, dynamic>? activityData;

    final activityJson = prefs.getString(_keyActivity);

    if (activityJson != null) {
      activityData = jsonDecode(activityJson);
    }

    return EntryDraft(
      stepIndex: prefs.getInt(_keyStep) ?? 0,
      reasonNote: prefs.getString(_keyReasonNote) ?? '',
      contextText: prefs.getString(_keyContextText) ?? '',
      selectedReasons:
          prefs.getStringList(_keyReasons)?.toSet() ??
              const {},
      heartRate: prefs.getInt(_keyHeartRate),
      activityData: activityData,
    );
  }

  Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_keyExists);
    await prefs.remove(_keyStep);
    await prefs.remove(_keyReasonNote);
    await prefs.remove(_keyContextText);
    await prefs.remove(_keyReasons);
    await prefs.remove(_keyHeartRate);
    await prefs.remove(_keyActivity);
  }
}