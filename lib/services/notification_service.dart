import 'package:shiftproof/data/api_client.dart';
import 'package:shiftproof/data/models/models.dart';

class NotificationService {
  NotificationService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;
  final ApiClient _apiClient;

  Future<PaginatedResponse<AppNotification>> listNotifications({
    int? page,
    int? limit,
  }) async {
    final queryParameters = <String, dynamic>{'page': page, 'limit': limit}
      ..removeWhere((_, value) => value == null);

    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '/api/v1/notifications',
      queryParameters: queryParameters,
    );
    return PaginatedResponse<AppNotification>.fromJson(
      response.data!,
      AppNotification.fromJson,
    );
  }

  Future<void> markAllNotificationsRead() async {
    await _apiClient.dio.patch<Map<String, dynamic>>(
      '/api/v1/notifications/mark-all-read',
    );
  }

  Future<AppNotification> markNotificationRead(String id) async {
    final response = await _apiClient.dio.patch<Map<String, dynamic>>(
      '/api/v1/notifications/$id/read',
    );
    return AppNotification.fromJson(response.data!);
  }
}
