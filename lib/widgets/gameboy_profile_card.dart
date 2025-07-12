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
  }) : assert(info.length == 3),
       super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Profile Image with rounded corners
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                height: 140,
                width: 140,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 140,
                  width: 140,
                  color: Colors.grey[300],
                  child: Icon(Icons.person, color: Colors.grey[600], size: 60),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Name and age in black text box style
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$name, $age',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
