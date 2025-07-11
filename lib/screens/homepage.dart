import 'package:flutter/material.dart';
import '../widgets/gameboy_screen.dart';
import '../widgets/gameboy_dpad.dart';
import '../widgets/gameboy_button.dart';
import '../widgets/gameboy_pill_button.dart';
import '../widgets/gameboy_speaker_dots.dart';
import '../widgets/gameboy_logo.dart';
import '../widgets/gameboy_profile_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181818),
      body: Center(
        child: AspectRatio(
          aspectRatio: 2 / 3.7, // Slightly taller for realism
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF8B0000),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyanAccent.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Main column for vertical layout
                Column(
                  children: [
                    const SizedBox(height: 28),
                    // Gameboy Screen with thick bezel
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0),
                      child: AspectRatio(
                        aspectRatio: 1.1, // Slightly wider for realism
                        child: GameboyScreen(
                          child: GameboyProfileCard(
                            imageUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
                            name: 'Ash Ketchum',
                            age: 21,
                            info: [
                              'Pokemon Trainer',
                              'From Pallet Town',
                              'Wants to be the very best!',
                            ],
                          ),
                        ),
                      ),
                    ),
                    // GAME BOY COLOR logo
                    const SizedBox(height: 8),
                    const GameboyLogo(),
                    // Spacer for button area
                    const SizedBox(height: 18),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // D-pad
                          Padding(
                            padding: const EdgeInsets.only(left: 32.0, top: 16.0),
                            child: GameboyDpad(),
                          ),
                          const Spacer(),
                          // A/B buttons (B lower than A)
                          Padding(
                            padding: const EdgeInsets.only(right: 38.0, top: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: const [
                                GameboyButton(label: 'A'),
                                SizedBox(height: 24),
                                GameboyButton(label: 'B'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Select/Start row
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          GameboyPillButton(label: 'SELECT'),
                          SizedBox(width: 24),
                          GameboyPillButton(label: 'START'),
                        ],
                      ),
                    ),
                    // Speaker dots
                    Padding(
                      padding: const EdgeInsets.only(right: 32.0, bottom: 18.0),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: GameboySpeakerDots(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 