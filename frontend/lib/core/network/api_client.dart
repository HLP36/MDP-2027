import 'dart:async';

import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../storage/secure_storage_service.dart';

class ApiClient {
  ApiClient({required this._storage}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(onRequest: _onRequest, onError: _onError),
    );
  }

  late final Dio _dio;

  final SecureStorageService _storage;

  /// Une seule opération de refresh peut être exécutée à la fois.
  Future<_RefreshTokenResponse>? _refreshFuture;

  Dio get dio => _dio;

  // ============================================================
  // REQUEST
  // ============================================================

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      /*
       * Certaines requêtes ne doivent pas recevoir le token.
       */
      if (_isAuthEndpoint(options.path)) {
        handler.next(options);
        return;
      }

      final token = await _storage.getAccessToken();

      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }

      handler.next(options);
    } catch (error) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: error,
          type: DioExceptionType.unknown,
        ),
      );
    }
  }

  // ============================================================
  // ERROR / 401
  // ============================================================

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    /*
     * Toutes les erreurs autres que 401 continuent normalement.
     */
    if (error.response?.statusCode != 401) {
      handler.next(error);
      return;
    }

    final requestOptions = error.requestOptions;

    /*
     * Login, refresh et logout ne doivent jamais déclencher
     * un refresh automatique.
     */
    if (_isAuthEndpoint(requestOptions.path)) {
      handler.next(error);
      return;
    }

    /*
     * Une requête ne peut être rejouée qu'une seule fois.
     */
    if (requestOptions.extra['retriedAfterRefresh'] == true) {
      await _storage.clearTokens();
      handler.next(error);
      return;
    }

    /*
     * Récupération du refresh token.
     */
    final refreshToken = await _storage.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      await _storage.clearTokens();
      handler.next(error);
      return;
    }

    try {
      /*
       * Tous les appels qui rencontrent un 401 pendant le même
       * refresh utilisent la même Future.
       *
       * Cela évite :
       *
       * Request A → 401 → refresh
       * Request B → 401 → refresh
       * Request C → 401 → refresh
       *
       * et produit à la place :
       *
       * Request A ─┐
       * Request B ─┼→ UN SEUL refresh → nouveaux tokens
       * Request C ─┘
       */
      final tokens = await _refreshAccessToken(refreshToken);

      /*
       * Sauvegarde des deux nouveaux tokens.
       */
      await _storage.saveAccessToken(tokens.accessToken);

      await _storage.saveRefreshToken(tokens.refreshToken);

      /*
       * Marque la requête afin d'éviter une boucle infinie.
       */
      requestOptions.extra['retriedAfterRefresh'] = true;

      requestOptions.headers['Authorization'] = 'Bearer ${tokens.accessToken}';

      /*
       * Rejoue automatiquement la requête originale.
       */
      final retryResponse = await _dio.fetch<dynamic>(requestOptions);

      handler.resolve(retryResponse);
    } catch (refreshError) {
      /*
       * Le refresh a échoué :
       *
       * - session expirée
       * - session révoquée
       * - refresh token invalide
       * - serveur inaccessible
       *
       * Dans tous les cas, la session locale doit être supprimée.
       */
      await _storage.clearTokens();

      handler.next(error);
    }
  }

  // ============================================================
  // REFRESH TOKEN
  // ============================================================

  Future<_RefreshTokenResponse> _refreshAccessToken(String refreshToken) {
    /*
     * Si un refresh est déjà en cours, on réutilise sa Future.
     */
    final existingRefresh = _refreshFuture;

    if (existingRefresh != null) {
      return existingRefresh;
    }

    /*
     * Création du refresh unique.
     */
    final refreshFuture = _performRefresh(refreshToken);

    _refreshFuture = refreshFuture;

    /*
     * Libération du verrou lorsque le refresh est terminé.
     */
    refreshFuture.whenComplete(() {
      if (identical(_refreshFuture, refreshFuture)) {
        _refreshFuture = null;
      }
    });

    return refreshFuture;
  }

  Future<_RefreshTokenResponse> _performRefresh(String refreshToken) async {
    final response = await _dio.post(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
      options: Options(extra: {'skipAuthRefresh': true}),
    );

    final data = response.data;

    if (data is! Map) {
      throw const FormatException('Réponse de refresh token invalide.');
    }

    final accessToken = data['accessToken'];
    final newRefreshToken = data['refreshToken'];

    if (accessToken is! String ||
        accessToken.isEmpty ||
        newRefreshToken is! String ||
        newRefreshToken.isEmpty) {
      throw const FormatException('Tokens de refresh invalides.');
    }

    return _RefreshTokenResponse(
      accessToken: accessToken,
      refreshToken: newRefreshToken,
    );
  }

  // ============================================================
  // AUTH ENDPOINTS
  // ============================================================

  bool _isAuthEndpoint(String path) {
    return path.endsWith('/auth/login') ||
        path.endsWith('/auth/refresh') ||
        path.endsWith('/auth/logout');
  }
}

// ============================================================
// REFRESH RESPONSE
// ============================================================

class _RefreshTokenResponse {
  const _RefreshTokenResponse({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;
}
