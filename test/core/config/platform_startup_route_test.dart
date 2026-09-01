import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/config/platform_startup_route.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';

void main() {
  test('resolvePlatformStartupRoute defaults to splash off-web', () {
    expect(resolvePlatformStartupRoute(), Constants.splashRoute);
  });

  test('resolveRouterInitialLocation maps branding splash to root', () {
    expect(resolveRouterInitialLocation(Constants.splashRoute), '/');
    expect(resolveRouterInitialLocation('/'), '/');
    expect(
      resolveRouterInitialLocation(Constants.homeRoute),
      Constants.homeRoute,
    );
    expect(
      resolveRouterInitialLocation('/dashboards/journey?epc=1'),
      '/dashboards/journey?epc=1',
    );
  });
}
