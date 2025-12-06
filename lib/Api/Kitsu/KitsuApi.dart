import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../logger.dart';

/// Kitsu API client for JSON:API format.
/// Documentation: https://kitsu.docs.apiary.io/
class KitsuApi {
  static const String baseUrl = 'https://kitsu.io/api/edge';
  static const String authUrl = 'https://kitsu.io/api/oauth/token';
  
  String? _accessToken;
  String? _refreshToken;
  DateTime? _tokenExpiry;

  Map<String, String> get _jsonApiHeaders => {
    'Accept': 'application/vnd.api+json',
    'Content-Type': 'application/vnd.api+json',
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };

  /// Check if we have a valid token
  bool get isAuthenticated =>
      _accessToken != null &&
      _tokenExpiry != null &&
      DateTime.now().isBefore(_tokenExpiry!);

  /// Public getters for token data (used by KitsuController for persistence)
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  DateTime? get tokenExpiry => _tokenExpiry;

  /// Set tokens from stored values
  void setTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiry,
  }) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _tokenExpiry = expiry;
  }

  /// Clear tokens (logout)
  void clearTokens() {
    _accessToken = null;
    _refreshToken = null;
    _tokenExpiry = null;
  }

  /// Authenticate with username and password (Resource Owner Password flow)
  /// This is the simpler method that works without client credentials
  Future<KitsuAuthResult> authenticateWithPassword(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(authUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'password',
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        return KitsuAuthResult.failure(
          error['error_description'] ?? 'Authentication failed',
        );
      }

      return _handleAuthResponse(response.body);
    } catch (e) {
      Logger.log('KitsuApi: Password auth error: $e');
      return KitsuAuthResult.failure(e.toString());
    }
  }

  /// Authenticate with OAuth (Authorization Code flow)
  /// Requires client ID and secret from Kitsu developer portal
  /// https://kitsu.io/settings/apps
  Future<KitsuAuthResult> authenticateWithOAuth({
    required String clientId,
    required String clientSecret,
    required String authCode,
    required String redirectUri,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(authUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'authorization_code',
          'client_id': clientId,
          'client_secret': clientSecret,
          'code': authCode,
          'redirect_uri': redirectUri,
        },
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        return KitsuAuthResult.failure(
          error['error_description'] ?? 'OAuth authentication failed',
        );
      }

      return _handleAuthResponse(response.body);
    } catch (e) {
      Logger.log('KitsuApi: OAuth auth error: $e');
      return KitsuAuthResult.failure(e.toString());
    }
  }

  /// Generate OAuth authorization URL for web-based login
  String getOAuthUrl({
    required String clientId,
    required String redirectUri,
  }) {
    return 'https://kitsu.io/api/oauth/authorize?'
        'response_type=code&'
        'client_id=$clientId&'
        'redirect_uri=${Uri.encodeComponent(redirectUri)}';
  }

  /// Handle OAuth callback and extract authorization code
  String? extractAuthCodeFromUri(Uri uri) {
    return uri.queryParameters['code'];
  }

  KitsuAuthResult _handleAuthResponse(String responseBody) {
    final data = jsonDecode(responseBody);
    _accessToken = data['access_token'];
    _refreshToken = data['refresh_token'];
    _tokenExpiry = DateTime.now().add(
      Duration(seconds: data['expires_in'] ?? 3600),
    );

    return KitsuAuthResult.success(
      accessToken: _accessToken!,
      refreshToken: _refreshToken!,
      expiresIn: data['expires_in'] ?? 3600,
    );
  }

  /// Refresh the access token
  Future<bool> refreshAccessToken() async {
    if (_refreshToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse(authUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'refresh_token',
          'refresh_token': _refreshToken,
        },
      );

      if (response.statusCode != 200) return false;

      final data = jsonDecode(response.body);
      _accessToken = data['access_token'];
      _refreshToken = data['refresh_token'];
      _tokenExpiry = DateTime.now().add(
        Duration(seconds: data['expires_in'] ?? 3600),
      );

      return true;
    } catch (e) {
      Logger.log('KitsuApi: Token refresh error: $e');
      return false;
    }
  }

  /// Search for anime or manga
  Future<List<KitsuMedia>> search(
    String query, {
    bool isAnime = true,
    int limit = 10,
  }) async {
    try {
      final type = isAnime ? 'anime' : 'manga';
      final uri = Uri.parse('$baseUrl/$type').replace(
        queryParameters: {
          'filter[text]': query,
          'page[limit]': limit.toString(),
          'fields[$type]': 'canonicalTitle,posterImage,episodeCount,chapterCount',
        },
      );

      final response = await http.get(uri, headers: _jsonApiHeaders);

      if (response.statusCode != 200) {
        Logger.log('KitsuApi: Search failed: ${response.statusCode}');
        return [];
      }

      return _parseMediaList(response.body);
    } catch (e) {
      Logger.log('KitsuApi: Search error: $e');
      return [];
    }
  }

  /// Get current user's ID
  Future<String?> getCurrentUserId() async {
    if (!isAuthenticated) return null;

    try {
      final uri = Uri.parse('$baseUrl/users').replace(
        queryParameters: {'filter[self]': 'true'},
      );

      final response = await http.get(uri, headers: _jsonApiHeaders);

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      final users = data['data'] as List;
      if (users.isEmpty) return null;

      return users.first['id'];
    } catch (e) {
      Logger.log('KitsuApi: Get user error: $e');
      return null;
    }
  }

  /// Get library entry for a media
  Future<KitsuLibraryEntry?> getLibraryEntry({
    required String userId,
    required String mediaId,
    required bool isAnime,
  }) async {
    try {
      final mediaType = isAnime ? 'anime' : 'manga';
      final uri = Uri.parse('$baseUrl/library-entries').replace(
        queryParameters: {
          'filter[userId]': userId,
          'filter[${mediaType}Id]': mediaId,
        },
      );

      final response = await http.get(uri, headers: _jsonApiHeaders);

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      final entries = data['data'] as List;
      if (entries.isEmpty) return null;

      return KitsuLibraryEntry.fromJson(entries.first);
    } catch (e) {
      Logger.log('KitsuApi: Get library entry error: $e');
      return null;
    }
  }

  /// Create a library entry
  Future<KitsuLibraryEntry?> createLibraryEntry({
    required String userId,
    required String mediaId,
    required bool isAnime,
    required int progress,
    String status = 'current',
  }) async {
    try {
      final mediaType = isAnime ? 'anime' : 'manga';
      final body = jsonEncode({
        'data': {
          'type': 'library-entries',
          'attributes': {
            'status': status,
            'progress': progress,
          },
          'relationships': {
            'user': {
              'data': {'type': 'users', 'id': userId}
            },
            mediaType: {
              'data': {'type': mediaType, 'id': mediaId}
            },
          },
        },
      });

      final response = await http.post(
        Uri.parse('$baseUrl/library-entries'),
        headers: _jsonApiHeaders,
        body: body,
      );

      if (response.statusCode != 201) {
        Logger.log('KitsuApi: Create entry failed: ${response.body}');
        return null;
      }

      final data = jsonDecode(response.body);
      return KitsuLibraryEntry.fromJson(data['data']);
    } catch (e) {
      Logger.log('KitsuApi: Create entry error: $e');
      return null;
    }
  }

  /// Update library entry progress
  Future<bool> updateProgress(String entryId, int progress) async {
    try {
      final body = jsonEncode({
        'data': {
          'id': entryId,
          'type': 'library-entries',
          'attributes': {
            'progress': progress,
          },
        },
      });

      final response = await http.patch(
        Uri.parse('$baseUrl/library-entries/$entryId'),
        headers: _jsonApiHeaders,
        body: body,
      );

      if (response.statusCode != 200) {
        Logger.log('KitsuApi: Update progress failed: ${response.body}');
        return false;
      }

      return true;
    } catch (e) {
      Logger.log('KitsuApi: Update progress error: $e');
      return false;
    }
  }

  List<KitsuMedia> _parseMediaList(String responseBody) {
    try {
      final data = jsonDecode(responseBody);
      final items = data['data'] as List;
      return items.map((item) => KitsuMedia.fromJson(item)).toList();
    } catch (e) {
      Logger.log('KitsuApi: Parse error: $e');
      return [];
    }
  }
}

/// Result of authentication attempt
class KitsuAuthResult {
  final bool success;
  final String? accessToken;
  final String? refreshToken;
  final int? expiresIn;
  final String? error;

  KitsuAuthResult._({
    required this.success,
    this.accessToken,
    this.refreshToken,
    this.expiresIn,
    this.error,
  });

  factory KitsuAuthResult.success({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
  }) =>
      KitsuAuthResult._(
        success: true,
        accessToken: accessToken,
        refreshToken: refreshToken,
        expiresIn: expiresIn,
      );

  factory KitsuAuthResult.failure(String error) =>
      KitsuAuthResult._(success: false, error: error);
}

/// Kitsu media item (anime or manga)
class KitsuMedia {
  final String id;
  final String title;
  final String? posterUrl;
  final int? episodeCount;
  final int? chapterCount;

  KitsuMedia({
    required this.id,
    required this.title,
    this.posterUrl,
    this.episodeCount,
    this.chapterCount,
  });

  factory KitsuMedia.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'] ?? {};
    final posterImage = attributes['posterImage'];

    return KitsuMedia(
      id: json['id'],
      title: attributes['canonicalTitle'] ?? 'Unknown',
      posterUrl: posterImage?['small'] ?? posterImage?['tiny'],
      episodeCount: attributes['episodeCount'],
      chapterCount: attributes['chapterCount'],
    );
  }
}

/// Kitsu library entry
class KitsuLibraryEntry {
  final String id;
  final int progress;
  final String status;

  KitsuLibraryEntry({
    required this.id,
    required this.progress,
    required this.status,
  });

  factory KitsuLibraryEntry.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'] ?? {};
    return KitsuLibraryEntry(
      id: json['id'],
      progress: attributes['progress'] ?? 0,
      status: attributes['status'] ?? 'current',
    );
  }
}
