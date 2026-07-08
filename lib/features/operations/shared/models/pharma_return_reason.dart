enum PharmaReturnReason {
  damaged('DAMAGED', 'Damaged'),
  expired('EXPIRED', 'Expired'),
  recalled('RECALLED', 'Recalled'),
  wrongDelivery('WRONG_DELIVERY', 'Wrong delivery'),
  customerRejection('CUSTOMER_REJECTION', 'Customer rejection');

  const PharmaReturnReason(this.code, this.label);

  final String code;
  final String label;

  static PharmaReturnReason? fromCode(String? value) {
    if (value == null || value.isEmpty) return null;
    final normalized = value.trim().toUpperCase();
    for (final reason in PharmaReturnReason.values) {
      if (reason.code == normalized) return reason;
    }
    return null;
  }
}
