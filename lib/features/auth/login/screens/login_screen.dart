import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/constants.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/features/auth/login/screens/utils/login_auth_redirect_utils.dart';
import 'package:traqtrace_app/features/auth/login/screens/widgets/login_form_widget.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_form_header.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_responsive_layout_widget.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_screen_host.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScreenHost(
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (LoginAuthRedirectUtils.shouldRedirectToCheckEmail(state)) {
            final email = state.registeredEmail?.trim();
            context.go(
              Uri(
                path: Constants.checkEmailRoute,
                queryParameters: {
                  if (email != null && email.isNotEmpty) 'email': email,
                },
              ).toString(),
            );
          } else if (state.status == AuthStatus.error) {
            context.showError(state.error ?? 'Authentication failed');
          }
          
        },
        builder: (context, state) {
          return AuthResponsiveFormLayout(
            header: AuthFormHeader.signIn,
            child: LoginFormWidget(state: state),
          );
        },
      ),
    );
  }
}
