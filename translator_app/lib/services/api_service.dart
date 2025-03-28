import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  // API url'sini .env dosyasından oku veya varsayılan değeri kullan
  final String baseUrl;
  
  ApiService({String? baseUrl}) 
      : this.baseUrl = baseUrl ?? dotenv.env['API_URL'] ?? 'http://localhost:8080/api';

  Future<String> translate({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/translate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': text,
          'source_lang': sourceLanguage,
          'target_lang': targetLanguage,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['error'] != null) {
          throw Exception(data['error']);
        }
        return data['translated_text'];
      } else {
        throw Exception('API hatası: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Çeviri API hatası: $e');
    }
  }

  Future<List<Map<String, String>>> getLanguages() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/languages'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((lang) => {
          'code': lang['code'],
          'name': lang['name'],
        }).toList();
      } else {
        throw Exception('Dil listesi alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Dil listesi API hatası: $e');
    }
  }

  Future<bool> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
} 