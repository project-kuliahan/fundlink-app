import 'package:fundlink_app/core/network/api_client.dart';
import 'package:fundlink_app/data/models/user_model.dart';

class UserRemoteDatasource {
  final ApiClient _apiClient = ApiClient();

  Future<UserModel> getUser() async {
    final response = await _apiClient.get('/user');
    return UserModel.fromJson(response);
  }
}
