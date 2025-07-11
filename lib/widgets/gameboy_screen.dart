import 'package:flutter/material.dart';

class GameboyScreen extends StatelessWidget {
  final Widget? child;
  const GameboyScreen({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black, width: 8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF231616),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[900]!, width: 2),
          ),
          child: child ?? Center(
            child: Text(
              'Profile Content',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'monospace',
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
} 