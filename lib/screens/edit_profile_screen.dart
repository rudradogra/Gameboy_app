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
import '../services/gameboy_sound.dart';
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
  late TextEditingController _bioController;
  late TextEditingController _locationController;
  late List<TextEditingController> _imageControllers;
  int selectedField = 0;
  bool showImageInputs = false; // Toggle between profile info and image inputs
  bool isLoading = false;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.currentProfile['name']?.toString().split(', ')[0] ?? '',
    );
    _ageController = TextEditingController(
      text:
          (widget.currentProfile['age'] != null &&
              widget.currentProfile['age'] != 0)
          ? widget.currentProfile['age'].toString()
          : '',
    );
    _bioController = TextEditingController(
      text: widget.currentProfile['bio']?.toString() ?? '',
    );
    _locationController = TextEditingController(
      text: widget.currentProfile['location']?.toString() ?? '',
    );

    // Initialize image controllers
    _imageControllers = List.generate(
      3,
      (index) => TextEditingController(
        text:
            widget.currentProfile['imageUrls'] != null &&
                widget.currentProfile['imageUrls'] is List &&
                (widget.currentProfile['imageUrls'] as List).length > index
            ? widget.currentProfile['imageUrls'][index]
            : widget.currentProfile['images'] != null &&
                  widget.currentProfile['images'] is List &&
                  (widget.currentProfile['images'] as List).length > index
            ? widget.currentProfile['images'][index]
            : '',
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _bioController.dispose();
    _locationController.dispose();
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
          selectedField = (selectedField - 1) % 5; // 4 fields + 1 save button
          if (selectedField < 0) selectedField = 4;
        }
      } else if (direction == 'down') {
        if (showImageInputs) {
          selectedField = (selectedField + 1) % 4;
        } else {
          selectedField = (selectedField + 1) % 5;
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
      if (selectedField == 4) {
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
        case 2:
          title = 'Edit Bio';
          currentValue = _bioController.text;
          keyboardType = TextInputType.multiline;
          maxLines = 4;
          break;
        case 3:
          title = 'Edit Location';
          currentValue = _locationController.text;
          break;
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF8B0000),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'PublicPixel',
          ),
        ),
        content: TextField(
          controller: TextEditingController(text: currentValue),
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'PublicPixel',
          ),
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
              style: TextStyle(
                color: Colors.white70,
                fontFamily: 'PublicPixel',
              ),
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
                    case 2:
                      _bioController.text = currentValue;
                      break;
                    case 3:
                      _locationController.text = currentValue;
                      break;
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

  void _saveChanges() async {
    if (isSaving) return; // Prevent multiple simultaneous saves

    setState(() {
      isSaving = true;
    });

    try {
      // Play button sound
      GameBoySound.playButtonClick();

      // Prepare the data for the API
      final name = _nameController.text.trim();
      final ageText = _ageController.text.trim();
      final bio = _bioController.text.trim();
      final location = _locationController.text.trim();
      final images = _imageControllers
          .map((c) => c.text.trim())
          .where((url) => url.isNotEmpty)
          .toList();

      // Validate required fields
      if (name.isEmpty) {
        GameBoySound.playError();
        GameboyActionPopup.show(
          context,
          'Error',
          message: 'Name is required',
          backgroundColor: Colors.red,
          icon: Icons.error,
        );
        return;
      }

      int? age;
      if (ageText.isNotEmpty) {
        age = int.tryParse(ageText);
        if (age == null || age < 18 || age > 99) {
          GameBoySound.playError();
          GameboyActionPopup.show(
            context,
            'Error',
            message: 'Age must be between 18 and 99',
            backgroundColor: Colors.red,
            icon: Icons.error,
            duration: Duration(milliseconds: 1500),
          );
          return;
        }
      }

      print('🚀 Updating profile...');
      final result = await ApiService.updateProfile(
        name: name,
        bio: bio.isEmpty ? null : bio,
        age: age,
        location: location.isEmpty ? null : location,
        images: images.isEmpty ? null : images,
      );

      if (result['success']) {
        final isNewProfile =
            widget.currentProfile['name']?.toString().trim().isEmpty ?? true;
        print(
          '✅ Profile ${isNewProfile ? "created" : "updated"} successfully!',
        );
        GameBoySound.playSuccess();

        GameboyActionPopup.show(
          context,
          'Success',
          message: isNewProfile
              ? 'Profile created successfully!'
              : 'Profile updated successfully!',
          backgroundColor: Colors.green,
          icon: Icons.check_circle,
        );

        // Navigate back with the updated profile data
        Future.delayed(Duration(milliseconds: 800), () {
          if (mounted) {
            final updatedProfile = {
              'name': '$name${age != null ? ', $age' : ''}',
              'age': age ?? 0,
              'bio': bio,
              'location': location,
              'images': images,
              'imageUrls': images, // For backwards compatibility
            };
            Navigator.pop(context, updatedProfile);
          }
        });
      } else {
        print('❌ Profile update failed: ${result['message']}');
        GameBoySound.playError();

        GameboyActionPopup.show(
          context,
          'Update Failed',
          message: result['message'] ?? 'Unknown error occurred',
          backgroundColor: Colors.red,
          icon: Icons.error,
        );
      }
    } catch (e) {
      print('💥 Profile update error: $e');
      GameBoySound.playError();

      GameboyActionPopup.show(
        context,
        'Network Error',
        message: 'Unable to connect to server',
        backgroundColor: Colors.red,
        icon: Icons.wifi_off,
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
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
              showImageInputs
                  ? 'EDIT IMAGES'
                  : (widget.currentProfile['name']?.toString().trim().isEmpty ??
                        true)
                  ? 'CREATE PROFILE'
                  : 'EDIT PROFILE',
              style: TextStyle(
                color: Colors.black,
                fontSize: 10, // Reduced from 12
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
                    ? '(← PROFILE | IMAGES →)'
                    : '(← PROFILE | IMAGES →)',
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
                _ageController.text.isEmpty ? 'age' : _ageController.text,
                _ageController.text.isEmpty,
              ),
              const SizedBox(height: 4),

              // Bio field
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: _buildInputField(
                  2,
                  Icons.edit,
                  _bioController.text.isEmpty ? 'Bio' : _bioController.text,
                  _bioController.text.isEmpty,
                ),
              ),
              // Location field
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: _buildInputField(
                  3,
                  Icons.location_on,
                  _locationController.text.isEmpty
                      ? 'Location'
                      : _locationController.text,
                  _locationController.text.isEmpty,
                ),
              ),
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

            // Save button
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color:
                    (showImageInputs
                        ? selectedField == 3
                        : selectedField == 4) // Changed from 5 to 4
                    ? Colors.yellow.withOpacity(0.8)
                    : Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color:
                      (showImageInputs
                          ? selectedField == 3
                          : selectedField == 4) // Changed from 5 to 4
                      ? Colors.black
                      : Colors.grey,
                  width: 1,
                ),
              ),
              child: Text(
                isSaving
                    ? 'SAVING...'
                    : (widget.currentProfile['name']
                              ?.toString()
                              .trim()
                              .isEmpty ??
                          true)
                    ? 'CREATE PROFILE'
                    : 'SAVE CHANGES',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color:
                      (showImageInputs
                          ? selectedField == 3
                          : selectedField == 4) // Changed from 5 to 4
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
