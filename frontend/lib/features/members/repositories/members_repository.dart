import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../models/member.dart';

class MembersRepository {
  MembersRepository({required ApiClient apiClient}) : _dio = apiClient.dio;

  final Dio _dio;

  Future<List<Member>> findAll() async {
    final response = await _dio.get('/members');

    final data = response.data;

    if (data is! List) {
      throw const FormatException('Réponse des membres invalide.');
    }

    return data
        .whereType<Map>()
        .map((item) => Member.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<Member> findOne(String id) async {
    final response = await _dio.get('/members/$id');

    final data = response.data;

    if (data is! Map) {
      throw const FormatException('Réponse du membre invalide.');
    }

    return Member.fromJson(Map<String, dynamic>.from(data));
  }

  Future<Member> create({
    required String firstName,
    required String lastName,
    String? postName,
    String? phone,
    String? address,
    String? field,
    String? district,
    String? church,
    DateTime? joinedAt,
  }) async {
    final response = await _dio.post(
      '/members',
      data: {
        'firstName': firstName,
        'lastName': lastName,
        'postName': ?postName,
        'phone': ?phone,
        'address': ?address,
        'field': ?field,
        'district': ?district,
        'church': ?church,
        'joinedAt': ?joinedAt?.toIso8601String(),
      },
    );

    final data = response.data;

    if (data is! Map) {
      throw const FormatException('Réponse de création du membre invalide.');
    }

    return Member.fromJson(Map<String, dynamic>.from(data));
  }

  Future<Member> update({
    required String id,
    String? firstName,
    String? lastName,
    String? postName,
    String? phone,
    String? address,
    String? field,
    String? district,
    String? church,
    MemberStatus? status,
  }) async {
    final response = await _dio.patch(
      '/members/$id',
      data: {
        'firstName': ?firstName,
        'lastName': ?lastName,
        'postName': ?postName,
        'phone': ?phone,
        'address': ?address,
        'field': ?field,
        'district': ?district,
        'church': ?church,
        'status': ?status?.name,
      },
    );

    final data = response.data;

    if (data is! Map) {
      throw const FormatException('Réponse de modification invalide.');
    }

    return Member.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> remove(String id) async {
    await _dio.delete('/members/$id');
  }
}
