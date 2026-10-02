import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/member_dashboard.dart';

final memberDashboardProvider = FutureProvider.family<MemberDashboard, String>((
  ref,
  memberId,
) async {
  throw UnimplementedError(
    'Le Dashboard membre sera connecté '
    'au backend lors de la phase API.',
  );
});
