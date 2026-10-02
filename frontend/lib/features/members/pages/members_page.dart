import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/members_provider.dart';
import '../widgets/members_header.dart';
import '../widgets/members_kpi_row.dart';
import '../widgets/members_table.dart';

class MembersPage extends ConsumerStatefulWidget {
  const MembersPage({super.key});

  @override
  ConsumerState<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends ConsumerState<MembersPage> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_handleSearch);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_handleSearch)
      ..dispose();

    super.dispose();
  }

  void _handleSearch() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(membersProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MembersHeader(
                searchController: _searchController,
                onRefresh: () {
                  ref.read(membersProvider.notifier).refresh();
                },
                onAddMember: () {
                  _openAddMember();
                },
              ),
              const SizedBox(height: 24),
              Expanded(
                child: membersAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => _buildErrorState(error),
                  data: (members) {
                    final filtered = members.where((member) {
                      if (_searchQuery.isEmpty) {
                        return true;
                      }

                      return member.fullName.toLowerCase().contains(
                            _searchQuery,
                          ) ||
                          member.memberCode.toLowerCase().contains(
                            _searchQuery,
                          ) ||
                          (member.phone?.toLowerCase().contains(_searchQuery) ??
                              false);
                    }).toList();

                    return Column(
                      children: [
                        MembersKpiRow(members: members),
                        const SizedBox(height: 24),
                        Expanded(
                          child: MembersTable(
                            members: filtered,
                            onView: _openDetails,
                            onEdit: _editMember,
                            onDelete: _deleteMember,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 42,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 12),
          const Text('Impossible de charger les membres.'),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () {
              ref.read(membersProvider.notifier).refresh();
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Réessayer'),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _openAddMember() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Le formulaire d’ajout du membre sera ouvert ici.'),
        ),
      );
  }

  void _openDetails(String memberId) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('Ouverture du membre : $memberId')),
      );
  }

  void _editMember(String memberId) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('Modification du membre : $memberId')),
      );
  }

  Future<void> _deleteMember(String memberId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer le membre ?'),
          content: const Text(
            'Cette action sera remplacée par '
            'une gestion sécurisée du statut '
            'du membre lorsque le backend sera connecté.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('Action demandée pour : $memberId')),
      );
  }
}
