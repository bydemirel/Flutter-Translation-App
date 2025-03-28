import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/translation.dart';

class TranslationDatabase {
  static const String _boxName = 'translations';
  late Box<Translation> _box;
  
  Future<void> init() async {
    // Modelleri kaydet
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TranslationAdapter());
    }
    
    // Box'ı aç
    _box = await Hive.openBox<Translation>(_boxName);
  }

  Future<void> saveTranslation(Translation translation) async {
    // Çeviriyi bir anahtar olarak kullanacağımız benzersiz bir dizgi oluştur
    final key = '${translation.originalText}_${translation.sourceLanguage}_${translation.targetLanguage}';
    await _box.put(key, translation);
  }

  Future<Translation?> findTranslation(
    String text,
    String sourceLanguage,
    String targetLanguage,
  ) async {
    final key = '${text}_${sourceLanguage}_${targetLanguage}';
    return _box.get(key);
  }

  Future<List<Translation>> getAllTranslations() async {
    return _box.values.toList();
  }

  Future<List<Translation>> getFavorites() async {
    return _box.values.where((translation) => translation.isFavorite).toList();
  }

  Future<void> toggleFavorite(
    String text,
    String sourceLanguage,
    String targetLanguage,
  ) async {
    final key = '${text}_${sourceLanguage}_${targetLanguage}';
    final translation = _box.get(key);
    
    if (translation != null) {
      final updatedTranslation = Translation(
        originalText: translation.originalText,
        translatedText: translation.translatedText,
        sourceLanguage: translation.sourceLanguage,
        targetLanguage: translation.targetLanguage,
        timestamp: translation.timestamp,
        isFavorite: !translation.isFavorite,
      );
      
      await _box.put(key, updatedTranslation);
    }
  }

  Future<void> deleteTranslation(
    String text,
    String sourceLanguage,
    String targetLanguage,
  ) async {
    final key = '${text}_${sourceLanguage}_${targetLanguage}';
    await _box.delete(key);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }
} 