import 'package:postgres/postgres.dart';
import 'package:ts70/pages/model.dart';

class PostGreSqlProvider {
  PostGreSqlProvider._();

  static const String _dbVoice = "voice";

  static List<Search> history = [];

  static final PostGreSqlProvider dbProvider = PostGreSqlProvider._();

  PostgreSQLConnection? _databaseVoice;

  Future<PostgreSQLConnection?> get databaseVoice async {
    if (_databaseVoice != null) {
      return _databaseVoice;
    }
    _databaseVoice = await getDatabaseInstanceVoice();
    return _databaseVoice;
  }

  getDatabaseInstanceVoice() async {
    final connect = PostgreSQLConnection(
        "47.100.38.198", 5433, "db659bbd405ee945f88e13bbd310396d7dts70",
        username: "dart", password: "nujx_C5brYtggq6");
    await connect.open();
    return connect;

    // Directory directory = await getApplicationDocumentsDirectory();
    // String path = "${directory.path}$_dbVoice.db";
    // return await openDatabase(path, version: 2,
    //     onCreate: (Database db, int version) async {
    //   await db.execute("CREATE TABLE IF NOT EXISTS $_dbVoice("
    //       "id INTEGER PRIMARY KEY ,"
    //       "title TEXT,"
    //       "url TEXT,"
    //       "book_meta TEXT,"
    //       "last_time INTEGER,"
    //       "idx INTEGER,"
    //       "count INTEGER,"
    //       "duration INTEGER,"
    //       "position INTEGER,"
    //       "cover TEXT)");
    // });
// CREATE TABLE voice(
//    id TEXT PRIMARY KEY     NOT NULL,
//    title           TEXT    NOT NULL,
//    url            TEXT     ,
//    book_meta            TEXT     ,
//    last_time            INT     ,
//    idx            INT     ,
//    count        INT,
//    duration        INT,
//    position        INT,
//    cover         TEXT
// );
  }

  syncDbCloud(List<Search> listenSearchModels) async {
    var client = await databaseVoice;
    await client!.transaction((ctx) async {
      await ctx.query("DELETE FROM voice");
      for (var element in listenSearchModels) {
        await ctx.query(
            "INSERT INTO public.voice VALUES (@id:text,@title:text,@url:text,@book_meta:text,@last_time:int4,@idx:int4,@count:int4,@duration:int4,@position:int4,@cover:text)",
            substitutionValues: element.toMap());
      }
    });
  }

  Future<List<Search>> voices() async {
    if (history.isNotEmpty) return history;

    var client = await databaseVoice;
    List result = await client!.query(
      _dbVoice,
      // orderBy: "last_time desc",
    );
    List<List<dynamic>> results = await client.query(
        "SELECT a, b FROM table WHERE a = @aValue",
        substitutionValues: {"aValue": 3});

    for (final row in results) {
      var a = row[0];
      var b = row[1];
    }

    history = result.map((e) => Search.fromJson(e)).toList();
    return history;
  }
}
