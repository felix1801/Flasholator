// HomePage widget with 3 tabs : Traduire, Réviser and Paquet
import 'dart:io';

import 'utils/deepl_translator.dart';  // version précédente
import 'utils/server_connection.dart'; // version modifiée
import 'package:flutter/material.dart';
import 'utils/flashcards_collection.dart';
import 'translate_tab.dart';
import 'review_tab.dart';
import 'data_table_tab.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';

class HomePage extends StatefulWidget {
  final FlashcardsCollection flashcardsCollection;
  final DeeplTranslator deeplTranslator; // version précédente
  final ServerConnection serverConnection; // version modifiée

  const HomePage(
      {Key? key,
      required this.flashcardsCollection,
      required this.deeplTranslator, // version précédente
      required this.serverConnection, // version modifiée
      })
      : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final dataTableTabKey = GlobalKey<DataTableTabState>();
  final reviewTabKey = GlobalKey<ReviewTabState>();

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
    requestPermissions(); // Call the requestPermissions() method here
  }
  }

  void dataTableTabFunction(Map<dynamic, dynamic> row) {
    dataTableTabKey.currentState?.addRow(row);
  }

  void reviewTabFunction() {
    reviewTabKey.currentState?.updateQuestionText();
  }

  Future<void> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage, // for read and write access
    ].request();

    PermissionStatus storageStatus = statuses[Permission.storage]!;
    if (storageStatus.isGranted) {
      // Permission granted, you can proceed with reading and writing
    } else {
      // Permission denied
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.translate)),
              Tab(icon: Icon(Icons.replay)),
              Tab(icon: Icon(Icons.folder)),
            ],
          ),
          title: const Text('Flasholator'),
        ),
        body: TabBarView(
          children: [
            TranslateTab(
                flashcardsCollection: widget.flashcardsCollection,
                deeplTranslator: widget.deeplTranslator, // version précédente
                serverConnection: widget.serverConnection, // version modifiée
                addRow: dataTableTabFunction,
                updateQuestionText: reviewTabFunction),
            ReviewTab(
                flashcardsCollection: widget.flashcardsCollection,
                key: reviewTabKey),
            DataTableTab(
              flashcardsCollection: widget.flashcardsCollection,
              key: dataTableTabKey,
              updateQuestionText: reviewTabFunction,
            )
          ],
        ),
      ),
    );
  }
}
