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
      ],
    );
  }
} 