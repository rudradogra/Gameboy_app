import 'package:flutter/material.dart';

class GameboyScreen extends StatelessWidget {
  final Widget? child;
  const GameboyScreen({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18), // Matches screen bottom radius
          topRight: Radius.circular(18), // Matches screen bottom radius
        ),
        border: Border.all(color: Colors.black, width: 16), // Increased border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0), // Increased padding
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFE6E6FA), // Light lavender
                Color(0xFFDDA0DD), // Plum
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Color(0xFFFF69B4),
              width: 3,
            ), // Hot pink border
          ),
          child:
              child ??
              Center(
                child: Text(
                  'Profile Content',
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'PublicPixel',
                    fontSize: 18,
                  ),
                ),
              ),
        ),
      ),
    );
  }
}
