import 'package:flutter/material.dart';

import '../../../../../../core/consts/app_consts.dart';
import 'user_management_constants.dart';

class UserManagementSectionWidth extends StatelessWidget {
  const UserManagementSectionWidth({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: Constants.sectionMaxWidth,
        ),
        child: child,
      ),
    );
  }
}
