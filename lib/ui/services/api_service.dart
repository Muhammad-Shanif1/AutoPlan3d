import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

import '../controller/auth/authcontroller.dart';

class ApiService {
  static const String baseUrl = 'https://autopnan-autoplan-backend.hf.space';
  // Use your computer's local IP for physical devices:
  // static const String baseUrl = 'http://192.168.17.5:8000';
  final _storage = GetStorage();

  // Singleton pattern
  ApiService._();
  static final ApiService instance = ApiService._();

  Map<String, String> _getHeaders({bool requireAuth = true, bool isMultipart = false}) {
    final headers = {
      'Accept': 'application/json',
    };

    if (!isMultipart) {
      headers['Content-Type'] = 'application/json';
    }
    
    if (requireAuth) {
      final token = _storage.read('token');
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      } else {
        print('⚠️ API Request to $requireAuth requires auth, but no token was found in storage.');
      }
    }
    return headers;
  }

  Future<http.Response> get(String endpoint, {bool requireAuth = true, bool autoLogout = true}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(requireAuth: requireAuth),
      ).timeout(const Duration(seconds: 15));
      return _handleResponse(response, requireAuth: requireAuth, autoLogout: autoLogout);
    } catch (e) {
      print('GET error on $endpoint: $e');
      rethrow;
    }
  }

  Future<http.Response> post(String endpoint, {dynamic body, bool requireAuth = true, bool autoLogout = true}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(requireAuth: requireAuth),
        body: body != null ? jsonEncode(body) : null,
      ).timeout(const Duration(seconds: 15));
      return _handleResponse(response, requireAuth: requireAuth, autoLogout: autoLogout);
    } catch (e) {
      print('POST error on $endpoint: $e');
      rethrow;
    }
  }

  Future<http.Response> put(String endpoint, {dynamic body, bool requireAuth = true, bool autoLogout = true}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(requireAuth: requireAuth),
        body: body != null ? jsonEncode(body) : null,
      ).timeout(const Duration(seconds: 15));
      return _handleResponse(response, requireAuth: requireAuth, autoLogout: autoLogout);
    } catch (e) {
      print('PUT error on $endpoint: $e');
      rethrow;
    }
  }

  Future<http.Response> delete(String endpoint, {dynamic body, bool requireAuth = true, bool autoLogout = true}) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(requireAuth: requireAuth),
        body: body != null ? jsonEncode(body) : null,
      ).timeout(const Duration(seconds: 15));
      return _handleResponse(response, requireAuth: requireAuth, autoLogout: autoLogout);
    } catch (e) {
      print('DELETE error on $endpoint: $e');
      rethrow;
    }
  }

  http.Response _handleResponse(http.Response response, {required bool requireAuth, bool autoLogout = true}) {
    if (response.statusCode == 401 && requireAuth && autoLogout) {
      // ONLY auto-logout if the request was supposed to be authenticated
      // (Session expired or invalid token)
      try {
        Get.find<AuthController>().logout(showSnackbar: false);
      } catch (e) {
        print('Error during auto-logout: $e');
      }
    }
    return response;
  }

  Future<http.Response> uploadImage(String endpoint, String filePath, {bool requireAuth = true}) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl$endpoint'));
      
      // Add headers
      final headers = _getHeaders(requireAuth: requireAuth, isMultipart: true);
      request.headers.addAll(headers);

      // Add file
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);
      
      return _handleResponse(response, requireAuth: requireAuth);
    } catch (e) {
      print('Upload error on $endpoint: $e');
      rethrow;
    }
  }
}
