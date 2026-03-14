import 'package:shiftproof/data/api_client.dart';

class HealthService {
  HealthService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;
  final ApiClient _apiClient;

  Future<Map<String, String>> healthCheck() async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>('/health');
    return Map<String, String>.from(response.data!);
  }
}
