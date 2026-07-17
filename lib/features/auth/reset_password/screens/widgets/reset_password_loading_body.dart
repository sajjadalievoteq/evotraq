import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_form_header.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_responsive_layout_widget.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_staggered_entrance.dart';

class ResetPasswordLoadingBody extends StatelessWidget {
  const ResetPasswordLoadingBody({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthResponsiveFormLayout(
      header: AuthFormHeader.resetPassword,
      child: AuthStaggeredEntrance(
        children: [
          const SizedBox(height: 48),
          const Center(child: CircularProgressIndicator()),
          const SizedBox(height: 24),
          Text(
            'Validating reset link…',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
