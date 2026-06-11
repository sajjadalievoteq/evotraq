import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/data/models/epcis/object_event.dart';
import 'package:traqtrace_app/features/epcis/cubit/object_events_cubit.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/utilities/detail/object_event_detail_ui_constants.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/widgets/detail/object_event_detail_awaiting_pane.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/widgets/detail/object_event_detail_content.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/widgets/detail/object_event_detail_not_found_pane.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/widgets/detail/skeleton/object_event_detail_skeleton.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/utilities/shared/object_event_shared_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_master_data_detail_scaffold.dart';
import 'package:traqtrace_app/shared/widgets/custom_snackbar_widget.dart';

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
    Widget body;

    if (widget.awaitingListSelection) {
      body = const ObjectEventDetailAwaitingPane();
    } else if (_loading) {
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
