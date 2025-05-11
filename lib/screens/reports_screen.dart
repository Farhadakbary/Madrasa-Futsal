import 'package:flutter/material.dart';
import 'package:futsal/database/helper.dart';
import 'dart:io';

class ReportsScreen extends StatelessWidget {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> _showPlayersDialog(
      BuildContext context,
      String title,
      Future<List<Map<String, dynamic>>> fetchFunction,
      ) async {
    try {
      final players = await fetchFunction;

      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.surfaceVariant,
                    Theme.of(context).colorScheme.background,
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: players.isEmpty
                        ? Center(
                      child: Text(
                        'No players found',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5),
                        ),
                      ),
                    )
                        : Scrollbar(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: players.length,
                        separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final player = players[index];
                          final registrationDate =
                          DateTime.parse(player['registrationDate']);
                          final daysPassed = DateTime.now()
                              .difference(registrationDate)
                              .inDays;

                          return Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surface
                                  .withOpacity(0.7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                backgroundImage: player['imagePath'] !=
                                    null &&
                                    File(player['imagePath'])
                                        .existsSync()
                                    ? FileImage(File(player['imagePath']))
                                    : null,
                                child: player['imagePath'] == null
                                    ? Icon(Icons.person,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary)
                                    : null,
                              ),
                              title: Text(
                                '${player['firstName']} ${player['lastName']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface,
                                ),
                              ),
                              subtitle: Text(
                                '$daysPassed days',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.7),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching players')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
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
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.9,
                ),
                delegate: SliverChildListDelegate([
                  ..._buildTimeBasedCards(context),
                  _buildReportCard(
                    context,
                    title: 'Expired Registrations',
                    icon: Icons.calendar_today,
                    color: colors.error,
                    fetchFunction: _dbHelper.getPlayersWithExpiredRegistration(),
                  ),
                  _buildReportCard(
                    context,
                    title: 'Expiring Soon',
                    icon: Icons.warning_rounded,
                    color: colors.tertiary,
                    fetchFunction: _dbHelper.getPlayersWithExpiringRegistration(),
                  ),
                  _buildReportCard(
                    context,
                    title: '30+ Days',
                    icon: Icons.timelapse_rounded,
                    color: colors.secondary,
                    fetchFunction: _dbHelper.getPlayersAfterThirtyDays(),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTimeBasedCards(BuildContext context) {
    final times = ['10:00', '12:00', '14:00', '16:00', '18:00', '20:00'];
    return times.map((time) {
      return _buildReportCard(
        context,
        title: 'Players at $time',
        icon: Icons.access_time_filled_rounded,
        color: Theme.of(context).colorScheme.primary,
        fetchFunction: _dbHelper.getPlayersByTime(time),
      );
    }).toList();
  }

  Widget _buildReportCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Color color,
        required Future<List<Map<String, dynamic>>> fetchFunction,
      }) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: InkWell(
        onTap: () => _showPlayersDialog(context, title, fetchFunction),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}