import 'dart:convert';
import 'dart:io';
import 'package:futsal/database/player_modle.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'futsal_players.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE players (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            firstName TEXT,
            lastName TEXT,
            phone TEXT,
            age INTEGER,
            position TEXT,
            fee REAL,
            registrationTime TEXT,
            imagePath TEXT
          )
        ''');

        db.execute('''
          CREATE TABLE main_team_players (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            firstName TEXT,
            lastName TEXT,
            jerseyNumber INTEGER,
            position TEXT,
            contractDuration INTEGER CHECK(contractDuration >= 1 AND contractDuration <= 5),
            salary REAL,
            imagePath TEXT,
            registrationDate TEXT,
            age INTEGER
          )
        ''');

        db.execute('''
          CREATE TABLE game_notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            teamName TEXT,
            opponentTeam TEXT,
            matchResult TEXT,
            matchDate TEXT,
            topScorer TEXT,
            description TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE main_team_players (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              firstName TEXT,
              lastName TEXT,
              jerseyNumber INTEGER,
              position TEXT,
              contractDuration INTEGER CHECK(contractDuration >= 1 AND contractDuration <= 5),
              salary REAL,
              imagePath TEXT,
              registrationDate TEXT,
              age INTEGER
            )
          ''');
        }
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE game_notes (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              teamName TEXT,
              opponentTeam TEXT,
              matchResult TEXT,
              matchDate TEXT,
              topScorer TEXT,
              description TEXT
            )
          ''');
        }
      },
    );
  }

  Future<int> insertPlayer(FutsalPlayer player) async {
    final db = await instance.database;
    return await db.insert('players', player.toMap());
  }

  Future<List<FutsalPlayer>> getAllPlayers() async {
    final db = await instance.database;
    try {
      final result = await db.query('players');
      return result.map((map) => FutsalPlayer.fromMap(map)).toList();
    } catch (e) {
      print("Error fetching: $e");
      return [];
    }
  }

  Future<int> updatePlayer(FutsalPlayer player) async {
    final db = await instance.database;
    return await db.update(
      'players',
      player.toMap(),
      where: 'id = ?',
      whereArgs: [player.id],
    );
  }

  Future<int> deletePlayer(int id) async {
    final db = await instance.database;
    return await db.delete(
      'players',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllPlayers() async {
    final db = await instance.database;
    await db.delete('players');
  }

  Future<int> insertMainTeamPlayer(Map<String, dynamic> player) async {
    final db = await instance.database;
    return await db.insert('main_team_players', player);
  }

  Future<List<Map<String, dynamic>>> getAllMainTeamPlayers() async {
    final db = await instance.database;
    try {
      final result = await db.query('main_team_players');
      return result;
    } catch (e) {
      print("Error fetching: $e");
      return [];
    }
  }

  Future<int> updateMainTeamPlayer(Map<String, dynamic> player) async {
    final db = await database; // دسترسی به دیتابیس

    // به‌روزرسانی رکورد بازیکن
    return await db.update(
      'main_team_players', // نام جدول
      {
        'firstName': player['firstName'],
        'lastName': player['lastName'],
        'jerseyNumber': player['jerseyNumber'],
        'position': player['position'],
        'contractDuration': player['contractDuration'],
        'salary': player['salary'],
        'imagePath': player['imagePath'],
        'age': player['age'],
      }, // داده‌های جدید
      where: 'id = ?', // شرط به‌روزرسانی
      whereArgs: [player['id']], // آرگومان شرط
    );
  }


  Future<int> deleteMainTeamPlayer(int id) async {
    final db = await instance.database;
    return await db.delete(
      'main_team_players',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllMainTeamPlayers() async {
    final db = await instance.database;
    await db.delete('main_team_players');
  }

  Future<int> insertGameNote(Map<String, dynamic> note) async {
    final db = await instance.database;
    return await db.insert('game_notes', note);
  }

  Future<List<Map<String, dynamic>>> getAllGameNotes() async {
    final db = await instance.database;
    try {
      final result = await db.query('game_notes');
      return result;
    } catch (e) {
      print("Error fetching: $e");
      return [];
    }
  }

  Future<int> updateGameNote(int id, Map<String, dynamic> note) async {
    final db = await instance.database;
    return await db.update(
      'game_notes',
      note,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteGameNote(int id) async {
    final db = await instance.database;
    return await db.delete(
      'game_notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllGameNotes() async {
    final db = await instance.database;
    await db.delete('game_notes');
  }

  //Backup codes
  Future<void> backupDatabase({String? customPath}) async {
    final db = await instance.database;

    // استخراج داده‌های جداول
    final players = await db.query('players');
    final mainTeamPlayers = await db.query('main_team_players');
    final gameNotes = await db.query('game_notes');

    final backupData = {
      'players': players,
      'main_team_players': mainTeamPlayers,
      'game_notes': gameNotes,
    };
    final jsonData = jsonEncode(backupData);

    // تنظیم مسیر ذخیره‌سازی
    final dir = customPath != null
        ? Directory(customPath)
        : await getApplicationDocumentsDirectory();

    // ایجاد دایرکتوری در صورت عدم وجود
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final file = File('${dir.path}/futsal_backup.json');
    await file.writeAsString(jsonData);
  }

  Future<void> restoreDatabase({String? customPath}) async {
    final db = await instance.database;

    // تنظیم مسیر خواندن فایل بکاپ
    final dir = customPath != null
        ? Directory(customPath)
        : await getApplicationDocumentsDirectory();

    final file = File('${dir.path}/futsal_backup.json');

    // بررسی وجود فایل بکاپ
    if (!file.existsSync()) {
      throw Exception('No backup file found in the specified path!');
    }

    final jsonData = await file.readAsString();
    final backupData = jsonDecode(jsonData);

    await db.transaction((txn) async {
      await txn.delete('players');
      await txn.delete('main_team_players');
      await txn.delete('game_notes');

      for (final player in backupData['players']) {
        await txn.insert('players', Map<String, dynamic>.from(player));
      }
      for (final player in backupData['main_team_players']) {
        await txn.insert('main_team_players', Map<String, dynamic>.from(player));
      }
      for (final note in backupData['game_notes']) {
        await txn.insert('game_notes', Map<String, dynamic>.from(note));
      }
    });
  }

}