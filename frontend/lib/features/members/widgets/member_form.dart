import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/member.dart';

class MemberForm extends StatefulWidget {
  const MemberForm({
    super.key,
    this.member,
    required this.onSubmit,
    this.onCancel,
  });

  final Member? member;
  final ValueChanged<Map<String, dynamic>> onSubmit;
  final VoidCallback? onCancel;

  @override
  State<MemberForm> createState() => _MemberFormState();
}

class _MemberFormState extends State<MemberForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _lastNameController;
  late final TextEditingController _postNameController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _fieldController;
  late final TextEditingController _districtController;
  late final TextEditingController _churchController;

  DateTime? _joinedAt;
  MemberStatus _status = MemberStatus.active;

  bool get isEditing => widget.member != null;

  @override
  void initState() {
    super.initState();

    final member = widget.member;

    _lastNameController = TextEditingController(text: member?.lastName ?? '');

    _postNameController = TextEditingController(text: member?.postName ?? '');

    _firstNameController = TextEditingController(text: member?.firstName ?? '');

    _phoneController = TextEditingController(text: member?.phone ?? '');

    _addressController = TextEditingController(text: member?.address ?? '');

    _fieldController = TextEditingController(text: member?.field ?? '');

    _districtController = TextEditingController(text: member?.district ?? '');

    _churchController = TextEditingController(text: member?.church ?? '');

    _joinedAt = member?.joinedAt ?? DateTime.now();
    _status = member?.status ?? MemberStatus.active;
  }

  @override
  void dispose() {
    _lastNameController.dispose();
    _postNameController.dispose();
    _firstNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _fieldController.dispose();
    _districtController.dispose();
    _churchController.dispose();

    super.dispose();
  }

  Future<void> _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _joinedAt ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: 'Date d’adhésion',
      cancelText: 'Annuler',
      confirmText: 'Valider',
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      _joinedAt = selectedDate;
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    widget.onSubmit({
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'postName': _postNameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
      'field': _fieldController.text.trim(),
      'district': _districtController.text.trim(),
      'church': _churchController.text.trim(),
      'joinedAt': _joinedAt?.toIso8601String(),
      'status': _status.name,
    });
  }

  String _statusLabel(MemberStatus status) {
    switch (status) {
      case MemberStatus.active:
        return 'Actif';

      case MemberStatus.inactive:
        return 'Inactif';

      case MemberStatus.suspended:
        return 'Suspendu';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEditing ? 'Modifier le membre' : 'Nouveau membre',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            isEditing
                ? 'Modifiez les informations du membre.'
                : 'Enregistrez les informations de base du nouveau membre.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 24),

          _buildSectionTitle(context, 'Informations personnelles'),

          const SizedBox(height: 12),

          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 760;

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: isWide
                        ? (constraints.maxWidth - 16) / 2
                        : constraints.maxWidth,
                    child: _buildTextField(
                      controller: _lastNameController,
                      label: 'Nom',
                      icon: Icons.person_outline,
                      required: true,
                    ),
                  ),

                  SizedBox(
                    width: isWide
                        ? (constraints.maxWidth - 16) / 2
                        : constraints.maxWidth,
                    child: _buildTextField(
                      controller: _postNameController,
                      label: 'Postnom',
                      icon: Icons.badge_outlined,
                    ),
                  ),

                  SizedBox(
                    width: isWide
                        ? (constraints.maxWidth - 16) / 2
                        : constraints.maxWidth,
                    child: _buildTextField(
                      controller: _firstNameController,
                      label: 'Prénom',
                      icon: Icons.person_outline,
                      required: true,
                    ),
                  ),

                  SizedBox(
                    width: isWide
                        ? (constraints.maxWidth - 16) / 2
                        : constraints.maxWidth,
                    child: _buildTextField(
                      controller: _phoneController,
                      label: 'Téléphone',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                  ),

                  SizedBox(
                    width: constraints.maxWidth,
                    child: _buildTextField(
                      controller: _addressController,
                      label: 'Adresse',
                      icon: Icons.location_on_outlined,
                      maxLines: 2,
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 28),

          _buildSectionTitle(context, 'Localisation MDP'),

          const SizedBox(height: 12),

          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 760;

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: isWide
                        ? (constraints.maxWidth - 16) / 2
                        : constraints.maxWidth,
                    child: _buildTextField(
                      controller: _fieldController,
                      label: 'Champ',
                      icon: Icons.map_outlined,
                    ),
                  ),

                  SizedBox(
                    width: isWide
                        ? (constraints.maxWidth - 16) / 2
                        : constraints.maxWidth,
                    child: _buildTextField(
                      controller: _districtController,
                      label: 'District',
                      icon: Icons.location_city_outlined,
                    ),
                  ),

                  SizedBox(
                    width: constraints.maxWidth,
                    child: _buildTextField(
                      controller: _churchController,
                      label: 'Église',
                      icon: Icons.church_outlined,
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 28),

          _buildSectionTitle(context, 'Adhésion et statut'),

          const SizedBox(height: 12),

          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 760;

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: isWide
                        ? (constraints.maxWidth - 16) / 2
                        : constraints.maxWidth,
                    child: _buildDateField(context),
                  ),

                  SizedBox(
                    width: isWide
                        ? (constraints.maxWidth - 16) / 2
                        : constraints.maxWidth,
                    child: _buildStatusField(),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 28),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.45,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: theme.colorScheme.primary),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    'L’équipe, le Team Leader, le Superviseur et '
                    'l’Inspecteur seront attribués séparément après '
                    'la création du membre.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (widget.onCancel != null) ...[
                OutlinedButton(
                  onPressed: widget.onCancel,
                  child: const Text('Annuler'),
                ),

                const SizedBox(width: 12),
              ],

              FilledButton.icon(
                onPressed: _submit,
                icon: Icon(
                  isEditing ? Icons.save_outlined : Icons.person_add_outlined,
                ),
                label: Text(isEditing ? 'Enregistrer' : 'Créer le membre'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = false,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator: required
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return '$label est obligatoire.';
              }

              return null;
            }
          : null,
    );
  }

  Widget _buildDateField(BuildContext context) {
    final dateText = _joinedAt == null
        ? 'Sélectionner une date'
        : DateFormat('dd/MM/yyyy').format(_joinedAt!);

    return InkWell(
      onTap: _selectDate,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date d’adhésion',
          prefixIcon: Icon(Icons.calendar_today_outlined),
          border: OutlineInputBorder(),
        ),
        child: Text(dateText),
      ),
    );
  }

  Widget _buildStatusField() {
    return DropdownButtonFormField<MemberStatus>(
      initialValue: _status,
      decoration: const InputDecoration(
        labelText: 'Statut',
        prefixIcon: Icon(Icons.toggle_on_outlined),
        border: OutlineInputBorder(),
      ),
      items: MemberStatus.values
          .map(
            (status) => DropdownMenuItem<MemberStatus>(
              value: status,
              child: Text(_statusLabel(status)),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value == null) {
          return;
        }

        setState(() {
          _status = value;
        });
      },
    );
  }
}
