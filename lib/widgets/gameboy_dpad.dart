import 'package:flutter/material.dart';
import 'grainy_texture.dart';

class GameboyDpad extends StatelessWidget {
  final Function(String)? onDirectionPressed;

  const GameboyDpad({Key? key, this.onDirectionPressed}) : super(key: key);

  Widget _buildDirectionButton(
    String direction,
    Alignment alignment,
    IconData icon,
  ) {
    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: GestureDetector(
          onTap: () => onDirectionPressed?.call(direction),
          child: GrainyContainer(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(6),
            intensity: 0.3,
            seed: direction.hashCode, // Unique grain per direction
            boxShadow: [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 3,
                offset: Offset(1, 1),
              ),
              BoxShadow(
                color: Colors.white24,
                blurRadius: 1,
                offset: Offset(-0.5, -0.5),
              ),
            ],
            child: Container(
              width: 35,
              height: 35,
              child: Icon(icon, color: Colors.white70, size: 20),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        children: [
          // Up button
          _buildDirectionButton(
            'up',
            Alignment.topCenter,
            Icons.keyboard_arrow_up,
          ),
          // Down button
          _buildDirectionButton(
            'down',
            Alignment.bottomCenter,
            Icons.keyboard_arrow_down,
          ),
          // Left button
          _buildDirectionButton(
            'left',
            Alignment.centerLeft,
            Icons.keyboard_arrow_left,
          ),
          // Right button
          _buildDirectionButton(
            'right',
            Alignment.centerRight,
            Icons.keyboard_arrow_right,
          ),
          // Center button
          Center(
            child: GestureDetector(
              onTap: () => onDirectionPressed?.call('center'),
              child: GrainyContainer(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(4),
                intensity: 0.3,
                seed: 'center'.hashCode,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 2,
                    offset: Offset(1, 1),
                  ),
                  BoxShadow(
                    color: Colors.white24,
                    blurRadius: 1,
                    offset: Offset(-0.5, -0.5),
                  ),
                ],
                child: Container(
                  width: 28,
                  height: 28,
                  child: Icon(
                    Icons.circle_outlined,
                    color: Colors.white70,
                    size: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
