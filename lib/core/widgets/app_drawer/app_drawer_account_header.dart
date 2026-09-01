import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/cubit/system_settings_cubit.dart';
import 'package:traqtrace_app/core/theme/theme_cubit.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/traq_background_texture.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/auth/user.dart';

class AppDrawerAccountHeader extends StatelessWidget {
  const AppDrawerAccountHeader({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      buildWhen: (previous, current) =>
          previous.isDarkMode != current.isDarkMode,
      builder: (context, themeState) {
        return BlocBuilder<SystemSettingsCubit, SystemSettingsState>(
          builder: (context, settingsState) {
            final isDarkMode = themeState.isDarkMode;
            return Stack(
              fit: StackFit.passthrough,
              children: [
                Positioned.fill(
                  child: ColoredBox(
                    color: context.colors.primary,
                    child: const TraqBackgroundTexture(),
                  ),
                ),
                UserAccountsDrawerHeader(
                  margin: EdgeInsets.zero,
                  otherAccountsPicturesSize: Size.square(45.0),
                  accountName: Row(
                    children: [
                      Text(
                        '${user.firstName} ${user.lastName}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                  accountEmail: Text(
                    user.email,
                    style: const TextStyle(fontSize: 14),
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: context.colors.background,
                    child: Text(
                      user.firstName.isNotEmpty
                          ? user.firstName[0].toUpperCase()
                          : 'U',
                      style: TextStyle(
                        fontSize: 40,
                        color: context.colors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  decoration: const BoxDecoration(color: Colors.transparent),
                  otherAccountsPictures: [
                    IconButton(
                      iconSize: 40,
                      icon: TraqIcon(
                        size: 40,
                        isDarkMode ? NavIcons.themeSun : NavIcons.themeMoon,
                        color: context.colors.background,
                      ),
                      onPressed: () async {
                        await context.read<ThemeCubit>().toggleTheme();
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}
