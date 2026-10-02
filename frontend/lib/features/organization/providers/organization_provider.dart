import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage_service.dart';

import '../models/organizational_unit.dart';
import '../models/organization_overview.dart';

import '../repositories/organization_repository.dart';

// ======================================================
// SECURE STORAGE PROVIDER
// ======================================================

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

// ======================================================
// API CLIENT PROVIDER
// ======================================================

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageServiceProvider);

  return ApiClient(storage: storage);
});

// ======================================================
// ORGANIZATION REPOSITORY PROVIDER
// ======================================================

final organizationRepositoryProvider = Provider<OrganizationRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);

  return OrganizationRepository(apiClient: apiClient);
});

// ======================================================
// ORGANIZATION OVERVIEW PROVIDER
//
// Provides the real organization KPI data from the API.
//
// GET /api/organization/overview
// ======================================================

final organizationOverviewProvider = FutureProvider<OrganizationOverview>((
  ref,
) async {
  final repository = ref.read(organizationRepositoryProvider);

  return repository.getOverview();
});

// ======================================================
// ORGANIZATION TREE PROVIDER
// ======================================================

final organizationTreeProvider =
    AsyncNotifierProvider<OrganizationTreeNotifier, List<OrganizationalUnit>>(
      OrganizationTreeNotifier.new,
    );

// ======================================================
// ORGANIZATION TREE NOTIFIER
// ======================================================

class OrganizationTreeNotifier extends AsyncNotifier<List<OrganizationalUnit>> {
  // ====================================================
  // REPOSITORY
  // ====================================================

  OrganizationRepository get _repository =>
      ref.read(organizationRepositoryProvider);

  // ====================================================
  // INITIAL LOAD
  // ====================================================

  @override
  Future<List<OrganizationalUnit>> build() async {
    return _repository.getTree();
  }

  // ====================================================
  // REFRESH TREE
  // ====================================================

  Future<void> refresh() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() => _repository.getTree());

    // Refresh organization overview at the same time
    // because CRUD operations can change KPI values.
    ref.invalidate(organizationOverviewProvider);
  }

  // ====================================================
  // CREATE ORGANIZATIONAL UNIT
  // ====================================================

  Future<OrganizationalUnit> createUnit({
    required String name,
    required String type,
    String? description,
    String? parentId,
    String? leaderId,
    bool? isActive,
  }) async {
    final unit = await _repository.create(
      name: name,
      type: type,
      description: description,
      parentId: parentId,
      leaderId: leaderId,
      isActive: isActive,
    );

    await refresh();

    return unit;
  }

  // ====================================================
  // UPDATE ORGANIZATIONAL UNIT
  // ====================================================

  Future<OrganizationalUnit> updateUnit({
    required String id,
    String? name,
    String? type,
    String? description,
    String? parentId,
    String? leaderId,
    bool? isActive,
  }) async {
    final unit = await _repository.update(
      id: id,
      name: name,
      type: type,
      description: description,
      parentId: parentId,
      leaderId: leaderId,
      isActive: isActive,
    );

    await refresh();

    return unit;
  }

  // ====================================================
  // DELETE ORGANIZATIONAL UNIT
  // ====================================================

  Future<void> removeUnit(String id) async {
    await _repository.remove(id);

    await refresh();
  }
}
