import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/mdp_logo.dart';
import '../widgets/login_background.dart';
import '../widgets/login_brand_panel.dart';
import '../widgets/login_controls.dart';
import '../widgets/login_form.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.035), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final size = MediaQuery.sizeOf(context);
    final isDesktop = size.width >= 900;

    return Scaffold(
      body: LoginBackground(
        isDark: isDark,
        child: SafeArea(
          child: Column(
            children: [
              // ─────────────────────────────────────
              // BARRE SUPÉRIEURE
              // ─────────────────────────────────────
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child: LoginControls(
                    localization: localization,
                    isDark: isDark,
                  ),
                ),
              ),

              // ─────────────────────────────────────
              // CONTENU PRINCIPAL
              // ─────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    isDesktop ? 48 : 22,
                    isDesktop ? 28 : 26,
                    isDesktop ? 48 : 22,
                    36,
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1050),
                          child: isDesktop
                              ? _DesktopLayout(
                                  localization: localization,
                                  isDark: isDark,
                                )
                              : _MobileLayout(
                                  localization: localization,
                                  isDark: isDark,
                                ),
                        ),
                      ),
                    ),
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

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({required this.localization, required this.isDark});

  final AppLocalizations localization;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 70),
            child: LoginBrandPanel(localization: localization),
          ),
        ),
        Expanded(
          flex: 4,
          child: LoginForm(localization: localization, isDark: isDark),
        ),
      ],
    );
  }
}

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({required this.localization, required this.isDark});

  final AppLocalizations localization;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const MdpLogo(size: 70, showName: true),
        const SizedBox(height: 34),
        LoginForm(localization: localization, isDark: isDark),
      ],
    );
  }
}
