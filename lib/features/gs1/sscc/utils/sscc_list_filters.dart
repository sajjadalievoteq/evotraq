bool ssccListHasSearchCriteria({
  String? ssccCode,
  String? containerType,
  String? containerStatus,
  String? sourceLocationName,
  String? destinationLocationName,
  String? gs1CompanyPrefix,
  DateTime? packingDateFrom,
  DateTime? packingDateTo,
  DateTime? shippingDateFrom,
  DateTime? shippingDateTo,
  DateTime? receivingDateFrom,
  DateTime? receivingDateTo,
}) {
  bool hasText(String? value) => value != null && value.trim().isNotEmpty;

  return hasText(ssccCode) ||
      hasText(containerType) ||
      hasText(containerStatus) ||
      hasText(sourceLocationName) ||
      hasText(destinationLocationName) ||
      hasText(gs1CompanyPrefix) ||
      packingDateFrom != null ||
      packingDateTo != null ||
      shippingDateFrom != null ||
      shippingDateTo != null ||
      receivingDateFrom != null ||
      receivingDateTo != null;
}
