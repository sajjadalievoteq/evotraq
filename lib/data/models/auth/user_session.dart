class UserSession {
  final String id;
  final String device;
  final String? ipAddress;
  final DateTime lastSeenAt;
  final DateTime createdAt;
  final bool current;

  const UserSession({
    required this.id,
    required this.device,
    this.ipAddress,
    required this.lastSeenAt,
    required this.createdAt,
    required this.current,
  });

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      id: json['id']?.toString() ?? '',
      device: (json['device'] as String?)?.trim().isNotEmpty == true
          ? json['device'] as String
          : 'Unknown device',
      ipAddress: json['ipAddress'] as String?,
      lastSeenAt: DateTime.parse(json['lastSeenAt'] as String).toLocal(),
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      current: json['current'] == true,
    );
  }
}
