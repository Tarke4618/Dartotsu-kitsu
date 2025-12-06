import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Functions/Function.dart';
import '../../Preferences/PrefManager.dart';
import '../../Services/BaseServiceData.dart';
import '../../Services/BridgeSyncService.dart';
import '../../logger.dart';
import 'KitsuApi.dart';

/// Singleton controller for Kitsu integration.
class KitsuController extends BaseServiceData {
  static final KitsuController _instance = KitsuController._();
  factory KitsuController() => _instance;
  KitsuController._();

  final KitsuApi _api = KitsuApi();
  String? _userId;

  bool get isLoggedIn => _api.isAuthenticated;
  String? get userId => _userId;
  KitsuApi get api => _api;

  /// Initialize controller and restore saved token
  @override
  bool getSavedToken() {
    try {
      final tokenData =
          loadCustomData<Map<String, dynamic>>('kitsu_token');
      if (tokenData == null) return false;

      final accessToken = tokenData['access_token'] as String?;
      final refreshToken = tokenData['refresh_token'] as String?;
      final expiryMs = tokenData['expiry'] as int?;

      if (accessToken == null || refreshToken == null || expiryMs == null) {
        return false;
      }

      final expiry = DateTime.fromMillisecondsSinceEpoch(expiryMs);
      if (DateTime.now().isAfter(expiry)) {
        // Token expired, try to refresh
        _api.setTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
          expiry: expiry,
        );
        _refreshToken();
        return true;
      }

      _api.setTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
        expiry: expiry,
      );

      token.value = accessToken;
      _fetchUserProfile();
      _registerWithBridgeSync();

      Logger.log('KitsuController: Restored saved token');
      return true;
    } catch (e) {
      Logger.log('KitsuController: Error loading token: $e');
      return false;
    }
  }

  @override
  void login(BuildContext context) {
    _showLoginDialog(context);
  }

  @override
  void removeSavedToken() {
    _api.clearTokens();
    _userId = null;
    token.value = '';
    username.value = '';
    avatar.value = '';;
    removeCustomData<Map<String, dynamic>>('kitsu_token');
    Logger.log('KitsuController: Token removed');
  }

  @override
  Future<void> saveToken(String token) async {
    // Token is saved via _saveTokenData after successful login
  }

  Future<void> _refreshToken() async {
    final success = await _api.refreshAccessToken();
    if (success) {
      await _saveTokenData();
      token.value = _api.accessToken ?? '';
      await _fetchUserProfile();
      _registerWithBridgeSync();
    } else {
      removeSavedToken();
    }
  }

  Future<void> _saveTokenData() async {
    final tokenData = {
      'access_token': _api.accessToken,
      'refresh_token': _api.refreshToken,
      'expiry': _api.tokenExpiry?.millisecondsSinceEpoch,
    };
    saveCustomData('kitsu_token', tokenData);
  }

  Future<void> _fetchUserProfile() async {
    final profile = await _api.getCurrentUserProfile();
    if (profile != null) {
      _userId = profile.id;
      username.value = profile.name;
      if (profile.avatar != null) {
        avatar.value = profile.avatar!;
      }
      Logger.log('KitsuController: User Profile: ${_userId} - ${username.value}');
    } else {
      Logger.log('KitsuController: Failed to fetch profile');
    }
  }

  void _registerWithBridgeSync() {
    BridgeSyncService.instance.registerTracker(
      'kitsu',
      _updateProgress,
    );
    Logger.log('KitsuController: Registered with BridgeSyncService');
  }

  /// Update progress on Kitsu (called by BridgeSyncService)
  Future<void> _updateProgress(
    String mediaId,
    int progress,
    String mediaType,
  ) async {
    if (_userId == null) {
      Logger.log('KitsuController: Cannot update - not logged in');
      return;
    }

    final isAnime = mediaType == 'anime';

    // Get or create library entry
    var entry = await _api.getLibraryEntry(
      userId: _userId!,
      mediaId: mediaId,
      isAnime: isAnime,
    );

    if (entry == null) {
      // Create new entry
      entry = await _api.createLibraryEntry(
        userId: _userId!,
        mediaId: mediaId,
        isAnime: isAnime,
        progress: progress,
      );
      if (entry != null) {
        Logger.log('KitsuController: Created library entry for $mediaId');
      }
    } else {
      // Update existing entry
      final success = await _api.updateProgress(entry.id, progress);
      if (success) {
        Logger.log('KitsuController: Updated progress for $mediaId to $progress');
      }
    }
  }

  /// Search for media on Kitsu
  Future<List<KitsuMedia>> searchMedia(String query, {bool isAnime = true}) {
    return _api.search(query, isAnime: isAnime);
  }

  void _showLoginDialog(BuildContext context) {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final clientIdController = TextEditingController();
    final clientSecretController = TextEditingController();
    final isLoading = false.obs;
    final errorMessage = ''.obs;
    final authMethod = 0.obs; // 0 = password, 1 = OAuth

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Login to Kitsu'),
        content: SingleChildScrollView(
          child: Obx(() => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Auth method toggle
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 0, label: Text('Password'), icon: Icon(Icons.password)),
                  ButtonSegment(value: 1, label: Text('OAuth'), icon: Icon(Icons.key)),
                ],
                selected: {authMethod.value},
                onSelectionChanged: (selected) {
                  authMethod.value = selected.first;
                  errorMessage.value = '';
                },
              ),
              const SizedBox(height: 16),
              
              // Password auth fields
              if (authMethod.value == 0) ...[
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username or Email',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
              ],
              
              // OAuth fields
              if (authMethod.value == 1) ...[
                const Text(
                  'Get your Client ID and Secret from:',
                  style: TextStyle(fontSize: 12),
                ),
                InkWell(
                  onTap: () => launchUrl(Uri.parse('https://kitsu.io/settings/apps')),
                  child: Text(
                    'kitsu.io/settings/apps',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(dialogContext).colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: clientIdController,
                  decoration: const InputDecoration(
                    labelText: 'Client ID',
                    prefixIcon: Icon(Icons.apps),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: clientSecretController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Client Secret',
                    prefixIcon: Icon(Icons.vpn_key),
                  ),
                ),
              ],
              
              // Error message
              if (errorMessage.value.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  errorMessage.value,
                  style: TextStyle(color: Theme.of(dialogContext).colorScheme.error),
                ),
              ],
              
              // Loading indicator
              if (isLoading.value) ...[
                const SizedBox(height: 12),
                const CircularProgressIndicator(),
              ],
            ],
          )),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          Obx(() => TextButton(
            onPressed: isLoading.value
                ? null
                : () async {
                    isLoading.value = true;
                    errorMessage.value = '';
                    
                    KitsuAuthResult result;
                    
                    if (authMethod.value == 0) {
                      // Password authentication
                      result = await _api.authenticateWithPassword(
                        usernameController.text.trim(),
                        passwordController.text,
                      );
                    } else {
                      // OAuth - open browser for authorization
                      final clientId = clientIdController.text.trim();
                      final clientSecret = clientSecretController.text.trim();
                      
                      if (clientId.isEmpty || clientSecret.isEmpty) {
                        errorMessage.value = 'Please enter Client ID and Secret';
                        isLoading.value = false;
                        return;
                      }
                      
                      // For OAuth, we need to launch browser and handle callback
                      // Using a simple workaround: ask user to paste the auth code
                      await _showOAuthFlowDialog(
                        dialogContext,
                        clientId: clientId,
                        clientSecret: clientSecret,
                        onSuccess: () {
                          Navigator.pop(dialogContext);
                          snackString('Logged in to Kitsu via OAuth');
                        },
                        onError: (error) {
                          errorMessage.value = error;
                        },
                      );
                      isLoading.value = false;
                      return;
                    }

                    if (result.success) {
                      await _saveTokenData();
                      token.value = _api.accessToken ?? '';
                      await _fetchUserProfile();
                      _registerWithBridgeSync();
                      
                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                        snackString('Logged in to Kitsu');
                      }
                    } else {
                      errorMessage.value = result.error ?? 'Login failed';
                    }

                    isLoading.value = false;
                  },
            child: Text(authMethod.value == 0 ? 'Login' : 'Start OAuth'),
          )),
        ],
      ),
    );
  }
  
  Future<void> _showOAuthFlowDialog(
    BuildContext context, {
    required String clientId,
    required String clientSecret,
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    const redirectUri = 'dartotsu://kitsu/callback';
    final authUrl = _api.getOAuthUrl(
      clientId: clientId,
      redirectUri: redirectUri,
    );
    
    final authCodeController = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('OAuth Authorization'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('1. Click "Open Browser" to authorize'),
            const Text('2. After authorizing, you\'ll be redirected'),
            const Text('3. Copy the "code" parameter from the URL'),
            const Text('4. Paste it below and click "Complete"'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => launchUrl(Uri.parse(authUrl)),
              icon: const Icon(Icons.open_in_browser),
              label: const Text('Open Browser'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: authCodeController,
              decoration: const InputDecoration(
                labelText: 'Authorization Code',
                hintText: 'Paste the code from the URL',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final authCode = authCodeController.text.trim();
              if (authCode.isEmpty) {
                onError('Please enter the authorization code');
                return;
              }
              
              final result = await _api.authenticateWithOAuth(
                clientId: clientId,
                clientSecret: clientSecret,
                authCode: authCode,
                redirectUri: redirectUri,
              );
              
              Navigator.pop(ctx);
              
              if (result.success) {
                await _saveTokenData();
                token.value = _api.accessToken ?? '';
                await _fetchUserProfile();
                _registerWithBridgeSync();
                onSuccess();
              } else {
                onError(result.error ?? 'OAuth failed');
              }
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }
}

// Make the singleton accessible
final Kitsu = KitsuController();
