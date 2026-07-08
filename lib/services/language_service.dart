import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const String _isArabicKey = 'isArabic';
  static bool _isArabic = false;

  static bool get isArabic => _isArabic;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isArabic = prefs.getBool(_isArabicKey) ?? false;
  }

  static Future<void> setLanguage(bool isArabic) async {
    _isArabic = isArabic;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isArabicKey, isArabic);
  }

  static Future<void> toggleLanguage() async {
    await setLanguage(!_isArabic);
  }

  static String getText(String french, String arabic) {
    return _isArabic ? arabic : french;
  }
}
