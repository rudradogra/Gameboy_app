import 'package:flutter/material.dart';
import '../widgets/gameboy_screen.dart';
import '../widgets/gameboy_dpad.dart';
import '../widgets/gameboy_button.dart';
import '../widgets/gameboy_pill_button.dart';
import '../widgets/gameboy_speaker_dots.dart';
import '../widgets/gameboy_logo.dart';
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
  String username = '';
  String password = '';
  bool showPassword = false;

  final List<String> menuItems = ['Username', 'Password', 'Login', 'Register'];

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

  void _performLogin() {
    if (username.isNotEmpty && password.isNotEmpty) {
      // Simple validation - in real app, use proper authentication
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login Successful!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to HomePage after successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildLoginForm() {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'LOGIN',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          SizedBox(height: 16),

          // Username field
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
                Icon(Icons.person, color: Colors.black, size: 18),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    username.isEmpty ? 'Username' : username,
                    style: TextStyle(
                      color: username.isEmpty ? Colors.grey[600] : Colors.black,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 10),

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
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 12),

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
              'LOGIN',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selectedField == 2 ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                fontSize: 14,
              ),
            ),
          ),

          SizedBox(height: 8),

          // Register link
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 6),
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
                fontFamily: 'monospace',
                fontSize: 10,
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
                    child: GameboyScreen(child: _buildLoginForm()),
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
                          setState(() {
                            showPassword = !showPassword;
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
