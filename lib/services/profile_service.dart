import 'package:shiftproof/data/api_client.dart';
import 'package:shiftproof/data/models/models.dart';

class ProfileService {
  ProfileService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  static final ProfileService _sharedInstance = ProfileService();
  static ProfileService get instance => _sharedInstance;

  final ApiClient _apiClient;

  /// PATCH /api/v1/users/profile — update name, gender, phone, city, area.
  Future<AppUser> updateProfile({
    String? name,
    String? gender,
    String? phoneNumber,
    String? city,
    String? area,
  }) async {
    final body = <String, dynamic>{
      if (name != null && name.isNotEmpty) 'name': name,
      if (gender != null && gender.isNotEmpty) 'gender': gender,
      if (phoneNumber != null && phoneNumber.isNotEmpty) 'phoneNumber': phoneNumber,
      if (city != null && city.isNotEmpty) 'city': city,
      if (area != null && area.isNotEmpty) 'area': area,
    };
    final response = await _apiClient.dio.patch<Map<String, dynamic>>(
      '/api/v1/users/profile',
      data: body,
    );
    final data = response.data;
    if (data == null) {
      throw Exception('Server returned an empty response.');
    }
    return AppUser.fromJson(data);
  }

  Future<AppUser> completeOnboarding({
    required String name,
    required String gender,
    String? phoneNumber,
    String? city,
    String? area,
  }) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      '/api/v1/users/onboarding',
      data: {
        'name': name,
        'gender': gender,
        if (phoneNumber != null && phoneNumber.isNotEmpty) 'phoneNumber': phoneNumber,
        if (city != null && city.isNotEmpty) 'city': city,
        if (area != null && area.isNotEmpty) 'area': area,
      },
    );
    final data = response.data;
    if (data == null) {
      throw Exception('Server returned an empty response.');
    }
    return AppUser.fromJson(data);
  }
}
