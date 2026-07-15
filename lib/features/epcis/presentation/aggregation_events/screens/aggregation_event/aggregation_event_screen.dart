import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/services/epcis/aggregation_event_service.dart';
import 'package:traqtrace_app/features/epcis/cubit/aggregation_events_cubit.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/aggregation_event_form_screen.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_detail/aggregation_event_detail_screen.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_events_list/aggregation_events_list_screen.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/utils/aggregation_event_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/gs1_split_view_screen.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/split_or_list_indexed_stack.dart';

import '../../../../cubit/cbv_vocabulary_cubit.dart';

class AggregationEventScreen extends StatefulWidget {
  const AggregationEventScreen({super.key});

  @override
  State<AggregationEventScreen> createState() =>
      _AggregationEventScreenState();
}

class _AggregationEventScreenState extends State<AggregationEventScreen> {
  late final AggregationEventsCubit _cubit;

  @override
  void initState() {
    super.initState();
    context.read<CbvVocabularyCubit>().loadVocabulary();
    _cubit = AggregationEventsCubit(
      service: getIt<AggregationEventService>(),
    );
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: SplitOrListIndexedStack(
        split: Gs1SplitViewScreen<AggregationEventsCubit, AggregationEventsState>(
          appBarTitle: AggregationEventUiConstants.appBarManagement,
          fabHeroTag: AggregationEventUiConstants.fabHeroTag,
          fabAddTooltip: AggregationEventUiConstants.fabAddTooltip,
          fabCloseTooltip: AggregationEventUiConstants.fabCloseTooltip,
          createHeaderText: AggregationEventUiConstants.splitCreateHeader,
          closeCreateTooltip: AggregationEventUiConstants.tooltipClose,
          emptyNoMatchText:
              AggregationEventUiConstants.emptyNoMatchSearch,
          listenWhenListChanged: (previous, current) =>
              previous.aggregationEvents != current.aggregationEvents,
          idsFromState: (s) => s.aggregationEvents
              .map((e) => e.eventId)
              .where((id) => id.isNotEmpty),
          createdIdFromState: (s) => s.selectedEvent?.eventId,
          isEmptyNoMatch: (s) =>
              s.status == AggregationEventsStatus.success &&
              s.aggregationEvents.isEmpty,
          listBuilder: (
            context, {
            required selectedId,
            required onSelect,
            required bindRefresh,
            required onRequestCreate,
          }) =>
              AggregationEventsListScreen(
                embedded: true,
                selectedEventId: selectedId,
                onSelectEvent: onSelect,
                onBindRefresh: bindRefresh,
                onEmbeddedCreate: onRequestCreate,
              ),
          detailViewBuilder: (context, id) => AggregationEventDetailScreen(
            key: ValueKey(id),
            eventId: id,
            embedded: true,
          ),
          detailCreateBuilder: (context, onSuccess) =>
              AggregationEventFormScreen(
                key: const ValueKey('__agg_event_embedded_new__'),
                embedded: true,
                onEmbeddedActionSuccess: onSuccess,
              ),
          detailAwaitBuilder: (context, {required listLoading}) => const AggregationEventDetailScreen(
            key: ValueKey('__agg_event_split_await__'),
            embedded: true,
            awaitingListSelection: true,
          ),
        ),
        fallback: const AggregationEventsListScreen(),
      ),
    );
  }
}
