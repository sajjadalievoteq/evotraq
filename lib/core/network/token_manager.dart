import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:traqtrace_app/core/config/app_config.dart';

class TokenManager {
  /// Client-side skew buffer: schedule logout slightly before JWT `exp`.
  static const Duration tokenExpirySafetyMargin = Duration(seconds: 5);

  final FlutterSecureStorage _secureStorage;

  TokenManager({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: AppConfig.authTokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: AppConfig.authTokenKey);
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: AppConfig.authTokenKey);
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// JWT `exp` as UTC, or `null` when the claim is missing/malformed.
  DateTime? getExpiration(String token) {
    final payload = decodePayload(token);
    if (payload == null) return null;

    final exp = payload['exp'];
    final seconds = _asUnixSeconds(exp);
    if (seconds == null) return null;

    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);
  }

  /// Whether [token] is past JWT `exp` (minus [safetyMargin]) relative to [clock].
  ///
  /// Returns `false` when `exp` cannot be read — undecodable tokens fall through
  /// to backend 401 / WebSocket auth rejection rather than a client-side guess.
  bool isExpired(
    String token, {
    DateTime? clock,
    Duration safetyMargin = tokenExpirySafetyMargin,
  }) {
    final remaining = remainingLifetime(
      token,
      clock: clock,
      safetyMargin: safetyMargin,
    );
    if (remaining == null) return false;
    return remaining <= Duration.zero;
  }

  /// Time left until JWT `exp` minus [safetyMargin], or `null` if undecodable.
  Duration? remainingLifetime(
    String token, {
    DateTime? clock,
    Duration safetyMargin = tokenExpirySafetyMargin,
  }) {
    final expiration = getExpiration(token);
    if (expiration == null) return null;

    final now = (clock ?? DateTime.now()).toUtc();
    return expiration.subtract(safetyMargin).difference(now);
  }

  /// Decodes the JWT payload without verifying the signature.
  Map<String, dynamic>? decodePayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return null;

    try {
      final normalized = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final json = jsonDecode(decoded);
      if (json is Map<String, dynamic>) return json;
      if (json is Map) return Map<String, dynamic>.from(json);
      return null;
    } catch (_) {
      return null;
    }
  }

  int? _asUnixSeconds(dynamic exp) {
    if (exp is int) return exp;
    if (exp is num) return exp.toInt();
    if (exp is String) return int.tryParse(exp.trim());
    return null;
  }
}
