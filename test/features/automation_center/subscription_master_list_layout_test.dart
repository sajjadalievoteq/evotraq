import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/data/models/automation_center/notification_subscription.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_cubit.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_state.dart';
import 'package:traqtrace_app/features/automation_center/screens/notification_center/notification_center_screen.dart';
import 'package:traqtrace_app/features/automation_center/screens/subscription_management/subscription_management_screen.dart';
import 'package:traqtrace_app/features/automation_center/screens/subscription_management/widgets/subscription_master_list.dart';

class _MockNotificationCubit extends MockCubit<NotificationState>
    implements NotificationCubit {}

void main() {
  testWidgets('embedded master list supports intrinsic desktop layout', (
    tester,
  ) async {
    final subscriptions = List.generate(
      2,
      (index) => NotificationSubscription(
        id: 'subscription-$index',
        subscriptionName: 'Subscription $index',
        webhookUrl: 'https://example.com/$index',
        status: 'ACTIVE',
        subscriptionType: 'BATCH',
        createdAt: DateTime.utc(2026),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: TraqTheme.light(),
        home: Scaffold(
          body: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 360,
                  child: SubscriptionMasterList(
                    subscriptions: subscriptions,
                    selectedId: subscriptions.first.id,
                    onSelected: (_) {},
                    shrinkWrap: true,
                  ),
                ),
                const Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Subscription 0'), findsOneWidget);
    expect(find.text('Subscription 1'), findsOneWidget);
    expect(find.byType(ListView), findsNothing);
  });

  testWidgets(
    'automation subscription screen supports one outer panel scroll',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final subscription = NotificationSubscription(
        id: 'subscription-1',
        subscriptionName: 'Production alerts',
        webhookUrl: 'https://example.com/hook',
        status: 'ACTIVE',
        subscriptionType: 'BATCH',
        createdAt: DateTime.utc(2026),
      );
      final cubit = _MockNotificationCubit();
      whenListen(
        cubit,
        const Stream<NotificationState>.empty(),
        initialState: NotificationState(
          status: NotificationStatus.success,
          subscriptions: [subscription],
        ),
      );
      when(
        () => cubit.loadSubscriptions(force: any(named: 'force')),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(
        MaterialApp(
          theme: TraqTheme.light(),
          home: BlocProvider<NotificationCubit>.value(
            value: cubit,
            child: Scaffold(
              body: SizedBox(
                width: 1200,
                height: 700,
                child: ListView(children: [SubscriptionManagementScreen()]),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Production alerts'), findsWidgets);
      expect(find.text('Delivery'), findsWidgets);
      expect(find.text('Status'), findsWidgets);
      expect(find.byType(SubscriptionManagementScreen), findsOneWidget);
    },
  );

  testWidgets('activity loading state supports one outer panel scroll', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final cubit = _MockNotificationCubit();
    whenListen(
      cubit,
      const Stream<NotificationState>.empty(),
      initialState: const NotificationState(
        status: NotificationStatus.success,
        deliveryActivityLoading: true,
      ),
    );
    when(
      () => cubit.loadDeliveryActivity(
        outcome: any(named: 'outcome'),
        forceSubscriptions: any(named: 'forceSubscriptions'),
      ),
    ).thenAnswer((_) async {});
    when(() => cubit.loadFailedBatches()).thenAnswer((_) async {});

    await tester.pumpWidget(
      MaterialApp(
        theme: TraqTheme.light(),
        home: BlocProvider<NotificationCubit>.value(
          value: cubit,
          child: Scaffold(
            body: SizedBox(
              width: 1200,
              height: 700,
              child: ListView(children: [NotificationCenterScreen()]),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(NotificationCenterScreen), findsOneWidget);
  });
}
