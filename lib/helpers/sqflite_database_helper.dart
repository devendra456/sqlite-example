import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SQFLiteDatabaseHelper {
  static const _databaseName = "SQLFLite.db";

  static const sQFLITETable = 'dataTable';

  SQFLiteDatabaseHelper._privateConstructor();

  static final SQFLiteDatabaseHelper instance =
      SQFLiteDatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: migrationScripts.length,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade);
  }

  Map<int, String> migrationScripts = {
    1: '''
    CREATE TABLE $sQFLITETable(
        srn INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        name TEXT,
        filePath TEXT,
        time TEXT,
        lat TEXT,
        lng TEXT
        )
        '''
  };

  Future _onCreate(Database db, int version) async {
    try {
      for (int i = 1; i <= migrationScripts.length; i++) {
        await db.execute(migrationScripts[i].toString());
      }
      print("Created");
    } catch (e) {
      print(e);
    }
  }

  Future<void> saveUserDataToSQFLITE(Map<String, dynamic> data) async {
    try {
      await _database?.insert(sQFLITETable, data);
    } catch (e) {
      print(e);
    }
  }

  Future<List<Map<String, dynamic>>> getUserDataFromSQFLITE() async {
    List<Map<String, dynamic>> data = [];

    //await Future.delayed(const Duration(seconds: 3));
    final rows = await _database?.query(sQFLITETable);
    print("$rows");
    if (rows != null) {
      data.addAll(rows);
    }
    return data;
  }

  FutureOr<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    for (int i = oldVersion + 1; i <= newVersion; i++) {
      await db.execute(migrationScripts[i].toString());
    }
  }

  Future<void> deleteUserData(int? srn) async {
    await _database?.delete(sQFLITETable, where: "srn = ?", whereArgs: [srn]);
  }

  Future<void> updateUserDetails(Map<String, dynamic> data) async {
    try {
      await _database?.update(sQFLITETable, data,
          where: 'srn = ?', whereArgs: [data["srn"]]);
    } catch (e) {
      print(e);
    }
  }
}
