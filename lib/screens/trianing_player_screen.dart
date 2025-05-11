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
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Players List'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colors.primary, colors.primaryContainer],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 200,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                  _applyFilters();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search, color: colors.primary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.filter_list_outlined, color: colors.onPrimary),
            onPressed: _showFilterMenu,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colors.background, colors.surfaceVariant],
          ),
        ),
        child: _filteredPlayers.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_alt_outlined,
                  size: 80, color: colors.onSurface.withOpacity(0.3)),
              const SizedBox(height: 16),
              Text(
                'No Players Found',
                style: TextStyle(
                  fontSize: 20,
                  color: colors.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        )
            : ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _filteredPlayers.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) =>
              _buildPlayerTile(_filteredPlayers[index], colors),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddFutsalPlayerScreen()),
          );
          _loadPlayers();
        },
        backgroundColor: colors.primary,
        child: Icon(Icons.add, color: colors.onPrimary),
      ),
    );
  }

  Widget _buildPlayerTile(FutsalPlayer player, ColorScheme colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: player.imagePath != null
                ? Image.file(File(player.imagePath!), fit: BoxFit.cover)
                : Icon(Icons.person, color: colors.primary),
          ),
        ),
        title: Text(
          '${player.firstName} ${player.lastName}',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            _buildInfoRow(Icons.sports_soccer, player.position, colors),
            _buildInfoRow(Icons.calendar_today, player.registrationDate!, colors),
            _buildInfoRow(Icons.access_time, player.registrationTime, colors),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: colors.primary),
              onPressed: () => _editPlayer(player),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: colors.error),
              onPressed: () => _confirmDelete(player.id!, colors),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: colors.onSurface.withOpacity(0.6)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: colors.onSurface.withOpacity(0.6),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Filter by Time', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'All',
                  '10:00',
                  '12:00',
                  '14:00',
                  '16:00',
                  '18:00',
                  '20:00',
                ].map((time) {
                  return ChoiceChip(
                    label: Text(time),
                    selected: _selectedTime == time,
                    onSelected: (selected) {
                      setState(() => _selectedTime = selected ? time : 'All');
                      _applyFilters();
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(int id, ColorScheme colors) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Player', style: TextStyle(color: colors.error)),
        content: const Text('Are you sure you want to delete this player?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: colors.onSurface)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: colors.error)),
          ),
        ],
      ),
    );

    if (confirmation == true) {
      await _dbHelper.deletePlayer(id);
      _loadPlayers();
    }
  }

  Future<void> _editPlayer(FutsalPlayer player) async {
    final updatedPlayer = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditFutsalPlayerScreen(player: player),
      ),
    );

    if (updatedPlayer != null) {
      setState(() {
        final index = _players.indexWhere((p) => p.id == updatedPlayer.id);
        if (index != -1) {
          _players[index] = updatedPlayer;
          _applyFilters();
        }
      });
    }
  }
}