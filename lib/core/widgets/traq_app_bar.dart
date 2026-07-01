import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';


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

}
