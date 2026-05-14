import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/impostor_word_pack.dart';

class ImpostorPackManager extends ChangeNotifier {
  static const String _storageKey = 'impostor_custom_packs';
  final Uuid _uuid = const Uuid();
  List<ImpostorWordPack> _customPacks = [];

  List<ImpostorWordPack> get customPacks => List.unmodifiable(_customPacks);

  ImpostorPackManager() {
    _loadCustomPacks();
  }

  Future<void> _loadCustomPacks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? stored = prefs.getString(_storageKey);
    if (stored != null) {
      final List<dynamic> decoded = jsonDecode(stored) as List<dynamic>;
      _customPacks = decoded.map((item) => ImpostorWordPack.fromJson(item as Map<String, dynamic>)).toList();
    }
    notifyListeners();
  }

  Future<void> _saveCustomPacks() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_customPacks.map((pack) => pack.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  void addPack(String title, List<String> words) {
    _customPacks.add(ImpostorWordPack(
      id: _uuid.v4(),
      title: title,
      words: List<String>.from(words),
      createdAt: DateTime.now(),
    ));
    _saveCustomPacks();
    notifyListeners();
  }

  void updatePack(ImpostorWordPack pack) {
    final index = _customPacks.indexWhere((item) => item.id == pack.id);
    if (index == -1) return;
    _customPacks[index] = pack;
    _saveCustomPacks();
    notifyListeners();
  }

  void removePack(String id) {
    _customPacks.removeWhere((pack) => pack.id == id);
    _saveCustomPacks();
    notifyListeners();
  }
}
