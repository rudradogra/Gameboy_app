import 'package:flutter/material.dart';
import '../widgets/gameboy_screen.dart';
import '../widgets/gameboy_dpad.dart';
import '../widgets/gameboy_button.dart';
import '../widgets/gameboy_pill_button.dart';
import '../widgets/gameboy_speaker_dots.dart';
import '../widgets/gameboy_logo.dart';
import 'login_screen.dart';
import 'homepage.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int selectedField =
      0; // 0: username, 1: email, 2: password, 3: confirm password, 4: register button, 5: login link
  String username = '';
  String email = '';
  String password = '';
  String confirmPassword = '';

  final List<String> menuItems = [
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
      }
    });
  }

  void _handleAButton() {
    switch (selectedField) {
      case 0: // Username field
        _showInputDialog('Username', username, (value) {
          setState(() {
            username = value;
          });
        });
        break;
      case 1: // Email field
        _showInputDialog('Email', email, (value) {
          setState(() {
            email = value;
          });
        });
        break;
      case 2: // Password field
        _showInputDialog('Password', password, (value) {
          setState(() {
            password = value;
          });
        }, isPassword: true);
        break;
      case 3: // Confirm Password field
        _showInputDialog('Confirm Password', confirmPassword, (value) {
          setState(() {
            confirmPassword = value;
          });
        }, isPassword: true);
        break;
      case 4: // Register button
        _performRegister();
        break;
      case 5: // Login link
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
          style: TextStyle(color: Colors.white, fontFamily: 'monospace'),
        ),
        content: TextField(
          controller: TextEditingController(text: currentValue),
          obscureText: isPassword,
          style: TextStyle(color: Colors.white),
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
            child: Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              onSave(tempValue);
              Navigator.pop(context);
            },
            child: Text('Save', style: TextStyle(color: Colors.cyanAccent)),
          ),
        ],
      ),
    );
  }

  void _performRegister() {
    if (username.isNotEmpty &&
        email.isNotEmpty &&
        password.isNotEmpty &&
        confirmPassword.isNotEmpty) {
      if (password == confirmPassword) {
        // Simple validation - in real app, use proper authentication
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration Successful!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to HomePage after successful registration
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Passwords do not match'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildRegisterForm() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'REGISTER',
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          SizedBox(height: 10),

          // Username field
          _buildInputField(
            0,
            Icons.person,
            username.isEmpty ? 'Username' : username,
            username.isEmpty,
          ),
          SizedBox(height: 4),

          // Email field
          _buildInputField(
            1,
            Icons.email,
            email.isEmpty ? 'Email' : email,
            email.isEmpty,
          ),
          SizedBox(height: 4),

          // Password field
          _buildInputField(
            2,
            Icons.lock,
            password.isEmpty ? 'Password' : '•' * password.length,
            password.isEmpty,
          ),
          SizedBox(height: 4),

          // Confirm Password field
          _buildInputField(
            3,
            Icons.lock_outline,
            confirmPassword.isEmpty
                ? 'Confirm Pass'
                : '•' * confirmPassword.length,
            confirmPassword.isEmpty,
          ),
          SizedBox(height: 8),

          // Register button
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: selectedField == 4
                  ? Colors.yellow.withOpacity(0.8)
                  : Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: selectedField == 4 ? Colors.black : Colors.grey,
                width: 1,
              ),
            ),
            child: Text(
              'REGISTER',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selectedField == 4 ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),

          SizedBox(height: 4),

          // Login link
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: selectedField == 5
                  ? Colors.yellow.withOpacity(0.3)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: selectedField == 5 ? Colors.black : Colors.transparent,
                width: 1,
              ),
            ),
            child: Text(
              'Have account? Login',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black87,
                fontFamily: 'monospace',
                fontSize: 9,
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
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: selectedField == index
            ? Colors.yellow.withOpacity(0.3)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: selectedField == index ? Colors.black : Colors.grey,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black, size: 14),
          SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isEmpty ? Colors.grey[600] : Colors.black,
                fontFamily: 'monospace',
                fontSize: 10,
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
      backgroundColor: const Color(0xFF181818),
      body: Center(
        child: AspectRatio(
          aspectRatio: 2 / 3.7,
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
            child: Column(
              children: [
                const SizedBox(height: 20),
                // GameBoy Logo
                const GameboyLogo(),
                const SizedBox(height: 16),
                // GameBoy Screen
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: AspectRatio(
                    aspectRatio: 1.1,
                    child: GameboyScreen(child: _buildRegisterForm()),
                  ),
                ),
                const SizedBox(height: 18),
                // Controls section
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // D-pad
                      Padding(
                        padding: const EdgeInsets.only(left: 32.0, top: 16.0),
                        child: GameboyDpad(
                          onDirectionPressed: _handleDpadNavigation,
                        ),
                      ),
                      const Spacer(),
                      // A/B buttons (diagonal layout)
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0, top: 8.0),
                        child: SizedBox(
                          width: 100,
                          height: 80,
                          child: Stack(
                            children: [
                              // B button (bottom-left)
                              Positioned(
                                left: 0,
                                top: 30,
                                child: GameboyButton(
                                  label: 'B',
                                  onPressed: () {
                                    Navigator.pop(context);
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
                          // Clear all fields
                          setState(() {
                            username = '';
                            email = '';
                            password = '';
                            confirmPassword = '';
                          });
                        },
                      ),
                      const SizedBox(width: 24),
                      GameboyPillButton(
                        label: 'START',
                        onPressed: _handleAButton,
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
    );
  }
}
