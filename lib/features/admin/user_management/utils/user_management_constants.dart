abstract final class UserManagementConstants {
  static const String pageTitle = 'User Management';
  static const String usersTitle = 'User List';
  static const String searchHint = 'Search by name, email or username';
  static const String roleLabel = 'Role';
  static const String statusLabel = 'Status';
  static const String refreshLabel = 'Refresh';
  static const String addUserLabel = 'Add User';
  static const String noUsersFound = 'No users found matching your criteria';
  static const String createUserSuccess = 'User created successfully';
  static const String updateUserSuccess = 'User updated successfully';
  static const String activateUserSuccess = 'User activated successfully';
  static const String deactivateUserSuccess = 'User deactivated successfully';
  static const String genericErrorMessage = 'An error occurred';
  static const String cancelLabel = 'Cancel';
  static const String allFilter = 'All';
  static const String defaultRole = 'USER';
  static const String pendingStatus = 'PENDING';
  static const String activeStatus = 'ACTIVE';
  static const String inactiveStatus = 'INACTIVE';

  static const List<String> filterRoles = <String>[
    allFilter,
    'ADMIN',
    'MANUFACTURER',
    'DISTRIBUTOR',
    'RETAILER',
    'USER',
  ];

  static const List<String> assignableRoles = <String>[
    'ADMIN',
    'MANUFACTURER',
    'DISTRIBUTOR',
    'RETAILER',
    'USER',
  ];

  static const List<String> filterStatuses = <String>[
    allFilter,
    activeStatus,
    inactiveStatus,
    pendingStatus,
  ];
}
