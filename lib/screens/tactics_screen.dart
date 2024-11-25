import 'package:flutter/material\.dart';


class FutsalField extends StatefulWidget {
  @override
  _FutsalFieldState createState() => _FutsalFieldState();
}

class _FutsalFieldState extends State<FutsalField> {
  Offset ballPosition = const Offset(175, 400);
  List<Offset> whitePlayers = [
    const Offset(100, 500),
    const Offset(200, 500),
    const Offset(150, 600),
    const Offset(250, 600),
    const Offset(175, 700),
  ];
  List<Offset> blackPlayers = [
    const Offset(100, 100),
    const Offset(200, 100),
    const Offset(150, 200),
    const Offset(250, 200),
    const Offset(175, 300),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/image/futsal.jpg',
              fit: BoxFit.cover,
            ),
          ),
          ..._buildPlayers(whitePlayers, Colors.white),
          ..._buildPlayers(blackPlayers, Colors.black),
          _buildBall(ballPosition),
        ],
      ),
    );
  }

  List<Widget> _buildPlayers(List<Offset> players, Color color) {
    return players.map((position) {
      return Positioned(
        left: position.dx,
        top: position.dy,
        child: Draggable(
          feedback: CircleAvatar(radius: 30, backgroundColor: color),
          childWhenDragging: Container(),
          onDragEnd: (details) {
            setState(() {
              int index = players.indexOf(position);
              players[index] = details.offset;
            });
          },
          child: CircleAvatar(radius: 20, backgroundColor: color),
        ),
      );
    }).toList();
  }

  Widget _buildBall(Offset position) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            ballPosition = Offset(ballPosition.dx + details.delta.dx, ballPosition.dy + details.delta.dy);
          });
        },
        child:const CircleAvatar(
          radius: 15,
          backgroundColor: Colors.white,
          child:Icon(Icons.sports_baseball)
          //Image.asset('images/ball.png'),
        ),
      ),
    );
  }
}
