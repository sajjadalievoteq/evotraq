import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/theme/theme_cubit.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/auth/presentation/widget/logout_confirm_dialog.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';

class TraqAppBar extends AppBar {
  TraqAppBar(
    BuildContext context, {
    super.key,
    super.leading,
    bool automaticallyImplyLeading = true,
    super.title,
    List<Widget>? actions,
    bool showLogoutAction = true,
    bool automaticallyImplyActions = true,
    Widget? flexibleSpace,
    super.bottom,
    super.elevation,
    super.scrolledUnderElevation,
    super.notificationPredicate,
    super.shadowColor,
    super.surfaceTintColor,
    super.shape,
    Color? backgroundColor,
    super.foregroundColor,
    super.iconTheme,
    super.actionsIconTheme,
    bool primary = true,
    super.centerTitle,
    bool excludeHeaderSemantics = false,
    super.titleSpacing,
    double toolbarOpacity = 1.0,
    double bottomOpacity = 1.0,
    super.toolbarHeight,
    super.leadingWidth,
    super.toolbarTextStyle,
    super.titleTextStyle,
    super.systemOverlayStyle,
    bool forceMaterialTransparency = false,
    bool useDefaultSemanticsOrder = true,
    super.clipBehavior,
    super.actionsPadding,
    bool animateColor = false,
  }) : super(
          automaticallyImplyLeading: automaticallyImplyLeading,
          automaticallyImplyActions: automaticallyImplyActions,
          backgroundColor: backgroundColor ?? context.colors.primary,
          flexibleSpace: flexibleSpace ?? context.appBarFlexibleBackground,
          primary: primary,
          excludeHeaderSemantics: excludeHeaderSemantics,
          toolbarOpacity: toolbarOpacity,
          bottomOpacity: bottomOpacity,
          forceMaterialTransparency: forceMaterialTransparency,
          useDefaultSemanticsOrder: useDefaultSemanticsOrder,
          animateColor: animateColor,
        );

  static List<Widget>? _mergeActions(
    BuildContext context,
    List<Widget>? actions,
    bool showLogoutAction,
  ) {
    final merged = <Widget>[
      BlocBuilder<ThemeCubit, ThemeState>(
        buildWhen: (previous, current) =>
            previous.isDarkMode != current.isDarkMode,
        builder: (context, themeState) {
          return IconButton(
            tooltip: themeState.isDarkMode ? 'Light mode' : 'Dark mode',
            onPressed: () => context.read<ThemeCubit>().toggleTheme(),
            icon: SvgPicture.asset(
              themeState.isDarkMode ? AppAssets.iconSun : AppAssets.iconMoon,
              width: 22,
              height: 22,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          );
        },
      ),
      IconButton(
        tooltip: 'Notifications',
        onPressed: () => context.go(Constants.notificationsRoute),
        icon: SvgPicture.asset(
          AppAssets.iconNotification,
          width: 22,
          height: 22,
          colorFilter: const ColorFilter.mode(
            Colors.white,
            BlendMode.srcIn,
          ),
        ),
      ),
      ...?actions,
    ];
merged.add(    SizedBox(width: 20,),);
    if (showLogoutAction) {
      try {
        context.read<AuthCubit>();
        merged.add(
          IconButton(
            icon: SvgPicture.asset(
              AppAssets.iconLogout,
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
            tooltip: TraqThemeAppBar.logoutActionTooltip,
            onPressed: () => showLogoutConfirmDialog(context),
          ),
        );
      } catch (_) {
      }
    }
    if (merged.isEmpty) return null;
    return merged;
  }
}
