import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/home/utils/home_strings.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/quick_actions/widgets/quick_actions_grid.dart';
import 'package:traqtrace_app/core/widgets/traq_section_title.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_permissions.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_type.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  static bool _hasAnyQuickAction(AuthCubit cubit) {
    final auth = cubit.state;
    return OperationType.values.any(
      (type) => auth.canPerform(OperationPermissions.stepForOperationType(type)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = context.select<AuthCubit, bool>(_hasAnyQuickAction);
    if (!visible) return const SizedBox.shrink();

    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TraqSectionTitle(label: HomeStrings.sectionQuickActions),
        SizedBox(height: 12),
        QuickActionsGrid(),
      ],
    );
  }
}
