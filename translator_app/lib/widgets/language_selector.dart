import 'package:flutter/material.dart';

class LanguageSelector extends StatelessWidget {
  final String selectedLanguage;
  final ValueChanged<String> onChanged;

  const LanguageSelector({
    Key? key,
    required this.selectedLanguage,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedLanguage,
      isExpanded: true,
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
      items: const [
        DropdownMenuItem(
          value: 'TR',
          child: Text('Türkçe'),
        ),
        DropdownMenuItem(
          value: 'EN',
          child: Text('İngilizce'),
        ),
        DropdownMenuItem(
          value: 'DE',
          child: Text('Almanca'),
        ),
        DropdownMenuItem(
          value: 'FR',
          child: Text('Fransızca'),
        ),
        DropdownMenuItem(
          value: 'ES',
          child: Text('İspanyolca'),
        ),
        DropdownMenuItem(
          value: 'IT',
          child: Text('İtalyanca'),
        ),
      ],
    );
  }
} 