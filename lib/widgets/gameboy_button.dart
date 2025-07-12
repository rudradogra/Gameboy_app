import 'package:flutter/material.dart';
import 'grainy_texture.dart';
import '../services/gameboy_sound.dart';

class GameboyButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const GameboyButton({Key? key, required this.label, this.onPressed})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null;

    return GestureDetector(
      onTap: onPressed != null
          ? () {
              GameBoySound.playButtonClick();
              onPressed!();
            }
          : null,
      child: GrainyContainer(
        color: isEnabled ? Colors.black87 : Colors.grey[600]!,
        borderRadius: BorderRadius.circular(25), // Circular shape
        intensity: 0.3,
        seed: label.hashCode, // Use label hash for consistent grain per button
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
        child: Container(
          width: 50,
          height: 50,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isEnabled ? Colors.white : Colors.grey[400],
                fontWeight: FontWeight.bold,
                fontSize: 22,
                fontFamily: 'PublicPixel',
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 2,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
