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
  bool isLoading = true;
  bool isPerformingAction = false;
  double heartsRemaining = 10.0; // Start with 10 full hearts
  bool isOutOfHearts = false; // Track if user has used all hearts

  List<Map<String, dynamic>> profiles = [];

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    try {
      print('🔄 HomePage: Starting _loadProfiles method');
      setState(() {
        isLoading = true;
      });

      print('🔄 Loading profiles from backend...');
      final result = await ApiService.discoverProfiles(page: 1, limit: 10);

      print('📥 HomePage: Received API result: ${result['success']}');
      print('🔍 HomePage: Full API response: $result');

      if (result['success']) {
        print('✅ HomePage: API call successful, processing data...');

        // Check if 'data' key exists and has 'profiles'
        if (result['data'] == null) {
          print('❌ HomePage: result[data] is null!');
          print('🔍 HomePage: Available keys: ${result.keys.toList()}');
        } else {
          print('✅ HomePage: result[data] exists');
          print('🔍 HomePage: data keys: ${result['data'].keys.toList()}');
        }

        final profilesData = result['data']['profiles'] as List;
        print('📋 HomePage: Raw profiles data length: ${profilesData.length}');
        print(
          '🔍 HomePage: First profile sample: ${profilesData.isNotEmpty ? profilesData[0] : 'No profiles'}',
        );

        // Transform backend data to match frontend format
        final transformedProfiles = profilesData.map((profile) {
          print(
            '🔄 HomePage: Transforming profile: ${profile['id']} - ${profile['name']}',
          );
          return {
            'id': profile['id'],
            'user_id': profile['user_id'],
            'imageUrls':
                (profile['image_urls'] as List?)?.cast<String>() ??
                [
                  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop&crop=face',
                ],
            'name': profile['name'] ?? 'Anonymous',
            'age': profile['age'] ?? 18,
            'info': [
              profile['bio'] ?? 'No bio available',
              profile['location'] ?? 'Location not specified',
              (profile['interests'] as List?)?.join(', ') ??
                  'No interests listed',
            ],
          };
        }).toList();

        print(
          '✅ HomePage: Transformation complete, ${transformedProfiles.length} profiles transformed',
        );

        setState(() {
          profiles = transformedProfiles;
          currentProfileIndex = 0;
          currentImageIndex = 0;
          showProfileInfo = false;
          isLoading = false;
        });

        print('✅ Loaded ${profiles.length} profiles');
      } else {
        print('❌ Failed to load profiles: ${result['message']}');
        print('🔍 HomePage: Error details: ${result['error']}');
        setState(() {
          isLoading = false;
        });

        // Show error popup
        GameBoySound.playError();
        GameboyActionPopup.show(
          context,
          'Error',
          message: 'Failed to load profiles: ${result['message']}',
          backgroundColor: Colors.red,
          icon: Icons.error,
        );
      }
    } catch (e, stackTrace) {
      print('💥 Error loading profiles: $e');
      print('📍 Stack trace: $stackTrace');
      setState(() {
        isLoading = false;
      });

      GameBoySound.playError();
      GameboyActionPopup.show(
        context,
        'Network Error',
        message: 'Unable to connect to server: $e',
        backgroundColor: Colors.red,
        icon: Icons.wifi_off,
      );
    }
  }

  void _handleDpadNavigation(String direction) {
    // Don't allow navigation if loading or no profiles
    if (isLoading || profiles.isEmpty || isPerformingAction) return;

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
      // Only allow superlike if we have enough hearts
      if (!isOutOfHearts && heartsRemaining >= 1.0) {
        _handleSuperlike();
      } else {
        // Show insufficient hearts message
        _showInsufficientHeartsMessage('superlike', 1.0);
      }
    }
  }

  void _handleSuperlike() async {
    if (isPerformingAction ||
        profiles.isEmpty ||
        isOutOfHearts ||
        heartsRemaining < 1.0)
      return;

    setState(() {
      isPerformingAction = true;
      heartsRemaining -= 1.0; // Superlike costs 1 full heart
      if (heartsRemaining <= 0) {
        isOutOfHearts = true;
      }
    });

    try {
      final currentProfile = profiles[currentProfileIndex];
      print('💫 Superliking ${currentProfile['name']}...');

      // Show immediate feedback
      GameboyActionPopup.show(
        context,
        'SUPERLIKE!',
        message: '${currentProfile['name']}\nSUPERLIKED!',
        backgroundColor: Colors.amber,
        icon: Icons.star,
        duration: Duration(milliseconds: 500),
      );

      // Send to backend
      final result = await ApiService.handleSwipe(
        currentProfile['user_id'],
        'superlike',
      );

      if (result['success']) {
        print('✅ Superlike sent successfully');

        // Check if it's a mutual match
        final matchData = result['data'];
        if (matchData['is_mutual'] == true) {
          // Show match popup
          Future.delayed(Duration(milliseconds: 600), () {
            GameboyActionPopup.show(
              context,
              'IT\'S A MATCH!',
              message: 'You and ${currentProfile['name']} liked each other!',
              backgroundColor: Colors.pink,
              icon: Icons.favorite,
              duration: Duration(milliseconds: 1500),
            );
          });
        }
      } else {
        print('❌ Superlike failed: ${result['message']}');
      }
    } catch (e) {
      print('💥 Superlike error: $e');
    } finally {
      setState(() {
        isPerformingAction = false;
      });
      _nextProfile();

      // Check if hearts are depleted
      if (heartsRemaining <= 0) {
        setState(() {
          isOutOfHearts = true;
        });

        // Show out of hearts popup
        GameboyActionPopup.show(
          context,
          'Out of Hearts',
          message:
              'You\'ve used all your hearts!\nContinue exploring or edit your profile.',
          backgroundColor: Colors.red,
          icon: Icons.favorite_border,
          duration: Duration(seconds: 3),
        );
      }
    }
  }

  void _handleLike() async {
    if (isPerformingAction ||
        profiles.isEmpty ||
        isOutOfHearts ||
        heartsRemaining < 0.5)
      return;

    setState(() {
      isPerformingAction = true;
      heartsRemaining -= 0.5; // Like costs half a heart
      if (heartsRemaining <= 0) {
        isOutOfHearts = true;
      }
    });

    try {
      final currentProfile = profiles[currentProfileIndex];
      print('❤️ Liking ${currentProfile['name']}...');

      // Show immediate feedback
      GameboyActionPopup.show(
        context,
        'LIKED!',
        message: '${currentProfile['name']}\nLIKED!',
        backgroundColor: Colors.green,
        icon: Icons.favorite,
        duration: Duration(milliseconds: 500),
      );

      // Send to backend
      final result = await ApiService.handleSwipe(
        currentProfile['user_id'],
        'like',
      );

      if (result['success']) {
        print('✅ Like sent successfully');

        // Check if it's a mutual match
        final matchData = result['data'];
        if (matchData['is_mutual'] == true) {
          // Show match popup
          Future.delayed(Duration(milliseconds: 600), () {
            GameboyActionPopup.show(
              context,
              'IT\'S A MATCH!',
              message: 'You and ${currentProfile['name']} liked each other!',
              backgroundColor: Colors.pink,
              icon: Icons.favorite,
              duration: Duration(milliseconds: 1500),
            );
          });
        }
      } else {
        print('❌ Like failed: ${result['message']}');
      }
    } catch (e) {
      print('💥 Like error: $e');
    } finally {
      setState(() {
        isPerformingAction = false;
      });
      _nextProfile();

      // Check if hearts are depleted
      if (heartsRemaining <= 0) {
        setState(() {
          isOutOfHearts = true;
        });

        // Show out of hearts popup
        GameboyActionPopup.show(
          context,
          'Out of Hearts',
          message:
              'You\'ve used all your hearts!\nContinue exploring or edit your profile.',
          backgroundColor: Colors.red,
          icon: Icons.favorite_border,
          duration: Duration(seconds: 3),
        );
      }
    }
  }

  void _handlePass() async {
    if (isPerformingAction || profiles.isEmpty) return;

    setState(() {
      isPerformingAction = true;
    });

    try {
      final currentProfile = profiles[currentProfileIndex];
      print('👎 Passing ${currentProfile['name']}...');

      // Show immediate feedback
      GameboyActionPopup.show(
        context,
        'PASSED',
        message: '${currentProfile['name']}\nPASSED',
        backgroundColor: Colors.redAccent,
        icon: Icons.close,
        duration: Duration(milliseconds: 500),
      );

      // Send to backend
      final result = await ApiService.handleSwipe(
        currentProfile['user_id'],
        'pass',
      );

      if (result['success']) {
        print('✅ Pass sent successfully');
      } else {
        print('❌ Pass failed: ${result['message']}');
      }
    } catch (e) {
      print('💥 Pass error: $e');
    } finally {
      setState(() {
        isPerformingAction = false;
      });
      _nextProfile();
    }
  }

  void _nextProfile() {
    if (profiles.isEmpty) return;

    setState(() {
      // Remove current profile from the list
      profiles.removeAt(currentProfileIndex);

      // If we're at the last profile, reset to 0
      if (currentProfileIndex >= profiles.length && profiles.isNotEmpty) {
        currentProfileIndex = 0;
      }

      // Reset image index and info state for new profile
      currentImageIndex = 0;
      showProfileInfo = false;
    });

    // If we're running low on profiles, load more
    if (profiles.length <= 2) {
      _loadMoreProfiles();
    }

    // If no profiles left, show message
    if (profiles.isEmpty) {
      GameboyActionPopup.show(
        context,
        'No More Profiles',
        message: 'Check back later for more people!',
        backgroundColor: Colors.blue,
        icon: Icons.refresh,
        duration: Duration(seconds: 2),
      );
    }
  }

  Future<void> _loadMoreProfiles() async {
    try {
      print('🔄 Loading more profiles...');
      final result = await ApiService.discoverProfiles(page: 1, limit: 10);

      if (result['success']) {
        final profilesData = result['data']['profiles'] as List;

        // Transform and add new profiles
        final newProfiles = profilesData.map((profile) {
          return {
            'id': profile['id'],
            'user_id': profile['user_id'],
            'imageUrls':
                (profile['image_urls'] as List?)?.cast<String>() ??
                [
                  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop&crop=face',
                ],
            'name': profile['name'] ?? 'Anonymous',
            'age': profile['age'] ?? 18,
            'info': [
              profile['bio'] ?? 'No bio available',
              profile['location'] ?? 'Location not specified',
              (profile['interests'] as List?)?.join(', ') ??
                  'No interests listed',
            ],
          };
        }).toList();

        setState(() {
          profiles.addAll(newProfiles);
        });

        print('✅ Added ${newProfiles.length} more profiles');
      }
    } catch (e) {
      print('💥 Error loading more profiles: $e');
    }
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
      final result = await ApiService.getCurrentUser();

      print('📥 getCurrentUser result: $result');

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
        // Check if this is a "profile not found" error or if we should create profile
        final shouldCreateProfile =
            result['should_create_profile'] == true ||
            result['error'] == 'PROFILE_NOT_FOUND' ||
            result['status_code'] == 404;

        final errorMessage = result['message'] ?? '';

        print('🔍 Error message: $errorMessage');
        print('🔍 Should create profile: $shouldCreateProfile');
        print('🔍 Status code: ${result['status_code']}');
        print('🔍 Error type: ${result['error']}');

        if (shouldCreateProfile) {
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
                    'age': null, // null so it shows placeholder
                    'bio': '',
                    'location': '',
                    'interests': <String>[],
                    'imageUrls': <String>[],
                    'images': <String>[],
                  },
                ),
              ),
            ).then((updatedProfile) {
              if (updatedProfile != null) {
                print('✅ Profile created: $updatedProfile');
                // Optionally reload the homepage data
                _loadProfiles();
              }
            });
          } else {
            print('❌ Widget not mounted, skipping navigation');
          }
        } else {
          // Other errors - show error message
          print('❌ Other error occurred: $errorMessage');
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

  void _showInsufficientHeartsMessage(String action, double required) {
    GameboyActionPopup.show(
      context,
      'Not Enough Hearts',
      message:
          'Need ${required == 1.0 ? '1 full heart' : '½ heart'} to $action!',
      backgroundColor: Colors.orange,
      icon: Icons.favorite_border,
      duration: Duration(milliseconds: 800),
    );
  }

  Widget _buildHeartDisplay() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(10, (index) {
          double heartValue = heartsRemaining - index;

          Widget heart;
          if (heartValue >= 1.0) {
            // Full heart
            heart = Icon(Icons.favorite, color: Colors.red, size: 12);
          } else if (heartValue >= 0.5) {
            // Half heart
            heart = Stack(
              children: [
                Icon(Icons.favorite_border, color: Colors.red, size: 12),
                ClipRect(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.5,
                    child: Icon(Icons.favorite, color: Colors.red, size: 12),
                  ),
                ),
              ],
            );
          } else {
            // Empty heart
            heart = Icon(
              Icons.favorite_border,
              color: Colors.red.withOpacity(0.3),
              size: 12,
            );
          }

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 1),
            child: heart,
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('🏠 HomePage build method called');

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
                          child: GameboyScreen(child: _buildScreenContent()),
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
                                        onPressed:
                                            isLoading ||
                                                profiles.isEmpty ||
                                                isPerformingAction
                                            ? null
                                            : _handlePass,
                                      ),
                                    ),
                                    // A button (top-right)
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: GameboyButton(
                                        label: 'A',
                                        onPressed:
                                            isLoading ||
                                                profiles.isEmpty ||
                                                isPerformingAction
                                            ? null
                                            : () {
                                                if (isOutOfHearts ||
                                                    heartsRemaining < 0.5) {
                                                  _showInsufficientHeartsMessage(
                                                    'like',
                                                    0.5,
                                                  );
                                                } else {
                                                  _handleLike();
                                                }
                                              },
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
                                  '← →': 'Change photo',
                                  'CENTER': 'Edit your profile',
                                  '↓': 'Toggle profile info',
                                  'A': 'Like profile (½ heart)',
                                  'B': 'Pass on profile',
                                  'START': 'Logout',
                                  'SELECT': 'Show controls (this popup)',
                                  '↑': 'Superlike profile (1 heart)',
                                  'HEARTS': 'You start with 10 hearts',
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
                      // Heart display
                      _buildHeartDisplay(),
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

  Widget _buildScreenContent() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.black54, strokeWidth: 2),
            SizedBox(height: 16),
            Text(
              'Loading Profiles...',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 12,
                fontFamily: 'PublicPixel',
              ),
            ),
          ],
        ),
      );
    }

    if (profiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, color: Colors.black54, size: 48),
            SizedBox(height: 16),
            Text(
              'No More Profiles',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'PublicPixel',
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Check back later!',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 10,
                fontFamily: 'PublicPixel',
              ),
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: _loadProfiles,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.black54),
                ),
                child: Text(
                  'REFRESH',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontFamily: 'PublicPixel',
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final currentProfile = profiles[currentProfileIndex];
    return Column(
      children: [
        // Heart display at the top
        _buildHeartDisplay(),
        // Show out of hearts message if no hearts remaining, but still show profile
        if (isOutOfHearts)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Text(
              'Out of hearts - Browse only',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red,
                fontSize: 8,
                fontFamily: 'PublicPixel',
              ),
            ),
          ),
        // Profile card takes remaining space
        Expanded(
          child: GameboyProfileCard(
            key: ValueKey(
              'profile_${currentProfile['id']}_${currentImageIndex}_$showProfileInfo',
            ),
            imageUrl: currentProfile['imageUrls'],
            name: currentProfile['name'],
            age: currentProfile['age'],
            info: List<String>.from(currentProfile['info']),
            currentImageIndex: currentImageIndex,
            showInfo: showProfileInfo,
          ),
        ),
      ],
    );
  }
}
