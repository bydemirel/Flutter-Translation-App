import 'package:flutter/material.dart';
import '../services/translation_service.dart';
import '../models/translation.dart';
import '../widgets/language_selector.dart';
import '../widgets/history_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TranslationService _translationService = TranslationService();
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  
  String _sourceLanguage = 'TR';
  String _targetLanguage = 'EN';
  bool _isTranslating = false;
  bool _isOnline = true;

  @override
  void dispose() {
    _sourceController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _translate() async {
    final text = _sourceController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isTranslating = true;
    });

    try {
      final translation = await _translationService.translate(
        text: text,
        sourceLanguage: _sourceLanguage,
        targetLanguage: _targetLanguage,
        forceOnline: _isOnline,
      );

      setState(() {
        _targetController.text = translation.translatedText;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Çeviri hatası: $e')),
      );
    } finally {
      setState(() {
        _isTranslating = false;
      });
    }
  }

  void _swapLanguages() {
    setState(() {
      final tempLang = _sourceLanguage;
      _sourceLanguage = _targetLanguage;
      _targetLanguage = tempLang;

      final tempText = _sourceController.text;
      _sourceController.text = _targetController.text;
      _targetController.text = tempText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Çeviri Uygulaması'),
        actions: [
          Switch(
            value: _isOnline,
            onChanged: (value) {
              setState(() {
                _isOnline = value;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HistoryList(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: LanguageSelector(
                    selectedLanguage: _sourceLanguage,
                    onChanged: (value) {
                      setState(() {
                        _sourceLanguage = value;
                      });
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.swap_horiz),
                  onPressed: _swapLanguages,
                ),
                Expanded(
                  child: LanguageSelector(
                    selectedLanguage: _targetLanguage,
                    onChanged: (value) {
                      setState(() {
                        _targetLanguage = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _sourceController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Çevrilecek metni girin',
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isTranslating ? null : _translate,
              child: _isTranslating
                  ? const CircularProgressIndicator()
                  : const Text('Çevir'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _targetController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Çeviri sonucu',
              ),
              maxLines: 5,
              readOnly: true,
            ),
          ],
        ),
      ),
    );
  }
} 