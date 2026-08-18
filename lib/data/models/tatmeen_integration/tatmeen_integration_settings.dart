import 'package:equatable/equatable.dart';

class TatmeenIntegrationSettings extends Equatable {
  const TatmeenIntegrationSettings({
    required this.enabled,
    this.username,
    this.passwordConfigured = false,
    this.apiKeyConfigured = false,
    this.apiKeyHint,
    this.updatedAt,
    this.updatedBy,
  });

  final bool enabled;
  final String? username;
  final bool passwordConfigured;
  final bool apiKeyConfigured;
  final String? apiKeyHint;
  final DateTime? updatedAt;
  final String? updatedBy;

  bool get credentialsComplete =>
      (username?.trim().isNotEmpty ?? false) &&
      passwordConfigured &&
      apiKeyConfigured;

  factory TatmeenIntegrationSettings.fromJson(Map<String, dynamic> json) {
    final updatedAtRaw = json['updatedAt'];
    return TatmeenIntegrationSettings(
      enabled: json['enabled'] == true,
      username: json['username'] as String?,
      passwordConfigured: json['passwordConfigured'] == true,
      apiKeyConfigured: json['apiKeyConfigured'] == true,
      apiKeyHint: json['apiKeyHint'] as String?,
      updatedAt: updatedAtRaw == null
          ? null
          : DateTime.tryParse(updatedAtRaw.toString())?.toLocal(),
      updatedBy: json['updatedBy'] as String?,
    );
  }

  TatmeenIntegrationSettings copyWith({
    bool? enabled,
    String? username,
    bool? passwordConfigured,
    bool? apiKeyConfigured,
    String? apiKeyHint,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    return TatmeenIntegrationSettings(
      enabled: enabled ?? this.enabled,
      username: username ?? this.username,
      passwordConfigured: passwordConfigured ?? this.passwordConfigured,
      apiKeyConfigured: apiKeyConfigured ?? this.apiKeyConfigured,
      apiKeyHint: apiKeyHint ?? this.apiKeyHint,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  @override
  List<Object?> get props => [
    enabled,
    username,
    passwordConfigured,
    apiKeyConfigured,
    apiKeyHint,
    updatedAt,
    updatedBy,
  ];
}

class UpdateTatmeenIntegrationSettingsRequest extends Equatable {
  const UpdateTatmeenIntegrationSettingsRequest({
    this.enabled,
    this.username,
    this.password,
    this.apiKey,
    this.clearPassword,
    this.clearApiKey,
  });

  final bool? enabled;
  final String? username;
  final String? password;
  final String? apiKey;
  final bool? clearPassword;
  final bool? clearApiKey;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (enabled != null) json['enabled'] = enabled;
    if (username != null) json['username'] = username;
    if (password != null) json['password'] = password;
    if (apiKey != null) json['apiKey'] = apiKey;
    if (clearPassword == true) json['clearPassword'] = true;
    if (clearApiKey == true) json['clearApiKey'] = true;
    return json;
  }

  @override
  List<Object?> get props => [
    enabled,
    username,
    password,
    apiKey,
    clearPassword,
    clearApiKey,
  ];
}

class TatmeenConnectionTestResult extends Equatable {
  const TatmeenConnectionTestResult({
    required this.success,
    required this.message,
  });

  final bool success;
  final String message;

  factory TatmeenConnectionTestResult.fromJson(Map<String, dynamic> json) {
    return TatmeenConnectionTestResult(
      success: json['success'] == true,
      message: (json['message'] as String?) ?? 'Connection test completed',
    );
  }

  @override
  List<Object?> get props => [success, message];
}
