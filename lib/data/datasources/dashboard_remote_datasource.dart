import 'package:fundlink_app/core/network/api_client.dart';
import 'package:fundlink_app/data/models/dashboard_model.dart';

class DashboardRemoteDatasource {
  final ApiClient _apiClient = ApiClient();

  Future<DashboardModel> getDashboard() async {
    final response = await _apiClient.get('/dashboard');
    return DashboardModel.fromJson(response);
  }
}
