/// GS1 CBV disposition short names allowed for decommissioning operations.
enum DecommissioningDisposition {
  destroyed('destroyed', 'Destroyed'),
  inactive('inactive', 'Inactive'),
  expired('expired', 'Expired'),
  dispensed('dispensed', 'Dispensed'),
  recalled('recalled', 'Recalled'),
  disposed('disposed', 'Disposed'),
  stolen('stolen', 'Stolen'),
  damaged('damaged', 'Damaged');

  const DecommissioningDisposition(this.code, this.label);

  final String code;
  final String label;

  static DecommissioningDisposition? fromCode(String? code) {
    if (code == null || code.isEmpty) return null;
    final normalized = code.trim().toLowerCase();
    for (final value in DecommissioningDisposition.values) {
      if (value.code == normalized) return value;
    }
    return null;
  }
}
