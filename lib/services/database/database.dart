import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'models/logs.dart';

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null)
      return _database!;

    // if _database is null we instantiate it
    _database = await initDB();
    return _database!;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "AppDB.db");
    return await openDatabase(path, version: 1, onOpen: (db) {
    }, onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE logs ("
          "id INTEGER PRIMARY KEY,"
          "create_date_time_unix INTEGER,"
          "log_text TEXT"
          ")");
    });
  }

  newLog(Log newLog) async {
    final db = await database;
    //insert to the table using the new id
    var raw = await db.rawInsert(
        "INSERT Into logs (id,create_date_time_unix,log_text)"
            " VALUES ((SELECT coalesce(MAX(id), 0) + 1 as id FROM logs limit 1),?,?)",
        [newLog.createDateTimeUnix, newLog.logText]);
    return raw;
  }

  Future<List<Log>> getLogs(int idSkip, int take, bool asc) async {
    final db = await database;
    var res = await db.query("logs",
        where: asc ? "id > ?" : "id < ?",
        whereArgs: [idSkip],
        orderBy: "id ${asc? "asc" : "desc"}"
    );
    List<Log> list =
    res.isNotEmpty ? res.map((c) => Log.fromJson(c)).toList() : [];
    return list;
  }

  // deleteClient(int id) async {
  //   final db = await database;
  //   return db.delete("Client", where: "id = ?", whereArgs: [id]);
  // }

  Future clearAllLogs() async {
    final db = await database;
    await db.rawDelete("delete from logs");
  }
}