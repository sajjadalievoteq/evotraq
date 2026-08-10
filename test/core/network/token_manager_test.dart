import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';

String buildJwt({required DateTime expUtc, Map<String, dynamic>? extraClaims}) {
  final header = base64Url.encode(utf8.encode('{"alg":"none","typ":"JWT"}'));
  final payloadMap = <String, dynamic>{
    'exp': expUtc.millisecondsSinceEpoch ~/ 1000,
    ...?extraClaims,
  };
  final payload = base64Url.encode(utf8.encode(jsonEncode(payloadMap)));
  return '$header.$payload.sig';
}

void main() {
  late TokenManager tokenManager;

  setUp(() {
    tokenManager = TokenManager();
  });

  group('TokenManager JWT expiration', () {
    test('getExpiration reads UTC NumericDate exp claim', () {
      final exp = DateTime.utc(2030, 1, 15, 12);
      final token = buildJwt(expUtc: exp);

      expect(tokenManager.getExpiration(token), exp);
    });

    test('remainingLifetime applies safety margin', () {
      final clock = DateTime.utc(2030, 1, 1, 12);
      final exp = clock.add(const Duration(seconds: 65));
      final token = buildJwt(expUtc: exp);

      final remaining = tokenManager.remainingLifetime(token, clock: clock);

      expect(
        remaining,
        const Duration(seconds: 65) - TokenManager.tokenExpirySafetyMargin,
      );
    });

    test('isExpired is true at or after exp minus safety margin', () {
      final clock = DateTime.utc(2030, 1, 1, 12);
      final exp = clock.add(TokenManager.tokenExpirySafetyMargin);
      final token = buildJwt(expUtc: exp);

      expect(tokenManager.isExpired(token, clock: clock), isTrue);
      expect(
        tokenManager.isExpired(
          token,
          clock: clock.subtract(const Duration(seconds: 1)),
        ),
        isFalse,
      );
    });

    test('malformed tokens return null expiration and are not isExpired', () {
      expect(tokenManager.getExpiration('not-a-jwt'), isNull);
      expect(tokenManager.remainingLifetime('not-a-jwt'), isNull);
      expect(tokenManager.isExpired('not-a-jwt'), isFalse);
    });

    test('payload without exp is treated as undecodable for scheduling', () {
      final header = base64Url.encode(utf8.encode('{"alg":"none"}'));
      final payload = base64Url.encode(utf8.encode('{"sub":"user"}'));
      final token = '$header.$payload.sig';

      expect(tokenManager.getExpiration(token), isNull);
      expect(tokenManager.isExpired(token), isFalse);
    });
  });
}
