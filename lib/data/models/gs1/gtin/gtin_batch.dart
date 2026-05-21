import 'package:equatable/equatable.dart';

class GtinBatch extends Equatable {
  final int? id;
  final String? uuid;
  final int gtinId;
  final String? gtinCode;
  final String batchLotNumber;
  final String? manufactureDate;
  final String expiryDate;
  final int? quantityManufactured;
  final int? quantityCommissioned;
  final bool recallAffected;
  final String? recallNotificationId;
  final String batchStatus;
  final String? productDescriptionOverride;
  final String? packSize;

  const GtinBatch({
    this.id,
    this.uuid,
    required this.gtinId,
    this.gtinCode,
    required this.batchLotNumber,
    this.manufactureDate,
    required this.expiryDate,
    this.quantityManufactured,
    this.quantityCommissioned,
    required this.recallAffected,
    this.recallNotificationId,
    required this.batchStatus,
    this.productDescriptionOverride,
    this.packSize,
  });

  factory GtinBatch.fromJson(Map<String, dynamic> json) => GtinBatch(
        id: json['id'] as int?,
        uuid: json['uuid'] as String?,
        gtinId: json['gtinId'] as int,
        gtinCode: json['gtinCode'] as String?,
        batchLotNumber: json['batchLotNumber'] as String,
        manufactureDate: json['manufactureDate'] as String?,
        expiryDate: json['expiryDate'] as String,
        quantityManufactured: json['quantityManufactured'] as int?,
        quantityCommissioned: json['quantityCommissioned'] as int?,
        recallAffected: json['recallAffected'] as bool? ?? false,
        recallNotificationId: json['recallNotificationId'] as String?,
        batchStatus: json['batchStatus'] as String? ?? 'ACTIVE',
        productDescriptionOverride:
            json['productDescriptionOverride'] as String?,
        packSize: json['packSize'] as String?,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (uuid != null) 'uuid': uuid,
        'gtinId': gtinId,
        if (gtinCode != null) 'gtinCode': gtinCode,
        'batchLotNumber': batchLotNumber,
        if (manufactureDate != null) 'manufactureDate': manufactureDate,
        'expiryDate': expiryDate,
        if (quantityManufactured != null)
          'quantityManufactured': quantityManufactured,
        if (quantityCommissioned != null)
          'quantityCommissioned': quantityCommissioned,
        'recallAffected': recallAffected,
        if (recallNotificationId != null)
          'recallNotificationId': recallNotificationId,
        'batchStatus': batchStatus,
        if (productDescriptionOverride != null)
          'productDescriptionOverride': productDescriptionOverride,
        if (packSize != null) 'packSize': packSize,
      };

  GtinBatch copyWith({
    int? id,
    String? uuid,
    int? gtinId,
    String? gtinCode,
    String? batchLotNumber,
    String? manufactureDate,
    String? expiryDate,
    int? quantityManufactured,
    int? quantityCommissioned,
    bool? recallAffected,
    String? recallNotificationId,
    String? batchStatus,
    String? productDescriptionOverride,
    String? packSize,
  }) =>
      GtinBatch(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        gtinId: gtinId ?? this.gtinId,
        gtinCode: gtinCode ?? this.gtinCode,
        batchLotNumber: batchLotNumber ?? this.batchLotNumber,
        manufactureDate: manufactureDate ?? this.manufactureDate,
        expiryDate: expiryDate ?? this.expiryDate,
        quantityManufactured: quantityManufactured ?? this.quantityManufactured,
        quantityCommissioned: quantityCommissioned ?? this.quantityCommissioned,
        recallAffected: recallAffected ?? this.recallAffected,
        recallNotificationId: recallNotificationId ?? this.recallNotificationId,
        batchStatus: batchStatus ?? this.batchStatus,
        productDescriptionOverride:
            productDescriptionOverride ?? this.productDescriptionOverride,
        packSize: packSize ?? this.packSize,
      );

  @override
  List<Object?> get props => [
        id, uuid, gtinId, gtinCode, batchLotNumber, manufactureDate,
        expiryDate, quantityManufactured, quantityCommissioned, recallAffected,
        recallNotificationId, batchStatus, productDescriptionOverride, packSize,
      ];
}
