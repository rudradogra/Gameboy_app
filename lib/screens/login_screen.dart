import 'package:flutter/material.dart';
import '../widgets/gameboy_screen.dart';
import '../widgets/gameboy_dpad.dart';
import '../widgets/gameboy_button.dart';
import '../widgets/gameboy_pill_button.dart';
import '../widgets/gameboy_speaker_dots.dart';
import '../widgets/gameboy_logo.dart';
import '../widgets/gameboy_controls_popup.dart';
import '../widgets/gameboy_action_popup.dart';
import '../services/api_service.dart';
import 'register_screen.dart';
import 'homepage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int selectedField =
      0; // 0: username, 1: password, 2: login button, 3: register link
  String email = '';
  String password = '';
  bool showPassword = false;
  bool isLoading = false;

  final List<String> menuItems = ['Email', 'Password', 'Login', 'Register'];

  void _handleDpadNavigation(String direction) {
    setState(() {
      switch (direction) {
        case 'up':
          selectedField = (selectedField - 1) % menuItems.length;
          if (selectedField < 0) selectedField = menuItems.length - 1;
          break;
        case 'down':
          selectedField = (selectedField + 1) % menuItems.length;
          break;
        case 'center':
          // Handle login when center is pressed
          _handleAButton();
          break;
      }
    });
  }

  void _handleAButton() {
    switch (selectedField) {
      case 0: // Email field
        _showInputDialog('Email', email, (value) {
          setState(() {
            email = value;
          });
        });
        break;
      case 1: // Password field
        _showInputDialog('Password', password, (value) {
          setState(() {
            password = value;
          });
        }, isPassword: true);
        break;
      case 2: // Login button
        _performLogin();
        break;
      case 3: // Register link
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RegisterScreen()),
        );
        break;
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF8B0000),
        title: Text(
          'Exit App',
          style: TextStyle(color: Colors.white, fontFamily: 'PublicPixel'),
        ),
        content: Text(
          'Are you sure you want to exit the app?',
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
              // Exit the app
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Text(
              'Exit',
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

  void _showInputDialog(
    String title,
    String currentValue,
    Function(String) onSave, {
    bool isPassword = false,
  }) {
    String tempValue = currentValue;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF8B0000),
        title: Text(
          title,
          style: TextStyle(color: Colors.white, fontFamily: 'PublicPixel'),
        ),
        content: TextField(
          controller: TextEditingController(text: currentValue),
          obscureText: isPassword,
          style: TextStyle(color: Colors.white, fontFamily: 'PublicPixel'),
          decoration: InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.cyanAccent),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.cyanAccent),
            ),
          ),
          onChanged: (value) => tempValue = value,
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
              onSave(tempValue);
              Navigator.pop(context);
            },
            child: Text(
              'Save',
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

  void _performLogin() async {
    if (email.isNotEmpty && password.isNotEmpty) {
      setState(() {
        isLoading = true;
      });

      try {
        print('🚀 Attempting login with email: $email');
        final result = await ApiService.login(email: email, password: password);

        print('📥 Login API response: $result');

        setState(() {
          isLoading = false;
        });

        if (result['success']) {
          print('✅ Login successful!');
          // Show success message
          GameboyActionPopup.show(
            context,
            'Success',
            message: 'Login Successful!',
            backgroundColor: Colors.green,
            icon: Icons.check_circle,
            duration: Duration(milliseconds: 800),
          );

          // Navigate to HomePage after successful login
          Future.delayed(Duration(milliseconds: 900), () {
            print('🧭 Navigating to HomePage...');
            if (mounted) {
              print('✅ Widget is mounted, proceeding with navigation');
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
                (route) => false, // Remove all previous routes
              );
            } else {
              print('❌ Widget is not mounted, skipping navigation');
            }
          });
        } else {
          print('❌ Login failed: ${result['message']}');
          print('🔍 Full error response: $result');
          // Show error message
          GameboyActionPopup.show(
            context,
            'Login Failed',
            message: result['message'] ?? 'Unknown error occurred',
            duration: Duration(seconds: 1),
            backgroundColor: Colors.red,
            icon: Icons.error,
          );
        }
      } catch (e) {
        print('💥 Login exception caught: $e');
        print('🔍 Exception type: ${e.runtimeType}');
        setState(() {
          isLoading = false;
        });

        GameboyActionPopup.show(
          context,
          'Network Error',
          message: 'Unable to connect to server: $e',
          backgroundColor: Colors.red,
          icon: Icons.wifi_off,
          duration: Duration(seconds: 1),
        );
      }
    } else {
      GameboyActionPopup.show(
        context,
        'Error',
        message: 'Please fill in all fields',
        backgroundColor: Colors.red,
        icon: Icons.error,
        duration: Duration(seconds: 1),
      );
    }
  }

  Widget _buildLoginForm() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'LOGIN',
            style: TextStyle(
              color: Colors.black,
              fontSize: 14, // Reduced from 16
              fontWeight: FontWeight.bold,
              fontFamily: 'PublicPixel',
            ),
          ),
          SizedBox(height: isLoading ? 8 : 16), // Reduced height when loading

          if (isLoading) ...[
            Text(
              'Connecting...',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 6, // Reduced from 8
                fontFamily: 'PublicPixel',
              ),
            ),
            SizedBox(height: 8), // Reduced from 16
          ],

          // Email field
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: selectedField == 0
                  ? Colors.yellow.withOpacity(0.3)
                  : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: selectedField == 0 ? Colors.black : Colors.grey,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.email, color: Colors.black, size: 18),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    email.isEmpty ? 'Email' : email,
                    style: TextStyle(
                      color: email.isEmpty ? Colors.grey[600] : Colors.black,
                      fontFamily: 'PublicPixel',
                      fontSize: 10, // Reduced from 12
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 8), // Reduced from 10
          // Password field
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: selectedField == 1
                  ? Colors.yellow.withOpacity(0.3)
                  : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: selectedField == 1 ? Colors.black : Colors.grey,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.lock, color: Colors.black, size: 18),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    password.isEmpty ? 'Password' : '•' * password.length,
                    style: TextStyle(
                      color: password.isEmpty ? Colors.grey[600] : Colors.black,
                      fontFamily: 'PublicPixel',
                      fontSize: 10, // Reduced from 12
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 10), // Reduced from 12
          // Login button
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: selectedField == 2
                  ? Colors.yellow.withOpacity(0.8)
                  : Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: selectedField == 2 ? Colors.black : Colors.grey,
                width: 1,
              ),
            ),
            child: Text(
              isLoading ? 'CONNECTING...' : 'LOGIN', // Show loading state
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selectedField == 2 ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'PublicPixel',
                fontSize: 10, // Reduced from 12
              ),
            ),
          ),

          SizedBox(height: 4), // Reduced spacing
          // Register link
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 4), // Reduced from 6
            decoration: BoxDecoration(
              color: selectedField == 3
                  ? Colors.yellow.withOpacity(0.3)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: selectedField == 3 ? Colors.black : Colors.transparent,
                width: 1,
              ),
            ),
            child: Text(
              'New? Register here',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black87,
                fontFamily: 'PublicPixel',
                fontSize: 7, // Reduced from 8
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1A1A1A), // Dark gray at top
              const Color(0xFF0F0F0F), // Darker at bottom
              const Color(0xFF1A1A1A), // Back to dark gray
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: AspectRatio(
              aspectRatio: 2 / 3.7,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF8B0000),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Screen and Power button stack
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0),
                      child: AspectRatio(
                        aspectRatio: 1.1,
                        child: GameboyScreen(child: _buildLoginForm()),
                      ),
                    ),
                    // GameBoy Logo in black border container
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0),
                      child: const GameboyLogo(),
                    ),
                    const SizedBox(height: 18),
                    // Controls section
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
                                  // B button (bottom-left) - Inactive on login screen
                                  Positioned(
                                    left: 0,
                                    top: 50,
                                    child: GameboyButton(
                                      label: 'B',
                                      onPressed: null, // Inactive
                                    ),
                                  ),
                                  // A button (top-right)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: GameboyButton(
                                      label: 'A',
                                      onPressed: _handleAButton,
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
                                '↑ ↓': 'Navigate menu items',
                                '← →': 'Not used',
                                'CENTER': 'Select/Login',
                                'A': 'Select/Login',
                                'B': 'Disabled (grayed out)',
                                'START': 'Exit App',
                                'SELECT': 'Show controls (this popup)',
                              });
                            },
                          ),
                          const SizedBox(width: 24),
                          GameboyPillButton(
                            label: 'START',
                            onPressed: _handleLogout,
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
