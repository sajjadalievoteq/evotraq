import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_router.dart';
import 'package:traqtrace_app/core/config/constants.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';

Future<void> showLogoutConfirmDialog(BuildContext context) async {
  final dialogContext = _dialogHostContext(context);

  final confirmed = await showDialog<bool>(
    context: dialogContext,
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
            child: Text(
              'Cancel',
              style: t.bodySm.copyWith(color: c.textPrimary),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Log out'),
          ),
        ],
      );
    },
  );

  if (confirmed != true) return;

  await getIt<AuthCubit>().logout();
  getIt<AppRouter>().router.go(Constants.loginRoute);
}

BuildContext _dialogHostContext(BuildContext context) {
  final root = getIt<AppRouter>().router.routerDelegate.navigatorKey.currentContext;
  if (root != null) return root;
  return context;
}
