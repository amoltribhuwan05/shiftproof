import '../data/api_client.dart';
import '../data/models/models.dart';

class PayoutService {
  final ApiClient _apiClient;

  PayoutService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;

  Future<PaginatedResponse<Payout>> listPayouts({int? page, int? limit}) async {
    final queryParameters = <String, dynamic>{'page': page, 'limit': limit}
      ..removeWhere((_, value) => value == null);

    final response = await _apiClient.dio.get(
      '/api/v1/payouts',
      queryParameters: queryParameters,
    );
    return PaginatedResponse<Payout>.fromJson(
      response.data,
      (json) => Payout.fromJson(json),
    );
  }
}
