import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/constants.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/custom_elevated_button.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/home/home_dashboard_cache.dart';

/// Shows log-out confirmation (surface background, Traq tokens), then clears home cache,
/// calls [AuthCubit.logout], and navigates to login if the user confirms.
Future<void> showLogoutConfirmDialog(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      final c = ctx.colors;
      final t = ctx.text;
      return AlertDialog(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(TraqRadius.md),
          side: BorderSide(color: c.border),
        ),
        title: Text(
          'Log out?',
          style: t.h3.copyWith(color: c.textPrimary),
        ),
        content: Text(
          'You will need to sign in again to access your account.',
          style: t.body.copyWith(color: c.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Center(
              child: Text(
                'Cancel',
                style: t.bodySm.copyWith(color: c.textPrimary),
              ),
            ),
          ),
          SizedBox(height: 10,),
          CustomElevatedButton(label: 'Logout',  onPressed: () => Navigator.of(ctx).pop(true),),

        ],
      );
    },
  );
  if (confirmed != true || !context.mounted) return;
  HomeDashboardCache.clear();
  await context.read<AuthCubit>().logout();
  if (context.mounted) context.go(Constants.loginRoute);
}
