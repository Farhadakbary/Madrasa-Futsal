import 'dart:io';
import 'package:flutter/material.dart';
import 'package:futsal/screens/adding_team-player.dart';
import 'package:futsal/screens/edit_main_team_players.dart';
import '../database/helper.dart';

class MainTeamPlayersListScreen extends StatefulWidget {
  const MainTeamPlayersListScreen({Key? key}) : super(key: key);

  @override
  _MainTeamPlayersListScreenState createState() =>
      _MainTeamPlayersListScreenState();
}

class _MainTeamPlayersListScreenState extends State<MainTeamPlayersListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _mainTeamPlayers = [];

  @override
  void initState() {
    super.initState();
    _loadMainTeamPlayers();
  }

  Future<void> _loadMainTeamPlayers() async {
    final players = await _dbHelper.getAllMainTeamPlayers();
    setState(() {
      _mainTeamPlayers = players;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Main Team Players',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _mainTeamPlayers.isEmpty
            ? const Center(
                child: Text(
                  'No players in the main team yet.',
                  style: TextStyle(fontSize: 18, color: Colors.blueGrey),
                ),
              )
            : ListView.builder(
                itemCount: _mainTeamPlayers.length,
                itemBuilder: (context, index) {
                  final player = _mainTeamPlayers[index];
                  return _buildPlayerTile(player, size);
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddMainTeamPlayerScreen(),
            ),
          );
          _loadMainTeamPlayers();
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add,color: Colors.white,),
      ),
    );
  }

  Widget _buildPlayerTile(Map<String, dynamic> player, Size size) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: player['imagePath'] != null
              ? FileImage(File(player['imagePath']))

              : const AssetImage('assets/image/team.jpg') as ImageProvider,

          backgroundColor: Colors.green.shade100,
        ),
        title: Text(
          '${player['firstName']} ${player['lastName']}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        subtitle: Text(
          'Jersey No: ${player['jerseyNumber']} | Position: ${player['position']}',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        tileColor: Colors.white,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () async {
                final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            EditMainTeamPlayerScreen(player: player)));
                if (result == true) {
                  _loadMainTeamPlayers();
                }
              },
              icon: const Icon(Icons.edit,color: Colors.green,),
            ),
            IconButton(
              onPressed: () async {
                final confirmation = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Confirm Delete'),
                      content: const Text(
                          'Are you sure you want to delete this player?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel')),
                        TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete',style: TextStyle(color: Colors.red),)),
                      ],
                    );
                  },
                );

                if (confirmation == true) {
                  await _dbHelper.deleteMainTeamPlayer(player['id']);

                  _loadMainTeamPlayers();
                }
              },
              icon: const Icon(Icons.delete,color: Colors.red,),
            ),
          ],
        ),
      ),
    );
  }
}
