import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../models/app_user_model.dart';
import '../models/task_model.dart';
import 'database_initializer_stub.dart'
    if (dart.library.io) 'database_initializer_io.dart'
    if (dart.library.js_interop) 'database_initializer_web.dart'
    as initializer;

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();

  DatabaseService._init();

  Future<Database>? _database;

  Future<Database> get database async {
    _database ??= _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    initializer.initializeSqliteFactory();
    final databasesPath = await getDatabasesPath();
    return openDatabase(
      path.join(databasesPath, 'todo.db'),
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL COLLATE NOCASE UNIQUE,
            password_hash TEXT NOT NULL,
            password_salt TEXT NOT NULL
          )
        ''');
        await database.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            title TEXT NOT NULL,
            description TEXT NOT NULL DEFAULT '',
            is_completed INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  Future<AppUser?> getUserByEmail(String email) async {
    final database = await this.database;
    final rows = await database.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return AppUser.fromMap(rows.first);
  }

  Future<AppUser> createUser({
    required String name,
    required String email,
    required String passwordHash,
    required String passwordSalt,
  }) async {
    final database = await this.database;
    final id = await database.insert('users', {
      'name': name,
      'email': email,
      'password_hash': passwordHash,
      'password_salt': passwordSalt,
    });
    return AppUser(
      id: id,
      name: name,
      email: email,
      passwordHash: passwordHash,
      passwordSalt: passwordSalt,
    );
  }

  Future<void> createTask(Task task) async {
    final database = await this.database;
    await database.insert('tasks', task.toMap());
  }

  Future<List<Task>> getTasksByUser(int userId) async {
    final database = await this.database;
    final rows = await database.query(
      'tasks',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
    return rows.map(Task.fromMap).toList();
  }

  Future<void> updateTask(Task task) async {
    final id = task.id;
    if (id == null) {
      throw StateError('Não é possível atualizar uma tarefa sem identificação.');
    }

    final database = await this.database;
    await database.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteTask(int id) async {
    final database = await this.database;
    await database.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
