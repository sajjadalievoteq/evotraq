/// Model for scan results from barcode scanning operations
class ScanResult {
  /// The raw scanned data
  final String data;
  
  /// Whether the scan result is valid
  final bool isValid;
  
  /// Error message if scan is invalid
  final String? error;
  
  /// Type of barcode detected (SGTIN, SSCC, etc.)
  final String? barcodeType;
  
  /// Additional metadata from the scan
  final Map<String, dynamic>? metadata;

  const ScanResult({
    required this.data,
    required this.isValid,
    this.error,
    this.barcodeType,
    this.metadata,
  });

  /// Create a successful scan result
  factory ScanResult.success({
    required String data,
    String? barcodeType,
    Map<String, dynamic>? metadata,
  }) {
    return ScanResult(
      data: data,
      isValid: true,
      barcodeType: barcodeType,
      metadata: metadata,
    );
  }

  /// Create a failed scan result
  factory ScanResult.error({
    required String data,
    required String error,
  }) {
    return ScanResult(
      data: data,
      isValid: false,
      error: error,
    );
  }

  @override
  String toString() {
    return 'ScanResult(data: $data, isValid: $isValid, error: $error, barcodeType: $barcodeType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScanResult &&
        other.data == data &&
        other.isValid == isValid &&
        other.error == error &&
        other.barcodeType == barcodeType;
  }

  @override
  int get hashCode {
    return data.hashCode ^ isValid.hashCode ^ error.hashCode ^ barcodeType.hashCode;
  }
}