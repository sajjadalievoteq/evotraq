class ScanResult {
  final String data;
  
  final bool isValid;
  
  final String? error;
  
  final String? barcodeType;
  
  final Map<String, dynamic>? metadata;

  const ScanResult({
    required this.data,
    required this.isValid,
    this.error,
    this.barcodeType,
    this.metadata,
  });

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