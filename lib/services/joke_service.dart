import 'dart:convert';
import 'package:http/http.dart' as http;

class JokeService {
  static Future<String> getJoke(String url) async {
    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Accept': 'application/json',
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['joke'] ?? data['setup'] + ' ' + data['delivery'];
      } else {
        return 'Failed to fetch joke.';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }
}
