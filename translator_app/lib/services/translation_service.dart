import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/translation.dart';
import '../database/translation_db.dart';

class TranslationService {
  final String baseUrl = 'https://api-free.deepl.com/v2/translate';
  late final String apiKey;
  final TranslationDatabase _db = TranslationDatabase();

  TranslationService() {
    apiKey = dotenv.env['DEEPL_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      print('UYARI: DeepL API anahtarı bulunamadı!');
    }
  }

  Future<Translation> translateOnline({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'DeepL-Auth-Key $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'text': [text],
          'source_lang': sourceLanguage,
          'target_lang': targetLanguage,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final translatedText = data['translations'][0]['text'];
        
        final translation = Translation(
          originalText: text,
          translatedText: translatedText,
          sourceLanguage: sourceLanguage,
          targetLanguage: targetLanguage,
        );
        
        // Çeviriyi yerel veritabanına kaydet
        await _db.saveTranslation(translation);
        
        return translation;
      } else {
        throw Exception('Çeviri isteği başarısız: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Çeviri sırasında hata oluştu: $e');
    }
  }

  Future<Translation?> translateOffline({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    // Önce yerel veritabanında arama yap
    return await _db.findTranslation(text, sourceLanguage, targetLanguage);
  }

  Future<Translation> translate({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
    bool forceOnline = false,
  }) async {
    if (!forceOnline) {
      // Önce çevrim dışı çeviriyi dene
      final offlineTranslation = await translateOffline(
        text: text,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );
      
      if (offlineTranslation != null) {
        return offlineTranslation;
      }
    }
    
    // Çevrim dışı çeviri bulunamadıysa veya zorunlu çevrimiçi ise
    return await translateOnline(
      text: text,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
    );
  }
} 