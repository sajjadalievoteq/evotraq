import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/app_loading_indicator.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/epcis/transformation_event.dart';
import 'package:traqtrace_app/features/epcis/cubit/transformation_events_cubit.dart';
import 'package:traqtrace_app/features/epcis/transformation_events/screens/transformation_events_list/widgets/transformation_event_list_item.dart';

class TransformationEventsList extends StatelessWidget {
  const TransformationEventsList({
    super.key,
    required this.scrollController,
    required this.onRefresh,
    required this.onCreateEvent,
    required this.onOpenEvent,
  });

  final ScrollController scrollController;
  final Future<void> Function() onRefresh;
  final VoidCallback onCreateEvent;
  final ValueChanged<TransformationEvent> onOpenEvent;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransformationEventsCubit, TransformationEventsState>(
      builder: (context, state) {
        if (state.isLoading && state.transformationEvents.isEmpty) {
          return const Center(child: AppLoadingIndicator());
        }

        if (state.errorMessage != null && state.transformationEvents.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TraqIcon(
                  AppAssets.iconAlert,
                  size: 48,
                  color: AppColorMapper.errorColor(context),
                ),
                const SizedBox(height: 16),
                Text('Error: ${state.errorMessage}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: onRefresh,
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        if (state.transformationEvents.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const TraqIcon(
                  AppAssets.iconTransform,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text('No transformation events found'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: onCreateEvent,
                  child: const Text('Create First Event'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView.separated(
            controller: scrollController,
            itemCount:
                state.transformationEvents.length + (state.isLoading ? 1 : 0),
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              if (index == state.transformationEvents.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: AppLoadingIndicator(),
                  ),
                );
              }

              final event = state.transformationEvents[index];
              return TransformationEventListItem(
                event: event,
                onTap: () => onOpenEvent(event),
              );
            },
          ),
        );
      },
    );
  }
}
