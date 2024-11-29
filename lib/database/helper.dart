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
      version: 4,
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 4) {
          await db.execute('ALTER TABLE Train_players ADD COLUMN registrationDate TEXT;');
        }
        if (oldVersion < 3) {
          await _createMainTeamTable(db);
        }
        if (oldVersion < 2) {
          await _createGameNotesTable(db);
        }
      },
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE Train_players (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firstName TEXT,
        lastName TEXT,
        phone TEXT,
        age INTEGER,
        position TEXT,
        fee REAL,
        registrationTime TEXT,
        registrationDate TEXT,
        imagePath TEXT
      )
    ''');

    await _createMainTeamTable(db);
    await _createGameNotesTable(db);
  }

  Future<void> _createMainTeamTable(Database db) async {
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

  Future<void> _createGameNotesTable(Database db) async {
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

  Future<int> insertPlayer(Map<String, dynamic> player) async {
    final db = await database;
    return await db.insert('Train_players', player);
  }

  Future<List<FutsalPlayer>> getAllPlayers() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('Train_players');
    print("Loaded players from database: $maps");
    return maps.map((map) => FutsalPlayer.fromMap(map)).toList();
  }
  Future<int> updatePlayer(FutsalPlayer player) async {
    final db = await database;
    return await db.update(
      'Train_players',
      player.toMap(),
      where: 'id = ?',
      whereArgs: [player.id],
    );
  }

  Future<int> deletePlayer(int id) async {
    final db = await database;
    return await db.delete(
      'Train_players',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getPlayersWithExpiredRegistration() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    return await db.query(
      'Train_players',
      where: 'registrationDate < ?',
      whereArgs: [now],
    );
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
    final db = await database;

    return await db.update(
      'main_team_players',
      {
        'firstName': player['firstName'],
        'lastName': player['lastName'],
        'jerseyNumber': player['jerseyNumber'],
        'position': player['position'],
        'contractDuration': player['contractDuration'],
        'salary': player['salary'],
        'imagePath': player['imagePath'],
        'age': player['age'],
        'registrationDate': player['registrationDate'],  // Add registrationDate here
      },
      where: 'id = ?',
      whereArgs: [player['id']],
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
// reports database codes

  Future<List<Map<String, dynamic>>> getPlayersByTime(String time) async {
    try {
      final db = await database;
      return await db.query(
        "Train_players",
        where: 'registrationTime = ?',
        whereArgs: [time],
      );
    } catch (e) {
      print('Error in getPlayersByTime: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getPlayersWithExpiringRegistration() async {
    try {
      final db = await database;
      final now = DateTime.now();
      final twentyDaysAgo = now.subtract(const Duration(days: 20));
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));

      final result = await db.query(
        'Train_players',
        where: 'registrationDate BETWEEN ? AND ?',
        whereArgs: [
          thirtyDaysAgo.toIso8601String(),
          twentyDaysAgo.toIso8601String(),
        ],
      );

      return result;
    } catch (e) {
      print('Error in getPlayersWithExpiringRegistration: $e');
      return [];
    }
  }

  Future<List<int>> getPlayerCountsByTime() async {
    try {
      final db = await database;

      const times = ['10:00', '12:00', '14:00', '16:00', '18:00'];

      List<int> counts = [];

      for (String time in times) {
        final result = await db.rawQuery(
          '''
          SELECT COUNT(*) as count
          FROM Train_players
          WHERE strftime('%H:%M', registrationTime) = ?
          ''',
          [time],
        );

        counts.add(result.first['count'] as int);
      }

      return counts;
    } catch (e) {
      print('Error in getPlayerCountsByTime: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getPlayersAfterThirtyDays() async {
    try {
      final db = await database;
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));

      final result = await db.query(
        'Train_players',
        where: 'registrationDate < ?',
        whereArgs: [thirtyDaysAgo.toIso8601String()],
      );

      return result;
    } catch (e) {
      print('Error in getPlayersAfterThirtyDays: $e');
      return [];
    }
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

  Future<int> updateGameNote(Map<String, dynamic> note) async {
    final db = await database;
    return await db.update(
      'game_notes',
      note,
      where: 'id = ?',
      whereArgs: [note['id']],
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

    final players = await db.query('Train_players');
    final mainTeamPlayers = await db.query('main_team_players');
    final gameNotes = await db.query('game_notes');

    final backupData = {
      'Train_players': players,
      'main_team_players': mainTeamPlayers,
      'game_notes': gameNotes,
    };
    final jsonData = jsonEncode(backupData);

    final dir = customPath != null
        ? Directory(customPath)
        : await getApplicationDocumentsDirectory();

    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final file = File('${dir.path}/futsal_backup.json');
    await file.writeAsString(jsonData);
  }

  Future<void> restoreDatabase({String? customPath}) async {
    final db = await instance.database;

    final dir = customPath != null
        ? Directory(customPath)
        : await getApplicationDocumentsDirectory();

    final file = File('${dir.path}/futsal_backup.json');

    if (!file.existsSync()) {
      throw Exception('No backup file found in the specified path!');
    }

    final jsonData = await file.readAsString();
    final backupData = jsonDecode(jsonData);

    await db.transaction((txn) async {
      await txn.delete('Train_players');
      await txn.delete('main_team_players');
      await txn.delete('game_notes');

      for (final player in backupData['Train_players']) {
        await txn.insert('Train_players', Map<String, dynamic>.from(player));
      }
      for (final player in backupData['main_team_players']) {
        await txn.insert(
            'main_team_players', Map<String, dynamic>.from(player));
      }
      for (final note in backupData['game_notes']) {
        await txn.insert('game_notes', Map<String, dynamic>.from(note));
      }
    });
  }
}
