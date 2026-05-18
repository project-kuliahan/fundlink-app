import 'package:fundlink_app/core/network/api_client.dart';
import 'package:fundlink_app/data/models/user_model.dart';

class AuthRemoteDatasource {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _apiClient.post('/login', {
      'email': email,
      'password': password,
    });
    return {
      'token': response['token'],
      'user': UserModel.fromJson(response['user']),
    };
  }

  Future<UserModel> getMe() async {
    final response = await _apiClient.get('/user');
    return UserModel.fromJson(response);
  }

  Future<void> logout() async {
    await _apiClient.post('/logout', {});
  }
}
