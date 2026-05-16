import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/player.dart';

class PlayerManager extends ChangeNotifier {
  static const String _storageKey = 'players_list';
  List<Player> _players = [];
  final Uuid _uuid = const Uuid();

  List<Player> get players => _players;
  int get playerCount => _players.length;

  PlayerManager() {
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? playersJson = prefs.getString(_storageKey);

    if (playersJson != null) {
      final List<dynamic> decodedList = jsonDecode(playersJson);
      _players = decodedList.map((json) => Player.fromJson(json)).toList();
    }

    // Default to 2 players if empty
    if (_players.isEmpty) {
      _players = [
        Player(id: _uuid.v4(), name: 'Player 1'),
        Player(id: _uuid.v4(), name: 'Player 2'),
      ];
      _savePlayers();
    }
    notifyListeners();
  }

  Future<void> _savePlayers() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = jsonEncode(_players.map((p) => p.toJson()).toList());
    await prefs.setString(_storageKey, encodedList);
  }

  void addPlayer() {
    if (_players.length >= 20) return;
    final newNumber = _players.length + 1;
    _players.add(Player(id: _uuid.v4(), name: 'Player $newNumber'));
    _savePlayers();
    notifyListeners();
  }

  void removePlayer(String id) {
    if (_players.length <= 2) return; // Minimum 2 players
    _players.removeWhere((p) => p.id == id);
    _savePlayers();
    notifyListeners();
  }

  void updatePlayerName(String id, String newName) {
    final index = _players.indexWhere((p) => p.id == id);
    if (index != -1) {
      _players[index].name = newName.isEmpty ? 'Player ${index + 1}' : newName;
      _savePlayers();
      notifyListeners();
    }
  }

  void updatePlayerSkipTokens(String id, int skipTokens) {
    final index = _players.indexWhere((p) => p.id == id);
    if (index != -1) {
      _players[index].skipTokens = skipTokens;
      _savePlayers();
      notifyListeners();
    }
  }

  void resetScores() {
    for (var player in _players) {
      player.score = 0;
    }
    notifyListeners();
  }

  void resetAllSkipTokens() {
    for (var player in _players) {
      player.skipTokens = 0;
    }
    _savePlayers();
    notifyListeners();
  }
}
