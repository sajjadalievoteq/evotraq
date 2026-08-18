import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_integration_settings.dart';

void main() {
  group('TatmeenIntegrationSettings', () {
    test('fromJson parses safe credential metadata', () {
      final settings = TatmeenIntegrationSettings.fromJson({
        'enabled': true,
        'username': 'tat-user',
        'passwordConfigured': true,
        'apiKeyConfigured': true,
        'apiKeyHint': '••••1234',
        'updatedAt': '2026-08-17T12:00:00Z',
        'updatedBy': 'admin',
      });

      expect(settings.enabled, isTrue);
      expect(settings.username, 'tat-user');
      expect(settings.passwordConfigured, isTrue);
      expect(settings.apiKeyHint, '••••1234');
      expect(settings.credentialsComplete, isTrue);
    });

    test('fromJson treats absent enabled as false', () {
      final settings = TatmeenIntegrationSettings.fromJson({});
      expect(settings.enabled, isFalse);
      expect(settings.credentialsComplete, isFalse);
    });

    test('patch request omits null fields', () {
      const request = UpdateTatmeenIntegrationSettingsRequest(
        username: 'user',
        password: 'secret',
      );
      expect(request.toJson(), {'username': 'user', 'password': 'secret'});
    });
  });
}
