import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages authentication tokens securely using flutter_secure_storage
class TokenManager {
  static const String _tokenKey = 'auth_token';
  final FlutterSecureStorage _secureStorage;

  /// Creates a new token manager instance with secure storage.
  TokenManager({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();
      
  /// Saves the authentication token securely.
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  /// Retrieves the stored authentication token.
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  /// Deletes the stored authentication token.
  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }
  
  /// Checks if a token exists.
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}