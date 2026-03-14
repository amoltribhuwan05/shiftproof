import '../data/api_client.dart';
import '../data/models/models.dart';

class NotificationService {
  final ApiClient _apiClient;

  NotificationService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;

  Future<PaginatedResponse<AppNotification>> listNotifications({
    int? page,
    int? limit,
  }) async {
    final queryParameters = <String, dynamic>{'page': page, 'limit': limit}
      ..removeWhere((_, value) => value == null);

    final response = await _apiClient.dio.get(
      '/api/v1/notifications',
      queryParameters: queryParameters,
    );
    return PaginatedResponse<AppNotification>.fromJson(
      response.data,
      (json) => AppNotification.fromJson(json),
    );
  }

  Future<void> markAllNotificationsRead() async {
    await _apiClient.dio.patch('/api/v1/notifications/mark-all-read');
  }

  Future<AppNotification> markNotificationRead(String id) async {
    final response = await _apiClient.dio.patch(
      '/api/v1/notifications/$id/read',
    );
    return AppNotification.fromJson(response.data);
  }
}
