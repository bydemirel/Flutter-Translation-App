import 'package:flutter/material.dart';
import '../models/translation.dart';
import '../database/translation_db.dart';

class HistoryList extends StatefulWidget {
  const HistoryList({Key? key}) : super(key: key);

  @override
  _HistoryListState createState() => _HistoryListState();
}

class _HistoryListState extends State<HistoryList> {
  final TranslationDatabase _db = TranslationDatabase();
  List<Translation> _translations = [];
  bool _showOnlyFavorites = false;

  @override
  void initState() {
    super.initState();
    _loadTranslations();
  }

  Future<void> _loadTranslations() async {
    List<Translation> translations;
    if (_showOnlyFavorites) {
      translations = await _db.getFavorites();
    } else {
      translations = await _db.getAllTranslations();
    }

    // Tarih sırasına göre sırala, en yeniler en üstte
    translations.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    setState(() {
      _translations = translations;
    });
  }

  Future<void> _toggleFavorite(Translation translation) async {
    await _db.toggleFavorite(
      translation.originalText,
      translation.sourceLanguage,
      translation.targetLanguage,
    );
    await _loadTranslations();
  }

  Future<void> _deleteTranslation(Translation translation) async {
    await _db.deleteTranslation(
      translation.originalText,
      translation.sourceLanguage,
      translation.targetLanguage,
    );
    await _loadTranslations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Çeviri Geçmişi'),
        actions: [
          IconButton(
            icon: Icon(_showOnlyFavorites
                ? Icons.favorite
                : Icons.favorite_border),
            onPressed: () {
              setState(() {
                _showOnlyFavorites = !_showOnlyFavorites;
                _loadTranslations();
              });
            },
          ),
        ],
      ),
      body: _translations.isEmpty
          ? const Center(child: Text('Henüz çeviri geçmişi yok'))
          : ListView.builder(
              itemCount: _translations.length,
              itemBuilder: (context, index) {
                final translation = _translations[index];
                return Dismissible(
                  key: Key('${translation.originalText}_${translation.sourceLanguage}_${translation.targetLanguage}'),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => _deleteTranslation(translation),
                  child: ListTile(
                    title: Text(translation.originalText),
                    subtitle: Text(
                      '${translation.translatedText}\n${translation.sourceLanguage} → ${translation.targetLanguage}',
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: Icon(
                        translation.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: translation.isFavorite ? Colors.red : null,
                      ),
                      onPressed: () => _toggleFavorite(translation),
                    ),
                  ),
                );
              },
            ),
    );
  }
} 