import 'package:flutter/material.dart';

abstract final class UserManagementConstants {
  static const String pageTitle = 'User Management';
  static const String approvalsPageTitle = 'Pending Approvals';
  static const String usersTitle = 'User List';
  static const String approvalsTitle = 'User Registration Approvals';
  static const String searchHint = 'Search by name, email or username';
  static const String roleLabel = 'Role';
  static const String statusLabel = 'Status';
  static const String refreshLabel = 'Refresh';
  static const String addUserLabel = 'Add User';
  static const String noUsersFound = 'No users found matching your criteria';
  static const String noPendingApprovals = 'No pending approvals';
  static const String approvalsErrorMessage = 'Unable to load pending approvals';
  static const String createUserSuccess = 'User created successfully';
  static const String updateUserSuccess = 'User updated successfully';
  static const String activateUserSuccess = 'User activated successfully';
  static const String deactivateUserSuccess = 'User deactivated successfully';
  static const String approveUserSuccess = 'User approved successfully';
  static const String rejectUserSuccess = 'Registration rejected successfully';
  static const String genericErrorMessage = 'An error occurred';
  static const String rejectDialogTitle = 'Reject Registration?';
  static const String rejectDialogActionSummary = 'This action will:';
  static const String rejectActionOne = 'Mark the registration as rejected';
  static const String rejectActionTwo = 'Send a rejection notification email';
  static const String rejectActionThree = 'Remove the user from the pending list';
  static const String rejectLabel = 'Reject';
  static const String approveLabel = 'Approve';
  static const String cancelLabel = 'Cancel';
  static const String registeredOnLabel = 'Registered on';
  static const String allFilter = 'All';
  static const String defaultRole = 'USER';
  static const String pendingStatus = 'PENDING';
  static const String activeStatus = 'ACTIVE';
  static const String inactiveStatus = 'INACTIVE';

  static const List<String> filterRoles = <String>[
    allFilter,
    'ADMIN',
    'USER',
    'VIEWER',
  ];

  static const List<String> assignableRoles = <String>[
    'ADMIN',
    'USER',
    'VIEWER',
  ];

  static const List<String> filterStatuses = <String>[
    allFilter,
    activeStatus,
    inactiveStatus,
    pendingStatus,
  ];

  static const double spacing = 16;
  static const double cardRadius = 20;
  static const double sectionMaxWidth = 1280;
  static const double dialogMaxWidth = 720;
  static const EdgeInsets sectionPadding = EdgeInsets.all(20);
}
