import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';
import 'package:traqtrace_app/data/models/product_journey/journey_step.dart';
import 'package:traqtrace_app/data/models/product_journey/product_search_result.dart';
import 'package:traqtrace_app/data/services/product_journey/product_journey_service.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/master_detail_split_layout.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/split_or_list_indexed_stack.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/list/operation_list_error_view.dart';
import 'package:traqtrace_app/features/product_journey/cubit/journey_cubit.dart';
import 'package:traqtrace_app/features/product_journey/screens/journey/widgets/journey_empty_state.dart';
import 'package:traqtrace_app/features/product_journey/screens/journey/widgets/journey_left_panel.dart';
import 'package:traqtrace_app/features/product_journey/screens/journey/widgets/journey_pin_canvas.dart';
import 'package:traqtrace_app/features/product_journey/screens/journey/widgets/journey_product_details_content.dart';
import 'package:traqtrace_app/features/product_journey/screens/journey/widgets/journey_search_bar.dart';
import 'package:traqtrace_app/features/product_journey/screens/journey/widgets/journey_step_detail_sheet.dart';
import 'package:traqtrace_app/features/product_journey/screens/journey/widgets/journey_suggestions_dropdown.dart';

class JourneyScreen extends StatefulWidget {
  const JourneyScreen({super.key, this.initialEpc});

  final String? initialEpc;

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => JourneyCubit(service: getIt<ProductJourneyService>())
        ..maybeSearch(widget.initialEpc),
      child: _JourneyBody(initialEpc: widget.initialEpc),
    );
  }
}

class _JourneyBody extends StatefulWidget {
  const _JourneyBody({this.initialEpc});

  final String? initialEpc;

  @override
  State<_JourneyBody> createState() => _JourneyBodyState();
}

class _JourneyBodyState extends State<_JourneyBody> {
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

  void _onStepTapped(JourneyStep step) {
    context.read<JourneyCubit>().selectStep(step);
    JourneyStepDetailSheet.show(context, step);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TraqAppBar(context, title: const Text('Product Journey Tracker')),
      drawer: const AppDrawer(),
      body: BlocBuilder<JourneyCubit, JourneyState>(
        builder: (context, state) => SplitOrListIndexedStack(
          split: MasterDetailSplitLayout(
            narrowListFlex: 34,
            wideListFlex: 28,
            list: JourneyLeftPanel(
              state: state,
              searchController: _searchController,
              onSearchChanged: _onSearchChanged,
              onSearchSubmitted: _onSearchSubmitted,
              onClearSearch: _onClearSearch,
              onSuggestionTap: _onSuggestionTap,
              onRetry: () => _onSearchSubmitted(_searchController.text),
            ),
            detail: _buildCanvasPane(context, state),
          ),
          fallback: _buildMobile(context, state),
        ),
      ),
    );
  }

  Widget _buildCanvasPane(BuildContext context, JourneyState state) {
    final c = context.colors;

    if (state.isLoaded && state.journey != null) {
      return JourneyPinsCanvas(
        journey: state.journey!,
        selectedStep: state.selectedStep,
        onStepTapped: _onStepTapped,
      );
    }

    return Stack(
      children: [
        if (state.isLoading)
          Positioned.fill(
            child: ColoredBox(
              color: c.background.withValues(alpha: 0.65),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
        if (!state.isLoading && !state.hasError && state.journey == null)
          const Center(child: JourneyEmptyState()),
      ],
    );
  }

  Widget _buildMobile(BuildContext context, JourneyState state) {
    final c = context.colors;
    return Stack(
      children: [
        if (state.isLoaded && state.journey != null)
          Positioned.fill(
            child: JourneyPinsCanvas(
              journey: state.journey!,
              selectedStep: state.selectedStep,
              onStepTapped: _onStepTapped,
            ),
          ),
        Positioned(
          top: 8,
          left: 16,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListenableBuilder(
                listenable: _searchController,
                builder: (context, _) => JourneySearchBar(
                  controller: _searchController,
                  onSubmitted: _onSearchSubmitted,
                  onChanged: _onSearchChanged,
                  isSearching: state.isSearching,
                  onClear: _onClearSearch,
                ),
              ),
              if (state.searchResults.isNotEmpty)
                JourneySuggestionsDropdown(
                  results: state.searchResults,
                  onTap: _onSuggestionTap,
                ),
            ],
          ),
        ),
        if (state.isLoading)
          Positioned.fill(
            child: ColoredBox(
              color: c.background.withValues(alpha: 0.65),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
        if (state.isLoaded && state.journey != null)
          DraggableScrollableSheet(
            initialChildSize: 0.18,
            minChildSize: 0.10,
            maxChildSize: 0.75,
            builder: (context, scrollController) => DecoratedBox(
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                border: Border(top: BorderSide(color: c.border)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: c.borderVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      child: JourneyProductDetailsContent(
                        journey: state.journey!,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (!state.isLoaded && !state.isLoading)
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.45,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: state.hasError
                      ? OperationListErrorView(
                          errorMessage: state.errorMessage ?? 'Unknown error',
                          onRetry: () =>
                              _onSearchSubmitted(_searchController.text),
                        )
                      : const JourneyEmptyState(),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
