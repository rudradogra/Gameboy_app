import 'package:flutter/material.dart';

class GameboyLogo extends StatelessWidget {
  const GameboyLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'GAME BOY ',
          style: TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.grey[200],
            letterSpacing: 1.5,
          ),
        ),
        Text(
          'C',
          style: TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.cyanAccent,
          ),
        ),
        Text(
          'O',
          style: TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.pinkAccent,
          ),
        ),
        Text(
          'L',
          style: TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.yellowAccent,
          ),
        ),
        Text(
          'O',
          style: TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.greenAccent,
          ),
        ),
        Text(
          'R',
          style: TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.deepPurpleAccent,
          ),
        ),
      ],
    );
  }
} 