import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();
  SupabaseService._();

  SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    const url = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
    if (url.isEmpty || anonKey.isEmpty) {
      if (kDebugMode) print('[Supabase] Missing env vars — multiplayer disabled');
      return;
    }
    await Supabase.initialize(url: url, anonKey: anonKey);
  }

  static bool get isAvailable {
    try {
      Supabase.instance.client;
      return true;
    } catch (_) {
      return false;
    }
  }

  static String generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  Future<Map<String, dynamic>?> createRoom({
    required String hostName,
    required String gameMode,
  }) async {
    final code = generateRoomCode();
    final res = await client.from('rooms').insert({
      'code': code,
      'host_name': hostName,
      'game_mode': gameMode,
      'status': 'lobby',
      'game_state': {},
    }).select().single();
    await client.from('room_players').insert({
      'room_id': res['id'],
      'player_name': hostName,
      'is_host': true,
      'score': 0,
      'xp': 0,
    });
    return res;
  }

  Future<Map<String, dynamic>?> joinRoom({
    required String code,
    required String playerName,
  }) async {
    final room = await client
        .from('rooms')
        .select()
        .eq('code', code.toUpperCase())
        .eq('status', 'lobby')
        .maybeSingle();
    if (room == null) return null;
    await client.from('room_players').insert({
      'room_id': room['id'],
      'player_name': playerName,
      'is_host': false,
      'score': 0,
      'xp': 0,
    });
    return room;
  }

  Future<List<Map<String, dynamic>>> getRoomPlayers(String roomId) async {
    final res = await client
        .from('room_players')
        .select()
        .eq('room_id', roomId)
        .order('created_at');
    return List<Map<String, dynamic>>.from(res);
  }

  RealtimeChannel subscribeToRoom(String roomId, {
    required void Function(Map<String, dynamic>) onPlayersChanged,
    required void Function(Map<String, dynamic>) onRoomChanged,
  }) {
    return client
        .channel('room:$roomId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'room_players',
          filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'room_id',
              value: roomId),
          callback: (payload) => onPlayersChanged(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'rooms',
          filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'id',
              value: roomId),
          callback: (payload) => onRoomChanged(payload.newRecord),
        )
        .subscribe();
  }

  Future<void> updateRoomState(
      String roomId, Map<String, dynamic> state) async {
    await client.from('rooms').update({'game_state': state}).eq('id', roomId);
  }

  Future<void> startGame(String roomId) async {
    await client
        .from('rooms')
        .update({'status': 'playing'})
        .eq('id', roomId);
  }

  Future<void> leaveRoom(String roomId, String playerName) async {
    await client
        .from('room_players')
        .delete()
        .eq('room_id', roomId)
        .eq('player_name', playerName);
  }

  Future<void> closeRoom(String roomId) async {
    await client
        .from('rooms')
        .update({'status': 'closed'})
        .eq('id', roomId);
  }

  Future<void> updatePlayerScore(
      String roomId, String playerName, int score, int xp) async {
    await client
        .from('room_players')
        .update({'score': score, 'xp': xp})
        .eq('room_id', roomId)
        .eq('player_name', playerName);
  }
}
