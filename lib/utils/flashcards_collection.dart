import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'flashcard.dart';

class FlashcardsCollection {
  static const String _dbName = 'flashcards.db';
  static const String table = 'flashcards';
  static const int _dbVersion = 1;
  late Database _database;

  FlashcardsCollection() {
    // Call the _initDatabase() method on build
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    // Initialize the database
    sqfliteFfiInit(); // Initialize the ffi loader, essential ?
    databaseFactory =
        databaseFactoryFfi; // Set the database factory to ffi, essential ?

    String dbPath;
    if (Platform.isLinux) {
      dbPath = _dbName;
    } else {
      final appDocDir = await getApplicationDocumentsDirectory();
      dbPath = join(appDocDir.path, _dbName);
    }
    print(dbPath); // Print the path of the database (for debugging purposes
    // Open the database
    _database = await openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Create the database if it doesn't exist
    await db.execute('''
      CREATE TABLE flashcards (
        id INTEGER PRIMARY KEY,
        front TEXT,
        back TEXT,
        sourceLang TEXT,
        targetLang TEXT,
        quality INTEGER,
        easiness REAL,
        interval INTEGER,
        repetitions INTEGER,
        timesReviewed INTEGER,
        lastReviewDate TEXT,
        nextReviewDate TEXT,
        addedDate TEXT
      )
    ''');
  }

  Future<List<Flashcard>> _loadFlashcards() async {
    // Load all flashcards from the database and convert it to Flashcard objects
    List<Map<String, dynamic>> queryResult = await _database.query(table);
    List<Flashcard> flashcards = queryResult.map((row) {
      return Flashcard.fromMap(row);
    }).toList();

    return flashcards;
  }

  Future<void> addFlashcard(
    String front,
    String back,
    String sourceLang,
    String targetLang,
  ) async {
    if (await checkIfFlashcardExists(front, back) ||
        front == '' ||
        back == '') {
      print('return');
      return;
    }

    // Add a flashcard and its reversed to the database
    final Flashcard flashcard = Flashcard(
      front: front,
      back: back,
      sourceLang: sourceLang,
      targetLang: targetLang,
    );

    final Flashcard reversedFlashcard = Flashcard(
      front: back,
      back: front,
      sourceLang: targetLang,
      targetLang: sourceLang,
    );

    await _database.insert(table, flashcard.toMap());
    await _database.insert(table, reversedFlashcard.toMap());
  }

  void removeFlashcard(String front, String back) async {
    // Remove a flashcard and its reversed from the database
    await _database.delete(
      table,
      where: '(front = ? AND back = ?) OR (front = ? AND back = ?)',
      whereArgs: [front, back, back, front],
    );
  }

  void editFlashcard(
      String front, String back, String newFront, String newBack) async {
    // Edit a flashcard and its reversed in the database
    await _database.transaction((txn) async {
      // With _database.transaction((txn)), update the front and back of the cards as a unique request to the database. If one fails, the other will not be executed.
      await txn.update(
        table,
        {'front': newFront, 'back': newBack},
        where: 'front = ? AND back = ?',
        whereArgs: [front, back],
      );
      await txn.update(
        table,
        {'front': newBack, 'back': newFront},
        where: 'front = ? AND back = ?',
        whereArgs: [back, front],
      );
    });
  }

  Future<List<Map>> loadData() async {
    // Get all words from the database
    List<Map<dynamic, dynamic>> data = [];

    List<Map> queryResult = await _database.query(
      'flashcards',
    );
    for (Map<dynamic, dynamic> row in queryResult) {
      Map<dynamic, dynamic> rowMap = Map<dynamic, dynamic>.from(row);
      data.add(rowMap);
    }

    return data;
  }

  Future<bool> checkIfFlashcardExists(String front, String back) async {
    // Check if a flashcard with the same front and back already exists in the database
    final queryResult = await _database.query(
      table,
      where: 'front = ? AND back = ?',
      whereArgs: [front, back],
    );

    return queryResult.isNotEmpty;
  }

  Future<List<Flashcard>> dueFlashcards() async {
    // Get all due flashcards from the database
    List<Flashcard> flashcards = await _loadFlashcards();

    List<Flashcard> dueFlashcards =
        flashcards.where((flashcard) => flashcard.isDue()).toList();
    dueFlashcards.shuffle();

    return dueFlashcards;
  }

  Future<void> review(String front, String back, int quality) async {
    // Review a flashcard and update it in the database
    List<Map<String, dynamic>> queryResult = await _database.query(
      table,
      where: 'front = ? AND back = ?',
      whereArgs: [front, back],
    );

    Map<String, dynamic> row = queryResult.first;
    Flashcard flashcard = Flashcard.fromMap(row);

    flashcard.review(quality);

    await _database.update(
      'flashcards',
      flashcard.toMap(),
      where: 'id = ?',
      whereArgs: [flashcard.id],
    );
  }
}
