import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadService {
  // Production server URL deployed on Railway
  static String get baseUrl {
    return 'https://gameboyappbackend-production.up.railway.app/api';
  }

  static final ImagePicker _picker = ImagePicker();

  // Get stored JWT token
  static Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('jwt_token');
    } catch (e) {
      print('💥 Error getting token: $e');
      return null;
    }
  }

  // Pick image from gallery or camera
  static Future<File?> pickImage({
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      print(
        '📷 Picking image from ${source == ImageSource.camera ? 'camera' : 'gallery'}',
      );

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        print('✅ Image picked: ${pickedFile.path}');
        return File(pickedFile.path);
      } else {
        print('❌ No image selected');
        return null;
      }
    } catch (e) {
      print('💥 Error picking image: $e');
      return null;
    }
  }

  // Pick multiple images
  static Future<List<File>> pickMultipleImages({int maxImages = 3}) async {
    try {
      print('📷 Picking multiple images (max: $maxImages)');

      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFiles.isNotEmpty) {
        // Limit to maxImages
        final limitedFiles = pickedFiles.take(maxImages).toList();
        final files = limitedFiles.map((xFile) => File(xFile.path)).toList();

        print('✅ ${files.length} images picked');
        return files;
      } else {
        print('❌ No images selected');
        return [];
      }
    } catch (e) {
      print('💥 Error picking multiple images: $e');
      return [];
    }
  }

  // Upload single image and get processed result
  static Future<Map<String, dynamic>> uploadImage(File imageFile) async {
    try {
      print('🚀 Uploading single image: ${imageFile.path}');

      final token = await _getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication required',
          'error': 'NO_TOKEN',
        };
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/images/upload'),
      );

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Add the image file
      request.files.add(
        await http.MultipartFile.fromPath('images', imageFile.path),
      );

      print('🌐 Sending upload request...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📡 Upload response status: ${response.statusCode}');
      print('📄 Upload response body: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData['data'],
          'message': responseData['message'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Upload failed',
          'error': responseData['error'],
          'status_code': response.statusCode,
        };
      }
    } catch (e, stackTrace) {
      print('💥 Upload error: $e');
      print('📍 Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'Network error: $e',
        'error': 'NETWORK_ERROR',
      };
    }
  }

  // Upload multiple images
  static Future<Map<String, dynamic>> uploadMultipleImages(
    List<File> imageFiles,
  ) async {
    try {
      print('🚀 Uploading ${imageFiles.length} images');

      final token = await _getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication required',
          'error': 'NO_TOKEN',
        };
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/images/upload'),
      );

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Add all image files
      for (int i = 0; i < imageFiles.length; i++) {
        request.files.add(
          await http.MultipartFile.fromPath('images', imageFiles[i].path),
        );
      }

      print('🌐 Sending multi-upload request...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📡 Multi-upload response status: ${response.statusCode}');
      print('📄 Multi-upload response body: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData['data'],
          'message': responseData['message'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Upload failed',
          'error': responseData['error'],
          'status_code': response.statusCode,
        };
      }
    } catch (e, stackTrace) {
      print('💥 Multi-upload error: $e');
      print('📍 Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'Network error: $e',
        'error': 'NETWORK_ERROR',
      };
    }
  }

  // Generate image preview
  static Future<Map<String, dynamic>> generatePreview(File imageFile) async {
    try {
      print('👁️ Generating preview for: ${imageFile.path}');

      final token = await _getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication required',
          'error': 'NO_TOKEN',
        };
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/images/preview'),
      );

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Add the image file
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      print('🌐 Sending preview request...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📡 Preview response status: ${response.statusCode}');
      print('📄 Preview response body: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData['data'],
          'message': responseData['message'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Preview generation failed',
          'error': responseData['error'],
          'status_code': response.statusCode,
        };
      }
    } catch (e, stackTrace) {
      print('💥 Preview error: $e');
      print('📍 Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'Network error: $e',
        'error': 'NETWORK_ERROR',
      };
    }
  }

  // Delete image
  static Future<Map<String, dynamic>> deleteImage(String filename) async {
    try {
      print('🗑️ Deleting image: $filename');

      final token = await _getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication required',
          'error': 'NO_TOKEN',
        };
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/images/$filename'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📡 Delete response status: ${response.statusCode}');
      print('📄 Delete response body: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': responseData['message']};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Delete failed',
          'error': responseData['error'],
          'status_code': response.statusCode,
        };
      }
    } catch (e, stackTrace) {
      print('💥 Delete error: $e');
      print('📍 Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'Network error: $e',
        'error': 'NETWORK_ERROR',
      };
    }
  }

  // Get full image URL
  static String getImageUrl(String filename) {
    return '$baseUrl/images/$filename';
  }

  // Validate Supabase or Railway URL format
  static bool isValidSupabaseUrl(String? url) {
    if (url == null || url.isEmpty) return false;

    try {
      final uri = Uri.parse(url);
      // Check if it's a Supabase storage URL or Railway deployment URL
      return uri.host.contains('supabase.co') ||
          uri.host.contains('supabase.in') ||
          uri.host.contains('railway.app') ||
          uri.host.contains('up.railway.app') ||
          _isValidLocalUrl(url); // Still support local URLs for development
    } catch (e) {
      return false;
    }
  }

  // Check if the URL is a valid local URL (for development)
  static bool _isValidLocalUrl(String url) {
    return url.startsWith('http://10.0.2.2') ||
        url.startsWith('http://localhost');
  }
}
