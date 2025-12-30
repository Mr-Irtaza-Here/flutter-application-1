import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://envizenfo.com/api/signin';
  
  // Timeout duration for API calls
  static const Duration timeout = Duration(seconds: 30);

  static Future<Map<String, dynamic>> signIn(
    String username,
    String password,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse(baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'username': username,
              'password': password,
            }),
          )
          .timeout(timeout);

      // Log the response for debugging - shows in terminal
      // ignore: avoid_print
      print('========== SERVER RESPONSE ==========');
      // ignore: avoid_print
      print('Status Code: ${response.statusCode}');
      // ignore: avoid_print  
      print('Response Body: ${response.body}');
      // ignore: avoid_print
      print('======================================');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Invalid username or password',
        };
      } else if (response.statusCode == 400) {
        // Try to parse error message from response
        try {
          final errorData = jsonDecode(response.body);
          return {
            'success': false,
            'message': errorData['message'] ?? 'Bad request',
          };
        } catch (_) {
          return {
            'success': false,
            'message': 'Bad request - please check your input',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
          'body': response.body,
        };
      }
    } on SocketException {
      return {
        'success': false,
        'message': 'No internet connection. Please check your network.',
      };
    } on http.ClientException catch (e) {
      return {
        'success': false,
        'message': 'Connection error: ${e.message}',
      };
    } on FormatException {
      return {
        'success': false,
        'message': 'Invalid response from server',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: $e',
      };
    }
  }
}
