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
import 'login_screen.dart';
import 'homepage.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int selectedField =
      0; // 0: name, 1: username, 2: email, 3: password, 4: confirm password, 5: register button, 6: login link
  String name = '';
  String username = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  bool isLoading = false;

  final List<String> menuItems = [
    'Name',
    'Username',
    'Email',
    'Password',
    'Confirm Password',
    'Register',
    'Login',
  ];

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
          // Handle current item selection when center is pressed
          _handleAButton();
          break;
      }
    });
  }

  void _handleAButton() {
    switch (selectedField) {
      case 0: // Name field
        _showInputDialog('Name', name, (value) {
          setState(() {
            name = value;
          });
        });
        break;
      case 1: // Username field
        _showInputDialog('Username', username, (value) {
          setState(() {
            username = value;
          });
        });
        break;
      case 2: // Email field
        _showInputDialog('Email', email, (value) {
          setState(() {
            email = value;
          });
        });
        break;
      case 3: // Password field
        _showInputDialog('Password', password, (value) {
          setState(() {
            password = value;
          });
        }, isPassword: true);
        break;
      case 4: // Confirm Password field
        _showInputDialog('Confirm Password', confirmPassword, (value) {
          setState(() {
            confirmPassword = value;
          });
        }, isPassword: true);
        break;
      case 5: // Register button
        _performRegister();
        break;
      case 6: // Login link
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
        break;
    }
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

  void _handleLogout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _performRegister() async {
    if (name.isNotEmpty &&
        username.isNotEmpty &&
        email.isNotEmpty &&
        password.isNotEmpty &&
        confirmPassword.isNotEmpty) {
      if (password == confirmPassword) {
        setState(() {
          isLoading = true;
        });

        try {
          print(
            '🚀 Attempting registration with email: $email, username: $username, name: $name',
          );
          final result = await ApiService.register(
            email: email,
            password: password,
            username: username,
            name: name,
          );

          print('📥 Registration API response: $result');

          setState(() {
            isLoading = false;
          });

          if (result['success']) {
            print('✅ Registration successful!');
            // Show success message
            GameboyActionPopup.show(
              context,
              'Success',
              message: 'Registration Successful!',
              backgroundColor: Colors.green,
              icon: Icons.check_circle,
            );

            // Navigate to HomePage after successful registration
            Future.delayed(Duration(milliseconds: 800), () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            });
          } else {
            print('❌ Registration failed: ${result['message']}');
            print('🔍 Full error response: $result');
            // Show error message
            GameboyActionPopup.show(
              context,
              'Registration Failed',
              message: result['message'] ?? 'Unknown error occurred',
              backgroundColor: Colors.red,
              icon: Icons.error,
            );
          }
        } catch (e) {
          print('💥 Registration exception caught: $e');
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
          );
        }
      } else {
        GameboyActionPopup.show(
          context,
          'Error',
          message: 'Passwords do not match',
          backgroundColor: Colors.red,
          icon: Icons.error,
        );
      }
    } else {
      GameboyActionPopup.show(
        context,
        'Error',
        message: 'Please fill in all fields',
        backgroundColor: Colors.red,
        icon: Icons.error,
      );
    }
  }

  Widget _buildRegisterForm() {
    return Padding(
      padding: const EdgeInsets.all(6.0), // Reduced from 8.0
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'REGISTER',
            style: TextStyle(
              color: Colors.black,
              fontSize: 10, // Reduced from 12
              fontWeight: FontWeight.bold,
              fontFamily: 'PublicPixel',
            ),
          ),
          SizedBox(height: 6), // Reduced from 10

          if (isLoading) ...[
            SizedBox(
              width: 16, // Reduced from 20
              height: 16, // Reduced from 20
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            ),
            SizedBox(height: 4), // Reduced from 8
            Text(
              'Creating...',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 6, // Reduced from 8
                fontFamily: 'PublicPixel',
              ),
            ),
            SizedBox(height: 6), // Reduced from 10
          ],

          // Name field
          _buildInputField(
            0,
            Icons.person_outline,
            name.isEmpty ? 'Name' : name,
            name.isEmpty,
          ),
          SizedBox(height: 2), // Reduced from 4
          // Username field
          _buildInputField(
            1,
            Icons.person,
            username.isEmpty ? 'Username' : username,
            username.isEmpty,
          ),
          SizedBox(height: 2), // Reduced from 4
          // Email field
          _buildInputField(
            2,
            Icons.email,
            email.isEmpty ? 'Email' : email,
            email.isEmpty,
          ),
          SizedBox(height: 2), // Reduced from 4
          // Password field
          _buildInputField(
            3,
            Icons.lock,
            password.isEmpty ? 'Password' : '•' * password.length,
            password.isEmpty,
          ),
          SizedBox(height: 2), // Reduced from 4
          // Confirm Password field
          _buildInputField(
            4,
            Icons.lock_outline,
            confirmPassword.isEmpty
                ? 'Confirm Pass'
                : '•' * confirmPassword.length,
            confirmPassword.isEmpty,
          ),
          SizedBox(height: 4), // Reduced from 8
          // Register button
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 4), // Reduced from 6
            decoration: BoxDecoration(
              color: selectedField == 5
                  ? Colors.yellow.withOpacity(0.8)
                  : Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(4), // Reduced from 6
              border: Border.all(
                color: selectedField == 5 ? Colors.black : Colors.grey,
                width: 1,
              ),
            ),
            child: Text(
              'REGISTER',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selectedField == 5 ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'PublicPixel',
                fontSize: 8, // Reduced from 10
              ),
            ),
          ),

          SizedBox(height: 2), // Added small spacing
          // Login link
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 2), // Reduced from 4
            decoration: BoxDecoration(
              color: selectedField == 6
                  ? Colors.yellow.withOpacity(0.3)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(4), // Reduced from 6
              border: Border.all(
                color: selectedField == 6 ? Colors.black : Colors.transparent,
                width: 1,
              ),
            ),
            child: Text(
              'Have account? Login',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black87,
                fontFamily: 'PublicPixel',
                fontSize: 8, // Fixed from 2 to 6
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(int index, IconData icon, String text, bool isEmpty) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ), // Reduced padding
      decoration: BoxDecoration(
        color: selectedField == index
            ? Colors.yellow.withOpacity(0.3)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(3), // Reduced from 4
        border: Border.all(
          color: selectedField == index ? Colors.black : Colors.grey,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black, size: 12), // Reduced from 14
          SizedBox(width: 3), // Reduced from 4
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isEmpty ? Colors.grey[600] : Colors.black,
                fontFamily: 'PublicPixel',
                fontSize: 8, // Reduced from 10
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
      backgroundColor: const Color(0xFF1A1A1A), // Subtle dark background
      body: Padding(
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
                      child: GameboyScreen(child: _buildRegisterForm()),
                    ),
                  ),
                  // GameBoy Logo in black border container
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: const GameboyLogo(),
                  ),
                  // Controls section
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: 20),
                        // D-pad
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                          child: GameboyDpad(
                            onDirectionPressed: _handleDpadNavigation,
                          ),
                        ),
                        const Spacer(),
                        // A/B buttons (diagonal layout)
                        Padding(
                          padding: const EdgeInsets.only(right: 32.0, top: 8.0),
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
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginScreen(),
                                        ),
                                      );
                                    },
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
                              'CENTER': 'Select current item',
                              'A': 'Select/Edit field',
                              'B': 'Back to Login',
                              'START': 'Back to Login',
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
    );
  }
}
