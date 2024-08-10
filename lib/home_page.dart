// HomePage widget with 3 tabs : Traduire, Réviser and Paquet
import 'dart:io';

import 'utils/deepl_translator.dart'; // version précédente
import 'utils/server_connection.dart'; // version modifiée
import 'package:flutter/material.dart';
import 'utils/flashcards_collection.dart';
import 'translate_tab.dart';
import 'review_tab.dart';
import 'data_table_tab.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  final FlashcardsCollection flashcardsCollection;
  final DeeplTranslator deeplTranslator; // version précédente
  final ServerConnection serverConnection; // version modifiée

  const HomePage({
    Key? key,
    required this.flashcardsCollection,
    required this.deeplTranslator, // version précédente
    required this.serverConnection, // version modifiée
  }) : super(key: key);

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

  void _launchEmail() async {
    String email = Uri.encodeComponent("felix.mortas@hotmail.fr");
    String subject = Uri.encodeComponent("Feedback pour Flasholator");
    String body = Uri.encodeComponent(
        "Bonjour, Les 2 fonctionnalités principales de cette application sont traduire puis réviser ce qu'on a traduit. Nous aimerions avoir ton avis sur l'application: nouveau nom, fonctionnalités, design, bugs, améliorations, zones d'ombre, idées, langues, intégration, accessibilité, lisibilité, ergonomie, etc. Merci d'avance pour ton retour ! L'équipe de Flasholator");
    Uri mail = Uri.parse("mailto:$email?subject=$subject&body=$body");
    if (await launchUrl(mail)) {
      //email app opened
    } else {
      //email app is not opened
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
          title: Row(
            children: [
              const Text('Flasholator'),
              const SizedBox(width: 8),
              IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            // Add your settings button logic here
          },
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
          onPressed: _launchEmail,
          style: ElevatedButton.styleFrom(
            primary:
                Colors.orange, // Couleur vive pour attirer l'attention
            onPrimary: Colors.white, // Couleur du texte
            padding: EdgeInsets.symmetric(
                horizontal: 16, vertical: 8), // Taille appropriée
            shape: RoundedRectangleBorder(
              borderRadius:
            BorderRadius.circular(8), // Bordures arrondies
            ),
            elevation: 5, // Effet de relief
          ),
          child: Row(
            children: [
              Icon(Icons.feedback, size: 18), // Icône pertinente
              SizedBox(width: 8), // Espace entre l'icône et le texte
              Text('Donner un feedback'), // Texte clair
            ],
          ),
              ),
            ),
          ],
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
