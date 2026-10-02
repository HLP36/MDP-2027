import 'package:flutter/widgets.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [
    Locale('fr'),
    Locale('en'),
  ];

  static const localizationsDelegate = _AppLocalizationsDelegate();

  bool get isFrench => locale.languageCode == 'fr';

  String get appName => 'MDP 2027';

  String get organizationName =>
      isFrench ? 'Maison du Père' : 'House of the Father';

  String get welcome => isFrench ? 'Bienvenue' : 'Welcome';

  String get login => isFrench ? 'Connexion' : 'Login';

  String get email => isFrench ? 'Adresse e-mail' : 'Email address';

  String get password => isFrench ? 'Mot de passe' : 'Password';

  String get loginButton => isFrench ? 'Se connecter' : 'Sign in';

  String get dashboard => isFrench ? 'Tableau de bord' : 'Dashboard';

  String get logout => isFrench ? 'Déconnexion' : 'Logout';

  String get french => 'Français';

  String get english => 'English';

  static AppLocalizations of(BuildContext context) {
    final localization =
        Localizations.of<AppLocalizations>(
          context,
          AppLocalizations,
        );

    return localization ?? const AppLocalizations(Locale('fr'));
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (supportedLocale) =>
          supportedLocale.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(
    covariant LocalizationsDelegate<AppLocalizations> old,
  ) {
    return false;
  }
}