import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/services/epcis/object_event_service.dart';
import 'package:traqtrace_app/features/epcis/cubit/object_events_cubit.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/screens/detail/object_event_detail_screen.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/screens/list/object_events_list_screen.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/object_event_form_screen.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/utilities/list/object_event_list_ui_constants.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/utilities/shared/object_event_shared_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/gs1_split_view_screen.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/split_or_list_indexed_stack.dart';

class ObjectEventScreen extends StatefulWidget {
  const ObjectEventScreen({super.key});

  @override
  State<ObjectEventScreen> createState() => _ObjectEventScreenState();
}

class _ObjectEventScreenState extends State<ObjectEventScreen> {
  late final ObjectEventsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = ObjectEventsCubit(service: getIt<ObjectEventService>());
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
        split: Gs1SplitViewScreen<ObjectEventsCubit, ObjectEventsState>(
          appBarTitle: ObjectEventSharedUiConstants.appBarManagement,
          fabHeroTag: ObjectEventSharedUiConstants.fabHeroTag,
          fabAddTooltip: ObjectEventSharedUiConstants.fabAddTooltip,
          fabCloseTooltip: ObjectEventSharedUiConstants.fabCloseTooltip,
          createHeaderText: ObjectEventSharedUiConstants.splitCreateHeader,
          closeCreateTooltip: ObjectEventSharedUiConstants.tooltipClose,
          emptyNoMatchText: ObjectEventListUiConstants.emptyNoMatchSearch,
          listenWhenListChanged: (previous, current) =>
              previous.objectEvents != current.objectEvents,
          idsFromState: (s) =>
              s.objectEvents.map((e) => e.eventId),
          createdIdFromState: (s) => s.selectedEvent?.eventId,
          isEmptyNoMatch: (s) =>
              s.status == ObjectEventsStatus.success &&
              s.objectEvents.isEmpty,
          listBuilder: (
            context, {
            required selectedId,
            required onSelect,
            required bindRefresh,
            required onRequestCreate,
          }) =>
              ObjectEventsListScreen(
                embedded: true,
                selectedEventId: selectedId,
                onSelectEvent: onSelect,
                onBindRefresh: bindRefresh,
                onEmbeddedCreate: onRequestCreate,
              ),
          detailViewBuilder: (context, id) => ObjectEventDetailScreen(
            key: ValueKey(id),
            eventId: id,
            embedded: true,
          ),
          detailCreateBuilder: (context, onSuccess) => ObjectEventFormScreen(
            key: const ValueKey('__obj_event_embedded_new__'),
            embedded: true,
            onEmbeddedActionSuccess: onSuccess,
          ),
          detailAwaitBuilder: (context) => const ObjectEventDetailScreen(
            key: ValueKey('__obj_event_split_await__'),
            embedded: true,
            awaitingListSelection: true,
          ),
        ),
        fallback: const ObjectEventsListScreen(),
      ),
    );
  }
}
