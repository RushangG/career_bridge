import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Get the path to the database file
    final path = join(await getDatabasesPath(), 'user_database.db');
    print('Database path: $path'); // Debugging line

    return openDatabase(
      path,
      onCreate: (db, version) {
        print('Creating database and tables...'); // Debugging line
        return db.execute(
          "CREATE TABLE users(email TEXT PRIMARY KEY, password TEXT, name TEXT, username TEXT, phone TEXT, role TEXT)",
        );
      },
      version: 1,
    );
  }

  Future<void> insertUser(User user) async {
    final db = await database;
    try {
      await db.insert(
        'users',
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('User inserted successfully'); // Debugging line
    } catch (e) {
      print('Error inserting user: $e'); // Debugging line
    }
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (maps.isNotEmpty) {
        return User.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('Error retrieving user: $e'); // Debugging line
      return null;
    }
  }
}
