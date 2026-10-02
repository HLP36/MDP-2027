import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/member.dart';
import 'members_provider.dart';

final memberDetailsProvider = FutureProvider.family<Member, String>((
  ref,
  memberId,
) async {
  final repository = ref.read(membersRepositoryProvider);

  return repository.findOne(memberId);
});
