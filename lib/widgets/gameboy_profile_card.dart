import 'package:flutter/material.dart';

class GameboyProfileCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final int age;
  final List<String> info;

  const GameboyProfileCard({
    Key? key,
    required this.imageUrl,
    required this.name,
    required this.age,
    required this.info,
  }) : assert(info.length == 3), super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF231616),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              height: 80,
              width: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 80,
                width: 80,
                color: Colors.grey[800],
                child: Icon(Icons.person, color: Colors.white38, size: 40),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Name and Age
          Text(
            '$name, $age',
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          // Info lines
          ...info.map((line) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Text(
              line,
              style: const TextStyle(
                color: Colors.white70,
                fontFamily: 'monospace',
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          )),
        ],
      ),
    );
  }
} 