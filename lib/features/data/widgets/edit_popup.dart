import 'package:flutter/material.dart';
import '../../../../config/constants.dart';

class EditPopup extends StatefulWidget {
  final Map<dynamic, dynamic> row;
  final Function(Map<String, String>, Map<dynamic, dynamic>) onEdit;
  final Function(Map<dynamic, dynamic>) onDelete;
  final bool languageDropdownEnabled;

  EditPopup({
    required this.row,
    required this.onEdit,
    required this.onDelete,
    required this.languageDropdownEnabled,
  });

  @override
  _EditPopupState createState() => _EditPopupState();
}

class _EditPopupState extends State<EditPopup> {
  late String _sourceLanguage;
  late String _word;
  late String _translation;
  late String _targetLanguage;

  @override
  void initState() {
    super.initState();
    _sourceLanguage = widget.row['sourceLang'];
    _word = widget.row['front'];
    _translation = widget.row['back'];
    _targetLanguage = widget.row['targetLang'];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifier la ligne'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildInputRow(
            'Langue source',
            _sourceLanguage,
            (value) => _sourceLanguage = value!,
            _word,
            (value) => _word = value,
            widget.languageDropdownEnabled,
          ),
          _buildInputRow(
            'Langue cible',
            _targetLanguage,
            (value) => _targetLanguage = value!,
            _translation,
            (value) => _translation = value,
            widget.languageDropdownEnabled,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onEdit({
              'sourceLang': _sourceLanguage,
              'front': _word,
              'back': _translation,
              'targetLang': _targetLanguage,
            }, widget.row);
            Navigator.of(context).pop();
          },
          child: const Text('Modifier'),
        ),
        TextButton(
          onPressed: () {
            widget.onDelete(widget.row);
            Navigator.of(context).pop();
          },
          child: const Text('Supprimer'),
        ),
      ],
    );
  }

  Widget _buildInputRow(
    String languageLabel,
    String languageValue,
    Function(String?) onLanguageChanged,
    String textValue,
    Function(String) onTextChanged,
    bool languageDropdownEnabled,
  ) {
    return Row(
      children: [
        Text('$languageLabel: '),
        DropdownButton<String>(
          value: languageValue,
          onChanged: languageDropdownEnabled ? (String? newValue) {
            if (newValue != null) {
              onLanguageChanged(newValue);
              // Mettre à jour l'interface utilisateur
              setState(() {
                languageValue = newValue;
              });
            }
          } : null,
          items: LANGUAGES.keys.map((String key) { // Utilisez les clés de LANGUAGES
            return DropdownMenuItem<String>(
              value: key, // La valeur passée est la clé (code à deux lettres)
              child: Text(LANGUAGES[key]!), // Affichez le nom complet de la langue
            );
          }).toList(),
        ),
        Expanded(
          child: TextField(
            controller: TextEditingController(text: textValue),
            onChanged: onTextChanged,
          ),
        ),
      ],
    );
  }
}