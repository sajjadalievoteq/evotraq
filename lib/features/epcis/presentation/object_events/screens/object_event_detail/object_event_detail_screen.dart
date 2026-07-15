import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/widgets/empty_state/app_empty_detail.dart';
import 'package:traqtrace_app/data/models/epcis/object_event.dart';
import 'package:traqtrace_app/features/epcis/cubit/object_events_cubit.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_detail/utils/object_event_detail_ui_constants.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_detail/widgets/object_event_detail_content.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_detail/widgets/object_event_detail_not_found_pane.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_detail/widgets/skeleton/object_event_detail_skeleton.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_events_list/utils/object_event_list_ui_constants.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/utils/object_event_shared_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_master_data_detail_scaffold.dart';

class ObjectEventDetailScreen extends StatefulWidget {
  const ObjectEventDetailScreen({
    super.key,
    this.eventId,
    this.embedded = false,
    this.awaitingListSelection = false,
    this.onEmbeddedActionSuccess,
  });

  final String? eventId;
  final bool embedded;
  final bool awaitingListSelection;
  final VoidCallback? onEmbeddedActionSuccess;

  @override
  State<ObjectEventDetailScreen> createState() =>
      _ObjectEventDetailScreenState();
}

class _ObjectEventDetailScreenState extends State<ObjectEventDetailScreen> {
  ObjectEvent? _event;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.eventId != null) _load();
  }

  @override
  void didUpdateWidget(covariant ObjectEventDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.eventId != widget.eventId && widget.eventId != null) {
      _load();
    }
  }

  Future<void> _load() async {
    if (widget.eventId == null) return;
    setState(() {
      _loading = true;
      _event = null;
    });
    try {
      final event = await context
          .read<ObjectEventsCubit>()
          .getObjectEventById(widget.eventId!);
      if (mounted) setState(() => _event = event);
    } catch (e) {
      if (mounted) {
        context.showError(
          '${ObjectEventDetailUiConstants.detailLoadFailedPrefix} $e',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.awaitingListSelection) {
      return BlocBuilder<ObjectEventsCubit, ObjectEventsState>(
        buildWhen: (prev, curr) =>
            prev.isListLoading != curr.isListLoading ||
            prev.status != curr.status,
        builder: (context, state) {
          final listLoading = state.isListLoading ||
              state.status == ObjectEventsStatus.initial;
          final body = listLoading
              ? const ObjectEventDetailSkeleton()
              : AppEmptyDetail(
                  title: ObjectEventListUiConstants.awaitingSelectionTitle,
                  subtitle: ObjectEventDetailUiConstants.detailAwaitingHint,
                  iconAsset: NavIcons.objectEvents,
                );
          return Gs1MasterDataDetailScaffold(
            embedded: widget.embedded,
            title: ObjectEventSharedUiConstants.appBarManagement,
            body: body,
          );
        },
      );
    }

    Widget body;
    if (_loading) {
      body = const ObjectEventDetailSkeleton();
    } else if (_event == null) {
      body = ObjectEventDetailNotFoundPane(onRetry: _load);
    } else {
      body = ObjectEventDetailContent(event: _event!);
    }

    return Gs1MasterDataDetailScaffold(
      embedded: widget.embedded,
      title: _event == null
          ? ObjectEventSharedUiConstants.appBarManagement
          : ObjectEventDetailUiConstants.detailTitle,
      body: body,
    );
  }
}
