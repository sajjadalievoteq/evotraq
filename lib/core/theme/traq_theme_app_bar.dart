part of 'traq_theme.dart';

abstract final class TraqThemeAppBar {
  static const String backgroundAsset = AppAssets.traqBackgroundSvg;

  static const String logoutActionIconAsset = AppAssets.iconLogout;
  static const String logoutActionTooltip = 'Log out';

  static Widget flexibleBackground(TraqColors c) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: c.primary,
            image: const DecorationImage(
              image: AssetImage(AppAssets.traqBackgroundPng),
              fit: BoxFit.cover,
              opacity: 0.2,
            ),
          ),
        ),
        ColoredBox(color: Colors.black.withOpacity(0.1)),
      ],
    );
  }

  static AppBarThemeData appBarTheme(TraqColors c, TraqText text) =>
      AppBarThemeData(

        backgroundColor: c.primary,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: c.primary,
        foregroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: text.body.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      );
}
