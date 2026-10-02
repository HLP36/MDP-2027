import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../models/city.dart';
import '../repositories/cities_repository.dart';

final citiesRepositoryProvider = Provider<CitiesRepository>((ref) {
  final storage = SecureStorageService();
  final apiClient = ApiClient(storage: storage);

  return CitiesRepository(apiClient: apiClient);
});

final citiesProvider = AsyncNotifierProvider<CitiesNotifier, List<City>>(
  CitiesNotifier.new,
);

class CitiesNotifier extends AsyncNotifier<List<City>> {
  CitiesRepository get _repository => ref.read(citiesRepositoryProvider);

  @override
  Future<List<City>> build() {
    return _repository.findAll();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.findAll);
  }

  Future<City> createCity({
    required String name,
    required String code,
    String? country,
  }) async {
    final city = await _repository.create(
      name: name,
      code: code,
      country: country,
    );

    await refresh();

    return city;
  }

  Future<void> updateCity({
    required String id,
    String? name,
    String? code,
    String? country,
    bool? isActive,
  }) async {
    await _repository.update(
      id: id,
      name: name,
      code: code,
      country: country,
      isActive: isActive,
    );

    await refresh();
  }

  Future<void> deleteCity(String id) async {
    await _repository.remove(id);
    await refresh();
  }
}
