import 'package:flutter/material.dart';

class AllLanguagesTable extends StatelessWidget {
  final List<Map<dynamic, dynamic>> data;
  final Function(Map<dynamic, dynamic>, String) onCellTap;
  final Map<String, String> languages;

  const AllLanguagesTable({super.key, 
    required this.data,
    required this.onCellTap,
    required this.languages,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Source')),
          DataColumn(label: Text('Word')),
          DataColumn(label: Text('Translation')),
          DataColumn(label: Text('Target')),
        ],
        rows: data.map((rowData) {
          return DataRow(cells: [
            DataCell(Text(languages[rowData['sourceLang']] ?? 'Unknown')),
            DataCell(GestureDetector(
              onTap: () => onCellTap(rowData, 'front'),
              child: Text(rowData['front']),
            )),
            DataCell(GestureDetector(
              onTap: () => onCellTap(rowData, 'back'),
              child: Text(rowData['back']),
            )),
            DataCell(Text(languages[rowData['targetLang']] ?? 'Unknown')),
          ]);
        }).toList(),
      ),
    );
  }
}