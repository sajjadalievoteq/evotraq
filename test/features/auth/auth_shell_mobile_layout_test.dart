import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/layout/app_layout_data.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_branding_section.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_form_header.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_form_panel.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_shell_mobile.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_surface_card.dart';

void main() {
  const viewportSizes = <Size>[
    Size(320, 568),
    Size(360, 800),
    Size(390, 844),
    Size(412, 915),
    Size(430, 932),
  ];

  const fittingViewports = <Size>[Size(390, 844), Size(430, 932)];

  Future<void> pumpMobileAuth(
    WidgetTester tester,
    Size size, {
    double formHeight = 280,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);

    await tester.pumpWidget(
      MaterialApp(
        theme: TraqTheme.light(),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          );
        },
        home: Scaffold(
          body: AuthShellMobile(
            layout: AppLayoutData.fromSize(size),
            child: SelectionArea(
              child: AuthFormPanel(
                header: AuthFormHeader.signIn,
                compactHeader: true,
                child: SizedBox(width: double.infinity, height: formHeight),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  double maxScrollExtent(WidgetTester tester) {
    final state = tester.state<ScrollableState>(find.byType(Scrollable));
    return state.position.maxScrollExtent;
  }

  for (final size in viewportSizes) {
    testWidgets(
      'mobile auth layout scrolls safely at ${size.width}x${size.height}',
      (tester) async {
        await pumpMobileAuth(tester, size);

        expect(tester.takeException(), isNull);
        expect(
          find.text('Every package. Every event.\nVerified.'),
          findsOneWidget,
        );
        expect(find.text('Sign in'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.scrollUntilVisible(
          find.text('CBV 2.0'),
          200,
          scrollable: find.byType(Scrollable),
        );

        expect(find.text('CBV 2.0'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'mobile auth keeps brand and sign-in connected at ${size.width}x${size.height}',
      (tester) async {
        await pumpMobileAuth(tester, size);

        final headline = tester.getRect(
          find.text('Every package. Every event.\nVerified.'),
        );
        final systemAccess = tester.getRect(find.text('SYSTEM ACCESS'));
        final signIn = tester.getRect(find.text('Sign in'));
        final gs1Eyebrow = tester.getRect(find.text('GS1 TRACK & TRACE'));

        expect(systemAccess.top - headline.bottom, lessThan(64));
        expect(systemAccess.top - headline.bottom, greaterThan(TraqSpacing.md));
        expect((systemAccess.left - signIn.left).abs(), lessThan(2));
        expect((gs1Eyebrow.left - systemAccess.left).abs(), lessThan(2));
      },
    );
  }

  testWidgets('short viewport still scrolls to reach the form and footer', (
    tester,
  ) async {
    await pumpMobileAuth(tester, const Size(320, 568));

    expect(maxScrollExtent(tester), greaterThan(0));

    await tester.scrollUntilVisible(
      find.text('CBV 2.0'),
      200,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('CBV 2.0'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final size in fittingViewports) {
    testWidgets(
      'does not add extra scroll when content fits at ${size.width}x${size.height}',
      (tester) async {
        await pumpMobileAuth(tester, size);

        expect(maxScrollExtent(tester), 0);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'centers the form card when space allows at ${size.width}x${size.height}',
      (tester) async {
        await pumpMobileAuth(tester, size);

        final viewport = tester.getRect(find.byType(SingleChildScrollView));
        final card = tester.getRect(find.byType(AuthSurfaceCard));
        final blockTop = tester.getTopLeft(find.byType(AuthBrandingSection)).dy;
        final blockBottom = tester.getBottomLeft(find.text('CBV 2.0')).dy;
        final blockCenterY = (blockTop + blockBottom) / 2;

        expect((card.center.dx - viewport.center.dx).abs(), lessThan(2));
        expect((blockCenterY - viewport.center.dy).abs(), lessThan(12));
        expect(
          (card.center.dy - viewport.center.dy).abs(),
          lessThan(viewport.height / 3),
        );
      },
    );
  }

  testWidgets(
    'tall form sizes to content instead of overflowing AuthFormPanel',
    (tester) async {
      await pumpMobileAuth(tester, const Size(412, 915), formHeight: 420);

      expect(tester.takeException(), isNull);
      expect(find.byType(AuthFormPanel), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('CBV 2.0'),
        200,
        scrollable: find.byType(Scrollable),
      );

      expect(find.text('CBV 2.0'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'selection area does not double-register when the auth shell rebuilds',
    (tester) async {
      await pumpMobileAuth(tester, const Size(390, 844));
      expect(tester.takeException(), isNull);

      tester.view.physicalSize = const Size(412, 915);
      await tester.pump();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(SelectionArea), findsOneWidget);
    },
  );

  testWidgets('mobile auth remains scrollable with keyboard insets', (
    tester,
  ) async {
    const size = Size(390, 844);
    await pumpMobileAuth(tester, size);

    tester.view.viewInsets = const FakeViewPadding(bottom: 320);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(tester.takeException(), isNull);
    expect(maxScrollExtent(tester), greaterThan(0));

    await tester.scrollUntilVisible(
      find.text('CBV 2.0'),
      200,
      scrollable: find.byType(Scrollable),
    );

    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('CBV 2.0'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
