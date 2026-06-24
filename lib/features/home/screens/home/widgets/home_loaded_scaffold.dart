import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';
import 'package:traqtrace_app/features/home/cubit/home_cubit.dart';
import 'package:traqtrace_app/features/home/cubit/home_state.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/home_scroll_body.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/loading/dashboard_loader.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/shared/home_error_view.dart';
import 'package:traqtrace_app/features/home/utils/home_strings.dart';

class HomeLoadedScaffold extends StatelessWidget {
  const HomeLoadedScaffold({super.key, required this.userEmail});

  final String userEmail;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: TraqAppBar(
        context,
        title: Text(
          HomeStrings.appBarTitle,
          style: context.text.body.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, homeState) {
          return RefreshIndicator(
            onRefresh: () {
              return context.read<HomeCubit>().refresh(accountEmail: userEmail);
            },
            child: homeState.isLoading
                ? const DashboardLoader()
                : homeState.hasError
                    ? HomeErrorView(
                        message:
                            homeState.errorMessage ?? HomeStrings.unknownError,
                      )
                    : const HomeScrollBody(),
          );
        },
      ),
    );
  }
}
