import 'package:flutter/material.dart';

import '../models/organizational_unit.dart';

class OrganizationUnitForm extends StatefulWidget {
  const OrganizationUnitForm({
    super.key,
    this.unit,
    required this.parentUnits,
    required this.onSubmit,
    this.onCancel,
    this.isSubmitting = false,
    this.availableTypes = const [
      'GLOBAL',
      'COMMITTEE',
      'INSPECTOR',
      'SUPERVISOR',
      'TEAM',
      'CHURCH',
      'CITY',
      'COUNTRY',
    ],
  });

  /// Null = création.
  /// Non-null = modification.
  final OrganizationalUnit? unit;

  /// Unités pouvant être sélectionnées comme parent.
  final List<OrganizationalUnit> parentUnits;

  /// Types disponibles côté interface.
  final List<String> availableTypes;

  /// Callback exécuté après validation du formulaire.
  final Future<void> Function({
    required String name,
    required String type,
    String? description,
    String? parentId,
    String? leaderId,
    required bool isActive,
  })
  onSubmit;

  final VoidCallback? onCancel;
  final bool isSubmitting;

  bool get isEditing => unit != null;

  @override
  State<OrganizationUnitForm> createState() => _OrganizationUnitFormState();
}

class _OrganizationUnitFormState extends State<OrganizationUnitForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  String? _selectedType;
  String? _selectedParentId;
  String? _selectedLeaderId;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();

    final unit = widget.unit;

    _nameController = TextEditingController(text: unit?.name ?? '');

    _descriptionController = TextEditingController(
      text: unit?.description ?? '',
    );

    _selectedType = unit?.type;

    _selectedParentId = unit?.parentId;

    _selectedLeaderId = unit?.leaderId;

    _isActive = unit?.isActive ?? true;

    if (_selectedType == null && widget.availableTypes.isNotEmpty) {
      _selectedType = widget.availableTypes.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionTitle(
            icon: Icons.account_tree_outlined,
            title: widget.isEditing ? 'Modifier l’unité' : 'Nouvelle unité',
            subtitle: widget.isEditing
                ? 'Modifiez les informations de cette unité organisationnelle.'
                : 'Créez une nouvelle unité dans la structure MDP.',
          ),

          const SizedBox(height: 28),

          TextFormField(
            controller: _nameController,
            enabled: !widget.isSubmitting,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Nom',
              hintText: 'Ex. Comité de gestion',
              prefixIcon: Icon(Icons.business_outlined),
            ),
            validator: (value) {
              final text = value?.trim() ?? '';

              if (text.isEmpty) {
                return 'Le nom est obligatoire.';
              }

              if (text.length < 2) {
                return 'Le nom doit contenir au moins 2 caractères.';
              }

              return null;
            },
          ),

          const SizedBox(height: 18),

          DropdownButtonFormField<String>(
            initialValue: _selectedType,
            decoration: const InputDecoration(
              labelText: 'Type d’unité',
              prefixIcon: Icon(Icons.category_outlined),
            ),
            items: widget.availableTypes
                .map(
                  (type) =>
                      DropdownMenuItem<String>(value: type, child: Text(type)),
                )
                .toList(),
            onChanged: widget.isSubmitting
                ? null
                : (value) {
                    setState(() {
                      _selectedType = value;
                    });
                  },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Sélectionnez un type.';
              }

              return null;
            },
          ),

          const SizedBox(height: 18),

          TextFormField(
            controller: _descriptionController,
            enabled: !widget.isSubmitting,
            minLines: 3,
            maxLines: 5,
            textInputAction: TextInputAction.newline,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Description de l’unité...',
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 48),
                child: Icon(Icons.notes_outlined),
              ),
            ),
          ),

          const SizedBox(height: 18),

          _ParentSelector(
            units: widget.parentUnits,
            selectedId: _selectedParentId,
            currentUnitId: widget.unit?.id,
            enabled: !widget.isSubmitting,
            onChanged: (value) {
              setState(() {
                _selectedParentId = value;
              });
            },
          ),

          const SizedBox(height: 18),

          _LeaderSelector(
            units: widget.parentUnits,
            selectedId: _selectedLeaderId,
            enabled: !widget.isSubmitting,
            onChanged: (value) {
              setState(() {
                _selectedLeaderId = value;
              });
            },
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.45,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.30),
              ),
            ),
            child: SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Unité active'),
              subtitle: Text(
                _isActive
                    ? 'Cette unité est actuellement active.'
                    : 'Cette unité est actuellement inactive.',
              ),
              value: _isActive,
              onChanged: widget.isSubmitting
                  ? null
                  : (value) {
                      setState(() {
                        _isActive = value;
                      });
                    },
            ),
          ),

          const SizedBox(height: 30),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (widget.onCancel != null)
                OutlinedButton(
                  onPressed: widget.isSubmitting ? null : widget.onCancel,
                  child: const Text('Annuler'),
                ),
              if (widget.onCancel != null) const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: widget.isSubmitting ? null : _submit,
                icon: widget.isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(widget.isEditing ? Icons.save_outlined : Icons.add),
                label: Text(widget.isEditing ? 'Enregistrer' : 'Créer l’unité'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    final name = _nameController.text.trim();

    final description = _descriptionController.text.trim();

    await widget.onSubmit(
      name: name,
      type: _selectedType!,
      description: description.isEmpty ? null : description,
      parentId: _selectedParentId,
      leaderId: _selectedLeaderId,
      isActive: _isActive,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: colorScheme.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ParentSelector extends StatelessWidget {
  const _ParentSelector({
    required this.units,
    required this.selectedId,
    required this.currentUnitId,
    required this.enabled,
    required this.onChanged,
  });

  final List<OrganizationalUnit> units;
  final String? selectedId;
  final String? currentUnitId;
  final bool enabled;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final availableUnits = units
        .where((unit) => unit.id != currentUnitId)
        .toList();

    return DropdownButtonFormField<String?>(
      initialValue: selectedId,
      decoration: const InputDecoration(
        labelText: 'Unité parent',
        hintText: 'Aucune unité parent',
        prefixIcon: Icon(Icons.account_tree_outlined),
      ),
      items: [
        const DropdownMenuItem<String?>(
          value: null,
          child: Text('Aucune unité parent'),
        ),
        ...availableUnits.map(
          (unit) => DropdownMenuItem<String?>(
            value: unit.id,
            child: Text(unit.name, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
      onChanged: enabled ? onChanged : null,
    );
  }
}

class _LeaderSelector extends StatelessWidget {
  const _LeaderSelector({
    required this.units,
    required this.selectedId,
    required this.enabled,
    required this.onChanged,
  });

  final List<OrganizationalUnit> units;
  final String? selectedId;
  final bool enabled;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final leaders = units
        .where((unit) => unit.leader != null)
        .map((unit) => unit.leader!)
        .fold<Map<String, OrganizationalUnitLeader>>({}, (map, leader) {
          map[leader.id] = leader;
          return map;
        })
        .values
        .toList();

    return DropdownButtonFormField<String?>(
      initialValue: selectedId,
      decoration: const InputDecoration(
        labelText: 'Responsable',
        hintText: 'Aucun responsable',
        prefixIcon: Icon(Icons.person_outline),
      ),
      items: [
        const DropdownMenuItem<String?>(
          value: null,
          child: Text('Aucun responsable'),
        ),
        ...leaders.map(
          (leader) => DropdownMenuItem<String?>(
            value: leader.id,
            child: Text(leader.fullName, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
      onChanged: enabled ? onChanged : null,
    );
  }
}
