import '../models/todo_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('todos_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE todos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        isDone INTEGER
      )
    ''');
  }

  Future<void> insertTodoItem(TodoItem item) async {
    final db = await database;
    await db.insert(
      'todos',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TodoItem>> retrieveTodoItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('todos');

    return List.generate(maps.length, (i) {
      return TodoItem(
        id: maps[i]['id'],
        title: maps[i]['title'],
        description: maps[i]['description'],
        isDone: maps[i]['isDone'] == 1,
      );
    });
  }

  Future<void> updateTodoItem(TodoItem item) async {
    final db = await database;
    await db.update(
      'todos',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> deleteTodoItem(int id) async {
    final db = await database;
    await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}