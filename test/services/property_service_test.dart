import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:shiftproof/data/api_client.dart';
import 'package:shiftproof/services/property_service.dart';

@GenerateMocks([Dio, ApiClient])
void main() {
  late PropertyService propertyService;
  late ApiClient mockApiClient;

  setUp(() {
    mockApiClient = ApiClient(); // For real use, we'd mock Dio
    propertyService = PropertyService(apiClient: mockApiClient);
  });

  group('PropertyService tests', () {
    test('instance creation', () {
      expect(propertyService, isNotNull);
    });
  });
}
