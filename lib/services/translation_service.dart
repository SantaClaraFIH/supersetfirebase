import 'package:translator/translator.dart';

class TranslationService {
  TranslationService._();

  static final GoogleTranslator _translator = GoogleTranslator();

  /// Translates [texts] in order, returning translations in the same order.
  static Future<List<String>> translateList(
    List<String> texts, {
    String to = 'es',
  }) {
    return Future.wait(texts.map((text) => _translateSingle(text, to)));
  }

  /// Translates the values of [texts], preserving keys.
  static Future<Map<String, String>> translateMap(
    Map<String, String> texts, {
    String to = 'es',
  }) async {
    final keys = texts.keys.toList();
    final translations = await translateList(texts.values.toList(), to: to);
    return {for (var i = 0; i < keys.length; i++) keys[i]: translations[i]};
  }

  static Future<String> _translateSingle(String text, String to) async {
    if (text.trim().isEmpty) return text;
    final translation = await _translator.translate(text, to: to);
    return translation.text;
  }
}
