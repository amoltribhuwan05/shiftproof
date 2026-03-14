import 'package:shiftproof/data/api_client.dart';
import 'package:shiftproof/data/models/models.dart';

class PayoutService {
  PayoutService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;
  final ApiClient _apiClient;

  Future<PaginatedResponse<Payout>> listPayouts({int? page, int? limit}) async {
    final queryParameters = <String, dynamic>{'page': page, 'limit': limit}
      ..removeWhere((_, value) => value == null);

    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '/api/v1/payouts',
      queryParameters: queryParameters,
    );
    return PaginatedResponse<Payout>.fromJson(response.data!, Payout.fromJson);
  }
}
