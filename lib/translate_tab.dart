// Translate tab widget with a language selector, a text field for the word to translate, a text label to display the translation and a button to translate the word.
import 'package:flutter/material.dart';
import 'utils/flashcards_collection.dart';
import 'utils/deepl_translator.dart'; // version traduction précédente
import 'utils/server_connection.dart'; // version traduction modifiée

class TranslateTab extends StatefulWidget {
  final FlashcardsCollection flashcardsCollection;
  final DeeplTranslator deeplTranslator; // Version traduction précédente
  final ServerConnection serverConnection; // Version traduction modifiée
  final Function(Map<dynamic, dynamic>) addRow;
  final Function() updateQuestionText;

  const TranslateTab({
    Key? key,
    required this.flashcardsCollection,
    required this.deeplTranslator, // Version traduction précédente
    required this.serverConnection, // Version traduction modifiée
    required this.addRow,
    required this.updateQuestionText,
  }) : super(key: key);

  @override
  State<TranslateTab> createState() => _TranslateTabState();
}

class _TranslateTabState extends State<TranslateTab> {
  String _sourceLanguage = 'FR';
  String _targetLanguage = 'ES';
  String _wordToTranslate = '';
  String _translatedWord = '';
  bool isTranslateButtonDisabled = false;
  bool isAddButtonDisabled = true;

  void _swapContent() {
    setState(() {
      final String tmp = _sourceLanguage;
      _sourceLanguage = _targetLanguage;
      _targetLanguage = tmp;
    });
  }

  Future<void> _translate() async {
    isTranslateButtonDisabled = true;
    try {
      String translation = await widget.deeplTranslator.translate( // Version traduction précédente
      // String translation = await widget.serverConnection.translate( // Version traduction modifiée
        _wordToTranslate,
        _targetLanguage,
        _sourceLanguage,
      );
      isTranslateButtonDisabled = false;
      isAddButtonDisabled = false;

      setState(() {
        _translatedWord = translation;
      });
    } catch (e) {
      print('Error translating text: $e');
    }
  }

  Future<void> _addFlashcard() async {
    if (_wordToTranslate != '' &&
        _translatedWord != '' &&
        _translatedWord != 'Erreur de connexion' &&
        !await widget.flashcardsCollection
            .checkIfFlashcardExists(_wordToTranslate, _translatedWord)) {
      _wordToTranslate = _wordToTranslate.toLowerCase()[0].toUpperCase() +
          _wordToTranslate.toLowerCase().substring(1);
      _translatedWord = _translatedWord.toLowerCase()[0].toUpperCase() +
          _translatedWord.toLowerCase().substring(1);

      widget.addRow({
        'front': _wordToTranslate,
        'back': _translatedWord,
        'sourceLang': _sourceLanguage,
        'targetLang': _targetLanguage,
      });
      widget.flashcardsCollection.addFlashcard(
          _wordToTranslate, _translatedWord, _sourceLanguage, _targetLanguage);

      widget.updateQuestionText();
      setState(() {});
    }
    isAddButtonDisabled = true;
  }

  void _openPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Êtes-vous sûr ?'),
          actions: [
            TextButton(
              onPressed: () {
                _addFlashcard();
                Navigator.of(context).pop();
              },
              child: const Text('Oui'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Non'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _sourceLanguage,
                  style: const TextStyle(fontSize: 18.0),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _swapContent();
                    });
                  },
                  child: const Icon(Icons.swap_horiz),
                ),
                Text(
                  _targetLanguage,
                  style: const TextStyle(fontSize: 18.0),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            TextField(
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: 'Écrivez ou collez votre texte ici pour le traduire',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _wordToTranslate = value;
                });
              },
            ),
            const SizedBox(height: 16.0),
            Text(
              _translatedWord,
              style: const TextStyle(fontSize: 18.0),
            ),
            Expanded(
              child: Container(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                    child: ElevatedButton(
                  onPressed: isTranslateButtonDisabled
                      ? null
                      : () async {
                          _translate();
                        },
                  child: const Text('Traduire'),
                )),
                const SizedBox(width: 16.0),
                Expanded(
                    child: ElevatedButton(
                  onPressed: isAddButtonDisabled ? null : _openPopup,
                  child: const Text('Ajouter'),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
