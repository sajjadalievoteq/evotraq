enum InboxOutboxListFilter {
  all('All'),
  inbox('Inbox'),
  outbox('Outbox');

  const InboxOutboxListFilter(this.label);

  final String label;
}
