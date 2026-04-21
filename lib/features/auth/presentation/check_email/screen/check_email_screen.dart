import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/auth/presentation/check_email/widget/check_email_content_widget.dart';
import 'package:traqtrace_app/features/auth/presentation/widgets/auth_responsive_layout_widget.dart';
import 'package:traqtrace_app/features/auth/presentation/widgets/background_container_widget.dart';

class CheckEmailScreen extends StatelessWidget {
  final String? email;

  const CheckEmailScreen({super.key, this.email});

  @override
  Widget build(BuildContext context) {
    return BackgroundContainerWidget(
      child: AuthResponsiveFormLayout(
        child: CheckEmailContentWidget(email: email),
      ),
    );
  }
}
