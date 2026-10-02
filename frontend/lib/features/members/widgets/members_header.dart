import 'package:flutter/material.dart';

class MembersHeader extends StatelessWidget {
  const MembersHeader({
    super.key,
    required this.searchController,
    required this.onRefresh,
    required this.onAddMember,
  });

  final TextEditingController searchController;
  final VoidCallback onRefresh;
  final VoidCallback onAddMember;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Membres',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Gérez les membres de Maison du Père.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 280,
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher un membre...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        searchController.clear();
                      },
                      icon: const Icon(Icons.clear_rounded),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              isDense: true,
            ),
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          tooltip: 'Actualiser',
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh_rounded),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: onAddMember,
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: const Text('Ajouter un membre'),
        ),
      ],
    );
  }
}
