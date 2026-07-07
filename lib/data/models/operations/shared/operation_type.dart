/// Discriminator for unified [Operation] records.
enum OperationType {
  shipping,
  receiving,
  returnShipping,
  returnReceiving,
  cancelShipping,
  cancelReceiving,
  packing,
  unpacking,
  updateStatus,
  commissioning,
}
