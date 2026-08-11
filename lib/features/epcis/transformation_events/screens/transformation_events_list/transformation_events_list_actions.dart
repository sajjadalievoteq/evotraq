part of 'transformation_events_list_screen.dart';

extension TransformationEventsListActions
    on _TransformationEventsListScreenState {
  Future<void> _loadTransformationEvents() async {
    final cubit = context.read<TransformationEventsCubit>();

    if (_filterTransformationId != null) {
      await cubit.findByTransformationId(_filterTransformationId!);
    } else if (_filterInputEPC != null) {
      await cubit.findByInputEPC(_filterInputEPC!);
    } else if (_filterOutputEPC != null) {
      await cubit.findByOutputEPC(_filterOutputEPC!);
    } else {
      await cubit.loadTransformationEvents();
    }
  }

  Future<void> _refreshData() async {
    await _loadTransformationEvents();
  }

  void _navigateToEventDetails(TransformationEvent event) {
    if (event.id != null) {
      context
          .push('/epcis/transformation-events/${event.id}', extra: event.id)
          .then((result) {
            if (result == true) {
              _refreshData();
            }
          });
    } else {
      context.showInfo('Event ID is missing');
    }
  }

  void _navigateToCreateEvent() {
    context.push('/epcis/transformation-events/new').then((result) {
      if (result == true) {
        _refreshData();
      }
    });
  }
}
