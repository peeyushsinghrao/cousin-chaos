import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService extends ChangeNotifier {
  static const String _keySound = 'sound_effects';
  static const String _keyHaptics = 'haptics';
  
  bool _soundEnabled = true;
  bool _hapticsEnabled = true;

  bool get soundEnabled => _soundEnabled;
  bool get hapticsEnabled => _hapticsEnabled;

  PreferencesService() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool(_keySound) ?? true;
    _hapticsEnabled = prefs.getBool(_keyHaptics) ?? true;
    notifyListeners();
  }

  Future<void> toggleSound() async {
    _soundEnabled = !_soundEnabled;
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

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    // Keep settings, but clear game data
    final sound = prefs.getBool(_keySound) ?? true;
    final haptics = prefs.getBool(_keyHaptics) ?? true;
    
    await prefs.clear();
    
    await prefs.setBool(_keySound, sound);
    await prefs.setBool(_keyHaptics, haptics);
    notifyListeners();
  }
}
