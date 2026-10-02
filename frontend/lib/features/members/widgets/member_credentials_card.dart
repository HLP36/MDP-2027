import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/member_credentials.dart';

class MemberCredentialsCard extends StatefulWidget {
  const MemberCredentialsCard({
    super.key,
    required this.credentials,
    this.memberCode,
  });

  final MemberCredentials credentials;
  final String? memberCode;

  @override
  State<MemberCredentialsCard> createState() => _MemberCredentialsCardState();
}

class _MemberCredentialsCardState extends State<MemberCredentialsCard> {
  bool _showPassword = true;

  Future<void> _copyCredentials() async {
    final credentials = widget.credentials;

    final buffer = StringBuffer()
      ..writeln('Identifiant membre : ${widget.memberCode ?? '-'}')
      ..writeln('Login : ${credentials.loginId}')
      ..writeln(
        'Mot de passe temporaire : '
        '${credentials.temporaryPassword ?? '-'}',
      );

    await Clipboard.setData(ClipboardData(text: buffer.toString()));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Identifiants copiés dans le presse-papiers.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final credentials = widget.credentials;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.25),
        ),
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.lock_person_outlined,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Identifiants du membre',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'À communiquer au membre après la création.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Copier les identifiants',
                onPressed: _copyCredentials,
                icon: const Icon(Icons.copy_all_outlined),
              ),
            ],
          ),

          const SizedBox(height: 20),

          if (widget.memberCode != null)
            _buildCredentialRow(
              context,
              label: 'ID membre',
              value: widget.memberCode!,
              icon: Icons.badge_outlined,
            ),

          _buildCredentialRow(
            context,
            label: 'Login',
            value: credentials.loginId,
            icon: Icons.person_outline,
          ),

          _buildCredentialRow(
            context,
            label: 'Mot de passe temporaire',
            value: credentials.temporaryPassword ?? 'Non disponible',
            icon: Icons.password_outlined,
            obscure: !_showPassword,
            trailing: credentials.temporaryPassword != null
                ? IconButton(
                    tooltip: _showPassword ? 'Masquer' : 'Afficher',
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                    icon: Icon(
                      _showPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  )
                : null,
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_outlined,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Le membre devra modifier son mot de passe '
                    'temporaire lors de sa première connexion.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    bool obscure = false,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: trailing,
          border: const OutlineInputBorder(),
        ),
        child: Text(
          obscure ? '•' * value.length : value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: obscure ? 2 : 0,
          ),
        ),
      ),
    );
  }
}
