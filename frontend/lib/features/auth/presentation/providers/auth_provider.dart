import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../data/models/auth_response_model.dart';
import '../../data/repositories/auth_repository.dart';

/// ============================================================
/// STORAGE
/// ============================================================

final secureStorageProvider = Provider<SecureStorageService>(
  (ref) => SecureStorageService(),
);

/// ============================================================
/// API CLIENT
/// ============================================================

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(storage: ref.read(secureStorageProvider));
});

/// ============================================================
/// AUTH REPOSITORY
/// ============================================================

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    apiClient: ref.read(apiClientProvider),
    storage: ref.read(secureStorageProvider),
  );
});

/// ============================================================
/// AUTH STATE
/// ============================================================

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthUserModel?>(
  AuthNotifier.new,
);

/// ============================================================
/// AUTH NOTIFIER
/// ============================================================

class AuthNotifier extends AsyncNotifier<AuthUserModel?> {
  late final AuthRepository _repository;

  @override
  Future<AuthUserModel?> build() async {
    debugPrint('');
    debugPrint('==============================================');
    debugPrint('MDP AUTH PROVIDER — INITIALISATION');
    debugPrint('==============================================');

    _repository = ref.read(authRepositoryProvider);

    final storage = ref.read(secureStorageProvider);

    final accessToken = await storage.getAccessToken();

    final refreshToken = await storage.getRefreshToken();

    /// ----------------------------------------------------------
    /// Aucune session locale
    /// ----------------------------------------------------------

    if (_isEmpty(accessToken) || _isEmpty(refreshToken)) {
      debugPrint('Aucune session locale.');

      return null;
    }

    debugPrint('Session locale trouvée.');

    /// ----------------------------------------------------------
    /// Vérification de la session avec /auth/me
    /// ----------------------------------------------------------

    try {
      final user = await _repository.getCurrentUser();

      debugPrint('Session valide.');

      debugPrint(
        'User        : '
        '${user.firstName} ${user.lastName}',
      );

      debugPrint('AccountType : ${user.accountType}');

      debugPrint('Roles       : ${user.roles}');

      return user;
    } catch (error) {
      debugPrint('Session actuelle invalide.');

      debugPrint('Erreur : $error');

      /// --------------------------------------------------------
      /// Tentative de récupération avec le refresh token
      /// --------------------------------------------------------

      try {
        debugPrint('Tentative de refresh automatique...');

        final refreshed = await _repository.refreshSession();

        debugPrint('Refresh automatique réussi.');

        return refreshed.user;
      } catch (refreshError) {
        debugPrint('Refresh automatique échoué.');

        debugPrint('Erreur refresh : $refreshError');

        await _repository.clearLocalSession();

        debugPrint('Session locale supprimée.');

        return null;
      }
    }
  }

  /// ============================================================
  /// LOGIN
  /// ============================================================

  Future<bool> login({
    required String identifier,
    required String password,
  }) async {
    debugPrint('');
    debugPrint('==============================================');
    debugPrint('MDP AUTH PROVIDER — LOGIN');
    debugPrint('==============================================');

    state = const AsyncLoading();

    try {
      final result = await _repository.login(
        identifier: identifier,
        password: password,
      );

      state = AsyncData(result.user);

      debugPrint('LOGIN SUCCESS');

      debugPrint(
        'User        : '
        '${result.user.firstName} ${result.user.lastName}',
      );

      debugPrint('AccountType : ${result.user.accountType}');

      debugPrint('Roles       : ${result.user.roles}');

      debugPrint(
        'Permissions : '
        '${result.user.permissions.length}',
      );

      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);

      debugPrint('LOGIN FAILED');

      debugPrint('Type  : ${error.runtimeType}');

      debugPrint('Error : $error');

      return false;
    }
  }

  /// ============================================================
  /// REFRESH SESSION
  /// ============================================================

  Future<bool> refreshSession() async {
    debugPrint('MDP AUTH PROVIDER — REFRESH');

    try {
      final result = await _repository.refreshSession();

      state = AsyncData(result.user);

      debugPrint('Refresh réussi.');

      return true;
    } catch (error, stackTrace) {
      debugPrint('Refresh échoué : $error');

      await _repository.clearLocalSession();

      state = AsyncError(error, stackTrace);

      return false;
    }
  }

  /// ============================================================
  /// LOGOUT
  /// ============================================================

  Future<void> logout() async {
    debugPrint('MDP AUTH PROVIDER — LOGOUT');

    try {
      await _repository.logout();
    } finally {
      state = const AsyncData(null);
    }

    debugPrint('Logout terminé.');
  }

  /// ============================================================
  /// HELPERS
  /// ============================================================

  bool _isEmpty(String? value) {
    return value == null || value.isEmpty;
  }
}
