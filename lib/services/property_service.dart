import 'package:shiftproof/data/api_client.dart';
import 'package:shiftproof/data/models/models.dart';

class PropertyService {
  PropertyService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;
  final ApiClient _apiClient;

  Future<PaginatedResponse<Property>> listProperties({
    int? page,
    int? limit,
  }) async {
    final queryParameters = <String, dynamic>{'page': page, 'limit': limit}
      ..removeWhere((_, value) => value == null);

    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '/api/v1/properties',
      queryParameters: queryParameters,
    );
    return PaginatedResponse<Property>.fromJson(
      response.data!,
      Property.fromJson,
    );
  }

  Future<Property> createProperty(CreatePropertyRequest request) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      '/api/v1/properties',
      data: request.toJson(),
    );
    return Property.fromJson(response.data!);
  }

  Future<Property> getProperty(String id) async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '/api/v1/properties/$id',
    );
    return Property.fromJson(response.data!);
  }

  Future<Property> updateProperty(
    String id,
    CreatePropertyRequest request,
  ) async {
    final response = await _apiClient.dio.put<Map<String, dynamic>>(
      '/api/v1/properties/$id',
      data: request.toJson(),
    );
    return Property.fromJson(response.data!);
  }

  Future<void> deleteProperty(String id) async {
    await _apiClient.dio.delete<Map<String, dynamic>>('/api/v1/properties/$id');
  }
}
