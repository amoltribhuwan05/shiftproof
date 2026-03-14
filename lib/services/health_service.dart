import '../data/api_client.dart';

class HealthService {
  final ApiClient _apiClient;

  HealthService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient.instance;

  Future<Map<String, String>> healthCheck() async {
    final response = await _apiClient.dio.get('/health');
    return Map<String, String>.from(response.data as Map);
  }
}
