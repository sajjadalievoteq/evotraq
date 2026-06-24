import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/user_management/user_management_models.dart';

String userApprovalDisplayName(UserResponse user) {
  final fullName = '${user.firstName} ${user.lastName}'.trim();
  return fullName.isEmpty ? user.username : fullName;
}

String userApprovalRegisteredDate(UserResponse user) {
  if (!user.createdAt.contains('T')) {
    return user.createdAt;
  }
  return user.createdAt.split('T').first;
}

String userApprovalAvatarInitial(UserResponse user) {
  if (user.firstName.isEmpty) return 'U';
  return user.firstName.characters.first.toUpperCase();
}
