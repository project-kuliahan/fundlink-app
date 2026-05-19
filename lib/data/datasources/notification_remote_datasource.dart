import 'package:fundlink_app/core/network/api_client.dart';
import 'package:fundlink_app/data/models/notification_model.dart';

class NotificationRemoteDatasource {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getNotificationsPaged({int page = 1}) async {
    final response = await _apiClient.get('/notifications?page=$page');
    final List<dynamic> data = response['data'] ?? [];
    return {
      'notifications': data.map((e) => NotificationModel.fromJson(e)).toList(),
      'current_page': response['current_page'] ?? 1,
      'last_page': response['last_page'] ?? 1,
    };
  }

  // Keep old method for backward compatibility
  Future<List<NotificationModel>> getNotifications({int page = 1}) async {
    final result = await getNotificationsPaged(page: page);
    return result['notifications'] as List<NotificationModel>;
  }

  Future<void> markAsRead(int id) async {
    await _apiClient.post('/notifications/$id/read', {});
  }
}
