class EpcStatusResponse {
  const EpcStatusResponse({
    required this.epc,
    required this.status,
    required this.compatibleWithShipping,
    required this.compatibleWithReceiving,
  });

  final String epc;
  final String status;
  final bool compatibleWithShipping;
  final bool compatibleWithReceiving;

  factory EpcStatusResponse.fromJson(Map<String, dynamic> json) {
    return EpcStatusResponse(
      epc: json['epc']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      compatibleWithShipping: json['compatibleWithShipping'] == true,
      compatibleWithReceiving: json['compatibleWithReceiving'] == true,
    );
  }
}
