import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/features/epcis/cubit/object_events_cubit.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_events_list/utils/object_event_list_ui_constants.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';
import 'package:world_countries/world_countries.dart';

class ObjectEventRecordInfoSection extends StatelessWidget {
  const ObjectEventRecordInfoSection({
    super.key,
    required this.pageSize,
    required this.onPageSizeChanged,
  });

  final int pageSize;
  final ValueChanged<int> onPageSizeChanged;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ObjectEventsCubit, ObjectEventsState>(
      buildWhen: (prev, curr) =>
          prev.objectEvents.length != curr.objectEvents.length ||
          prev.isListLoading != curr.isListLoading,
      builder: (context, state) {
        return AppLayoutBuilder(
builder: (context, layout) {
          return
Card(

            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: layout.resolve(compact: 12.0, medium: 16.0),
                vertical: layout.resolve(compact: 10.0, medium: 8.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      state.isListLoading
                          ? 'Loading…'
                          : '${state.objectEvents.length} ${ObjectEventListUiConstants.entityPluralEvents}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  DropdownButton<int>(
                    value: pageSize,
                    isDense: true,
                    underline: const SizedBox(),
                    items: ObjectEventListUiConstants.pageSizeOptions
                        .map((n) => DropdownMenuItem(
                              value: n,
                              child: Text('$n / page',
                                  style: Theme.of(context).textTheme.bodySmall),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) onPageSizeChanged(v);
                    },
                  ),
                ],
              ),
            ),
);
      },);}
    );
  }
}
