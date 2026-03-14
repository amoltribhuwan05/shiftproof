import '../data/api_client.dart';
import '../data/models/models.dart';

class PropertyService {
  final ApiClient _apiClient;

  PropertyService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;

  Future<PaginatedResponse<Property>> listProperties({
    int? page,
    int? limit,
  }) async {
    final queryParameters = <String, dynamic>{'page': page, 'limit': limit}
      ..removeWhere((_, value) => value == null);

    final response = await _apiClient.dio.get(
      '/api/v1/properties',
      queryParameters: queryParameters,
    );
    return PaginatedResponse<Property>.fromJson(
      response.data,
      (json) => Property.fromJson(json),
    );
  }

  Future<Property> createProperty(CreatePropertyRequest request) async {
    final response = await _apiClient.dio.post(
      '/api/v1/properties',
      data: request.toJson(),
    );
    return Property.fromJson(response.data);
  }

  Future<Property> getProperty(String id) async {
    final response = await _apiClient.dio.get('/api/v1/properties/$id');
    return Property.fromJson(response.data);
  }

  Future<Property> updateProperty(
    String id,
    CreatePropertyRequest request,
  ) async {
    final response = await _apiClient.dio.put(
      '/api/v1/properties/$id',
      data: request.toJson(),
    );
    return Property.fromJson(response.data);
  }

  Future<void> deleteProperty(String id) async {
    await _apiClient.dio.delete('/api/v1/properties/$id');
  }
}
