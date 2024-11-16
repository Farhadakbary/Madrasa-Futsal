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
  List<FutsalPlayer> _filteredPlayers = [];
  String _searchQuery = '';
  String _selectedTime = 'All';

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    final players = await _dbHelper.getAllPlayers();
    setState(() {
      _players = players.cast<FutsalPlayer>();
      _applyFilters();
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredPlayers = _players.where((player) {
        final matchesTime =
            _selectedTime == 'All' || player.registrationTime == _selectedTime;

        if (_selectedTime == '10:00') {
          return player.registrationTime == '10:00';
        }
        else if (_selectedTime == '12:00') {
          return player.registrationTime == '12:00';
        } else if (_selectedTime == '14:00') {
          return player.registrationTime == '14:00';
        }
        else if (_selectedTime == '16:00') {
          return player.registrationTime == '16:00';
        } else if (_selectedTime == '18:00') {
          return player.registrationTime == '18:00';
        } else if (_selectedTime == '20:00') {
          return player.registrationTime == '20:00';
        }
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
        title: const Text('Players List'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        actions: [
          // جستجو
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: PlayerSearchDelegate(
                  players: _players,
                  onSearchSelected: (query) {
                    setState(() {
                      _searchQuery = query;
                      _applyFilters();
                    });
                  },
                ),
              );
            },
          ),
          // فیلتر
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
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

    return ListView.builder(
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
    );
  }
}
