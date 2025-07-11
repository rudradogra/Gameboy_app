import 'package:flutter/material.dart';

class GameboyPillButton extends StatelessWidget {
  final String label;
  const GameboyPillButton({Key? key, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[400],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 2,
            offset: Offset(1, 1),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.black87,
          fontFamily: 'monospace',
          fontSize: 14,
        ),
      ),
    );
  }
} 