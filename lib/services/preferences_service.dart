import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService extends ChangeNotifier {
  static const String _keySound = 'sound_effects';
  static const String _keyHaptics = 'haptics';
  static const String _keyVolume = 'volume';
  static const String _keyQuestionsPerGame = 'questions_per_game';
  static const String _keyWheelStyle = 'wheel_style';

  bool _soundEnabled = true;
  bool _hapticsEnabled = true;
  double _volume = 0.8;
  int _questionsPerGame = 10;
  String _wheelStyle = 'Classic';

  bool get soundEnabled => _soundEnabled;
  bool get hapticsEnabled => _hapticsEnabled;
  bool get hapticEnabled => _hapticsEnabled;
  double get volume => _volume;
  int get questionsPerGame => _questionsPerGame;
  String get wheelStyle => _wheelStyle;

  PreferencesService() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool(_keySound) ?? true;
    _hapticsEnabled = prefs.getBool(_keyHaptics) ?? true;
    _volume = prefs.getDouble(_keyVolume) ?? 0.8;
    _questionsPerGame = prefs.getInt(_keyQuestionsPerGame) ?? 10;
    _wheelStyle = prefs.getString(_keyWheelStyle) ?? 'Classic';
    notifyListeners();
  }

  Future<void> toggleSound() async {
    _soundEnabled = !_soundEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySound, _soundEnabled);
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySound, _soundEnabled);
    notifyListeners();
  }

  Future<void> toggleHaptics() async {
    _hapticsEnabled = !_hapticsEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHaptics, _hapticsEnabled);
    notifyListeners();
  }

  Future<void> setHapticEnabled(bool value) async {
    _hapticsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHaptics, _hapticsEnabled);
    notifyListeners();
  }

  Future<void> setVolume(double value) async {
    _volume = value.clamp(0.0, 1.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyVolume, _volume);
    notifyListeners();
  }

  Future<void> setQuestionsPerGame(int value) async {
    _questionsPerGame = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyQuestionsPerGame, _questionsPerGame);
    notifyListeners();
  }

  Future<void> setWheelStyle(String value) async {
    _wheelStyle = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyWheelStyle, _wheelStyle);
    notifyListeners();
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    final sound = prefs.getBool(_keySound) ?? true;
    final haptics = prefs.getBool(_keyHaptics) ?? true;
    await prefs.clear();
    await prefs.setBool(_keySound, sound);
    await prefs.setBool(_keyHaptics, haptics);
    notifyListeners();
  }
}
