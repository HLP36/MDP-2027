import 'package:flutter/foundation.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/auth_response_model.dart';

class AuthRepository {
  AuthRepository({required this._apiClient, required this._storage});

  final ApiClient _apiClient;
  final SecureStorageService _storage;

  /// ============================================================
  /// LOGIN
  /// ============================================================

  Future<AuthResponseModel> login({
    required String identifier,
    required String password,
  }) async {
    debugPrint('');
    debugPrint('==============================================');
    debugPrint('MDP AUTH — LOGIN');
    debugPrint('==============================================');

    try {
      final response = await _apiClient.dio.post(
        '/auth/login',
        data: {'identifier': identifier.trim(), 'password': password},
      );

      final data = Map<String, dynamic>.from(response.data as Map);

      final result = AuthResponseModel.fromJson(data);

      await _saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );

      debugPrint('LOGIN SUCCESS');
      debugPrint('User ID       : ${result.user.id}');
      debugPrint('Login ID      : ${result.user.loginId}');
      debugPrint('Email         : ${result.user.email}');
      debugPrint(
        'Name          : '
        '${result.user.firstName} ${result.user.lastName}',
      );
      debugPrint('Status        : ${result.user.status}');
      debugPrint('Account Type  : ${result.user.accountType}');
      debugPrint('Roles         : ${result.user.roles}');
      debugPrint('Permissions   : ${result.user.permissions.length}');

      return result;
    } catch (error, stackTrace) {
      debugPrint('LOGIN FAILED');
      debugPrint('Type  : ${error.runtimeType}');
      debugPrint('Error : $error');
      debugPrint('$stackTrace');

      rethrow;
    }
  }

  /// ============================================================
  /// CURRENT USER
  /// ============================================================

  Future<AuthUserModel> getCurrentUser() async {
    debugPrint('MDP AUTH — GET CURRENT USER');

    try {
      final response = await _apiClient.dio.get('/auth/me');

      final data = Map<String, dynamic>.from(response.data as Map);

      final user = AuthUserModel.fromJson(data);

      debugPrint(
        'Current user : '
        '${user.firstName} ${user.lastName}',
      );

      debugPrint('Account type : ${user.accountType}');

      debugPrint('Roles        : ${user.roles}');

      debugPrint('Permissions  : ${user.permissions.length}');

      return user;
    } catch (error, stackTrace) {
      debugPrint('GET CURRENT USER FAILED');
      debugPrint('Type  : ${error.runtimeType}');
      debugPrint('Error : $error');
      debugPrint('$stackTrace');

      rethrow;
    }
  }

  /// ============================================================
  /// REFRESH TOKEN
  /// ============================================================

  Future<AuthResponseModel> refreshSession() async {
    debugPrint('MDP AUTH — REFRESH SESSION');

    final refreshToken = await _storage.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      throw StateError('Aucun refresh token disponible.');
    }

    try {
      final response = await _apiClient.dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final data = Map<String, dynamic>.from(response.data as Map);

      final result = AuthResponseModel.fromJson(data);

      await _saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );

      debugPrint('REFRESH SUCCESS');
      debugPrint(
        'User : ${result.user.firstName} '
        '${result.user.lastName}',
      );

      return result;
    } catch (error, stackTrace) {
      debugPrint('REFRESH FAILED');
      debugPrint('Type  : ${error.runtimeType}');
      debugPrint('Error : $error');
      debugPrint('$stackTrace');

      rethrow;
    }
  }

  /// ============================================================
  /// LOGOUT
  /// ============================================================

  Future<void> logout() async {
    debugPrint('MDP AUTH — LOGOUT');

    try {
      final accessToken = await _storage.getAccessToken();

      if (accessToken != null && accessToken.isNotEmpty) {
        await _apiClient.dio.post('/auth/logout');

        debugPrint('Session serveur révoquée.');
      }
    } catch (error) {
      /*
       * Même si le serveur est inaccessible,
       * nous devons toujours supprimer la session locale.
       */
      debugPrint('Logout serveur échoué : $error');
    } finally {
      await clearLocalSession();
    }
  }

  /// ============================================================
  /// LOCAL SESSION
  /// ============================================================

  Future<void> clearLocalSession() async {
    await _storage.clearTokens();

    debugPrint('Session locale supprimée.');
  }

  /// ============================================================
  /// TOKENS
  /// ============================================================

  Future<void> _saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    if (accessToken.isEmpty) {
      throw StateError('Access token vide reçu du serveur.');
    }

    if (refreshToken.isEmpty) {
      throw StateError('Refresh token vide reçu du serveur.');
    }

    await _storage.saveAccessToken(accessToken);

    await _storage.saveRefreshToken(refreshToken);
  }
}
