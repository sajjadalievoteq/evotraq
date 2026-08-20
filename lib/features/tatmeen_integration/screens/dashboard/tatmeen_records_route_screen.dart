import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/layout/app_layout_data.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_records_models.dart';
import 'package:traqtrace_app/features/tatmeen_integration/screens/dashboard/tatmeen_records_screen.dart';

class TatmeenRecordsRouteScreen extends StatelessWidget {
  const TatmeenRecordsRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.layout.isDesktopUp) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.go(Constants.tatmeenIntegrationRoute);
        }
      });
      return const SizedBox.shrink();
    }
    final extra = GoRouterState.of(context).extra;
    return TatmeenRecordsScreen(filter: RecordsFilter.fromExtra(extra));
  }
}
