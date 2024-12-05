import 'dart:io';
import 'package:flutter/material.dart';
import 'package:futsal/database/player_modle.dart';
import 'package:futsal/screens/edit_training_players.dart';
import '../database/helper.dart';
import 'addingTrainingPlayer.dart';

class PlayersListScreen extends StatefulWidget {
  const PlayersListScreen({Key? key}) : super(key: key);

  @override
  _PlayersListScreenState createState() => _PlayersListScreenState();
}

class _PlayersListScreenState extends State<PlayersListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<FutsalPlayer> _players = [];
  List<FutsalPlayer> _filteredPlayers = [];
  String _searchQuery = '';
  String _selectedTime = 'All';

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    try {
      final players = await DatabaseHelper.instance.getAllPlayers();
      setState(() {
        _players = players.cast<FutsalPlayer>();
        _applyFilters();
      });
    } catch (e) {
      print('Error loading players: $e');
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredPlayers = _players.where((player) {
        final matchesTime =
            _selectedTime == 'All' || player.registrationTime == _selectedTime;

        final matchesSearch = player.firstName
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            player.lastName.toLowerCase().contains(_searchQuery.toLowerCase());

        return matchesTime && matchesSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Players List',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: SizedBox(
              width: 200,
              child: TextField(
                onChanged: (query) {
                  setState(() {
                    _searchQuery = query;
                    _applyFilters();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: const TextStyle(color: Colors.white),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.blue.shade600,
                ),
              ),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.filter_list,
              color: Colors.white,
            ),
            onSelected: (value) {
              setState(() {
                _selectedTime = value;
                _applyFilters();
              });
            },
            itemBuilder: (context) {
              return <PopupMenuEntry<String>>[
                const PopupMenuItem(value: 'All', child: Text('All')),
                const PopupMenuItem(value: '10:00', child: Text('10:00')),
                const PopupMenuItem(value: '12:00', child: Text('12:00')),
                const PopupMenuItem(value: '14:00', child: Text('14:00')),
                const PopupMenuItem(value: '16:00', child: Text('16:00')),
                const PopupMenuItem(value: '18:00', child: Text('18:00')),
                const PopupMenuItem(value: '20:00', child: Text('20:00')),
              ];
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _filteredPlayers.isEmpty
            ? const Center(
                child: Text(
                  'No players found.',
                  style: TextStyle(fontSize: 18, color: Colors.blueGrey),
                ),
              )
            : ListView.builder(
                itemCount: _filteredPlayers.length,
                itemBuilder: (context, index) {
                  final player = _filteredPlayers[index];
                  return _buildPlayerTile(player);
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AddFutsalPlayerScreen()),
          );
          _loadPlayers();
        },
        backgroundColor: Colors.blue,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
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
          backgroundColor: Colors.blue.shade100,
          child: player.imagePath != null
              ? ClipOval(
                  child: Image.file(
                    File(player.imagePath!),
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                )
              : const Icon(
                  Icons.person,
                  size: 40,
                  color: Colors.black,
                ),
        ),
        title: Text(
          '${player.firstName} ${player.lastName}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        subtitle: Column(
          children: [
            Text(
              'Plays in: ${player.position}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            Text(
              'Registered on: ${player.registrationDate}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            Text(
              'Registered at: ${player.registrationTime}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        tileColor: Colors.white,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () async {
                final updatedPlayer = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditFutsalPlayerScreen(player: player),
                  ),
                );

                if (updatedPlayer != null) {
                  setState(() {
                    final index =
                        _players.indexWhere((p) => p.id == updatedPlayer.id);
                    if (index != -1) {
                      _players[index] = updatedPlayer;
                      _applyFilters();
                    }
                  });
                }
              },
              icon: const Icon(
                Icons.edit,
                color: Colors.blue,
              ),
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
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            )),
                      ],
                    );
                  },
                );

                if (confirmation == true) {
                  await _dbHelper.deletePlayer(player.id!);

                  _loadPlayers();
                }
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlayerSearchDelegate extends SearchDelegate<String> {
  final List<FutsalPlayer> players;
  final ValueChanged<String> onSearchSelected;

  PlayerSearchDelegate({required this.players, required this.onSearchSelected});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    onSearchSelected(query);
    close(context, query);
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = players
        .where((player) =>
            player.firstName.toLowerCase().contains(query.toLowerCase()) ||
            player.lastName.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Scaffold(
      body: ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final player = suggestions[index];
          return ListTile(
            title: Text('${player.firstName} ${player.lastName}'),
            onTap: () {
              query = '${player.firstName} ${player.lastName}';
              showResults(context);
            },
          );
        },
      ),
    );
  }
}
