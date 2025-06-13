import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  factory DatabaseHelper() => instance;

  DatabaseHelper._internal();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final path = join(await getDatabasesPath(), 'database.sqlite');
    _database = await openDatabase(path, version: 2, onCreate: _onCreate);
    return _database!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        password TEXT NOT NULL,
        lastModified INTEGER,
        deleted INTEGER DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE clients (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        cpfCnpj TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        cep TEXT,
        address TEXT,
        neighborhood TEXT,
        city TEXT,
        state TEXT,
        lastModified INTEGER,
        deleted INTEGER DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        unit TEXT NOT NULL,
        stockQty REAL NOT NULL,
        price REAL NOT NULL,
        status INTEGER NOT NULL,
        cost REAL,
        barcode TEXT,
        lastModified INTEGER,
        deleted INTEGER DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE orders (
        id TEXT PRIMARY KEY,
        clientId TEXT,
        userId TEXT,
        total REAL,
        createdAt TEXT,
        lastModified INTEGER,
        deleted INTEGER DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE order_items (
        orderId TEXT,
        clientId TEXT,
        id TEXT,
        price REAL,
        productId TEXT,
        quantity REAL NOT NULL,
        total REAL NOT NULL,
        PRIMARY KEY(orderId, id)
      )
    ''');
    await db.execute('''
      CREATE TABLE order_payments ( 
        orderId TEXT,
        id TEXT,
        amount REAL,
        value REAL,
        PRIMARY KEY(orderId, id)
      )
    ''');
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
  }
}
