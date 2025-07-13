import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

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
    final token = await getToken();
    final headers = {'Content-Type': 'application/json'};

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Handle API response
  static Map<String, dynamic> handleResponse(http.Response response) {
    print('🔍 API: Processing response with status ${response.statusCode}');
    print('📄 API: Raw response body: ${response.body}');

    try {
      final body = json.decode(response.body);
      print('✅ API: Successfully parsed JSON: $body');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('🎉 API: Success response');
        return {
          'success': true,
          'data': body,
          'statusCode': response.statusCode,
        };
      } else {
        print('❌ API: Error response');
        return {
          'success': false,
          'error': body['error'] ?? 'Unknown error',
          'message': body['message'] ?? 'Request failed',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('💥 API: JSON parsing failed: $e');
      return {
        'success': false,
        'error': 'Invalid response format',
        'message': 'Failed to parse server response: ${response.body}',
        'statusCode': response.statusCode,
      };
    }
  }

  // Register user
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String username,
    required String name,
  }) async {
    try {
      print(
        '🌐 API: Starting register request for email: $email, username: $username',
      );
      final headers = await getHeaders();
      print('📡 API: Headers: $headers');

      final url = '$baseUrl/auth/register';
      print('🎯 API: Request URL: $url');

      final body = json.encode({
        'email': email,
        'password': password,
        'username': username,
        'name': name,
      });
      print('📦 API: Request body: $body');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      print('📊 API: Response status code: ${response.statusCode}');
      print('📋 API: Response body: ${response.body}');

      final result = handleResponse(response);
      print('🔄 API: Processed result: $result');

      if (result['success'] && result['data']['token'] != null) {
        print('🔐 API: Storing auth token');
        await storeToken(result['data']['token']);
      }

      return result;
    } catch (e) {
      print('💥 API: Register exception: $e');
      print('🔍 API: Exception stack trace: ${StackTrace.current}');
      return {
        'success': false,
        'error': 'Network error',
        'message': e.toString(),
      };
    }
  }

  // Login user
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🌐 API: Starting login request for email: $email');
      final headers = await getHeaders();
      print('📡 API: Headers: $headers');

      final url = '$baseUrl/auth/login';
      print('🎯 API: Request URL: $url');

      final body = json.encode({'email': email, 'password': password});
      print('📦 API: Request body: $body');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      print('📊 API: Response status code: ${response.statusCode}');
      print('📋 API: Response body: ${response.body}');

      final result = handleResponse(response);
      print('🔄 API: Processed result: $result');

      if (result['success'] && result['data']['token'] != null) {
        print('🔐 API: Storing auth token');
        await storeToken(result['data']['token']);
      }

      return result;
    } catch (e) {
      print('💥 API: Login exception: $e');
      print('🔍 API: Exception stack trace: ${StackTrace.current}');
      return {
        'success': false,
        'error': 'Network error',
        'message': e.toString(),
      };
    }
  }

  // Verify token
  static Future<Map<String, dynamic>> verifyToken() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/auth/verify'),
        headers: headers,
      );

      return handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error',
        'message': e.toString(),
      };
    }
  }

  // Logout user
  static Future<void> logout() async {
    await clearToken();
  }

  // Get user profile
  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/users/me'),
        headers: headers,
      );

      return handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error',
        'message': e.toString(),
      };
    }
  }

  // Get dating profile
  static Future<Map<String, dynamic>> getDatingProfile() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/profiles/me'),
        headers: headers,
      );

      return handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error',
        'message': e.toString(),
      };
    }
  }

  // Discover profiles
  static Future<Map<String, dynamic>> discoverProfiles({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/profiles/discover?page=$page&limit=$limit'),
        headers: headers,
      );

      return handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error',
        'message': e.toString(),
      };
    }
  }

  // Create/update dating profile
  static Future<Map<String, dynamic>> saveDatingProfile({
    required int age,
    String? bio,
    List<String>? interests,
    String? location,
    List<String>? imageUrls,
  }) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/profiles/me'),
        headers: headers,
        body: json.encode({
          'age': age,
          'bio': bio ?? '',
          'interests': interests ?? [],
          'location': location ?? '',
          'image_urls': imageUrls ?? [],
        }),
      );

      return handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error',
        'message': e.toString(),
      };
    }
  }

  // Create match (like/superlike/pass)
  static Future<Map<String, dynamic>> createMatch({
    required String targetUserId,
    required String action, // 'like', 'superlike', 'pass'
  }) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/matches'),
        headers: headers,
        body: json.encode({'target_user_id': targetUserId, 'action': action}),
      );

      return handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error',
        'message': e.toString(),
      };
    }
  }

  // Get user's own profile
  static Future<Map<String, dynamic>> getMyProfile() async {
    try {
      print('🌐 API: Starting get my profile request');
      final headers = await getHeaders();
      final url = '$baseUrl/profiles/me';
      print('🎯 API: Request URL: $url');

      final response = await http.get(Uri.parse(url), headers: headers);

      print('📥 API: Profile response status: ${response.statusCode}');
      return handleResponse(response);
    } catch (e) {
      print('💥 API: Get profile error: $e');
      return {
        'success': false,
        'error': 'Network error',
        'message': e.toString(),
      };
    }
  }

  // Update user profile
  static Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? bio,
    int? age,
    String? location,
    List<String>? images,
    List<String>? interests,
  }) async {
    try {
      print('🌐 API: Starting update profile request');
      final headers = await getHeaders();
      final url = '$baseUrl/profiles/me';
      print('🎯 API: Request URL: $url');

      final bodyData = <String, dynamic>{};
      if (name != null) bodyData['name'] = name;
      if (bio != null) bodyData['bio'] = bio;
      if (age != null) bodyData['age'] = age;
      if (location != null) bodyData['location'] = location;
      if (images != null) bodyData['images'] = images;
      if (interests != null) bodyData['interests'] = interests;

      final body = json.encode(bodyData);
      print('📦 API: Request body: $body');

      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      print('📥 API: Update profile response status: ${response.statusCode}');
      return handleResponse(response);
    } catch (e) {
      print('💥 API: Update profile error: $e');
      return {
        'success': false,
        'error': 'Network error',
        'message': e.toString(),
      };
    }
  }

  // Get matches
  static Future<Map<String, dynamic>> getMatches({
    bool includeAll = false,
  }) async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/matches/me?include_all=$includeAll'),
        headers: headers,
      );

      return handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error',
        'message': e.toString(),
      };
    }
  }
}
