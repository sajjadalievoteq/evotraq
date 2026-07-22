import 'package:traqtrace_app/data/models/inbox_outbox/inbox_outbox_list_filter.dart';

String inboxOutboxEmptyTitle(InboxOutboxListFilter filter) {
  return switch (filter) {
    InboxOutboxListFilter.all => 'No in-transit shipments',
    InboxOutboxListFilter.inbox => 'No inbound shipments in transit',
    InboxOutboxListFilter.outbox => 'No outbound shipments in transit',
  };
}

String inboxOutboxEmptySubtitle(InboxOutboxListFilter filter) {
  return switch (filter) {
    InboxOutboxListFilter.all => 'Open shipments to or from your operational location appear here.',
    InboxOutboxListFilter.inbox => 'Shipments addressed to your location appear here until received.',
    InboxOutboxListFilter.outbox =>
      'Shipments you sent appear here until the destination receives them.',
  };
}
