import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SessionRecord {
  final String id;
  final String mode;
  final DateTime playedAt;
  final List<String> players;
  final String winner;
  final String themeColor;

  SessionRecord({
    required this.id,
    required this.mode,
    required this.playedAt,
    required this.players,
    required this.winner,
    this.themeColor = 'purple',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'mode': mode,
        'playedAt': playedAt.toIso8601String(),
        'players': players,
        'winner': winner,
        'themeColor': themeColor,
      };

  factory SessionRecord.fromJson(Map<String, dynamic> json) => SessionRecord(
        id: json['id'] as String,
        mode: json['mode'] as String,
        playedAt: DateTime.parse(json['playedAt'] as String),
        players: List<String>.from(json['players'] as List<dynamic>),
        winner: json['winner'] as String,
        themeColor: json['themeColor'] as String? ?? 'purple',
      );
}

class SessionService {
  static const String _storageKey = 'cousin_chaos_sessions';

  static Future<void> saveSession(SessionRecord session) async {
    final prefs = await SharedPreferences.getInstance();
    final sessions = await loadSessions();
    sessions.insert(0, session);
    final encoded = jsonEncode(sessions.map((s) => s.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  static Future<List<SessionRecord>> loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((json) => SessionRecord.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
