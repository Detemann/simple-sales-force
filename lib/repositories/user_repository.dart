import 'package:sqflite/sqflite.dart';
import '../models/user.dart';

class UserRepository {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbDir = await getDatabasesPath();
    final path = '$dbDir/database.sqlite';
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            password TEXT NOT NULL,
            lastModified INTEGER,
            deleted INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }

  Future<void> insertUser(User user) async {
    final db = await database;
    await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<User?> getUserById(String id) async {
    final db = await database;
    final result = await db.query('users', where: 'id = ? AND deleted = 0', whereArgs: [id]);
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  Future<User?> authenticate(String id, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'name = ? AND password = ? AND deleted = 0',
      whereArgs: [id, password],
    );
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  Future<void> updateUser(User user) async {
    final db = await database;
    await db.update('users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
  }

  Future<void> softDeleteUser(String id) async {
    final db = await database;
    await db.update(
      'users',
      {'deleted': 1, 'lastModified': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<User>> getAllUsers() async {
    final db = await database;
    final result = await db.query('users', where: 'deleted = 0');
    return result.map((e) => User.fromMap(e)).toList();
  }
}
