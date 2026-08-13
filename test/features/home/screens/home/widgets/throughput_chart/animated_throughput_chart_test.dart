import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/data/models/auth/user.dart';
import 'package:traqtrace_app/data/models/home/dashboard_stats.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/features/home/cubit/home_cubit.dart';
import 'package:traqtrace_app/features/home/cubit/home_state.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/throughput_chart/widgets/animated_throughput_chart.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/throughput_chart/widgets/throughput_bar_chart.dart';

class _MockHomeCubit extends MockCubit<HomeState> implements HomeCubit {}

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  const labels8 = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
  const values8 = [10.0, 20.0, 14.0, 40.0, 18.0, 32.0, 12.0, 28.0];

  Widget chartHost({
    required List<double> values,
    required bool loading,
    bool reduceMotion = false,
    List<String> labels = labels8,
  }) {
    return MaterialApp(
      theme: TraqTheme.light(),
      builder: (context, child) {
        if (!reduceMotion) return child!;
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        );
      },
      home: Scaffold(
        body: SizedBox(
          width: 640,
          height: 280,
          child: AnimatedThroughputChart(
            values: values,
            labels: labels,
            loading: loading,
          ),
        ),
      ),
    );
  }

  AnimatedThroughputChartState chartState(WidgetTester tester) {
    return tester.state<AnimatedThroughputChartState>(
      find.byType(AnimatedThroughputChart),
    );
  }

  testWidgets('loading state paints bars and has no circular indicator', (
    tester,
  ) async {
    await tester.pumpWidget(chartHost(values: values8, loading: true));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byKey(AnimatedThroughputChart.barsKey), findsOneWidget);
  });

  testWidgets('loaded zero throughput keeps a calm chart', (tester) async {
    await tester.pumpWidget(
      chartHost(values: List<double>.filled(8, 0), loading: false),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byKey(AnimatedThroughputChart.barsKey), findsOneWidget);
  });

  testWidgets('loading to loaded morph keeps the bar visualization', (
    tester,
  ) async {
    await tester.pumpWidget(chartHost(values: values8, loading: true));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.pumpWidget(chartHost(values: values8, loading: false));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byKey(AnimatedThroughputChart.barsKey), findsOneWidget);
  });

  testWidgets('reduced motion snaps without replaying continuous motion', (
    tester,
  ) async {
    await tester.pumpWidget(
      chartHost(values: values8, loading: true, reduceMotion: true),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byKey(AnimatedThroughputChart.barsKey), findsOneWidget);
    expect(chartState(tester).morphRunCount, 0);
  });

  testWidgets('ordinary rebuilds do not replay the entrance', (tester) async {
    await tester.pumpWidget(chartHost(values: values8, loading: false));
    await tester.pump();
    expect(chartState(tester).morphRunCount, 1);

    await tester.pumpWidget(chartHost(values: values8, loading: false));
    await tester.pump();
    expect(chartState(tester).morphRunCount, 1);
  });

  testWidgets('subsequent value updates morph without a new entrance replay', (
    tester,
  ) async {
    await tester.pumpWidget(chartHost(values: values8, loading: false));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(chartState(tester).morphRunCount, 1);

    await tester.pumpWidget(
      chartHost(values: [4, 8, 6, 12, 5, 9, 3, 11], loading: false),
    );
    await tester.pump();

    expect(chartState(tester).morphRunCount, 2);
  });

  group('ThroughputBarChart', () {
    late _MockHomeCubit homeCubit;
    late _MockAuthCubit authCubit;

    DashboardStats stats({int total = 1284, Map<int, int>? buckets}) {
      return DashboardStats(
        gtinCount: 0,
        glnCount: 0,
        sgtinCount: 0,
        ssccCount: 0,
        totalEvents: 0,
        eventsByType: const {},
        throughputTotal: total,
        throughputBuckets: buckets ?? {0: 12, 1: 40, 2: 18},
      );
    }

    AuthState adminAuth() {
      return AuthState(
        status: AuthStatus.authenticated,
        user: User(
          id: 1,
          username: 'admin',
          email: 'admin@example.com',
          firstName: 'A',
          lastName: 'D',
          role: 'ADMIN',
          enabled: true,
        ),
        token: 't',
        bootstrapCompleted: true,
      );
    }

    Future<void> pumpChart(
      WidgetTester tester, {
      required HomeState homeState,
      bool reduceMotion = false,
    }) async {
      homeCubit = _MockHomeCubit();
      authCubit = _MockAuthCubit();
      final authState = adminAuth();
      whenListen(homeCubit, Stream<HomeState>.empty(), initialState: homeState);
      whenListen(authCubit, Stream<AuthState>.empty(), initialState: authState);
      when(() => homeCubit.state).thenReturn(homeState);
      when(() => authCubit.state).thenReturn(authState);

      await tester.pumpWidget(
        MaterialApp(
          theme: TraqTheme.light(),
          builder: (context, child) {
            if (!reduceMotion) return child!;
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: child!,
            );
          },
          home: MultiBlocProvider(
            providers: [
              BlocProvider<HomeCubit>.value(value: homeCubit),
              BlocProvider<AuthCubit>.value(value: authCubit),
            ],
            child: const Scaffold(
              body: SizedBox(
                width: 800,
                height: 400,
                child: ThroughputBarChart(),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('loading keeps the bar chart and hides the spinner', (
      tester,
    ) async {
      await pumpChart(
        tester,
        homeState: HomeState(
          status: HomeLoadStatus.success,
          stats: stats(),
          throughputLoading: true,
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(AnimatedThroughputChart), findsOneWidget);
    });

    testWidgets('loaded state shows the real throughput total', (tester) async {
      await pumpChart(
        tester,
        homeState: HomeState(
          status: HomeLoadStatus.success,
          stats: stats(total: 1284),
        ),
        reduceMotion: true,
      );

      final formatted = NumberFormat.decimalPattern().format(1284);
      expect(find.text(formatted), findsOneWidget);
    });

    testWidgets('zero throughput still shows the formatted zero total', (
      tester,
    ) async {
      await pumpChart(
        tester,
        homeState: HomeState(
          status: HomeLoadStatus.success,
          stats: stats(total: 0, buckets: const {}),
        ),
        reduceMotion: true,
      );

      expect(find.text('0'), findsWidgets);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byKey(AnimatedThroughputChart.barsKey), findsOneWidget);
    });
  });
}
