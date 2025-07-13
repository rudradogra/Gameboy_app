import 'package:flutter/material.dart';
import '../widgets/gameboy_screen.dart';
import '../widgets/gameboy_dpad.dart';
import '../widgets/gameboy_button.dart';
import '../widgets/gameboy_pill_button.dart';
import '../widgets/gameboy_speaker_dots.dart';
import '../widgets/gameboy_logo.dart';
import '../widgets/gameboy_profile_card.dart';
import '../widgets/gameboy_controls_popup.dart';
import '../widgets/gameboy_action_popup.dart';
import '../services/api_service.dart';
import '../services/gameboy_sound.dart';
import '../widgets/grainy_texture.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentProfileIndex = 0;
  int currentImageIndex = 0;
  bool showProfileInfo = false;

  final List<Map<String, dynamic>> profiles = [
    {
      'imageUrls': [
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop&crop=face',
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&h=400&fit=crop&crop=face',
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&h=400&fit=crop&crop=face',
      ],
      'name': 'Rudra Dogra',
      'age': 19,
      'info': ['Software Developer', 'From Delhi', 'Loves coding and gaming!'],
    },
    {
      'imageUrls': [
        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=400&fit=crop&crop=face',
        'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=400&fit=crop&crop=face',
        'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&h=400&fit=crop&crop=face',
      ],
      'name': 'Alex Rodriguez',
      'age': 25,
      'info': ['Photographer', 'From Barcelona', 'Adventure seeker'],
    },
  ];

  void _handleDpadNavigation(String direction) {
    setState(() {
      if (direction == 'down') {
        // Toggle info when down is pressed
        showProfileInfo = !showProfileInfo;
      } else if (direction == 'center') {
        // Edit profile when center is pressed (Note: this doesn't call setState since it's a navigation)
      } else if (direction == 'up') {
        // Superlike when up is pressed (Note: this doesn't call setState since it shows popup)
      } else if (direction == 'left') {
        // Navigate to previous image
        final currentProfile = profiles[currentProfileIndex];
        final imageCount = (currentProfile['imageUrls'] as List).length;
        currentImageIndex = (currentImageIndex - 1 + imageCount) % imageCount;
      } else if (direction == 'right') {
        // Navigate to next image
        final currentProfile = profiles[currentProfileIndex];
        final imageCount = (currentProfile['imageUrls'] as List).length;
        currentImageIndex = (currentImageIndex + 1) % imageCount;
      }
    });

    // Handle actions that don't need setState
    if (direction == 'center') {
      _editProfile();
    } else if (direction == 'up') {
      _handleSuperlike();
    }
  }

  void _handleSuperlike() {
    GameboyActionPopup.show(
      context,
      'SUPERLIKE!',
      message: '${profiles[currentProfileIndex]['name']}\nSUPERLIKED!',
      backgroundColor: Colors.amber,
      icon: Icons.star,
      duration: Duration(milliseconds: 500),
    );
    _nextProfile();
  }

  void _handleLike() {
    GameboyActionPopup.show(
      context,
      'LIKED!',
      message: '${profiles[currentProfileIndex]['name']}\nLIKED!',
      backgroundColor: Colors.green,
      icon: Icons.favorite,
      duration: Duration(milliseconds: 500),
    );
    _nextProfile();
  }

  void _handlePass() {
    GameboyActionPopup.show(
      context,
      'PASSED',
      message: '${profiles[currentProfileIndex]['name']}\nPASSED',
      backgroundColor: Colors.redAccent,
      icon: Icons.close,
      duration: Duration(milliseconds: 500),
    );
    _nextProfile();
  }

  void _nextProfile() {
    setState(() {
      currentProfileIndex = (currentProfileIndex + 1) % profiles.length;
      currentImageIndex = 0; // Reset image index for new profile
      showProfileInfo = false; // Reset info state for new profile
    });
  }

  void _logout() {
    print('🚪 Logout function called');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF8B0000),
        title: Text(
          'Logout',
          style: TextStyle(color: Colors.white, fontFamily: 'PublicPixel'),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.white70, fontFamily: 'PublicPixel'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.white70,
                fontFamily: 'PublicPixel',
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: Text(
              'Logout',
              style: TextStyle(
                color: Colors.cyanAccent,
                fontFamily: 'PublicPixel',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editProfile() async {
    try {
      print('🔄 Starting edit profile flow...');

      // Fetch the logged-in user's profile
      final result = await ApiService.getMyProfile();

      if (result['success']) {
        final userProfile = result['data']['profile'];
        print('✅ Profile loaded successfully: ${userProfile['bio']}');

        // Transform API response to expected format
        final transformedProfile = {
          'name': userProfile['name'] ?? '', // API might not have name field
          'age': userProfile['age'],
          'bio': userProfile['bio'],
          'location': userProfile['location'],
          'interests': userProfile['interests'] ?? [],
          'imageUrls':
              userProfile['image_urls'] ??
              [], // Transform image_urls to imageUrls
          'images':
              userProfile['image_urls'] ??
              [], // Also add images for backwards compatibility
        };

        // Navigate to edit screen with user's own profile
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  EditProfileScreen(currentProfile: transformedProfile),
            ),
          ).then((updatedProfile) {
            // Handle the returned updated profile if needed
            if (updatedProfile != null) {
              print('✅ Profile updated: $updatedProfile');
              // You could refresh the homepage data here if needed
            }
          });
        }
      } else {
        // Check if this is a "profile not found" error
        final errorMessage = result['message'] ?? '';
        final isProfileNotFound =
            errorMessage.toLowerCase().contains('profile not found') ||
            errorMessage.toLowerCase().contains('create your profile');

        print('🔍 Error message: $errorMessage');
        print('🔍 Is profile not found: $isProfileNotFound');

        if (isProfileNotFound) {
          // Profile doesn't exist yet - navigate directly to create profile
          print('✅ Profile not found - navigating to create profile');
          GameBoySound.playNavigation();

          // Navigate to edit screen with empty profile data for creation
          print('🧭 Navigating to create profile screen...');
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProfileScreen(
                  currentProfile: {
                    'name': '',
                    'age':
                        null, // Changed from 18 to null so it shows placeholder
                    'bio': '',
                    'interests': <String>[],
                    'profilePicture': null,
                  },
                ),
              ),
            ).then((updatedProfile) {
              if (updatedProfile != null) {
                print('✅ Profile created: $updatedProfile');
              }
            });
          } else {
            print('❌ Widget not mounted, skipping navigation');
          }
        } else {
          // Other errors - show error message
          GameBoySound.playError();
          GameboyActionPopup.show(
            context,
            'Error',
            message: errorMessage.isNotEmpty
                ? errorMessage
                : 'Failed to load profile',
            backgroundColor: Colors.red,
            icon: Icons.error,
          );
        }
      }
    } catch (e) {
      print('💥 Edit profile error: $e');
      GameBoySound.playError();
      GameboyActionPopup.show(
        context,
        'Network Error',
        message: 'Unable to connect to server',
        backgroundColor: Colors.red,
        icon: Icons.wifi_off,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🏠 HomePage build method called');
    final currentProfile = profiles[currentProfileIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A), // Subtle dark background
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: AspectRatio(
            aspectRatio: 2 / 3.7, // Slightly taller for realism
            child: GrainyContainer(
              color: const Color(0xFF8B0000),
              borderRadius: BorderRadius.circular(40),
              intensity: 0.25,
              seed: 12345,
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
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
                              key: ValueKey(
                                'profile_${currentProfileIndex}_${currentImageIndex}_$showProfileInfo',
                              ),
                              imageUrl: currentProfile['imageUrls'],
                              name: currentProfile['name'],
                              age: currentProfile['age'],
                              info: List<String>.from(currentProfile['info']),
                              currentImageIndex: currentImageIndex,
                              showInfo: showProfileInfo,
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
                                  '↑': 'Superlike profile',
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
                        padding: const EdgeInsets.only(
                          right: 32.0,
                          bottom: 18.0,
                        ),
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
      ),
    );
  }
}
