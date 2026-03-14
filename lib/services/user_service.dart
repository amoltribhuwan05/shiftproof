import '../data/api_client.dart';
import '../data/models/models.dart';

class UserService {
  final ApiClient _apiClient;

  UserService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  Future<AppUser> getMe() async {
    final response = await _apiClient.dio.get('/api/v1/auth/me');
    return AppUser.fromJson(response.data as Map<String, dynamic>);
  }
}
