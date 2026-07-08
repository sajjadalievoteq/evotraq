import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/models/scan_result.dart';
import 'package:traqtrace_app/data/models/product_journey/journey_step.dart';
import 'package:traqtrace_app/data/models/product_journey/product_search_result.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/master_detail_split_layout.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/split_or_list_indexed_stack.dart';
import 'package:traqtrace_app/features/product_journey/cubit/journey_cubit.dart';
import 'package:traqtrace_app/features/product_journey/screens/JourneyDashboard/widgets/journey_canvas_pane.dart';
import 'package:traqtrace_app/features/product_journey/screens/JourneyDashboard/widgets/journey_left_panel.dart';
import 'package:traqtrace_app/features/product_journey/screens/JourneyDashboard/widgets/journey_mobile_layout.dart';
import 'package:traqtrace_app/features/product_journey/screens/JourneyDetails/widgets/journey_step_detail_sheet.dart';

class JourneyDashboardBody extends StatefulWidget {
  const JourneyDashboardBody({super.key, this.initialEpc});

  final String? initialEpc;

  @override
  State<JourneyDashboardBody> createState() => _JourneyDashboardBodyState();
}

class _JourneyDashboardBodyState extends State<JourneyDashboardBody> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final epc = widget.initialEpc;
    if (epc != null && epc.isNotEmpty) _searchController.text = epc;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      context.read<JourneyCubit>().searchSuggestions(value);
    });
    setState(() {});
  }

  void _onSearchSubmitted(String value) {
    if (value.trim().isEmpty) return;
    context.read<JourneyCubit>().clearSuggestions();
    context.read<JourneyCubit>().search(value.trim());
  }

  void _onClearSearch() {
    _searchController.clear();
    context.read<JourneyCubit>().clear();
    setState(() {});
  }

  void _onSuggestionTap(ProductSearchResult result) {
    _searchController.text = result.displayName;
    context.read<JourneyCubit>().clearSuggestions();
    context.read<JourneyCubit>().search(result.identifier);
    setState(() {});
  }

  void _onScanResult(ScanResult result) {
    if (!result.isValid) return;
    final value = result.data;
    _searchController.text = value;
    context.read<JourneyCubit>().clearSuggestions();
    context.read<JourneyCubit>().search(value);
    setState(() {});
  }

  void _onStepTapped(JourneyStep step) {
    context.read<JourneyCubit>().selectStep(step);
    JourneyStepDetailSheet.show(context, step);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JourneyCubit, JourneyState>(
      builder: (context, state) => SplitOrListIndexedStack(
        split: MasterDetailSplitLayout(
          narrowListFlex: 22,
          wideListFlex: 30,
          list: JourneyLeftPanel(
            state: state,
            searchController: _searchController,
            onSearchChanged: _onSearchChanged,
            onSearchSubmitted: _onSearchSubmitted,
            onClearSearch: _onClearSearch,
            onSuggestionTap: _onSuggestionTap,
            onRetry: () => _onSearchSubmitted(_searchController.text),
            onScanResult: _onScanResult,
          ),
          detail: JourneyCanvasPane(
            state: state,
            onStepTapped: _onStepTapped,
          ),
        ),
        fallback: JourneyMobileLayout(
          state: state,
          searchController: _searchController,
          onSearchChanged: _onSearchChanged,
          onSearchSubmitted: _onSearchSubmitted,
          onClearSearch: _onClearSearch,
          onSuggestionTap: _onSuggestionTap,
          onRetry: () => _onSearchSubmitted(_searchController.text),
          onStepTapped: _onStepTapped,
          onScanResult: _onScanResult,
        ),
      ),
    );
  }
}
