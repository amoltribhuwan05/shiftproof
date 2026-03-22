import 'package:dio/dio.dart';
import 'package:shiftproof/data/api_client.dart';
import 'package:shiftproof/data/models/models.dart';

class PaymentService {
  PaymentService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;
  final ApiClient _apiClient;

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

    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '/api/v1/payments',
      queryParameters: queryParameters,
    );
    return PaginatedResponse<Payment>.fromJson(
      response.data!,
      Payment.fromJson,
    );
  }

  Future<Payment> createPayment(
    CreatePaymentRequest request, {
    String? idempotencyKey,
  }) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      '/api/v1/payments',
      data: request.toJson(),
      options: idempotencyKey != null
          ? Options(headers: {'X-Idempotency-Key': idempotencyKey})
          : null,
    );
    return Payment.fromJson(response.data!);
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

    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '/api/v1/payments/collections',
      queryParameters: queryParameters,
    );
    return PaginatedResponse<Payment>.fromJson(
      response.data!,
      Payment.fromJson,
    );
  }

  Future<PaymentSummary> getPaymentSummary() async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '/api/v1/payments/summary',
    );
    return PaymentSummary.fromJson(response.data!);
  }

  /// POST /api/v1/payments/{id}/pay — confirm payment after gateway success.
  /// [paymentMethod]: "upi" | "card" | "netbanking"
  /// [transactionRef]: gateway-issued reference / UTR number
  Future<Payment> payPayment(
    String paymentId, {
    required String paymentMethod,
    required String transactionRef,
  }) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      '/api/v1/payments/$paymentId/pay',
      data: {
        'paymentMethod': paymentMethod,
        'transactionRef': transactionRef,
      },
    );
    return Payment.fromJson(response.data!);
  }
}
