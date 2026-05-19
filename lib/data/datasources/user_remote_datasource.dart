import 'dart:typed_data';
import 'package:fundlink_app/core/network/api_client.dart';
import 'package:fundlink_app/data/models/user_model.dart';

class UserRemoteDatasource {
  final ApiClient _apiClient = ApiClient();

  Future<UserModel> getUser() async {
    final response = await _apiClient.get('/user');
    return UserModel.fromJson(response);
  }

  Future<UserModel> updateProfile({
    required String name,
    required String email,
    String? phone,
    Uint8List? photoBytes,
    String? photoName,
  }) async {
    final fields = <String, String>{
      'name': name,
      'email': email,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
    };

    late final Map<String, dynamic> response;
    if (photoBytes != null && photoBytes.isNotEmpty) {
      response = await _apiClient.postMultipart(
        '/user/profile',
        fields,
        'photo',
        photoBytes,
        photoName ?? 'photo.jpg',
      );
    } else {
      // No photo: still use multipart so server accepts it
      response = await _apiClient.postMultipart(
        '/user/profile',
        fields,
        'photo',
        Uint8List(0),
        '',
      );
    }
    // Response may wrap user in 'user' key or return directly
    final userJson = response['user'] ?? response;
    return UserModel.fromJson(userJson as Map<String, dynamic>);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await _apiClient.post('/user/password', {
      'current_password': currentPassword,
      'password': newPassword,
      'password_confirmation': confirmPassword,
    });
  }
}
