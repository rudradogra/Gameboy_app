import 'package:flutter/material.dart';

class GameboyLogo extends StatelessWidget {
  const GameboyLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          // Matches screen bottom radius
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
      ),
      child: Text(
        'SWIPE BOY',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'PublicPixel',
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.grey[200],
          letterSpacing: 2.0,
        ),
      ),
    );
  }
}
