import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:futsal/screens/reports_screen.dart';
import 'package:futsal/screens/tactics_screen.dart';
import 'package:futsal/screens/team_player_screen.dart';
import 'package:futsal/screens/trianing_player_screen.dart';
import 'package:google_fonts/google_fonts.dart';

import 'drawer_screens/about_screen.dart';
import 'drawer_screens/backup_screen.dart';
import 'drawer_screens/share_screen.dart';
import 'notes_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;

  const DashboardScreen({Key? key, required this.onThemeChanged}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ValueNotifier<List<int>> _chartDataNotifier = ValueNotifier([12, 8, 5]);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colors = _getColorScheme(context);

    return Scaffold(
      appBar: _buildAppBar(isDarkMode, colors),
      drawer: _buildDrawer(isDarkMode),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(colors),
              const SizedBox(height: 24),
              _buildQuickActions(colors),
              const SizedBox(height: 24),
              _buildSecondaryActions(colors),
              const SizedBox(height: 24),
              _buildChartSection(colors),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(bool isDarkMode, ColorScheme colors) {
    return AppBar(
      title: Text('Futsal Manager',
          style: GoogleFonts.poppins(
              fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
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
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: Switch(
            activeTrackColor: colors.secondary,
            activeColor: colors.onPrimary,
            value: isDarkMode,
            onChanged: widget.onThemeChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeCard(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [colors.primary.withOpacity(0.8), colors.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 2,
          )
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.sports_soccer, size: 36, color: colors.onPrimary),
          const SizedBox(width: 16),
          Text('Welcome, Coach!',
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: colors.onPrimary)),
        ],
      ),
    );
  }

  Widget _buildQuickActions(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions',
            style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.onSurface)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildActionCard(
              context,
              title: 'Players',
              icon: Icons.people_alt_rounded,
              color: colors.secondary,
              route: const MainTeamPlayersListScreen(),
            ),
            _buildActionCard(
              context,
              title: 'Trainers',
              icon: Icons.fitness_center_rounded,
              color: colors.tertiary,
              route: const PlayersListScreen(),
            ),
            _buildActionCard(
              context,
              title: 'Tactics',
              icon: Icons.track_changes_rounded,
              color: colors.errorContainer,
              route:  FutsalField(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSecondaryActions(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Management Tools',
            style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.onSurface)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildToolCard(
                context,
                title: 'Match Reports',
                icon: Icons.assignment_rounded,
                color: colors.primaryContainer,
                route:  ReportsScreen(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildToolCard(
                context,
                title: 'Match Notes',
                icon: Icons.note_alt_rounded,
                color: colors.secondaryContainer,
                route: const NotesListScreen(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChartSection(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Player Statistics',
            style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.onSurface)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 2,
              )
            ],
          ),
          height: 260,
          child: ValueListenableBuilder<List<int>>(
            valueListenable: _chartDataNotifier,
            builder: (context, data, _) {
              return BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: BarTouchData(enabled: false),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) => Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            ['Active', 'Expiring', 'Inactive'][value.toInt()],
                            style: GoogleFonts.poppins(
                                fontSize: 10, color: colors.onSurface),
                          ),
                        ),
                      ),
                    ),
                    leftTitles: const AxisTitles(),
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                  ),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: data[0].toDouble(),
                          color: colors.primary,
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                        )
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: data[1].toDouble(),
                          color: colors.secondary,
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                        )
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: data[2].toDouble(),
                          color: colors.error,
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                        )
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context,
      {required String title,
        required IconData icon,
        required Color color,
        required Widget route}) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => route)),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 8),
            Text(title,
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface)),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard(BuildContext context,
      {required String title,
        required IconData icon,
        required Color color,
        required Widget route}) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => route)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 2,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.onPrimary),
            const SizedBox(height: 12),
            Text(title,
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onPrimary)),
          ],
        ),
      ),
    );
  }

  Drawer _buildDrawer(bool isDarkMode) {
    return Drawer(
      child: Column(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primaryContainer
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      child: const Icon(Icons.sports_soccer,
                          size: 48, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text('FC Barcelona',
                        style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ]),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
              ),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildDrawerItem(
                      icon: Icons.backup_rounded, label: 'Backup', route: const BackupScreen()),
                  _buildDrawerItem(
                      icon: Icons.share_rounded, label: 'Share', route: const ShareScreen()),
                  _buildDrawerItem(
                      icon: Icons.info_rounded, label: 'About', route: const AboutScreen()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      {required IconData icon, required String label, required Widget route}) {
    return ListTile(
      leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary)),
      title: Text(label,
          style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface)),
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => route)),
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
    );
  }

  ColorScheme _getColorScheme(BuildContext context) {
    return Theme.of(context).colorScheme;
  }
}