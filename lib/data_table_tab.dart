// DataTableTab widget
import 'package:flutter/material.dart';
import 'utils/flashcards_collection.dart';
import 'constants.dart';

class DataTableTab extends StatefulWidget {
  final FlashcardsCollection flashcardsCollection;
  final Function() updateQuestionText;

  const DataTableTab({
    Key? key,
    required this.flashcardsCollection,
    required this.updateQuestionText,
  }) : super(key: key);

  @override
  State<DataTableTab> createState() => DataTableTabState();
}

class DataTableTabState extends State<DataTableTab> {
  List<Map<dynamic, dynamic>> data = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    List<Map<dynamic, dynamic>> fetchedData =
        await widget.flashcardsCollection.loadData();
    setState(() {
      data = fetchedData.where((row) => (row['sourceLang']) == TARGET_LANGUAGE).toList();
    });
  }

  void addRow(Map<dynamic, dynamic> row) {
    setState(() {
      data.insert(data.length-10, row);
    });
  }

  void removeRow(Map<dynamic, dynamic> row) {
    widget.flashcardsCollection.removeFlashcard(row['front'], row['back']);
    setState(() {
      data.removeAt(data.indexOf(row));
    });
  }

  void editRow(String? newText, Map<dynamic, dynamic> row, String key) {
    final front = row['front'];
    final back = row['back'];
    final newFront = key == 'front' ? newText : row['front'];
    final newBack = key == 'back' ? newText : row['back'];

    if (data.indexOf(row) != -1 && newText != null) {
      widget.flashcardsCollection.editFlashcard(front, back, newFront, newBack);
      setState(() {
        row[key] = newText;
      });
      widget.updateQuestionText();
    }
  }

  void _openEditPopup(Map<dynamic, dynamic> row, String key) {
    String? newText;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Modifier un mot'),
          content: TextField(
            controller: TextEditingController(text: row[key]),
            onChanged: (String value) {
              newText = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                editRow(newText, row, key);
                Navigator.of(context).pop();
              },
              child: const Text('Modifier'),
            ),
            TextButton(
              onPressed: () {
                _openConfirmPopup(row, context);
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  // Function that open a popup with "Ajouter un mot" title, and a text display with sourcLang next to a text input field. Same for the targetLang next to a text input field. There is 2 buttons : "Ajouter" and "Annuler". when clicked the "Ajouter popup", call the function "addFalshcard" of the flashcards_collection object
  void _openAddPopup() {
    
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
      double scaffoldHeight = constraints.maxHeight;
      return Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: PaginatedDataTable(
                  headingRowHeight: kMinInteractiveDimension,
                  columns: [
                    DataColumn(
                      label: SizedBox(
                        width: constraints.maxWidth * 0.35,
                        child: Text(LANGUAGES[TARGET_LANGUAGE]!),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: constraints.maxWidth * 0.35,
                        child: Text(LANGUAGES[SOURCE_LANGUAGE]!),
                      ),
                    ),
                  ],
                  rowsPerPage:
                      (scaffoldHeight.floor() / kMinInteractiveDimension.ceil())
                              .floor() -
                          3,
                  source: _DataSource(data, _openEditPopup),
                ),
              ),
            ),
            SizedBox(height: scaffoldHeight % kMinInteractiveDimension.ceil()),
            ElevatedButton(
              onPressed: _openAddPopup,
              child: Text('Ajouter un mot'),
            ),
          ],
        ),
      );
    });
  }
}

class _DataSource extends DataTableSource {
  final List<Map> data;
  final Function(Map<dynamic, dynamic>, String) _openEditPopup;

  _DataSource(this.data, this._openEditPopup);

  @override
  DataRow? getRow(int index) {
    final rowData = data[index];
    return DataRow(cells: [
      DataCell(GestureDetector(
          onTap: () {
            _openEditPopup(data[index], 'front');
          },
          child: Text(rowData['front']))),
      DataCell(GestureDetector(
          onTap: () {
            _openEditPopup(data[index], 'back');
          },
          child: Text(rowData['back']))),
    ]);
  }

  @override
  int get rowCount => data.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}    
    