import 'dart:io';
import 'package:flutter/material.dart';
import 'package:futsal/database/helper.dart';

class FutsalField extends StatefulWidget {
  @override
  _FutsalFieldState createState() => _FutsalFieldState();
}

class _FutsalFieldState extends State<FutsalField> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  Offset ballPosition = Offset.zero;
  List<Player> whiteTeam = List.generate(
    5,
        (index) => Player(
      position1: Offset.zero,
      position: index == 4 ? 'Goalkeeper' : 'Player',
    ),
  );
  List<Player> blackTeam = List.generate(
    5,
        (index) => Player(
      position1: Offset.zero,
      position: index == 4 ? 'Goalkeeper' : 'Player',
    ),
  );
  String selectedFormation = '3-1';

  final Map<String, List<Offset>> _formations = {
    '3-1': const [
      Offset(0.2, 0.85), // Left defender
      Offset(0.5, 0.8),  // Center defender
      Offset(0.8, 0.85), // Right defender
      Offset(0.5, 0.65), // Pivot
      Offset(0.5, 0.92), // Goalkeeper
    ],
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateFormation();
  }

  void _updateFormation() {
    final size = MediaQuery.of(context).size;
    setState(() {
      ballPosition = Offset(size.width / 2, size.height / 2);
      _applyFormation(whiteTeam, size, false);
      _applyFormation(blackTeam, size, true);
    });
  }

  void _applyFormation(List<Player> team, Size size, bool isOpponent) {
    final formation = _formations[selectedFormation]!;
    for (int i = 0; i < 5; i++) {
      final offset = formation[i];
      team[i].position1 = Offset(
        offset.dx * size.width,
        isOpponent ? (1 - offset.dy) * size.height : offset.dy * size.height,
      );
    }
  }

  Future<void> _selectPlayer(int index, bool isWhiteTeam) async {
    final players = await _dbHelper.getAllMainTeamPlayers();
    final selected = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Player'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: players.length,
            itemBuilder: (context, i) => ListTile(
              leading: _buildPlayerAvatar(players[i]['imagePath']),
              title: Text('${players[i]['firstName']} ${players[i]['lastName']}'),
              subtitle: Text('No. ${players[i]['jerseyNumber']} • ${players[i]['position']}'),
              onTap: () => Navigator.pop(context, players[i]),
            ),
          ),
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        if (isWhiteTeam) {
          whiteTeam[index] = Player.fromMap(selected, whiteTeam[index].position1);
        } else {
          blackTeam[index] = Player.fromMap(selected, blackTeam[index].position1);
        }
      });
    }
  }

  Widget _buildPlayerAvatar(String? imagePath) {
    return CircleAvatar(
      radius: 20,
      backgroundImage: imagePath != null ? FileImage(File(imagePath)) : null,
      child: imagePath == null ? const Icon(Icons.person) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [

              Positioned.fill(
                child: Image.asset(
                  'assets/image/futsal.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              ..._buildTeam(whiteTeam, Colors.white, true),
              ..._buildTeam(blackTeam, Colors.red, false),
              _buildBall(),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildTeam(List<Player> team, Color color, bool isWhiteTeam) {
    return team.asMap().entries.map((entry) {
      final index = entry.key;
      final player = entry.value;
      final isGoalkeeper = index == 4;

      return Positioned(
        left: player.position1.dx - 25,
        top: player.position1.dy - 25,
        child: GestureDetector(
          onPanUpdate: (details) {
            if (!isGoalkeeper) {
              setState(() {
                player.position1 = Offset(
                  (player.position1.dx + details.delta.dx)
                      .clamp(0.0, MediaQuery.of(context).size.width - 50),
                  (player.position1.dy + details.delta.dy)
                      .clamp(0.0, MediaQuery.of(context).size.height - 50),
                );
              });
            }
          },
          onTap: () => _selectPlayer(index, isWhiteTeam),
          child: _PlayerWidget(
            player: player,
            color: isGoalkeeper ? Colors.yellow : color,
            isGoalkeeper: isGoalkeeper,
          ),
        ),
      );
    }).toList();
  }

  Widget _buildBall() {
    return Positioned(
      left: ballPosition.dx - 15,
      top: ballPosition.dy - 15,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            ballPosition = Offset(
              (ballPosition.dx + details.delta.dx)
                  .clamp(0.0, MediaQuery.of(context).size.width - 30),
              (ballPosition.dy + details.delta.dy)
                  .clamp(0.0, MediaQuery.of(context).size.height - 30),
            );
          });
        },
        child: Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [Colors.white, Colors.grey],
              stops: [0.4, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
          ),
          child: const Icon(
            Icons.sports_soccer,
            size: 20,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

class Player {
  int? id;
  String firstName;
  String lastName;
  int jerseyNumber;
  String position;
  String? imagePath;
  Offset position1;

  Player({
    this.id,
    this.firstName = '',
    this.lastName = '',
    this.jerseyNumber = 0,
    this.position = '',
    this.imagePath,
    required this.position1,
  });

  factory Player.fromMap(Map<String, dynamic> map, Offset position1) => Player(
    id: map['id'],
    firstName: map['firstName'],
    lastName: map['lastName'],
    jerseyNumber: map['jerseyNumber'],
    position: map['position'],
    imagePath: map['imagePath'],
    position1: position1,
  );
}

class _PlayerWidget extends StatelessWidget {
  final Player player;
  final Color color;
  final bool isGoalkeeper;

  const _PlayerWidget({
    required this.player,
    required this.color,
    this.isGoalkeeper = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (player.imagePath != null)
            CircleAvatar(
              radius: 20,
              backgroundImage: FileImage(File(player.imagePath!)),
            )
          else
            Text(
              player.firstName,
              style: TextStyle(
                // fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color.computeLuminance() > 0.5
                    ? Colors.black
                    : Colors.white,
              ),
            ),
          if (isGoalkeeper)
            const Icon(Icons.sports_handball, size: 16, color: Colors.black),
        ],
      ),
    );
  }
}