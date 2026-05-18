import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:fundlink_app/core/error/exceptions.dart';
import 'package:fundlink_app/data/datasources/auth_local_datasource.dart';

class ApiClient {
  static const String baseUrl = 'https://bahamud.my.id/api';
  final AuthLocalDatasource _local = AuthLocalDatasource();

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  Future<Map<String, String>> _headers({bool withAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (withAuth) {
      final token = await _local.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    bool withAuth = true,
  }) async {
    final headers = await _headers(withAuth: withAuth);
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data, {
    bool withAuth = true,
  }) async {
    final headers = await _headers(withAuth: withAuth);
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data, {
    bool withAuth = true,
  }) async {
    final headers = await _headers(withAuth: withAuth);
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool withAuth = true,
  }) async {
    final headers = await _headers(withAuth: withAuth);
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> postMultipart(
    String endpoint,
    Map<String, String> fields,
    String fileField,
    Uint8List fileBytes,
    String fileName, {
    bool withAuth = true,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (withAuth) {
      final token = await _local.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    final request =
        http.MultipartRequest('POST', Uri.parse('$baseUrl$endpoint'));
    request.headers.addAll(headers);
    request.fields.addAll(fields);
    request.files.add(http.MultipartFile.fromBytes(
      fileField,
      fileBytes,
      filename: fileName,
    ));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = response.body.isNotEmpty
        ? jsonDecode(response.body) as Map<String, dynamic>
        : <String, dynamic>{};

    switch (response.statusCode) {
      case 200:
      case 201:
        return body;
      case 401:
        _local.removeToken();
        _local.removeUser();
        throw UnauthorizedException(
          body['message'] ?? 'Session expired. Please login again.',
        );
      case 422:
        final errors = body['errors'] ?? body['message'] ?? body;
        throw ValidationException(
          errors is Map<String, dynamic> ? errors : {'error': [errors]},
        );
      case 429:
        throw RateLimitException(
          'Too many requests. Please try again later.',
        );
      case 500:
        throw ServerException(
          body['message'] ?? 'Server error. Please try again later.',
        );
      default:
        throw ApiException(
          body['message'] ?? 'Something went wrong. Status: ${response.statusCode}',
        );
    }
  }
}
