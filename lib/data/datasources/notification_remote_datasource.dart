import 'package:fundlink_app/core/network/api_client.dart';
import 'package:fundlink_app/data/models/notification_model.dart';

class NotificationRemoteDatasource {
  final ApiClient _apiClient = ApiClient();

  Future<List<NotificationModel>> getNotifications({int page = 1}) async {
    final response = await _apiClient.get('/notifications?page=$page');
    final List<dynamic> data = response['data'] ?? [];
    return data.map((e) => NotificationModel.fromJson(e)).toList();
  }
}
