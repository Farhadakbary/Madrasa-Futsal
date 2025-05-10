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
    final colors = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Team Players'),
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
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colors.background, colors.surfaceVariant],
          ),
        ),
        child: _mainTeamPlayers.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_alt_outlined,
                  size: 80, color: colors.onSurface.withOpacity(0.3)),
              const SizedBox(height: 20),
              Text(
                'No Players Found',
                style: TextStyle(
                  fontSize: 22,
                  color: colors.onSurface.withOpacity(0.5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _mainTeamPlayers.length,
          itemBuilder: (context, index) {
            final player = _mainTeamPlayers[index];
            return _buildPlayerCard(player, colors, context);
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
        backgroundColor: colors.primary,
        child: Icon(Icons.add, color: colors.onPrimary),
      ),
    );
  }

  Widget _buildPlayerCard(
      Map<String, dynamic> player, ColorScheme colors, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.primary.withOpacity(0.2), width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: player['imagePath'] != null
                ? Image.file(File(player['imagePath']), fit: BoxFit.cover)
                : Icon(Icons.person_outline,
                size: 20, color: colors.primary),
          ),
        ),
        title: Text(
          '${player['firstName']} ${player['lastName']}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                _buildInfoChip(
                  label: '${player['jerseyNumber']}',
                  icon: Icons.numbers,
                  colors: colors,
                ),
                const SizedBox(width: 4),
                _buildInfoChip(
                  label: player['position'],
                  icon: Icons.sports_soccer,
                  colors: colors,
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: colors.primary,size: 20),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditMainTeamPlayerScreen(player: player),
                  ),
                );
                if (result == true) _loadMainTeamPlayers();
              },
            ),
            IconButton(
              icon: Icon(Icons.delete, color: colors.error,size: 20,),
              onPressed: () => _confirmDelete(player['id'], colors, context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required String label,
    required IconData icon,
    required ColorScheme colors,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 6,
              fontWeight: FontWeight.w500,
              color: colors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
      int id, ColorScheme colors, BuildContext context) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Player', style: TextStyle(color: colors.error)),
        content: const Text('Are you sure you want to delete this player?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: TextStyle(color: colors.onSurface))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Delete', style: TextStyle(color: colors.error))),
        ],
      ),
    );

    if (confirmation == true) {
      await _dbHelper.deleteMainTeamPlayer(id);
      _loadMainTeamPlayers();
    }
  }
}