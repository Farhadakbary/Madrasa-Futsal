import 'package:flutter/material.dart';
import 'package:futsal/database/helper.dart';
import 'dart:io';

class ReportsScreen extends StatelessWidget {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> _showPlayersDialog(
      BuildContext context, String title, Future<List<Map<String, dynamic>>> fetchFunction) async {
    final players = await fetchFunction;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: double.maxFinite,
            child: players.isEmpty
                ? const Text('No players found.')
                : ListView.builder(
              itemCount: players.length,
              itemBuilder: (context, index) {
                final player = players[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: player['imagePath'] != null
                        ? FileImage(File(player['imagePath']))
                        : const Icon(Icons.person)
                    as ImageProvider,
                  ),
                  title: Text('${player['firstName']} ${player['lastName']}'),
                  subtitle: Text('Registration Time: ${player['registrationTime']}'),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        children: [
          ..._buildTimeBasedCards(context),
          _buildReportCard(
            context,
            title: 'Expired Contracts',
            icon: Icons.warning,
            color: Colors.red,
            fetchFunction: _dbHelper.getExpiredContracts(),
          ),
          _buildReportCard(
            context,
            title: 'Contracts Ending in 1 Year',
            icon: Icons.schedule,
            color: Colors.orange,
            fetchFunction: _dbHelper.getContractsEndingInOneYear(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTimeBasedCards(BuildContext context) {
    final times = ['10:00', '12:00', '14:00', '16:00', '18:00', '20:00'];
    return times.map((time) {
      return _buildReportCard(
        context,
        title: 'Players at $time',
        icon: Icons.access_time,
        color: Colors.green,
        fetchFunction: _dbHelper.getPlayersByTime(time),
      );
    }).toList();
  }

  Widget _buildReportCard(BuildContext context,
      {required String title,
        required IconData icon,
        required Color color,
        required Future<List<Map<String, dynamic>>> fetchFunction}) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => _showPlayersDialog(context, title, fetchFunction),
        borderRadius: BorderRadius.circular(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
