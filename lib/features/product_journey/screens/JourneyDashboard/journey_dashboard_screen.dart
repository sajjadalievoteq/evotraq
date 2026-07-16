import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';
import 'package:traqtrace_app/data/services/home/dashboard_service.dart';
import 'package:traqtrace_app/data/services/product_journey/product_journey_service.dart';
import 'package:traqtrace_app/features/product_journey/cubit/journey_cubit.dart';
import 'package:traqtrace_app/features/product_journey/screens/JourneyDashboard/widgets/journey_dashboard_body.dart';

class JourneyDashboardScreen extends StatelessWidget {
  const JourneyDashboardScreen({super.key, this.initialEpc});

  final String? initialEpc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = JourneyCubit(
          service: getIt<ProductJourneyService>(),
          dashboardService: getIt<DashboardService>(),
        );
        final epc = initialEpc;
        if (epc != null && epc.isNotEmpty) {
          cubit.maybeSearch(epc);
        } else {
          cubit.loadRecentEvents();
        }
        return cubit;
      },
      child: Scaffold(
        appBar: TraqAppBar(
          context,
          title: const Text('Product Journey Tracker'),
        ),
        drawer: const AppDrawer(),
        body: JourneyDashboardBody(initialEpc: initialEpc),
      ),
    );
  }
}
