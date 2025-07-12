import 'package:flutter/material.dart';
import '../services/gameboy_sound.dart';

class GameboyControlsPopup {
  static void show(BuildContext context, Map<String, String> controls) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 280,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF8B0000),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.cyanAccent, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyanAccent.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.gamepad, color: Colors.cyanAccent, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'GAMEBOY CONTROLS',
                        style: TextStyle(
                          color: Colors.cyanAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'PublicPixel',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Controls list
                ...controls.entries
                    .map(
                      (entry) => Container(
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: Colors.grey[600]!,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                entry.key,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'PublicPixel',
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: TextStyle(
                                  color: Colors.grey[300],
                                  fontSize: 8,
                                  fontFamily: 'PublicPixel',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),

                const SizedBox(height: 16),

                // Action buttons row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Sound toggle button
                    GestureDetector(
                      onTap: () {
                        GameBoySound.toggleSound();
                        // Show a brief feedback
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              GameBoySound.isSoundEnabled
                                  ? 'Sound ON'
                                  : 'Sound OFF',
                              style: TextStyle(
                                fontFamily: 'PublicPixel',
                                fontSize: 8,
                              ),
                            ),
                            duration: Duration(milliseconds: 800),
                            backgroundColor: const Color(0xFF8B0000),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: GameBoySound.isSoundEnabled
                              ? Colors.green
                              : Colors.grey[400],
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              GameBoySound.isSoundEnabled
                                  ? Icons.volume_up
                                  : Icons.volume_off,
                              color: Colors.black,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              GameBoySound.isSoundEnabled ? 'ON' : 'OFF',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'PublicPixel',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Close button
                    GestureDetector(
                      onTap: () {
                        GameBoySound.playButtonClick();
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.cyanAccent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'CLOSE',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'PublicPixel',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
