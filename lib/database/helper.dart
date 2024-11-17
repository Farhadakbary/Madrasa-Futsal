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

  // Insert player into the database
  Future<int> insertPlayer(FutsalPlayer player) async {
    final db = await instance.database;
    return await db.insert('players', player.toMap());
  }

  // Get all players from the database
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

  // Update player information in the database
  Future<int> updatePlayer(FutsalPlayer player) async {
    final db = await instance.database;
    return await db.update(
      'players',
      player.toMap(),
      where: 'id = ?',
      whereArgs: [player.id],
    );
  }

  // Delete a player from the database
  Future<int> deletePlayer(int id) async {
    final db = await instance.database;
    return await db.delete(
      'players',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete all players from the database
  Future<void> deleteAllPlayers() async {
    final db = await instance.database;
    await db.delete('players');
  }

  // Insert a main team player into the database
  Future<int> insertMainTeamPlayer(Map<String, dynamic> player) async {
    final db = await instance.database;
    return await db.insert('main_team_players', player);
  }

  // Get all main team players from the database
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

  // Update main team player information in the database
  Future<int> updateMainTeamPlayer(int id, Map<String, dynamic> player) async {
    final db = await instance.database;
    return await db.update(
      'main_team_players',
      player,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete a main team player from the database
  Future<int> deleteMainTeamPlayer(int id) async {
    final db = await instance.database;
    return await db.delete(
      'main_team_players',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete all main team players from the database
  Future<void> deleteAllMainTeamPlayers() async {
    final db = await instance.database;
    await db.delete('main_team_players');
  }

  // Insert a game note into the database
  Future<int> insertGameNote(Map<String, dynamic> note) async {
    final db = await instance.database;
    return await db.insert('game_notes', note);
  }

  // Get all game notes from the database
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

  // Update game note information in the database
  Future<int> updateGameNote(int id, Map<String, dynamic> note) async {
    final db = await instance.database;
    return await db.update(
      'game_notes',
      note,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete a game note from the database
  Future<int> deleteGameNote(int id) async {
    final db = await instance.database;
    return await db.delete(
      'game_notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete all game notes from the database
  Future<void> deleteAllGameNotes() async {
    final db = await instance.database;
    await db.delete('game_notes');
  }

  // ------------------ Backup and Restore Methods ------------------

  // Backup the database to a file
  Future<void> backupDatabase() async {
    final db = await instance.database;

    // Get data from the tables
    final players = await db.query('players');
    final mainTeamPlayers = await db.query('main_team_players');
    final gameNotes = await db.query('game_notes');

    // Convert data to JSON format
    final backupData = {
      'players': players,
      'main_team_players': mainTeamPlayers,
      'game_notes': gameNotes,
    };
    final jsonData = jsonEncode(backupData);

    // Save the JSON data to a file
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/futsal_backup.json');

    // Write the JSON data to the file
    await file.writeAsString(jsonData);
  }

  // Restore the database from a backup file
  Future<void> restoreDatabase() async {
    final db = await instance.database;

    // Get the backup file path
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/futsal_backup.json');

    // Check if the backup file exists
    if (!file.existsSync()) {
      throw Exception('No backup file found!');
    }

    // Read the JSON data from the file
    final jsonData = await file.readAsString();
    final backupData = jsonDecode(jsonData);

    // Clear the existing data from the tables
    await db.delete('players');
    await db.delete('main_team_players');
    await db.delete('game_notes');

    // Insert the backup data into the tables
    for (final player in backupData['players']) {
      await db.insert('players', Map<String, dynamic>.from(player));
    }

    for (final player in backupData['main_team_players']) {
      await db.insert('main_team_players', Map<String, dynamic>.from(player));
    }

    for (final note in backupData['game_notes']) {
      await db.insert('game_notes', Map<String, dynamic>.from(note));
    }
  }
}
