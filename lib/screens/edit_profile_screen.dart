import 'package:flutter/material.dart';
import '../widgets/gameboy_screen.dart';
import '../widgets/gameboy_dpad.dart';
import '../widgets/gameboy_button.dart';
import '../widgets/gameboy_pill_button.dart';
import '../widgets/gameboy_speaker_dots.dart';
import '../widgets/gameboy_logo.dart';
import '../widgets/gameboy_controls_popup.dart';
import 'login_screen.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> currentProfile;

  const EditProfileScreen({Key? key, required this.currentProfile})
    : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late List<TextEditingController> _infoControllers;
  int selectedField = 0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.currentProfile['name'].split(', ')[0],
    );
    _ageController = TextEditingController(
      text: widget.currentProfile['age'].toString(),
    );
    _infoControllers = List.generate(
      3,
      (index) =>
          TextEditingController(text: widget.currentProfile['info'][index]),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    for (var controller in _infoControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleDpadNavigation(String direction) {
    setState(() {
      if (direction == 'up') {
        selectedField = (selectedField - 1) % 6; // 5 fields + 1 for save button
        if (selectedField < 0) selectedField = 5;
      } else if (direction == 'down') {
        selectedField = (selectedField + 1) % 6;
      } else if (direction == 'center') {
        // Edit selected field when center is pressed
        _handleAButton();
      }
    });
  }

  void _handleAButton() {
    // Handle A button press based on selected field
    if (selectedField == 5) {
      _saveChanges();
    } else {
      _showEditDialog(selectedField);
    }
  }

  void _handleLogout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _showEditDialog(int fieldIndex) {
    String title = '';
    String currentValue = '';
    TextInputType? keyboardType;
    bool isPassword = false;
    int maxLines = 1;

    switch (fieldIndex) {
      case 0:
        title = 'Edit Name';
        currentValue = _nameController.text;
        break;
      case 1:
        title = 'Edit Age';
        currentValue = _ageController.text;
        keyboardType = TextInputType.number;
        break;
      default:
        title = 'Edit Info ${fieldIndex - 1}';
        currentValue = _infoControllers[fieldIndex - 2].text;
        maxLines = 2;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF8B0000),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
        ),
        content: TextField(
          controller: TextEditingController(text: currentValue),
          style: const TextStyle(color: Colors.white),
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white54),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.cyanAccent),
            ),
          ),
          onChanged: (value) {
            currentValue = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: Colors.white70, fontFamily: 'monospace'),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                switch (fieldIndex) {
                  case 0:
                    _nameController.text = currentValue;
                    break;
                  case 1:
                    _ageController.text = currentValue;
                    break;
                  default:
                    _infoControllers[fieldIndex - 2].text = currentValue;
                }
              });
              Navigator.pop(context);
            },
            child: const Text(
              'SAVE',
              style: TextStyle(
                color: Colors.cyanAccent,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveChanges() {
    // Save changes and pop back with updated profile
    final updatedProfile = {
      'name': '${_nameController.text}, ${_ageController.text}',
      'age': int.tryParse(_ageController.text) ?? 0,
      'info': _infoControllers.map((c) => c.text).toList(),
    };
    Navigator.pop(context, updatedProfile);
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
                // Screen and Power button stack
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: AspectRatio(
                    aspectRatio: 1.1,
                    child: GameboyScreen(child: _buildEditForm()),
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
                                  onPressed: () => Navigator.pop(context),
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
                            '↑ ↓': 'Navigate form fields',
                            '← →': 'Not used',
                            'CENTER': 'Edit selected field',
                            'A': 'Edit selected field',
                            'B': 'Back to homepage',
                            'START': 'Logout',
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
    );
  }

  Widget _buildEditForm() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Title
          const Text(
            'EDIT PROFILE',
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 12),

          // Name field
          _buildInputField(
            0,
            Icons.person,
            _nameController.text.isEmpty ? 'Name' : _nameController.text,
            _nameController.text.isEmpty,
          ),
          const SizedBox(height: 6),

          // Age field
          _buildInputField(
            1,
            Icons.numbers,
            _ageController.text.isEmpty ? 'Age' : _ageController.text,
            _ageController.text.isEmpty,
          ),
          const SizedBox(height: 6),

          // Info fields
          ...List.generate(3, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: _buildInputField(
                index + 2,
                Icons.info,
                _infoControllers[index].text.isEmpty
                    ? 'Info ${index + 1}'
                    : _infoControllers[index].text,
                _infoControllers[index].text.isEmpty,
              ),
            );
          }),

          const SizedBox(height: 8),

          // Save button
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: selectedField == 5
                  ? Colors.yellow.withOpacity(0.8)
                  : Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: selectedField == 5 ? Colors.black : Colors.grey,
                width: 1,
              ),
            ),
            child: Text(
              'SAVE CHANGES',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selectedField == 5 ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(int index, IconData icon, String text, bool isEmpty) {
    return GestureDetector(
      onTap: () => _showEditDialog(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: isEmpty ? Colors.grey[600] : Colors.black,
                  fontFamily: 'monospace',
                  fontSize: 10,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
