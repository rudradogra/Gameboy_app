import 'package:flutter/material.dart';

class GameboyPillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const GameboyPillButton({Key? key, required this.label, this.onPressed})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
            BoxShadow(
              color: Colors.white70,
              blurRadius: 2,
              offset: Offset(-1, -1),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black87,
            fontFamily: 'monospace',
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
