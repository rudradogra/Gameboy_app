import 'package:flutter/material.dart';
import '../widgets/gameboy_screen.dart';
import '../widgets/gameboy_dpad.dart';
import '../widgets/gameboy_button.dart';
import '../widgets/gameboy_pill_button.dart';
import '../widgets/gameboy_speaker_dots.dart';
import '../widgets/gameboy_logo.dart';
import '../widgets/gameboy_profile_card.dart';
import '../widgets/gameboy_controls_popup.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentProfileIndex = 0;
  final GlobalKey<GameboyProfileCardState> _profileCardKey = GlobalKey();

  final List<Map<String, dynamic>> profiles = [
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop&crop=face',
      'name': 'Rudra Dogra',
      'age': 19,
      'info': ['Software Developer', 'From Delhi', 'Loves coding and gaming!'],
    },
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1494790108755-2616c0763b13?w=400&h=400&fit=crop&crop=face',
      'name': 'Sarah Chen',
      'age': 22,
      'info': ['Graphic Designer', 'From Tokyo', 'Art and coffee enthusiast'],
    },
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=400&fit=crop&crop=face',
      'name': 'Alex Rodriguez',
      'age': 25,
      'info': ['Photographer', 'From Barcelona', 'Adventure seeker'],
    },
  ];

  void _handleDpadNavigation(String direction) {
    if (direction == 'down') {
      // Toggle the profile info when down is pressed
      _profileCardKey.currentState?.toggleInfo();
    } else if (direction == 'center') {
      // Edit profile when center is pressed
      _editProfile();
    }
    print('D-pad pressed: $direction');
  }

  void _handleLike() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Liked ${profiles[currentProfileIndex]['name']}! 💖'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );
    _nextProfile();
  }

  void _handlePass() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Passed on ${profiles[currentProfileIndex]['name']}'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 1),
      ),
    );
    _nextProfile();
  }

  void _nextProfile() {
    setState(() {
      currentProfileIndex = (currentProfileIndex + 1) % profiles.length;
    });
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF8B0000),
        title: Text(
          'Logout',
          style: TextStyle(color: Colors.white, fontFamily: 'monospace'),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.white70, fontFamily: 'monospace'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: Text('Logout', style: TextStyle(color: Colors.cyanAccent)),
          ),
        ],
      ),
    );
  }

  void _editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditProfileScreen(currentProfile: profiles[currentProfileIndex]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentProfile = profiles[currentProfileIndex];

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
                    const SizedBox(height: 20),
                    // Screen and Power button stack
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0),
                      child: AspectRatio(
                        aspectRatio: 1.1,
                        child: GameboyScreen(
                          child: GameboyProfileCard(
                            key: _profileCardKey,
                            imageUrl: currentProfile['imageUrl'],
                            name: currentProfile['name'],
                            age: currentProfile['age'],
                            info: List<String>.from(currentProfile['info']),
                          ),
                        ),
                      ),
                    ),
                    // GameBoy Logo in black border container
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0),
                      child: const GameboyLogo(),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(width: 20),
                          // D-pad
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16.0,
                              top: 16.0,
                            ),
                            child: GameboyDpad(
                              onDirectionPressed: _handleDpadNavigation,
                            ),
                          ),
                          const Spacer(),
                          // A/B buttons (diagonal layout)
                          Padding(
                            padding: const EdgeInsets.only(
                              right: 32.0,
                              top: 8.0,
                            ),
                            child: SizedBox(
                              width: 120,
                              height: 100,
                              child: Stack(
                                children: [
                                  // B button (bottom-left)
                                  Positioned(
                                    left: 0,
                                    top: 50,
                                    child: GameboyButton(
                                      label: 'B',
                                      onPressed: _handlePass,
                                    ),
                                  ),
                                  // A button (top-right)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: GameboyButton(
                                      label: 'A',
                                      onPressed: _handleLike,
                                    ),
                                  ),
                                ],
                              ),
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
                        children: [
                          GameboyPillButton(
                            label: 'SELECT',
                            onPressed: () {
                              // Show controls popup
                              GameboyControlsPopup.show(context, {
                                '↑ ↓': 'Not used',
                                '← →': 'Not used',
                                'CENTER': 'Edit your profile',
                                '↓': 'Toggle profile info',
                                'A': 'Like profile',
                                'B': 'Pass on profile',
                                'START': 'Logout',
                                'SELECT': 'Show controls (this popup)',
                              });
                            },
                          ),
                          const SizedBox(width: 24),
                          GameboyPillButton(
                            label: 'START',
                            onPressed: _logout,
                          ),
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
