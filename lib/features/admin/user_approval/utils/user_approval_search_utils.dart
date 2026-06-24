import 'package:traqtrace_app/data/models/user_management/user_management_models.dart';

bool userApprovalMatchesSearch(UserResponse user, String query) {
  if (query.isEmpty) return true;
  final q = query.toLowerCase();
  return user.username.toLowerCase().contains(q) ||
      user.email.toLowerCase().contains(q) ||
      user.firstName.toLowerCase().contains(q) ||
      user.lastName.toLowerCase().contains(q) ||
      ('${user.firstName} ${user.lastName}').toLowerCase().contains(q);
}
