import 'package:shiftproof/data/api_client.dart';
import 'package:shiftproof/data/models/models.dart';

class PlanService {
  PlanService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;
  final ApiClient _apiClient;

  Future<List<Plan>> listPlans() async {
    final response = await _apiClient.dio.get<List<dynamic>>('/api/v1/plans');
    return response.data!
        .map((e) => Plan.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
