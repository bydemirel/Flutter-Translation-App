import 'package:hive/hive.dart';

part 'translation.g.dart';

@HiveType(typeId: 0)
class Translation {
  @HiveField(0)
  final String originalText;

  @HiveField(1)
  final String translatedText;

  @HiveField(2)
  final String sourceLanguage;

  @HiveField(3)
  final String targetLanguage;

  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  final bool isFavorite;

  Translation({
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    DateTime? timestamp,
    this.isFavorite = false,
  }) : this.timestamp = timestamp ?? DateTime.now();
} 