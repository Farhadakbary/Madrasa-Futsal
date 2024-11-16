import 'dart:io';
import 'package:flutter/material.dart';
import '../database/helper.dart';
import '../database/player_modle.dart';
import 'addingTrainingPlayer.dart';

class PlayersListScreen extends StatefulWidget {
  const PlayersListScreen({Key? key}) : super(key: key);

  @override
  _PlayersListScreenState createState() => _PlayersListScreenState();
}

class _PlayersListScreenState extends State<PlayersListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<FutsalPlayer> _players = [];

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    final players = await _dbHelper.getAllPlayers();
    setState(() {
      _players = players.cast<FutsalPlayer>();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Players List'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _players.isEmpty
            ? const Center(
          child: Text(
            'No players added yet.',
            style: TextStyle(fontSize: 18, color: Colors.blueGrey),
          ),
        )
            : ListView.builder(
          itemCount: _players.length,
          itemBuilder: (context, index) {
            final player = _players[index];
            return _buildPlayerTile(player);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>const AddFutsalPlayerScreen()),
          );
          _loadPlayers();
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPlayerTile(FutsalPlayer player) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: player.imagePath != null
              ? FileImage(File(player.imagePath!))
              : const AssetImage('assets/default_player.png') as ImageProvider,
          backgroundColor: Colors.red.shade100,
        ),
        title: Text(
          '${player.firstName} ${player.lastName}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        subtitle: Text(
          'Registered on: ${player.registrationTime}',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        tileColor: Colors.white,
        trailing: const Icon(Icons.chevron_right, color: Colors.blue),
      ),
    );
  }
}
