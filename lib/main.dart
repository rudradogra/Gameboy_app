import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'services/gameboy_sound.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the GameBoy sound system
  await GameBoySound.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gameboy Tinder',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(
          0xFF1E1E1E,
        ), // Rich dark background
        fontFamily: 'PublicPixel',
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF8B0000), // GameBoy red
          secondary: Colors.cyanAccent,
          surface: const Color(0xFF2C2C2C),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
