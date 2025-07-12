import 'package:flutter/material.dart';

class GameboyButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const GameboyButton({Key? key, required this.label, this.onPressed})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.black87,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 6,
              offset: Offset(3, 3),
            ),
            BoxShadow(
              color: Colors.white24,
              blurRadius: 2,
              offset: Offset(-1, -1),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ),
    );
  }
}
