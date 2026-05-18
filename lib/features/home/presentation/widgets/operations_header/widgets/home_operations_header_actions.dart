import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/theme_cubit.dart';
import 'package:traqtrace_app/core/widgets/traq_elevated_icon_button.dart';
import 'package:traqtrace_app/features/home/presentation/constants/home_navigation.dart';
import 'package:traqtrace_app/features/home/presentation/constants/home_strings.dart';

class HomeOperationsHeaderActions extends StatelessWidget {
  const HomeOperationsHeaderActions({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final onIcon = scheme.onSurface;
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        BlocBuilder<ThemeCubit, ThemeState>(
          buildWhen: (previous, current) =>
              previous.isDarkMode != current.isDarkMode,
          builder: (context, themeState) {
            return IconButton(
              tooltip: themeState.isDarkMode
                  ? HomeStrings.themeTooltipLight
                  : HomeStrings.themeTooltipDark,
              onPressed: () async {
                await context.read<ThemeCubit>().toggleTheme();
              },
              icon: SvgPicture.asset(
                themeState.isDarkMode ? AppAssets.iconSun : AppAssets.iconMoon,
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(onIcon, BlendMode.srcIn),
              ),
            );
          },
        ),
        IconButton(
          tooltip: HomeStrings.notificationsTooltip,
          onPressed: () => context.go(HomeNavigation.notifications),
          icon: SvgPicture.asset(
            AppAssets.iconAlert,
            width: 22,
            height: 22,
            colorFilter: ColorFilter.mode(onIcon, BlendMode.srcIn),
          ),
        ),
        TraqElevatedIconButton(
          onPressed: () => context.go(HomeNavigation.epcisObjectEventNew),
          icon: SvgPicture.asset(
            AppAssets.iconPlus,
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(scheme.onPrimary, BlendMode.srcIn),
          ),
          label: HomeStrings.newEventButton,
        ),
      ],
    );
  }
}
