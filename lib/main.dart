import 'package:flutter/material.dart';
import 'package:futsal/screens/dashboard.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  void _toggleTheme(bool isDarkMode) {
    setState(() {
      _isDarkMode = isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: SplashScreen(onThemeChanged: _toggleTheme),
    );
  }
}


class SplashScreen extends StatefulWidget {
  final ValueChanged<bool>? onThemeChanged;

  const SplashScreen({super.key, this.onThemeChanged});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}


class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
        )
    );

        _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
        )
    );

        _slideAnimation = Tween<Offset>(
        begin: const Offset(0.0, 0.5),
    end: Offset.zero,
    ).animate(
    CurvedAnimation(
    parent: _animationController,
    curve: Curves.fastOutSlowIn,
    ),
    );

    _animationController.forward();

    Future.delayed(const Duration(seconds: 3), () {
    if (mounted) {
    Navigator.of(context).pushReplacement(
    MaterialPageRoute(
    builder: (context) => DashboardScreen(
    onThemeChanged: widget.onThemeChanged!,
    ),
    ),
    );
    }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade800,
              Colors.green.shade900,
              Colors.green.shade700,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SlideTransition(
                position: _slideAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Icon(
                          Icons.sports_soccer,
                          size: 120,
                          color: Colors.white,
                          shadows: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        Positioned(
                          bottom: 20,
                          child: Container(
                            width: 100,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'FUTSAL PRO',
                  style: GoogleFonts.orbitron(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 4,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Tactical Management System',
                  style: GoogleFonts.raleway(
                    fontSize: 16,
                    color: Colors.white70,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 50),
              CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
                backgroundColor: Colors.white.withOpacity(0.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}