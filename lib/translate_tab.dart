// Translate tab widget with a language selector, a text field for the word to translate, a text label to display the translation and a button to translate the word.
import 'package:flutter/material.dart';
import 'utils/flashcards_collection.dart';
import 'utils/deepl_translator.dart'; // version traduction locale
import 'utils/server_connection.dart'; // version traduction serveur
import 'language_selection.dart';
import 'constants.dart';

class TranslateTab extends StatefulWidget {
  final FlashcardsCollection flashcardsCollection;
  final DeeplTranslator deeplTranslator; // Version traduction locale
  final ServerConnection serverConnection; // Version traduction serveur
  final Function(Map<dynamic, dynamic>) addRow;
  final Function() updateQuestionText;

  const TranslateTab({
    Key? key,
    required this.flashcardsCollection,
    required this.deeplTranslator, // Version traduction locale
    required this.serverConnection, // Version traduction serveur
    required this.addRow,
    required this.updateQuestionText,
  }) : super(key: key);

  @override
  State<TranslateTab> createState() => _TranslateTabState();
}

class _TranslateTabState extends State<TranslateTab> {
  final languageSelection = LanguageSelection();
  String _wordToTranslate = '';
  String _translatedWord = '';
  bool isTranslateButtonDisabled = false;
  bool isAddButtonDisabled = true;

  void _swapContent() {
    setState(() {
      final String tmp = languageSelection.sourceLanguage;
      languageSelection.sourceLanguage = languageSelection.targetLanguage;
      languageSelection.targetLanguage = tmp;
    });
  }

  Future<void> _translate() async {
    isTranslateButtonDisabled = true;
    try {
      String translation = await widget.deeplTranslator.translate(
        // Version traduction locale
        // String translation = await widget.serverConnection.translate( // Version traduction serveur
        _wordToTranslate,
        languageSelection.targetLanguage,
        languageSelection.sourceLanguage,
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
        'sourceLang': languageSelection.sourceLanguage,
        'targetLang': languageSelection.targetLanguage,
      });
      widget.flashcardsCollection.addFlashcard(
          _wordToTranslate,
          _translatedWord,
          languageSelection.sourceLanguage,
          languageSelection.targetLanguage);

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
                DropdownButton<String>(
                  value: languageSelection.sourceLanguage,
                  onChanged: (String? newValue) {
                    if (newValue != languageSelection.targetLanguage) {
                      setState(() {
                        languageSelection.sourceLanguage = newValue!;
                      });
                    }
                  },
                  items:
                      LANGUAGES.entries.map((MapEntry<String, String> entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      onTap: () {
                        if (languageSelection.targetLanguage == entry.key) {
                          return null;
                        }
                      },
                      enabled: languageSelection.targetLanguage !=
                          entry
                              .key, // Disable tapping on the item if it's the target language
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: 18.0,
                          color: languageSelection.targetLanguage == entry.key
                              ? Colors.grey
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _swapContent();
                    });
                  },
                  child: const Icon(Icons.swap_horiz),
                ),
                DropdownButton<String>(
                  value: languageSelection.targetLanguage,
                  onChanged: (String? newValue) {
                    if (newValue != languageSelection.sourceLanguage) {
                      setState(() {
                        languageSelection.targetLanguage = newValue!;
                      });
                    }
                  },
                  items:
                      LANGUAGES.entries.map((MapEntry<String, String> entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,

                      onTap: () {
                        if (languageSelection.sourceLanguage == entry.key) {
                          return null;
                        }
                      },
                      enabled: languageSelection.sourceLanguage !=
                          entry.key, // Enable tapping on all items
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: 18.0,
                          color: languageSelection.sourceLanguage == entry.key
                              ? Colors.grey
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            TextField(
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: 'Écrivez ou collez votre texte ici pour le traduire',
                border: OutlineInputBorder(),
                counterText: "",
              ),
              maxLength: 100,
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
