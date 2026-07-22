import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/inbox_outbox/screens/inbox_outbox/widgets/inbox_outbox_split_list_body.dart';

class InboxOutboxSplitList extends StatelessWidget {
  const InboxOutboxSplitList({
    super.key,
    this.embedded = false,
    this.onSelectOperation,
    this.selectedOperationId,
    this.onBindRefresh,
    this.emptyIconAsset,
  });

  final bool embedded;
  final ValueChanged<String>? onSelectOperation;
  final String? selectedOperationId;
  final void Function(VoidCallback refreshFn)? onBindRefresh;
  final String? emptyIconAsset;

  @override
  Widget build(BuildContext context) {
    return InboxOutboxSplitListBody(
      embedded: embedded,
      onSelectOperation: onSelectOperation,
      selectedOperationId: selectedOperationId,
      onBindRefresh: onBindRefresh,
      emptyIconAsset: emptyIconAsset,
    );
  }
}
