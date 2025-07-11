import 'package:flutter/material.dart';

class GameboyDpad extends StatelessWidget {
  const GameboyDpad({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 20,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          Container(
            width: 60,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          Container(width: 28, height: 28, decoration: BoxDecoration(color: Colors.black87, shape: BoxShape.circle)),
        ],
      ),
    );
  }
} 