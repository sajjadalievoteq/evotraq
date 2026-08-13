import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/animation/traq_animation_manager.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/auth/utils/auth_role_context.dart';
import 'package:traqtrace_app/features/home/utils/home_strings.dart';
import 'package:traqtrace_app/features/home/cubit/home_cubit.dart';
import 'package:traqtrace_app/features/home/cubit/home_state.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/throughput_chart/widgets/animated_throughput_chart.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/throughput_chart/widgets/animated_throughput_total.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/throughput_chart/widgets/throughput_range_toggle.dart';

class ThroughputBarChart extends StatelessWidget {
  const ThroughputBarChart({super.key});

  static int rangeIndexForHours(int hours) {
    return switch (hours) {
      1 => 0,
      168 => 2,
      _ => 1,
    };
  }

  static int hoursForRangeIndex(int index) {
    return const [1, 24, 168][index];
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (p, c) =>
          p.stats != c.stats ||
          p.throughputLoading != c.throughputLoading ||
          p.throughputHours != c.throughputHours,
      builder: (context, state) {
        final buckets = state.stats?.throughputBuckets ?? {};
        final realTotal = state.stats?.throughputTotal ?? 0;
        final rangeIndex = rangeIndexForHours(state.throughputHours);

        final List<double> bars;
        final List<String> barLabels;
        if (rangeIndex == 0) {
          bars = [(buckets[0] ?? 0).toDouble()];
          barLabels = [HomeStrings.chartNow];
        } else if (rangeIndex == 2) {
          bars = List.generate(7, (day) {
            var sum = 0;
            for (var h = 0; h < 24; h++) {
              sum += buckets[day * 24 + h] ?? 0;
            }
            return sum.toDouble();
          });
          barLabels = List.generate(7, (i) {
            final daysAgo = 6 - i;
            if (daysAgo == 0) return 'Today';
            return DateFormat(
              'EEE',
            ).format(DateTime.now().subtract(Duration(days: daysAgo)));
          });
        } else {
          final nowHour = DateTime.now().hour;
          bars = List.generate(24, (i) => (buckets[i] ?? 0).toDouble());
          barLabels = List.generate(
            24,
            (i) => '${(nowHour - 23 + i + 24) % 24}:00',
          );
        }

        final reduceMotion =
            TraqAnimationManager.reduceMotion(context) ||
            MediaQuery.disableAnimationsOf(context);
        final secondary = context.colors.textSecondary;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedThroughputTotal(
                        value: realTotal,
                        reduceMotion: reduceMotion,
                        style: context.text.h1.copyWith(
                          fontSize: 36,
                          height: 1.05,
                          letterSpacing: -0.5,
                          color: context.colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: TraqSpacing.xs),
                      Text(
                        HomeStrings.chartUnitsSerialized,
                        style: context.text.bodySm.copyWith(color: secondary),
                      ),
                    ],
                  ),
                ),
                if (context.canReadThroughput)
                  ThroughputRangeToggle(
                    selectedIndex: rangeIndex,
                    onChanged: (i) {
                      context.read<HomeCubit>().selectThroughputHours(
                        hoursForRangeIndex(i),
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: TraqSpacing.lg),
            Expanded(
              child: AnimatedThroughputChart(
                values: bars,
                labels: barLabels,
                loading: state.throughputLoading,
                rangeIndex: rangeIndex,
              ),
            ),
          ],
        );
      },
    );
  }
}
