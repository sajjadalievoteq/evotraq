import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_presenter.dart';
import 'package:traqtrace_app/data/models/epcis/transformation_event.dart';
import 'package:traqtrace_app/features/epcis/cubit/transformation_events_cubit.dart';
import 'package:traqtrace_app/features/epcis/transformation_events/screens/transformation_events_list/transformation_events_list_screen.dart';

extension TransformationEventsListActions
    on TransformationEventsListScreenState {
  Future<void> loadTransformationEvents() async {
    final cubit = context.read<TransformationEventsCubit>();

    if (filterTransformationId != null) {
      await cubit.findByTransformationId(filterTransformationId!);
    } else if (filterInputEPC != null) {
      await cubit.findByInputEPC(filterInputEPC!);
    } else if (filterOutputEPC != null) {
      await cubit.findByOutputEPC(filterOutputEPC!);
    } else {
      await cubit.loadTransformationEvents();
    }
  }

  Future<void> refreshData() async {
    await loadTransformationEvents();
  }

  void navigateToEventDetails(TransformationEvent event) {
    if (event.id != null) {
      context
          .push('/epcis/transformation-events/${event.id}', extra: event.id)
          .then((result) {
            if (result == true) {
              refreshData();
            }
          });
    } else {
      context.showInfo('Event ID is missing');
    }
  }

  void navigateToCreateEvent() {
    context.push('/epcis/transformation-events/new').then((result) {
      if (result == true) {
        refreshData();
      }
    });
  }
}
