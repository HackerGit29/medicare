import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final settingsProvider = StateNotifierProvider<SettingsNotifier, String>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<String> {
  SettingsNotifier() : super('fr') {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('app_language');
    if (lang != null) {
      state = lang;
    }
  }

  Future<void> setLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    state = langCode;
    await prefs.setString('app_language', langCode);
  }
}
