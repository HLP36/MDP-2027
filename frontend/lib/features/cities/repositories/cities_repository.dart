import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../models/city.dart';

class CitiesRepository {
  CitiesRepository({required ApiClient apiClient}) : _dio = apiClient.dio;

  final Dio _dio;

  Future<List<City>> findAll() async {
    final response = await _dio.get('/cities');

    final data = response.data;

    if (data is! List) {
      throw const FormatException('Réponse des villes invalide.');
    }

    return data
        .whereType<Map>()
        .map((item) => City.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<City> create({
    required String name,
    required String code,
    String? country,
  }) async {
    final response = await _dio.post(
      '/cities',
      data: {
        'name': name,
        'code': code,
        if (country != null && country.trim().isNotEmpty)
          'country': country.trim(),
      },
    );

    final data = response.data;

    if (data is! Map) {
      throw const FormatException('Réponse de création de la ville invalide.');
    }

    return City.fromJson(Map<String, dynamic>.from(data));
  }

  Future<City> update({
    required String id,
    String? name,
    String? code,
    String? country,
    bool? isActive,
  }) async {
    final response = await _dio.patch(
      '/cities/$id',
      data: {
        if (name != null) 'name': name,
        if (code != null) 'code': code,
        if (country != null) 'country': country,
        if (isActive != null) 'isActive': isActive,
      },
    );

    final data = response.data;

    if (data is! Map) {
      throw const FormatException(
        'Réponse de modification de la ville invalide.',
      );
    }

    return City.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> remove(String id) async {
    await _dio.delete('/cities/$id');
  }
}
