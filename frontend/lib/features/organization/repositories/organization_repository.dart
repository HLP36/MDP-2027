import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../models/organizational_unit.dart';
import '../models/organization_overview.dart';

class OrganizationRepository {
  OrganizationRepository({required ApiClient apiClient}) : _dio = apiClient.dio;

  final Dio _dio;

  // ======================================================
  // GET ORGANIZATIONAL UNITS
  // ======================================================

  Future<List<OrganizationalUnit>> findAll({
    String? type,
    String? parentId,
    bool? isActive,
  }) async {
    final response = await _dio.get(
      '/organization',
      queryParameters: {
        if (type != null && type.isNotEmpty) 'type': type,
        if (parentId != null && parentId.isNotEmpty) 'parentId': parentId,
        'isActive': ?isActive,
      },
    );

    final data = response.data;

    if (data is! List) {
      throw const FormatException(
        'Réponse des unités organisationnelles invalide.',
      );
    }

    return data
        .whereType<Map>()
        .map(
          (item) =>
              OrganizationalUnit.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  // ======================================================
  // GET ORGANIZATIONAL TREE
  // ======================================================

  Future<List<OrganizationalUnit>> getTree() async {
    final response = await _dio.get('/organization/tree');

    final data = response.data;

    if (data is! List) {
      throw const FormatException(
        'Réponse de l’arbre organisationnel invalide.',
      );
    }

    return data
        .whereType<Map>()
        .map(
          (item) =>
              OrganizationalUnit.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  // ======================================================
  // GET ORGANIZATION OVERVIEW
  // ======================================================

  Future<OrganizationOverview> getOverview() async {
    final response = await _dio.get('/organization/overview');

    final data = response.data;

    if (data is! Map) {
      throw const FormatException(
        'Réponse de l’aperçu organisationnel invalide.',
      );
    }

    return OrganizationOverview.fromJson(Map<String, dynamic>.from(data));
  }

  // ======================================================
  // GET ONE ORGANIZATIONAL UNIT
  // ======================================================

  Future<OrganizationalUnit> findOne(String id) async {
    final response = await _dio.get('/organization/$id');

    final data = response.data;

    if (data is! Map) {
      throw const FormatException(
        'Réponse de l’unité organisationnelle invalide.',
      );
    }

    return OrganizationalUnit.fromJson(Map<String, dynamic>.from(data));
  }

  // ======================================================
  // CREATE ORGANIZATIONAL UNIT
  // ======================================================

  Future<OrganizationalUnit> create({
    required String name,
    required String type,
    String? description,
    String? parentId,
    String? leaderId,
    bool? isActive,
  }) async {
    final response = await _dio.post(
      '/organization',
      data: {
        'name': name,
        'type': type,
        'description': ?description,
        'parentId': ?parentId,
        'leaderId': ?leaderId,
        'isActive': ?isActive,
      },
    );

    final data = response.data;

    if (data is! Map) {
      throw const FormatException('Réponse de création invalide.');
    }

    return OrganizationalUnit.fromJson(Map<String, dynamic>.from(data));
  }

  // ======================================================
  // UPDATE ORGANIZATIONAL UNIT
  // ======================================================

  Future<OrganizationalUnit> update({
    required String id,
    String? name,
    String? type,
    String? description,
    String? parentId,
    String? leaderId,
    bool? isActive,
  }) async {
    final response = await _dio.patch(
      '/organization/$id',
      data: {
        'name': ?name,
        'type': ?type,
        'description': ?description,
        'parentId': ?parentId,
        'leaderId': ?leaderId,
        'isActive': ?isActive,
      },
    );

    final data = response.data;

    if (data is! Map) {
      throw const FormatException('Réponse de modification invalide.');
    }

    return OrganizationalUnit.fromJson(Map<String, dynamic>.from(data));
  }

  // ======================================================
  // DELETE ORGANIZATIONAL UNIT
  // ======================================================

  Future<void> remove(String id) async {
    await _dio.delete('/organization/$id');
  }
}
