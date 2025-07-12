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
  late List<TextEditingController> _imageControllers;
  int selectedField = 0;
  bool showImageInputs = false; // Toggle between profile info and image inputs

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
    _imageControllers = List.generate(
      3,
      (index) => TextEditingController(
        text:
            widget.currentProfile['imageUrls'] != null &&
                widget.currentProfile['imageUrls'] is List &&
                (widget.currentProfile['imageUrls'] as List).length > index
            ? widget.currentProfile['imageUrls'][index]
            : '',
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
    for (var controller in _imageControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleDpadNavigation(String direction) {
    setState(() {
      if (direction == 'up') {
        if (showImageInputs) {
          selectedField =
              (selectedField - 1) % 4; // 3 image fields + 1 save button
          if (selectedField < 0) selectedField = 3;
        } else {
          selectedField = (selectedField - 1) % 6; // 5 fields + 1 save button
          if (selectedField < 0) selectedField = 5;
        }
      } else if (direction == 'down') {
        if (showImageInputs) {
          selectedField = (selectedField + 1) % 4;
        } else {
          selectedField = (selectedField + 1) % 6;
        }
      } else if (direction == 'left') {
        // Switch to profile info mode
        showImageInputs = false;
        selectedField = 0;
      } else if (direction == 'right') {
        // Switch to image editing mode
        showImageInputs = true;
        selectedField = 0;
      } else if (direction == 'center') {
        // Edit selected field when center is pressed
        _handleAButton();
      }
    });
  }

  void _handleAButton() {
    // Handle A button press based on selected field
    if (showImageInputs) {
      if (selectedField == 3) {
        _saveChanges();
      } else {
        _showEditDialog(selectedField);
      }
    } else {
      if (selectedField == 5) {
        _saveChanges();
      } else {
        _showEditDialog(selectedField);
      }
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
    int maxLines = 1;

    if (showImageInputs) {
      // Image editing mode
      title = 'Edit Image ${fieldIndex + 1} URL';
      currentValue = _imageControllers[fieldIndex].text;
      keyboardType = TextInputType.url;
      maxLines = 3;
    } else {
      // Profile info editing mode
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
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF8B0000),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontFamily: 'PublicPixel'),
        ),
        content: TextField(
          controller: TextEditingController(text: currentValue),
          style: const TextStyle(color: Colors.white, fontFamily: 'PublicPixel'),
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
              style: TextStyle(color: Colors.white70, fontFamily: 'PublicPixel'),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                if (showImageInputs) {
                  _imageControllers[fieldIndex].text = currentValue;
                } else {
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
                }
              });
              Navigator.pop(context);
            },
            child: const Text(
              'SAVE',
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

  void _saveChanges() {
    // Save changes and pop back with updated profile
    final updatedProfile = {
      'name': '${_nameController.text}, ${_ageController.text}',
      'age': int.tryParse(_ageController.text) ?? 0,
      'info': _infoControllers.map((c) => c.text).toList(),
      'imageUrls': _imageControllers
          .map((c) => c.text)
          .where((url) => url.isNotEmpty)
          .toList(),
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
                            '↑ ↓': showImageInputs
                                ? 'Navigate image fields'
                                : 'Navigate form fields',
                            '← →': 'Switch between Profile/Images',
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
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Title
            Text(
              showImageInputs ? 'EDIT IMAGES' : 'EDIT PROFILE',
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: 'PublicPixel',
              ),
            ),
            const SizedBox(height: 6),

            // Mode indicator
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: showImageInputs
                    ? Colors.blue.withOpacity(0.2)
                    : Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  color: showImageInputs ? Colors.blue : Colors.green,
                  width: 1,
                ),
              ),
              child: Text(
                showImageInputs
                    ? 'IMAGE MODE (← PROFILE | IMAGES →)'
                    : 'PROFILE MODE (← PROFILE | IMAGES →)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 7,
                  fontFamily: 'PublicPixel',
                ),
              ),
            ),
            const SizedBox(height: 8),

            if (!showImageInputs) ...[
              // Profile editing fields
              _buildInputField(
                0,
                Icons.person,
                _nameController.text.isEmpty ? 'Name' : _nameController.text,
                _nameController.text.isEmpty,
              ),
              const SizedBox(height: 4),

              _buildInputField(
                1,
                Icons.numbers,
                _ageController.text.isEmpty ? 'Age' : _ageController.text,
                _ageController.text.isEmpty,
              ),
              const SizedBox(height: 4),

              ...List.generate(3, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
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
            ] else ...[
              // Image editing fields
              ...List.generate(3, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: _buildInputField(
                    index,
                    Icons.image,
                    _imageControllers[index].text.isEmpty
                        ? 'Image ${index + 1} URL'
                        : _imageControllers[index].text,
                    _imageControllers[index].text.isEmpty,
                  ),
                );
              }),
            ],

            const SizedBox(height: 6),

            // Save button
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color:
                    (showImageInputs ? selectedField == 3 : selectedField == 5)
                    ? Colors.yellow.withOpacity(0.8)
                    : Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color:
                      (showImageInputs
                          ? selectedField == 3
                          : selectedField == 5)
                      ? Colors.black
                      : Colors.grey,
                  width: 1,
                ),
              ),
              child: Text(
                'SAVE CHANGES',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color:
                      (showImageInputs
                          ? selectedField == 3
                          : selectedField == 5)
                      ? Colors.black
                      : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'PublicPixel',
                  fontSize: 9,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(int index, IconData icon, String text, bool isEmpty) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: selectedField == index
            ? Colors.yellow.withOpacity(0.3)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: selectedField == index ? Colors.black : Colors.grey,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black, size: 12),
          const SizedBox(width: 3),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isEmpty ? Colors.grey[600] : Colors.black,
                fontFamily: 'PublicPixel',
                fontSize: 9,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
