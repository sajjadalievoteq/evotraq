import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/home/utils/home_strings.dart';
import 'package:traqtrace_app/features/home/cubit/home_cubit.dart';
import 'package:traqtrace_app/features/home/cubit/home_state.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/compliance_posture/widgets/dashboard_health_status_row.dart';

class SystemHealthCard extends StatelessWidget {
  const SystemHealthCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (p, c) => p.healthStatus != c.healthStatus,
      builder: (context, state) {
        final health = state.healthStatus;

        return Card(

          child: Padding(
            padding: const EdgeInsets.all(Constants.spacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DashboardHealthStatusRow(
                  title: HomeStrings.healthBackend,
                  isHealthy: health?.backendHealthy ?? false,
                ),
                DashboardHealthStatusRow(
                  title: HomeStrings.healthDatabase,
                  isHealthy: health?.databaseHealthy ?? false,
                ),
                DashboardHealthStatusRow(
                  title: HomeStrings.healthCache,
                  isHealthy: health?.cacheHealthy ?? false,
                ),
                if (health?.backendVersion != null) ...[
                  const Divider(),
                  Text(
                    HomeStrings.healthVersionLine(health!.backendVersion!),
                    style: context.text.bodySm.copyWith(
                      color: context.colors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
