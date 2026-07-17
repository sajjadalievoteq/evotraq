import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/inbox_outbox/screens/inbox_outbox_split_list.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation_entry_screen.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation_detail/shipping_operation_detail_screen.dart';

class InboxOutboxScreen extends StatelessWidget {
  const InboxOutboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OperationEntryScreen(
      appBarTitle: 'Inbox / Outbox',
      fabHeroTag: 'inbox_outbox_fab',
      fabAddTooltip: 'Set operational location in Profile',
      createHeaderText: 'Operational Location',
      emptyNoMatchText: 'No in-transit shipments match your search or filter.',
      fabNavigateRoute: Constants.profileRoute,
      listBuilder: (context, {
        required selectedId,
        required onSelect,
        required bindRefresh,
        required onRequestCreate,
      }) =>
          InboxOutboxSplitList(
        embedded: true,
        selectedOperationId: selectedId,
        onSelectOperation: onSelect,
        onBindRefresh: bindRefresh,
      ),
      detailViewBuilder: (context, id) => ShippingOperationDetailScreen(
        key: ValueKey('inbox_outbox_$id'),
        operationId: id,
        embedded: true,
      ),
      detailAwaitBuilder: (context, {required listLoading}) =>
          ShippingOperationDetailScreen(
        key: const ValueKey('inbox_outbox_await'),
        embedded: true,
        listLoading: listLoading,
        awaitingSelection: true,
      ),
      fallbackList: const InboxOutboxSplitList(
        emptyIconAsset: NavIcons.inboxOutbox,
      ),
      showFloatingActionButton: false,
    );
  }
}
