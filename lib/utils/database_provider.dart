import 'dart:io';

import 'package:common_utils/common_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ts70/model/model.dart';

class DataBaseProvider {
  DataBaseProvider._();

  static const String _dbVoice = "voice";

  static final DataBaseProvider dbProvider = DataBaseProvider._();

  Database? _databaseVoice;

  Future<Database?> get databaseVoice async {
    if (_databaseVoice != null) {
      return _databaseVoice;
    }
    _databaseVoice = await getDatabaseInstanceVoice();
    return _databaseVoice;
  }

  getDatabaseInstanceVoice() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = "${directory.path}$_dbVoice.db";
    return await openDatabase(path, version: 3,
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE IF NOT EXISTS $_dbVoice("
          "id INTEGER PRIMARY KEY ,"
          "title TEXT,"
          "url TEXT,"
          "label TEXT,"
          "book_meta TEXT,"
          "last_time INTEGER,"
          "idx INTEGER,"
          "count INTEGER,"
          "duration INTEGER,"
          "position INTEGER,"
          "cover TEXT)");
    });
  }

  addVoiceOrUpdate(Search listenSearchModel) async {
    if (listenSearchModel.id == null) {
      return;
    }
    listenSearchModel.lastTime = DateUtil.getNowDateMs();
    var client = await databaseVoice;

    int result = await client!.update(_dbVoice, listenSearchModel.toMap(),
        where: "id=?", whereArgs: [listenSearchModel.id]);
    if (result < 1) {
      result = await client.insert(
        _dbVoice,
        listenSearchModel.toMap(),
      );
    }
    return result;
  }

  Future<List<Search>> voices() async {
    var client = await databaseVoice;
    List result = await client!.query(
      _dbVoice,
      orderBy: "last_time desc",
    );
    final history = result.map((e) => Search.fromJson(e)).toList();
    return history;
  }

  Future<Search?> voiceById(int? id) async {
    var client = await databaseVoice;
    List result = await client!.query(_dbVoice, where: "id=?", whereArgs: [id]);
    if (result.isEmpty) return null;
    return result.map((e) => Search.fromJson(e)).first;
  }

  delById(String? id) async {
    var client = await databaseVoice;
    return await client!.delete(_dbVoice, where: "id=?", whereArgs: [id]);
  }

  clear() async {
    var client = await databaseVoice;
    client!.delete(_dbVoice);
  }
}
