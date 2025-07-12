import 'package:flutter/material.dart';
import '../widgets/gameboy_screen.dart';
import '../widgets/gameboy_dpad.dart';
import '../widgets/gameboy_button.dart';
import '../widgets/gameboy_pill_button.dart';
import '../widgets/gameboy_speaker_dots.dart';
import '../widgets/gameboy_logo.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> currentProfile;

  const EditProfileScreen({Key? key, required this.currentProfile}) : super(key: key);

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
    _nameController = TextEditingController(text: widget.currentProfile['name'].split(', ')[0]);
    _ageController = TextEditingController(text: widget.currentProfile['age'].toString());
    _infoControllers = List.generate(
      3,
      (index) => TextEditingController(
        text: widget.currentProfile['info'][index],
      ),
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
            child: const Text('CANCEL', style: TextStyle(color: Colors.white70, fontFamily: 'monospace')),
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
            child: const Text('SAVE', style: TextStyle(color: Colors.cyanAccent, fontFamily: 'monospace')),
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
            child: Stack(
              children: [
                // Screen content
                GameboyScreen(
                  child: _buildEditForm(),
                ),
                
                // D-pad
                Positioned(
                  left: 20,
                  bottom: 20,
                  child: GameboyDpad(
                    onDirectionPressed: _handleDpadNavigation,
                  ),
                ),
                
                // A/B buttons
                Positioned(
                  right: 20,
                  bottom: 60,
                  child: Row(
                    children: [
                      GameboyButton(
                        label: 'B',
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 16),
                      GameboyButton(
                        label: 'A',
                        onPressed: _handleAButton,
                      ),
                    ],
                  ),
                ),
                
                // Speaker dots
                const Positioned(
                  right: 20,
                  bottom: 20,
                  child: GameboySpeakerDots(),
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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const GameboyLogo(),
          const SizedBox(height: 20),
          
          // Title
          const Text(
            'EDIT PROFILE',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          
          // Name field
          _buildInputField(
            0,
            Icons.person,
            _nameController.text.isEmpty ? 'Name' : _nameController.text,
            _nameController.text.isEmpty,
          ),
          const SizedBox(height: 12),
          
          // Age field
          _buildInputField(
            1,
            Icons.numbers,
            _ageController.text.isEmpty ? 'Age' : 'Age: ${_ageController.text}',
            _ageController.text.isEmpty,
          ),
          const SizedBox(height: 20),
          
          // Info fields
          ...List.generate(3, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildInputField(
                index + 2,
                Icons.info,
                _infoControllers[index].text.isEmpty ? 'Info ${index + 1}' : _infoControllers[index].text,
                _infoControllers[index].text.isEmpty,
                maxLines: 2,
              ),
            );
          }),
          
          const Spacer(),
          
          // Save button
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            decoration: BoxDecoration(
              color: selectedField == 5 ? Colors.yellow.withOpacity(0.3) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selectedField == 5 ? Colors.black : Colors.transparent,
                width: 2,
              ),
            ),
            child: GameboyPillButton(
              label: 'SAVE CHANGES',
              onPressed: _saveChanges,
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInputField(int index, IconData icon, String text, bool isEmpty, {int maxLines = 1}) {
    return GestureDetector(
      onTap: () => _showEditDialog(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selectedField == index
              ? Colors.yellow.withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selectedField == index ? Colors.black : Colors.grey[700]!,
            width: 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: selectedField == index ? Colors.black : Colors.white70, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: isEmpty ? Colors.grey[400] : Colors.white,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
