part of 'traq_theme.dart';

/// App bar background asset and [AppBarThemeData] for Traq.
abstract final class TraqThemeAppBar {
  /// SVG used behind app bars via [AppBar.flexibleSpace].
  ///
  /// [AppBarThemeData] (Flutter 3.33+) does not support `flexibleSpace`. Prefer
  /// [TraqAppBar] from `core/widgets/traq_app_bar.dart` for [AppBar]s, or pass
  /// [flexibleBackground] / [TraqContextX.appBarFlexibleBackground] (e.g. for
  /// [SliverAppBar]).
  static const String backgroundAsset = AppAssets.traqBackgroundSvg;

  /// Icon and tooltip for the default log-out action in [TraqAppBar]. Configure here only.
  static const IconData logoutActionIcon = Icons.logout;
  static const String logoutActionTooltip = 'Log out';

  /// Stack for [AppBar.flexibleSpace] / [SliverAppBar.flexibleSpace].
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
