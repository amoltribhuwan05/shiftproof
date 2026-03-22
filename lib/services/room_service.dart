import 'package:shiftproof/data/api_client.dart';
import 'package:shiftproof/data/models/models.dart';

class RoomService {
  RoomService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;
  final ApiClient _apiClient;

  /// GET /api/v1/properties/{propertyId}/rooms — returns a flat list (not paginated).
  Future<List<Room>> listRooms({required String propertyId}) async {
    final response = await _apiClient.dio.get<List<dynamic>>(
      '/api/v1/properties/$propertyId/rooms',
    );
    return (response.data ?? [])
        .cast<Map<String, dynamic>>()
        .map(Room.fromJson)
        .toList();
  }

  /// POST /api/v1/properties/{propertyId}/rooms
  Future<Room> createRoom(
    String propertyId,
    CreateRoomRequest request,
  ) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      '/api/v1/properties/$propertyId/rooms',
      data: request.toJson(),
    );
    return Room.fromJson(response.data!);
  }

  /// PATCH /api/v1/rooms/{id}
  Future<Room> updateRoom(String id, UpdateRoomRequest request) async {
    final response = await _apiClient.dio.patch<Map<String, dynamic>>(
      '/api/v1/rooms/$id',
      data: request.toJson(),
    );
    return Room.fromJson(response.data!);
  }

  /// DELETE /api/v1/rooms/{id}
  Future<void> deleteRoom(String id) async {
    await _apiClient.dio.delete<void>('/api/v1/rooms/$id');
  }
}
