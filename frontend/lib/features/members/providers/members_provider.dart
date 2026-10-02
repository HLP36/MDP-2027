import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage_service.dart';

import '../models/member.dart';
import '../repositories/members_repository.dart';

final membersRepositoryProvider = Provider<MembersRepository>((ref) {
  final storage = SecureStorageService();

  final apiClient = ApiClient(storage: storage);

  return MembersRepository(apiClient: apiClient);
});

final membersProvider = AsyncNotifierProvider<MembersNotifier, List<Member>>(
  MembersNotifier.new,
);

class MembersNotifier extends AsyncNotifier<List<Member>> {
  MembersRepository get _repository => ref.read(membersRepositoryProvider);

  @override
  Future<List<Member>> build() async {
    return _repository.findAll();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(_repository.findAll);
  }

  Future<Member> createMember({
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
    final member = await _repository.create(
      firstName: firstName,
      lastName: lastName,
      postName: postName,
      phone: phone,
      address: address,
      field: field,
      district: district,
      church: church,
      joinedAt: joinedAt,
    );

    await refresh();

    return member;
  }

  Future<void> deleteMember(String id) async {
    await _repository.remove(id);

    await refresh();
  }
}
