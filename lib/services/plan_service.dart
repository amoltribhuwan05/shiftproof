import '../data/api_client.dart';
import '../data/models/models.dart';

class PlanService {
  final ApiClient _apiClient;

  PlanService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient.instance;

  Future<List<Plan>> listPlans() async {
    final response = await _apiClient.dio.get('/api/v1/plans');
    return (response.data as List<dynamic>)
        .map((e) => Plan.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
