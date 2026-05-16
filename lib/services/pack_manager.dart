import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/pack.dart';
import '../core/constants/pack_data.dart';

class PackManager extends ChangeNotifier {
  static const String _storageKey = 'custom_packs_list';
  List<Pack> _customPacks = [];
  final Set<String> _selectedPackIds = {};
  final Uuid _uuid = const Uuid();

  List<Pack> get customPacks => _customPacks;
  List<Pack> get defaultPacks => PackData.defaultPacks;
  Set<String> get selectedPackIds => _selectedPackIds;

  List<Pack> get allPacks => [...defaultPacks, ..._customPacks];

  PackManager() {
    _loadCustomPacks();
  }

  Future<void> _loadCustomPacks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? packsJson = prefs.getString(_storageKey);
    if (packsJson != null) {
      final List<dynamic> decodedList = jsonDecode(packsJson);
      _customPacks = decodedList.map((json) => Pack.fromJson(json)).toList();
    }
    notifyListeners();
  }

  Future<void> _saveCustomPacks() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = jsonEncode(_customPacks.map((p) => p.toJson()).toList());
    await prefs.setString(_storageKey, encodedList);
  }

  void togglePackSelection(String packId) {
    if (_selectedPackIds.contains(packId)) {
      _selectedPackIds.remove(packId);
    } else {
      _selectedPackIds.add(packId);
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedPackIds.clear();
    notifyListeners();
  }

  bool isSelected(String packId) => _selectedPackIds.contains(packId);

  /// Returns true if at least one selected pack is 18+
  bool get hasAny18PlusSelected {
    for (var pack in allPacks) {
      if (_selectedPackIds.contains(pack.id) && pack.is18Plus) return true;
    }
    return false;
  }

  /// Merge all selected packs into one shuffled deck
  List<GameCardPrompt> getMergedDeck() {
    final List<GameCardPrompt> deck = [];
    for (var pack in allPacks) {
      if (_selectedPackIds.contains(pack.id)) {
        deck.addAll(pack.prompts);
      }
    }
    deck.shuffle();
    return deck;
  }

  // ── Custom Pack Management ──

  void addCustomPack(String title) {
    _customPacks.add(Pack(
      id: _uuid.v4(),
      title: title,
      description: 'Your custom Truth & Dare pack.',
      emoji: '✏️',
      isCustom: true,
      prompts: [],
    ));
    _saveCustomPacks();
    notifyListeners();
  }

  void addPromptToCustomPack(String packId, String text, String type) {
    final index = _customPacks.indexWhere((p) => p.id == packId);
    if (index != -1) {
      _customPacks[index].prompts.add(GameCardPrompt(
        id: _uuid.v4(),
        text: text,
        type: type,
      ));
      _saveCustomPacks();
      notifyListeners();
    }
  }

  void removePromptFromCustomPack(String packId, String promptId) {
    final index = _customPacks.indexWhere((p) => p.id == packId);
    if (index != -1) {
      _customPacks[index].prompts.removeWhere((p) => p.id == promptId);
      _saveCustomPacks();
      notifyListeners();
    }
  }

  void removeCustomPack(String id) {
    _customPacks.removeWhere((p) => p.id == id);
    _selectedPackIds.remove(id);
    _saveCustomPacks();
    notifyListeners();
  }
}
