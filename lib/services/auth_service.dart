import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';

import '../models/user.dart';
import 'database_service.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

class _ResetCode {
  final String code;
  final DateTime expiresAt;
  _ResetCode(this.code, this.expiresAt);
}

/// Authentication on top of the local SQLite database.
/// Passwords are never stored in clear text: SHA-256 with a random salt.
class AuthService {
  final DatabaseService _dbService;
  bool _seeded = false;
  final Map<String, _ResetCode> _resetCodes = {};

  AuthService({DatabaseService? db})
      : _dbService = db ?? DatabaseService.instance;

  Future<Database> get _db async {
    final db = await _dbService.database;
    if (!_seeded) {
      _seeded = true;
      await _seedDemoAccounts(db);
    }
    return db;
  }

  // ---------------------------------------------------------------- helpers

  String _newSalt() {
    final rnd = Random.secure();
    return base64Url.encode(List<int>.generate(16, (_) => rnd.nextInt(256)));
  }

  String _hash(String password, String salt) =>
      sha256.convert(utf8.encode('$salt$password')).toString();

  String _normalize(String email) => email.trim().toLowerCase();

  Future<int> _insert(Database db, String name, String email, String password,
      UserRole role) {
    final salt = _newSalt();
    return db.insert('users', {
      'name': name,
      'email': _normalize(email),
      'password_hash': _hash(password, salt),
      'salt': salt,
      'role': role.name,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Two test accounts created the first time the database is empty.
  Future<void> _seedDemoAccounts(Database db) async {
    final count =
    Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM users'));
    if (count == 0) {
      await _insert(db, 'Client Demo', 'client@demo.com', '123456', UserRole.client);
      await _insert(db, 'Pro Demo', 'pro@demo.com', '123456', UserRole.pro);
    }
  }

  // -------------------------------------------------------------- public API

  Future<User> signIn(String email, String password) async {
    final db = await _db;
    final rows = await db.query('users',
        where: 'email = ?', whereArgs: [_normalize(email)], limit: 1);
    if (rows.isEmpty ||
        _hash(password, rows.first['salt'] as String) !=
            rows.first['password_hash']) {
      throw AuthException('E-mail ou mot de passe incorrect.');
    }
    return User.fromMap(rows.first);
  }

  Future<User> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final db = await _db;
    try {
      final id = await _insert(db, name.trim(), email, password, role);
      return User(
          id: id, name: name.trim(), email: _normalize(email), role: role);
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw AuthException('Un compte existe déjà avec cet e-mail.');
      }
      rethrow;
    }
  }

  /// Generates a 6-digit code valid 10 minutes.
  /// Demo mode: the code is returned to be shown on screen. With a real
  /// backend it would be sent by e-mail instead.
  Future<String> requestResetCode(String email) async {
    final db = await _db;
    final normalized = _normalize(email);
    final rows = await db.query('users',
        columns: ['id'], where: 'email = ?', whereArgs: [normalized], limit: 1);
    if (rows.isEmpty) throw AuthException('Aucun compte avec cet e-mail.');

    final code = (100000 + Random.secure().nextInt(900000)).toString();
    _resetCodes[normalized] =
        _ResetCode(code, DateTime.now().add(const Duration(minutes: 10)));
    return code;
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final normalized = _normalize(email);
    final entry = _resetCodes[normalized];
    if (entry == null ||
        entry.code != code.trim() ||
        DateTime.now().isAfter(entry.expiresAt)) {
      throw AuthException('Code invalide ou expiré.');
    }
    final db = await _db;
    final salt = _newSalt();
    await db.update(
      'users',
      {'password_hash': _hash(newPassword, salt), 'salt': salt},
      where: 'email = ?',
      whereArgs: [normalized],
    );
    _resetCodes.remove(normalized);
  }
}