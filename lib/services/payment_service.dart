import 'package:dio/dio.dart';
import '../data/api_client.dart';
import '../data/models/models.dart';

class PaymentService {
  final ApiClient _apiClient;

  PaymentService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;

  Future<PaginatedResponse<Payment>> listPayments({
    int? page,
    int? limit,
    String? propertyId,
    String? status,
    String? type,
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page,
      'limit': limit,
      'propertyId': propertyId,
      'status': status,
      'type': type,
    }..removeWhere((_, value) => value == null);

    final response = await _apiClient.dio.get(
      '/api/v1/payments',
      queryParameters: queryParameters,
    );
    return PaginatedResponse<Payment>.fromJson(
      response.data,
      (json) => Payment.fromJson(json),
    );
  }

  Future<Payment> createPayment(
    CreatePaymentRequest request, {
    String? idempotencyKey,
  }) async {
    final response = await _apiClient.dio.post(
      '/api/v1/payments',
      data: request.toJson(),
      options: idempotencyKey != null
          ? Options(headers: {'X-Idempotency-Key': idempotencyKey})
          : null,
    );
    return Payment.fromJson(response.data);
  }

  Future<PaginatedResponse<Payment>> getCollections({
    int? page,
    int? limit,
    String? propertyId,
    String? status,
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page,
      'limit': limit,
      'propertyId': propertyId,
      'status': status,
    }..removeWhere((_, value) => value == null);

    final response = await _apiClient.dio.get(
      '/api/v1/payments/collections',
      queryParameters: queryParameters,
    );
    return PaginatedResponse<Payment>.fromJson(
      response.data,
      (json) => Payment.fromJson(json),
    );
  }

  Future<PaymentSummary> getPaymentSummary() async {
    final response = await _apiClient.dio.get('/api/v1/payments/summary');
    return PaymentSummary.fromJson(response.data);
  }
}
