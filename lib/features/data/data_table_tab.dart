// DataTableTab widget
import 'package:flutter/material.dart';
import '../../core/services/flashcards/flashcards_collection.dart';
import '../shared/utils/language_selection.dart';
import '../../config/constants.dart';
import 'widgets/all_languages_table.dart';
import 'widgets/couple_languages_table.dart';
import 'widgets/edit_popup.dart'; 

// Add doc comments
class DataTableTab extends StatefulWidget {
  final FlashcardsCollection flashcardsCollection;
  final Function() updateQuestionText;
  final ValueNotifier<bool> isAllLanguagesToggledNotifier;


  const DataTableTab({
    Key? key,
    required this.flashcardsCollection,
    required this.updateQuestionText,
    required this.isAllLanguagesToggledNotifier,
  }) : super(key: key);

  @override
  State<DataTableTab> createState() => DataTableTabState();
}

class DataTableTabState extends State<DataTableTab> {
  List<Map<dynamic, dynamic>> data = [];
  LanguageSelection languageSelection = LanguageSelection.getInstance();

  @override
  void initState() {
    super.initState();
    _fetchData(widget.isAllLanguagesToggledNotifier.value);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void updateSwitchState(bool newValue) {
    setState(() {
      widget.isAllLanguagesToggledNotifier.value = newValue;
    });
  }

  Future<void> _fetchData(bool isAllLanguagesToggled) async {
    List<Map<dynamic, dynamic>> fetchedData =
        await widget.flashcardsCollection.loadData();
    setState(() {
      if (isAllLanguagesToggled) {
        data = fetchedData.where((row) => fetchedData.indexOf(row) % 2 == 0).toList();
      } else {
        data = fetchedData
          .where((row) =>
              row['sourceLang'] == languageSelection.sourceLanguage &&
              row['targetLang'] == languageSelection.targetLanguage)
          .toList();
      }
    });
  }

  void addRow(Map<dynamic, dynamic> row) {
    setState(() {
      data.add(row);
    });
  }

  void removeRow(Map<dynamic, dynamic> row) {
    widget.flashcardsCollection.removeFlashcard(row['front'], row['back']);
    setState(() {
      data.removeAt(data.indexOf(row));
    });
  }

  void editRow(String? newText, Map<dynamic, dynamic> row, String face) {
    final front = row['front'];
    final back = row['back'];
    final newFront = face == 'front' ? newText : row['front'];
    final newBack = face == 'back' ? newText : row['back'];

    if (data.contains(row) && newText != null) {
      widget.flashcardsCollection.editFlashcard(front, back, newFront, newBack);
      setState(() {
        row[face] = newText;
      });
      widget.updateQuestionText();
    }
  }

  void _openEditPopup(Map<dynamic, dynamic> row, String face) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditPopup(
        row: row,
        face: face,
        onEdit: editRow, // Assurez-vous que editRow est définie dans votre fichier principal
        onDelete: _openConfirmPopup, // Assurez-vous que _openConfirmPopup est définie dans votre fichier principal
      );

      },
    );
  }

  void _addFlashcard(String front, String back) {
    widget.flashcardsCollection.addFlashcard(front, back,
        languageSelection.sourceLanguage, languageSelection.targetLanguage);
    addRow({'front': front, 'back': back});
  }

  void _openAddPopup() {
    String? front;
    String? back;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajouter un mot'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(LANGUAGES[languageSelection.sourceLanguage]!),
                  Expanded(
                    child: TextField(
                      onChanged: (String value) {
                        front = value;
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(LANGUAGES[languageSelection.targetLanguage]!),
                  Expanded(
                    child: TextField(
                      onChanged: (String value) {
                        back = value;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (front != null &&
                    back != null &&
                    front!.isNotEmpty &&
                    back!.isNotEmpty) {
                  _addFlashcard(front!, back!);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Ajouter'),
            ),
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: const Text('Annuler'),
            ),
          ],
        );
      },
    );
  }

  void _openConfirmPopup(
      Map<dynamic, dynamic> row, BuildContext parentContext) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Es-tu sûr ?'),
          actions: [
            TextButton(
              onPressed: () {
                removeRow(row);
                Navigator.of(parentContext).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Oui'),
            ),
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: const Text('Non'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
              ValueListenableBuilder<bool>(
                valueListenable: widget.isAllLanguagesToggledNotifier,
                builder: (context, value, child) {
                  return Switch(
                    value: value,
                    onChanged: (bool newValue) {
                      widget.isAllLanguagesToggledNotifier.value = newValue;
                      _fetchData(newValue);
                    },
                  );
                },
              ),
            Expanded(
              child: ValueListenableBuilder<bool>(
                valueListenable: widget.isAllLanguagesToggledNotifier,
                builder: (context, isAllLanguagesToggled, child) {
                  if (isAllLanguagesToggled) {
                    return AllLanguagesTable(
                      data: data,
                      onCellTap: _openEditPopup,
                      languages: LANGUAGES,
                    );
                  } else {
                    return CoupleLanguagesTable(
                      data: data,
                      sourceLanguage: LANGUAGES[languageSelection.sourceLanguage]!,
                      targetLanguage: LANGUAGES[languageSelection.targetLanguage]!,
                      onCellTap: _openEditPopup,
                    );
                  }
                },
              ),
            ),
            ElevatedButton(
              onPressed: _openAddPopup,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Ajouter un mot'),
            ),
          ],
        ),
      );
    });
  }
}