import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Opens the local SQLite database.
/// The structure is designed in DB Browser for SQLite and shipped as an
/// asset: on the first launch it is copied to the phone's database folder.
class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  static const _dbName = 'servicebooking.db';
  static const _assetPath = 'assets/database/servicebooking.db';

  Database? _db;

  Future<Database> get database async => _db ??= await _open();

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), _dbName);

    if (!await databaseExists(path)) {
      await Directory(dirname(path)).create(recursive: true);
      final data = await rootBundle.load(_assetPath);
      await File(path).writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        flush: true,
      );
    }
    return openDatabase(path);
  }
}