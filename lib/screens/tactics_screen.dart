import 'package:flutter/material.dart';

class FutsalField extends StatefulWidget {
  @override
  _FutsalFieldState createState() => _FutsalFieldState();
}

class _FutsalFieldState extends State<FutsalField> {
  Offset ballPosition = Offset.zero;
  List<Offset> whitePlayers = [];
  List<Offset> blackPlayers = [];
  String selectedFormation = '3-1';
  final Map<String, List<Offset>> _formations = {
    '3-1':const [
      Offset(0.2, 0.85), // Left defender
      Offset(0.5, 0.8),  // Center defender
      Offset(0.8, 0.85), // Right defender
      Offset(0.5, 0.65), // Pivot
      Offset(0.5, 0.92), // Goalkeeper
    ],
    '2-2':const [
      Offset(0.3, 0.8),  // Left back
      Offset(0.7, 0.8),  // Right back
      Offset(0.3, 0.65), // Left forward
      Offset(0.7, 0.65), // Right forward
      Offset(0.5, 0.92), // Goalkeeper
    ],
    '1-2-1':const [
      Offset(0.5, 0.8),  // Center defender
      Offset(0.3, 0.7),  // Left mid
      Offset(0.7, 0.7),  // Right mid
      Offset(0.5, 0.6),  // Forward
      Offset(0.5, 0.92), // Goalkeeper
    ],
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateFormation();
  }

  void _updateFormation() {
    final size = MediaQuery.sizeOf(context);
    setState(() {
      ballPosition = Offset(size.width / 2, size.height / 2);

      whitePlayers = _formations[selectedFormation]!
          .map((offset) => Offset(offset.dx * size.width, offset.dy * size.height))
          .toList();

      blackPlayers = _formations[selectedFormation]!
          .map((offset) => Offset(offset.dx * size.width, (1 - offset.dy) * size.height))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Futsal Tactical Board - $selectedFormation'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                selectedFormation = value;
                _updateFormation();
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: '3-1', child: Text('3-1 Formation')),
              const PopupMenuItem(value: '2-2', child: Text('2-2 Formation')),
              const PopupMenuItem(value: '1-2-1', child: Text('1-2-1 Formation')),
            ],
          ),
        ],
      ),
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
              ..._buildPlayers(whitePlayers, Colors.white, true),
              ..._buildPlayers(blackPlayers, Colors.red, false),
              _buildBall(ballPosition),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildPlayers(List<Offset> players, Color color, bool isHomeTeam) {
    return players.asMap().entries.map((entry) {
      final index = entry.key;
      final position = entry.value;
      final isGoalkeeper = index == 4;

      return Positioned(
        left: position.dx - 25,
        top: position.dy - 25,
        child: Draggable(
          feedback: _PlayerWidget(
            number: index + 1,
            color: isGoalkeeper ? Colors.yellow : color,
            isGoalkeeper: isGoalkeeper,
          ),
          childWhenDragging: Opacity(opacity: 0.5, child: _PlayerWidget(
            number: index + 1,
            color: isGoalkeeper ? Colors.yellow : color,
            isGoalkeeper: isGoalkeeper,
          )),
          onDragEnd: (details) {
            if (!isGoalkeeper) {
              setState(() {
                players[index] = details.offset;
              });
            }
          },
          child: _PlayerWidget(
            number: index + 1,
            color: isGoalkeeper ? Colors.yellow : color,
            isGoalkeeper: isGoalkeeper,
          ),
        ),
      );
    }).toList();
  }

  Widget _buildBall(Offset position) {
    return Positioned(
      left: position.dx - 15,
      top: position.dy - 15,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            ballPosition = details.localPosition + position - const Offset(15, 15);
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

class _PlayerWidget extends StatelessWidget {
  final int number;
  final Color color;
  final bool isGoalkeeper;

  const _PlayerWidget({
    required this.number,
    required this.color,
    this.isGoalkeeper = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color,
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isGoalkeeper)
              const Icon(Icons.sports_handball, size: 20, color: Colors.black),
            Text(
              '$number',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}