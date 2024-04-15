import 'dart:convert';
import 'package:http/http.dart' as http;

class ServerConnection {
  Future<String> translate(
      String text, String sourceLang, String targetLang) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/translate'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'text': text,
        'source_lang': sourceLang,
        'target_lang': targetLang,
      }),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return result['translation'];
    } else {
      throw Exception('Failed to translate text');
    }
  }
}
