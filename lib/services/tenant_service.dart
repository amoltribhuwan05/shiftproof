import 'package:shiftproof/data/api_client.dart';
import 'package:shiftproof/data/models/models.dart';

class TenantService {
  TenantService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;
  final ApiClient _apiClient;

  /// GET /api/v1/properties/{propertyId}/tenants?page=1&limit=20
  Future<PaginatedResponse<Tenant>> listTenants({
    required String propertyId,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '/api/v1/properties/$propertyId/tenants',
      queryParameters: {'page': page, 'limit': limit},
    );
    return PaginatedResponse<Tenant>.fromJson(
      response.data!,
      Tenant.fromJson,
    );
  }

  /// POST /api/v1/tenants/join — tenant joins a property using an invite code.
  Future<void> joinProperty(String inviteCode) async {
    await _apiClient.dio.post<Map<String, dynamic>>(
      '/api/v1/tenants/join',
      data: {'inviteCode': inviteCode},
    );
  }

  /// POST /api/v1/properties/{propertyId}/tenants/invite
  /// Returns [TenantInviteResponse] containing the generated invite code.
  Future<TenantInviteResponse> inviteTenant(
    String propertyId,
    InviteTenantRequest request,
  ) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      '/api/v1/properties/$propertyId/tenants/invite',
      data: request.toJson(),
    );
    return TenantInviteResponse.fromJson(response.data!);
  }

  /// DELETE /api/v1/tenants/{id}
  Future<void> removeTenant(String id) async {
    await _apiClient.dio.delete<void>('/api/v1/tenants/$id');
  }
}
