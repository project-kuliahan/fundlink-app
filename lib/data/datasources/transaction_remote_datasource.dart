import 'dart:typed_data';

import 'package:fundlink_app/core/constants/app_limits.dart';
import 'package:fundlink_app/core/error/exceptions.dart';
import 'package:fundlink_app/core/network/api_client.dart';
import 'package:fundlink_app/data/models/transaction_model.dart';

class TransactionRemoteDatasource {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getTransactions({int page = 1}) async {
    final response = await _apiClient.get('/transactions?page=$page');
    final List<dynamic> data = response['data'] ?? [];
    return {
      'transactions': data.map((e) => TransactionModel.fromJson(e)).toList(),
      'current_page': response['current_page'] ?? 1,
      'last_page': response['last_page'] ?? 1,
      'total': response['total'] ?? 0,
    };
  }

  Future<TransactionModel> createTransaction(
    Map<String, dynamic> data, {
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    late final Map<String, dynamic> response;
    if (imageBytes != null && imageBytes.isNotEmpty) {
      if (imageBytes.lengthInBytes > AppLimits.maxUploadImageBytes) {
        throw ValidationException({
          'image': ['Ukuran gambar maksimal ${AppLimits.maxUploadImageKb} KB'],
        });
      }
      response = await _apiClient.postMultipart(
        '/transactions',
        data.map((k, v) => MapEntry(k, v.toString())),
        'attachment',
        imageBytes,
        imageName ?? 'photo.jpg',
      );
    } else {
      response = await _apiClient.post('/transactions', data);
    }
    return TransactionModel.fromJson(response['transaction']);
  }
}
