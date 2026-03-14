import 'package:shiftproof/data/api_client.dart';
import 'package:shiftproof/data/models/models.dart';

class UserService {
  UserService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;
  final ApiClient _apiClient;

  Future<AppUser> getMe() async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '/api/v1/auth/me',
    );
    return AppUser.fromJson(response.data!);
  }
}
