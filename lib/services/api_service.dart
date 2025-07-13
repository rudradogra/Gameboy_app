import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Use platform-specific URL for Android emulator vs iOS simulator
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api'; // Android emulator maps to host localhost
    } else {
      return 'http://localhost:3000/api'; // iOS simulator and other platforms
    }
  }

  // Get stored token with enhanced logging
  static Future<String?> _getToken() async {
    try {
      print(
        '🔑 ApiService: Attempting to retrieve JWT token from SharedPreferences',
      );
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token != null) {
        print('✅ ApiService: JWT token found and retrieved successfully');
        print('🔍 ApiService: Token length: ${token.length} characters');
      } else {
        print('❌ ApiService: No JWT token found in SharedPreferences');
      }

      return token;
    } catch (e) {
      print('💥 ApiService: Error retrieving JWT token: $e');
      return null;
    }
  }

  // Get stored token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Store token
  static Future<void> storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Clear token
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Get headers with authorization
  static Future<Map<String, String>> getHeaders() async {
    final token = await _getToken();
    print(
      '🔍 ApiService: Getting headers with token: ${token != null ? 'Present' : 'Missing'}',
    );

    final headers = {'Content-Type': 'application/json'};

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
      print('✅ ApiService: Authorization header added to request');
    } else {
      print(
        '⚠️ ApiService: No token available, proceeding without authorization',
      );
    }

    return headers;
  }

  // Get current user profile with enhanced logging
  static Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      print('👤 ApiService: Getting current user profile...');
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/profiles/me'),
        headers: headers,
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      Map<String, dynamic> body;
      try {
        body = json.decode(response.body);
      } catch (e) {
        print('💥 Failed to parse response JSON: $e');
        return {
          'success': false,
          'error': 'Invalid response format',
          'message': 'Server returned invalid JSON',
          'status_code': response.statusCode,
        };
      }

      if (response.statusCode == 200) {
        return {'success': true, 'data': body};
      } else if (response.statusCode == 404) {
        // Profile not found - this is expected for new users
        print(
          '👤 ApiService: Profile not found (404) - user needs to create profile',
        );
        return {
          'success': false,
          'error': 'PROFILE_NOT_FOUND',
          'message':
              body['message'] ??
              'Profile not found - please create your profile',
          'status_code': response.statusCode,
          'should_create_profile': true,
        };
      } else {
        // Other error codes
        return {
          'success': false,
          'error': body['error'] ?? 'Unknown error',
          'message': body['message'] ?? 'Failed to get user profile',
          'status_code': response.statusCode,
        };
      }
    } catch (e) {
      print('💥 Error getting current user: $e');
      return {
        'success': false,
        'error': 'NETWORK_ERROR',
        'message': 'Network error: $e',
        'exception': e.toString(),
      };
    }
  }

  // Discover profiles with comprehensive logging
  static Future<Map<String, dynamic>> discoverProfiles({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      print(
        '🔍 ApiService: Starting discoverProfiles - page: $page, limit: $limit',
      );

      final url = '$baseUrl/profiles/discover?page=$page&limit=$limit';
      print('🌐 ApiService: Making request to: $url');

      final headers = await getHeaders();
      print(
        '📋 ApiService: Headers prepared, authorization present: ${headers.containsKey('Authorization')}',
      );

      print('🚀 ApiService: Sending HTTP GET request...');
      final response = await http.get(Uri.parse(url), headers: headers);

      print('📡 ApiService: Response received');
      print('📊 ApiService: Status code: ${response.statusCode}');
      print(
        '📄 ApiService: Response body length: ${response.body.length} characters',
      );
      print('📝 ApiService: Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ ApiService: Successful response, parsing JSON...');
        final body = json.decode(response.body);
        print('🔍 ApiService: Parsed JSON keys: ${body.keys.toList()}');

        if (body['data'] != null && body['data']['profiles'] != null) {
          final profileCount = (body['data']['profiles'] as List).length;
          print('👥 ApiService: Found $profileCount profiles in response');
        }

        return {'success': true, 'data': body};
      } else {
        print('❌ ApiService: Error response');
        final body = json.decode(response.body);
        return {
          'success': false,
          'message': body['message'] ?? 'Unknown error',
          'error': body['error'],
        };
      }
    } catch (e, stackTrace) {
      print('💥 ApiService: Exception in discoverProfiles: $e');
      print('📍 ApiService: Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'Network error: $e',
        'error': e.toString(),
      };
    }
  }

  // Update user profile
  static Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> profileData,
  ) async {
    try {
      print('🔄 Updating profile with data: $profileData');

      final headers = await getHeaders();
      final body = json.encode({
        'name': profileData['name'],
        'age': profileData['age'],
        'bio': profileData['bio'],
        'location': profileData['location'],
        'interests': profileData['interests'] ?? [], // Default to empty array
        'images':
            profileData['imageUrls'], // Changed from 'image_urls' to 'images'
      });

      print('📤 Sending profile update request');
      print('📄 Request body: $body');

      final response = await http.put(
        Uri.parse('$baseUrl/profiles/me'),
        headers: headers,
        body: body,
      );

      print('📡 Profile update response status: ${response.statusCode}');
      print('📄 Profile update response body: ${response.body}');

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        print('✅ Profile update successful');
        return {'success': true, 'data': responseBody};
      } else {
        print('❌ Profile update failed: ${responseBody['message']}');
        return {
          'success': false,
          'message': responseBody['message'] ?? 'Failed to update profile',
        };
      }
    } catch (e) {
      print('💥 Error updating profile: $e');
      return {'success': false, 'message': 'Network error'};
    }
  }

  // Login user
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        // Store JWT token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', body['token']);

        return {'success': true, 'data': body};
      } else {
        return {'success': false, 'message': body['message'] ?? 'Login failed'};
      }
    } catch (e) {
      print('Login error: $e');
      return {'success': false, 'message': 'Network error'};
    }
  }

  // Register user
  static Future<Map<String, dynamic>> register(
    String email,
    String password,
    String username,
    String name,
  ) async {
    try {
      print('🚀 ApiService: Starting registration process...');
      print('📧 ApiService: Email: $email');
      print('🔒 ApiService: Password length: ${password.length} characters');
      print('👤 ApiService: Username: $username');
      print('🏷️ ApiService: Name: $name');

      final url = '$baseUrl/auth/register';
      print('🌐 ApiService: Registration URL: $url');

      final requestBody = {
        'email': email,
        'password': password,
        'username': username,
        'name': name,
      };
      print('📤 ApiService: Request body: $requestBody');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      print('📡 ApiService: Registration response received');
      print('📊 ApiService: Status code: ${response.statusCode}');
      print('📄 ApiService: Response headers: ${response.headers}');
      print('📝 ApiService: Response body: ${response.body}');

      Map<String, dynamic> body;
      try {
        body = json.decode(response.body);
        print('✅ ApiService: Successfully parsed JSON response');
      } catch (jsonError) {
        print('💥 ApiService: Failed to parse JSON response: $jsonError');
        print('🔍 ApiService: Raw response body: ${response.body}');
        return {
          'success': false,
          'message': 'Invalid server response: Unable to parse JSON',
          'error': 'JSON_PARSE_ERROR',
          'raw_response': response.body,
        };
      }

      if (response.statusCode == 201) {
        print('✅ ApiService: Registration successful!');

        if (body['token'] != null) {
          // Store JWT token
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', body['token']);
          print('✅ ApiService: JWT token stored successfully');
        } else {
          print('⚠️ ApiService: No token found in successful response');
        }

        return {'success': true, 'data': body};
      } else {
        print(
          '❌ ApiService: Registration failed with status ${response.statusCode}',
        );
        print('🔍 ApiService: Error message: ${body['message']}');
        print('🔍 ApiService: Error details: ${body['error']}');
        print('🔍 ApiService: Full error response: $body');

        return {
          'success': false,
          'message': body['message'] ?? 'Registration failed',
          'error': body['error'],
          'status_code': response.statusCode,
          'full_response': body,
        };
      }
    } catch (e, stackTrace) {
      print('💥 ApiService: Registration exception: $e');
      print('📍 ApiService: Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'Network error: $e',
        'error': 'NETWORK_ERROR',
        'exception': e.toString(),
      };
    }
  }

  // Logout user
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await _getToken();
    return token != null;
  }

  // Delete profile
  static Future<Map<String, dynamic>> deleteProfile() async {
    try {
      final headers = await getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/profiles/me'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        final body = json.decode(response.body);
        return {
          'success': false,
          'message': body['message'] ?? 'Failed to delete profile',
        };
      }
    } catch (e) {
      print('Error deleting profile: $e');
      return {'success': false, 'message': 'Network error'};
    }
  }

  // Get user profile by ID
  static Future<Map<String, dynamic>> getProfile(String profileId) async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/profiles/$profileId'),
        headers: headers,
      );

      final body = json.decode(response.body);
      return {'success': response.statusCode == 200, 'data': body};
    } catch (e) {
      print('Error getting profile: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Create or update profile
  static Future<Map<String, dynamic>> createProfile(
    Map<String, dynamic> profileData,
  ) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/profiles'),
        headers: headers,
        body: json.encode({
          'name': profileData['name'],
          'age': profileData['age'],
          'bio': profileData['bio'],
          'location': profileData['location'],
          'interests': profileData['interests'],
          'image_urls': profileData['imageUrls'],
        }),
      );

      final body = json.decode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'data': body};
      } else {
        return {
          'success': false,
          'message': body['message'] ?? 'Failed to create profile',
        };
      }
    } catch (e) {
      print('Error creating profile: $e');
      return {'success': false, 'message': 'Network error'};
    }
  }

  // Handle swipe action (like/pass)
  static Future<Map<String, dynamic>> handleSwipe(
    String targetUserId,
    String action,
  ) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/profiles/match'),
        headers: headers,
        body: json.encode({'target_user_id': targetUserId, 'action': action}),
      );

      final body = json.decode(response.body);
      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'data': body,
      };
    } catch (e) {
      print('Error handling swipe: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Get matches
  static Future<Map<String, dynamic>> getMatches() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/profiles/matches'),
        headers: headers,
      );

      final body = json.decode(response.body);
      return {'success': response.statusCode == 200, 'data': body};
    } catch (e) {
      print('Error getting matches: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
}
