import 'package:flutter/material.dart';

class GameboyButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const GameboyButton({Key? key, required this.label, this.onPressed})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isEnabled ? Colors.black87 : Colors.grey[600],
          shape: BoxShape.circle,
          boxShadow: isEnabled
              ? [
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
                ]
              : [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 3,
                    offset: Offset(1, 1),
                  ),
                ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isEnabled ? Colors.white : Colors.grey[400],
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
