import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/mdp_text_field.dart';
import '../providers/auth_provider.dart';
import 'login_button.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({
    super.key,
    required this.localization,
    required this.isDark,
  });

  final AppLocalizations localization;
  final bool isDark;

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await ref
        .read(authProvider.notifier)
        .login(
          identifier: _identifierController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) return;

    if (success) {
      context.go('/dashboard');
      return;
    }

    _showError();
  }

  void _showError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.localization.isFrench
                    ? 'Impossible de vous connecter. '
                          'Veuillez vérifier vos identifiants ou votre connexion.'
                    : 'Unable to sign in. Please check your credentials or your connection.',
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateIdentifier(String? value) {
    if (value == null || value.trim().isEmpty) {
      return widget.localization.isFrench
          ? 'Veuillez saisir votre identifiant ou adresse e-mail.'
          : 'Please enter your login ID or email address.';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return widget.localization.isFrench
          ? 'Veuillez saisir votre mot de passe.'
          : 'Please enter your password.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = ref.watch(authProvider).isLoading;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(34),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(
            alpha: widget.isDark ? 0.78 : 0.90,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.7)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: widget.isDark ? 0.24 : 0.07,
              ),
              blurRadius: 45,
              offset: const Offset(0, 22),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.localization.welcome,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.7,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                widget.localization.isFrench
                    ? 'Connectez-vous à votre espace administrateur.'
                    : 'Sign in to your administrator workspace.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.62),
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 30),

              // ─────────────────────────────────────
              // IDENTIFIANT
              // ─────────────────────────────────────
              MdpTextField(
                controller: _identifierController,
                label: widget.localization.isFrench
                    ? 'Identifiant ou e-mail'
                    : 'Login ID or email',
                hint: widget.localization.isFrench
                    ? 'MDP-ADMIN-001 ou admin@mdp2027.com'
                    : 'MDP-ADMIN-001 or admin@mdp2027.com',
                icon: Icons.person_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: _validateIdentifier,
              ),

              const SizedBox(height: 21),

              // ─────────────────────────────────────
              // MOT DE PASSE
              // ─────────────────────────────────────
              MdpTextField(
                controller: _passwordController,
                label: widget.localization.password,
                hint: '••••••••••••',
                icon: Icons.lock_outline_rounded,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _login(),
                suffixIcon: IconButton(
                  tooltip: _obscurePassword
                      ? (widget.localization.isFrench
                            ? 'Afficher le mot de passe'
                            : 'Show password')
                      : (widget.localization.isFrench
                            ? 'Masquer le mot de passe'
                            : 'Hide password'),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 19,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                validator: _validatePassword,
              ),

              const SizedBox(height: 17),

              // ─────────────────────────────────────
              // OPTIONS
              // ─────────────────────────────────────
              _OptionsRow(
                localization: widget.localization,
                rememberMe: _rememberMe,
                onRememberChanged: (value) {
                  setState(() {
                    _rememberMe = value;
                  });
                },
              ),

              const SizedBox(height: 27),

              // ─────────────────────────────────────
              // CONNEXION
              // ─────────────────────────────────────
              LoginButton(
                onPressed: _login,
                localization: widget.localization,
                isLoading: isLoading,
              ),

              const SizedBox(height: 25),

              // ─────────────────────────────────────
              // SÉCURITÉ
              // ─────────────────────────────────────
              Center(
                child: Text(
                  widget.localization.isFrench
                      ? 'Accès sécurisé • MDP 2027'
                      : 'Secure access • MDP 2027',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionsRow extends StatelessWidget {
  const _OptionsRow({
    required this.localization,
    required this.rememberMe,
    required this.onRememberChanged,
  });

  final AppLocalizations localization;
  final bool rememberMe;
  final ValueChanged<bool> onRememberChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: Checkbox(
            value: rememberMe,
            onChanged: (value) {
              onRememberChanged(value ?? false);
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            activeColor: AppColors.primary,
          ),
        ),

        const SizedBox(width: 9),

        Expanded(
          child: Text(
            localization.isFrench ? 'Se souvenir de moi' : 'Remember me',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        TextButton(
          onPressed: () {
            // Mot de passe oublié.
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          ),
          child: Text(
            localization.isFrench
                ? 'Mot de passe oublié ?'
                : 'Forgot password?',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
