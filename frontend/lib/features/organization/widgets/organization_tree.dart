import 'package:flutter/material.dart';

import '../models/organizational_unit.dart';
import 'organization_unit_card.dart';

class OrganizationTree extends StatelessWidget {
  const OrganizationTree({super.key, required this.units});

  final List<OrganizationalUnit> units;

  @override
  Widget build(BuildContext context) {
    if (units.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: units.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return OrganizationUnitCard(unit: units[index]);
      },
    );
  }
}
