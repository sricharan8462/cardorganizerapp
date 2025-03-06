import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('card_organizer.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE folders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE cards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        suit TEXT NOT NULL,
        image_url TEXT,
        folder_id INTEGER NOT NULL,
        FOREIGN KEY (folder_id) REFERENCES folders (id) ON DELETE CASCADE
      )
    ''');

    // Insert default folders when the database is created
    await _insertDefaultFolders(db);
  }

  Future<void> _insertDefaultFolders(Database db) async {
    List<String> folderNames = ["Hearts", "Spades", "Diamonds", "Clubs"];

    for (String name in folderNames) {
      await db.insert('folders', {
        'name': name,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  // CRUD Operations for Cards
  Future<int> addCard(
    String name,
    String suit,
    String imageUrl,
    int folderId,
  ) async {
    final db = await instance.database;
    return await db.insert('cards', {
      'name': name,
      'suit': suit,
      'image_url': imageUrl,
      'folder_id': folderId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getCards(int folderId) async {
    final db = await instance.database;
    return await db.query(
      'cards',
      where: 'folder_id = ?',
      whereArgs: [folderId],
    );
  }

  Future<int> updateCard(
    int id,
    String name,
    String suit,
    String imageUrl,
    int folderId,
  ) async {
    final db = await instance.database;
    return await db.update(
      'cards',
      {
        'name': name,
        'suit': suit,
        'image_url': imageUrl,
        'folder_id': folderId,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCard(int id) async {
    final db = await instance.database;
    return await db.delete('cards', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD Operations for Folders
  Future<int> addFolder(String name) async {
    final db = await instance.database;
    return await db.insert('folders', {
      'name': name,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getFolders() async {
    final db = await instance.database;
    return await db.query('folders');
  }

  Future<int> deleteFolder(int id) async {
    final db = await instance.database;
    return await db.delete('folders', where: 'id = ?', whereArgs: [id]);
  }
}
