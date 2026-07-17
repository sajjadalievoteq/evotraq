enum InboxOutboxDirection {
  inbound('INBOUND'),
  outbound('OUTBOUND');

  const InboxOutboxDirection(this.apiValue);
  final String apiValue;
}
