import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/home/presentation/cubit/home_dashboard_cubit.dart';
import 'package:traqtrace_app/features/home/presentation/cubit/home_dashboard_state.dart';
import 'package:traqtrace_app/features/home/presentation/widgets/compliance_posture/widgets/dashboard_health_status_row.dart';

class SystemHealthCard extends StatelessWidget {
  const SystemHealthCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeDashboardCubit, HomeDashboardState>(
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
                  title: 'Backend API',
                  isHealthy: health?.backendHealthy ?? false,
                ),
                DashboardHealthStatusRow(
                  title: 'Database',
                  isHealthy: health?.databaseHealthy ?? false,
                ),
                DashboardHealthStatusRow(
                  title: 'Cache',
                  isHealthy: health?.cacheHealthy ?? false,
                ),
                if (health?.backendVersion != null) ...[
                  const Divider(),
                  Text(
                    'Version: ${health!.backendVersion}',
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
