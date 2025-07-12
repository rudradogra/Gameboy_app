import 'package:flutter/material.dart';

class GameboyPowerButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isActive;

  const GameboyPowerButton({
    Key? key,
    this.onPressed,
    this.isActive = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isActive ? onPressed : null,
      child: Container(
        width: 25,
        height: 25,
        decoration: BoxDecoration(
          color: isActive ? Colors.red[800] : Colors.grey[600],
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive ? Colors.red[900]! : Colors.grey[700]!,
            width: 2,
          ),
          boxShadow: isActive ? [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 3,
              offset: Offset(2, 2),
            ),
          ] : [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 2,
              offset: Offset(1, 1),
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.grey[400],
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
