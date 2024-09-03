// language_selection.dart
class LanguageSelection {
  static final LanguageSelection _instance = LanguageSelection._internal();

  String sourceLanguage = 'FR';
  String targetLanguage = 'EN';

  factory LanguageSelection() {
    return _instance;
  }

  LanguageSelection._internal();

  static LanguageSelection getInstance() {
    return _instance;
  }
}