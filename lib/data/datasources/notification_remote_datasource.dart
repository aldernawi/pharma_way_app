import '../../core/network/dio_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_helper.dart';
import '../models/notification_model.dart';

class NotificationRemoteDataSource {
  final DioClient _dioClient = DioClient();

  Future<List<NotificationModel>> getNotifications({int page = 1, int perPage = 20}) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.notifications,
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      return ApiHelper.extractList(
        response.data,
        (json) => NotificationModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _dioClient.patch('/notifications/$id/read');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _dioClient.patch('/notifications/read-all');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _dioClient.delete('/notifications/$id');
    } catch (e) {
      rethrow;
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _dioClient.get('/notifications/unread-count');
      final data = response.data;
      if (data is Map && data['data'] is Map) {
        return data['data']['count'] ?? 0;
      }
      return 0;
    } catch (e) {
      rethrow;
    }
  }
}
