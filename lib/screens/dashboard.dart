import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:futsal/screens/drawer_screens/about_screen.dart';
import 'package:futsal/screens/drawer_screens/backup_screen.dart';
import 'package:futsal/screens/drawer_screens/share_screen.dart';
import 'package:futsal/screens/notes_screen.dart';
import 'package:futsal/screens/reports_screen.dart';
import 'package:futsal/screens/tactics_screen.dart';
import 'package:futsal/screens/team_player_screen.dart';
import 'package:futsal/screens/trianing_player_screen.dart';
import 'package:google_fonts/google_fonts.dart';

import '../database/helper.dart';

class DashboardScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;

  DashboardScreen({Key? key, required this.onThemeChanged}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  late ValueNotifier<List<int>> _chartDataNotifier;

  @override
  void initState() {
    super.initState();
    _chartDataNotifier = ValueNotifier<List<int>>([]);
    _loadChartData();
  }

  void _loadChartData() async {
    final expiredPlayersCount = await _dbHelper.getPlayersWithExpiredRegistration();
    final expiringPlayersCount = await _dbHelper.getPlayersWithExpiringRegistration();
    final playersAfterThirtyDaysCount = await _dbHelper.getPlayersAfterThirtyDays();

    _chartDataNotifier.value = [
      expiredPlayersCount.length,
      expiringPlayersCount.length,
      playersAfterThirtyDaysCount.length,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Futsal ",
          style: TextStyle(color: Colors.white, fontSize: 30),
        ),
        centerTitle: true,
        backgroundColor: Colors.red.shade400,
        actions: [
          Switch(
            activeColor: Colors.black,
            value: Theme.of(context).brightness == Brightness.dark,
            onChanged: (bool value) {
              widget.onThemeChanged(value);
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedBackground(),
            ),
            ListView(
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                      color: Colors.blue.shade700.withOpacity(0.85),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      image: const DecorationImage(
                          image: AssetImage('assets/image/team.jpg'),
                          fit: BoxFit.cover)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 45,
                        backgroundImage: AssetImage('assets/image/logo.jfif'),
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'FC Barcelona',
                        style: GoogleFonts.roboto(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildDrawerItem(
                  context,
                  icon: Icons.backup,
                  title: 'Backup',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const BackupScreen()));
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.share,
                  title: 'Share',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ShareScreen()));
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.info_outline,
                  title: 'About',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AboutScreen()));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade700,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Center(
                      child: Padding(
                        padding:const EdgeInsets.fromLTRB(30,10, 30, 10),
                        child: Text(
                          'Welcome Back',
                          style: GoogleFonts.roboto(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Quick Stats',
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ActionCard(
                    title: 'players',
                    icon: Icons.people,
                    color: Colors.green.shade500,
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                              const MainTeamPlayersListScreen()));
                    },
                  ),
                  ActionCard(
                    title: 'Trainers',
                    icon: Icons.people_outline,
                    color: Colors.blue.shade500,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PlayersListScreen()),
                      );
                    },
                  ),
                  ActionCard(
                    title: 'Tactics',
                    icon: Icons.golf_course_rounded,
                    color: Colors.orange.shade500,
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FutsalField()));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SecondActionCards(
                    title: 'All Reports',
                    icon: Icons.report,
                    color: Colors.blue.shade400,
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ReportsScreen()));
                    },
                  ),
                  SecondActionCards(
                    title: 'Match Results',
                    icon: Icons.edit_note_sharp,
                    color: Colors.green.shade400,
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const NotesListScreen()));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                "Detailed States",
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              ValueListenableBuilder<List<int>>(
                valueListenable: _chartDataNotifier,
                builder: (context, data, child) {
                  return Container(
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: BarChart(
                      BarChartData(
                        barGroups: _buildBarGroups(data),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, _) {
                                switch (value.toInt()) {
                                  case 0:
                                    return const Text('Registered',
                                        style: TextStyle(fontSize: 8));
                                  case 1:
                                    return const Text('In 10 Days',
                                        style: TextStyle(fontSize: 8));
                                  case 2:
                                    return const Text('Expired(+30)',
                                        style: TextStyle(fontSize: 8));
                                  default:
                                    return const Text('');
                                }
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 2,
                              reservedSize: 28,
                              getTitlesWidget: (value, _) => Text(
                                value.toInt().toString(),
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: const FlGridData(show: true),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(List<int> data) {
    return [
      BarChartGroupData(x: 0, barRods: [
        BarChartRodData(
          toY: data.isNotEmpty ? data[0].toDouble() : 0,
          color: Colors.green.shade400,
        ),
      ]),
      BarChartGroupData(x: 1, barRods: [
        BarChartRodData(
          toY: data.isNotEmpty ? data[1].toDouble() : 0,
          color: Colors.orange.shade400,
        ),
      ]),
      BarChartGroupData(x: 2, barRods: [
        BarChartRodData(
          toY: data.isNotEmpty ? data[2].toDouble() : 0,
          color: Colors.red.shade400,
        ),
      ]),
    ];
  }

  Widget _buildDrawerItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
      }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }
}

class ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const ActionCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Card(
        color: color,
        child: Container(
          width: 100,
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Icon(
                icon,
                size: 30,
                color: Colors.white,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SecondActionCards extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const SecondActionCards({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Card(
        color: color,
        child: Container(
          // width: 100,
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Icon(
                icon,
                size: 30,
                color: Colors.white,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedBackground extends StatefulWidget {
  @override
  _AnimatedBackgroundState createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: BackgroundPainter(progress: _animation.value),
        );
      },
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final double progress;

  BackgroundPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.black.withOpacity(0.8),
          Colors.red.withOpacity(1),
          Colors.black.withOpacity(0.8)
        ],
        stops: [progress, progress + 0.2, progress + 0.4],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


