import 'package:flutter/material.dart';

class CoupleLanguagesTable extends StatelessWidget {
  final List<Map<dynamic, dynamic>> data;
  final String sourceLanguage;
  final String targetLanguage;
  final Function(Map<dynamic, dynamic>, String) onCellTap;

  const CoupleLanguagesTable({super.key, 
    required this.data,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        columns: [
          DataColumn(
            label: SizedBox(
              width: MediaQuery.of(context).size.width * 0.35,
              child: Text(sourceLanguage),
            ),
          ),
          DataColumn(
            label: SizedBox(
              width: MediaQuery.of(context).size.width * 0.35,
              child: Text(targetLanguage),
            ),
          ),
        ],
        rows: data.map((rowData) {
          return DataRow(cells: [
            DataCell(GestureDetector(
              onTap: () => onCellTap(rowData, 'front'),
              child: Text(rowData['front']),
            )),
            DataCell(GestureDetector(
              onTap: () => onCellTap(rowData, 'back'),
              child: Text(rowData['back']),
            )),
          ]);
        }).toList(),
      ),
    );
  }
}