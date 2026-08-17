import 'package:flutter/material.dart';

class PeriodSymptoms {
  static const List<({String code, String label, IconData icon})> all = [
    (code: 'cramps', label: '腹痛', icon: Icons.healing),
    (code: 'headache', label: '头痛', icon: Icons.psychology),
    (code: 'backache', label: '腰痛', icon: Icons.accessibility_new),
    (code: 'bloating', label: '腹胀', icon: Icons.circle),
    (code: 'breast_tenderness', label: '乳房胀痛', icon: Icons.favorite),
    (code: 'fatigue', label: '疲劳', icon: Icons.battery_1_bar),
    (code: 'insomnia', label: '失眠', icon: Icons.bedtime),
    (code: 'acne', label: '痘痘', icon: Icons.face),
    (code: 'nausea', label: '恶心', icon: Icons.sick),
    (code: 'appetite_change', label: '食欲变化', icon: Icons.restaurant),
    (code: 'dizziness', label: '头晕', icon: Icons.center_focus_strong),
    (code: 'mood_swings', label: '情绪波动', icon: Icons.mood),
  ];

  static String labelOf(String code) {
    final match = all.where((s) => s.code == code);
    return match.isNotEmpty ? match.first.label : code;
  }
}
