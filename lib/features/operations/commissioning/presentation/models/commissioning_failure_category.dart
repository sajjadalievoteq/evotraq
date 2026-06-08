/// High-level failure categories for commissioning item errors.
enum CommissioningFailureCategory {
  duplicateSerial,
  alreadyCommissioned,
  invalidSerial,
  validation,
  epcis,
  other,
}
