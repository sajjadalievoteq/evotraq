import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/network/dio_service_logging.dart';

void main() {
  group('DioServiceLogger body formatting', () {
    test('null body renders as none', () {
      expect(DioServiceLogger.formatBodyForTest(null), '(none)');
    });

    test('small map payload is compact and not pretty-printed by default', () {
      final out = DioServiceLogger.formatBodyForTest({
        'id': 1,
        'name': 'alpha',
      });
      expect(out, contains('Map(keys='));
      expect(out, contains('"id":1'));
      expect(out, isNot(contains('\n  "id"')));
    });

    test('truncates oversized string payloads', () {
      final huge = 'x' * (kDioBodyPreviewLimitChars + 500);
      final out = DioServiceLogger.formatBodyForTest(huge, previewLimit: 100);
      expect(out.length, lessThan(huge.length));
      expect(out, contains('[truncated'));
      expect(out.startsWith('x' * 100), isTrue);
    });

    test('redacts sensitive map keys', () {
      final out = DioServiceLogger.formatBodyForTest({
        'username': 'admin',
        'password': 'secret-value',
        'token': 'abc',
        'Authorization': 'Bearer xyz',
        'webhookSecret': 'whsec',
        'nested': {'access_token': 'nested-secret', 'ok': true},
      });
      expect(out, contains('"username":"admin"'));
      expect(out, contains('"password":"***"'));
      expect(out, contains('"token":"***"'));
      expect(out, contains('"Authorization":"***"'));
      expect(out, contains('"webhookSecret":"***"'));
      expect(out, contains('"access_token":"***"'));
      expect(out, isNot(contains('secret-value')));
      expect(out, isNot(contains('nested-secret')));
    });

    test('redacts sensitive headers', () {
      final headers = DioServiceLogger.redactHeadersForTest({
        'Authorization': 'Bearer secret-token',
        'Content-Type': 'application/json',
        'X-Api-Key': 'key-123',
        'Cookie': 'session=abc',
      });
      expect(headers['Authorization'], '***');
      expect(headers['X-Api-Key'], '***');
      expect(headers['Cookie'], '***');
      expect(headers['Content-Type'], 'application/json');
    });

    test('binary byte payloads are summarized without decoding', () {
      final bytes = Uint8List.fromList(List<int>.filled(2048, 7));
      final out = DioServiceLogger.formatBodyForTest(bytes);
      expect(out, contains('binary bytes'));
      expect(out, contains('2048'));
      expect(out, isNot(contains('777')));
    });

    test('malformed JSON string is truncated without throwing', () {
      final bad = '{not-json:' + ('y' * 6000);
      final out = DioServiceLogger.formatBodyForTest(bad, previewLimit: 128);
      expect(out.length, lessThan(bad.length));
      expect(out, contains('[truncated'));
    });

    test('large list uses metadata + short preview by default', () {
      final list = List.generate(200, (i) => {'id': i, 'name': 'item-$i'});
      final out = DioServiceLogger.formatBodyForTest(
        list,
        path: '/api/master-data/glns',
      );
      expect(out, contains('List(length=200'));
      expect(out, contains('preview='));
      expect(out, isNot(contains('item-50')));
      final encoded = jsonEncode(list);
      expect(out.length, lessThan(encoded.length ~/ 10));
    });

    test('forceFull still redacts secrets', () {
      final out = DioServiceLogger.formatBodyForTest(
        {'password': 'plain', 'ok': 1},
        forceFull: true,
      );
      expect(out, contains('"password": "***"'));
      expect(out, isNot(contains('plain')));
    });

    test('FormData summarizes fields and redacts secrets', () {
      final form = FormData.fromMap({
        'name': 'file-upload',
        'password': 'pw',
      });
      final out = DioServiceLogger.formatBodyForTest(form);
      expect(out, contains('FormData'));
      expect(out, contains('password'));
      expect(out, contains('***'));
      expect(out, isNot(contains('pw')));
    });
  });
}
