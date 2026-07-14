import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:traqtrace_app/core/utils/gs1/check_digit_utils.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_converter.dart';

class GS1Generator {
  static final Uuid _uuid = Uuid();

  static String generateUUID() {
    return _uuid.v4();
  }

  /// Builds a GS1 Digital Link SGTIN from Pure Identity components.
  /// [itemReference] is the EPC item reference (indicator digit + item ref).
  static String generateSGTIN(
    String companyPrefix,
    String itemReference,
    String serialNumber,
  ) {
    final indicatorAndItem = itemReference.replaceAll(RegExp(r'\D'), '');
    final gcp = companyPrefix.replaceAll(RegExp(r'\D'), '');
    if (indicatorAndItem.isEmpty || gcp.isEmpty || serialNumber.isEmpty) {
      final pad = (gcp + indicatorAndItem).padLeft(14, '0');
      return 'https://id.gs1.org/01/$pad/21/$serialNumber';
    }
    final body =
        '${indicatorAndItem[0]}$gcp${indicatorAndItem.substring(1)}';
    final padded13 = body.padLeft(13, '0');
    final gtin14 = '$padded13${CheckDigitUtils.calculateMod10String(padded13)}';
    return Gs1Converter.gtinSerialToEpc(gtin14, serialNumber) ??
        'https://id.gs1.org/01/$gtin14/21/$serialNumber';
  }

  static String generateRandomSGTIN(
    String companyPrefix,
    String itemReference, {
    int serialLength = 7,
  }) {
    final serialNumber = _generateRandomSerialNumber(serialLength);
    return generateSGTIN(companyPrefix, itemReference, serialNumber);
  }

  static List<String> generateBatchSGTINs(
    String companyPrefix,
    String itemReference,
    int count, {
    int startSerial = 1,
  }) {
    final List<String> sgtins = [];

    for (int i = 0; i < count; i++) {
      final serialNumber = (startSerial + i).toString().padLeft(7, '0');
      sgtins.add(generateSGTIN(companyPrefix, itemReference, serialNumber));
    }

    return sgtins;
  }

  /// Builds a GS1 Digital Link GLN (AI 414) from Pure Identity components.
  static String generateGLN(String companyPrefix, String locationReference) {
    final gcp = companyPrefix.replaceAll(RegExp(r'\D'), '');
    final loc = locationReference.replaceAll(RegExp(r'\D'), '');
    final body = '$gcp$loc'.padLeft(12, '0');
    final gln13 = '$body${CheckDigitUtils.calculateMod10String(body)}';
    return Gs1Converter.glnToEpc(gln13) ?? 'https://id.gs1.org/414/$gln13';
  }

  /// Builds a GS1 Digital Link SSCC from Pure Identity components.
  /// [serialReference] is the EPC serial reference (extension digit + serial).
  static String generateSSCC(String companyPrefix, String serialReference) {
    final gcp = companyPrefix.replaceAll(RegExp(r'\D'), '');
    final serialRef = serialReference.replaceAll(RegExp(r'\D'), '');
    if (serialRef.isNotEmpty && gcp.isNotEmpty) {
      final body = '${serialRef[0]}$gcp${serialRef.substring(1)}';
      if (body.length == 17) {
        final sscc18 = '$body${CheckDigitUtils.calculateMod10String(body)}';
        return Gs1Converter.ssccToEpc(sscc18) ?? 'https://id.gs1.org/00/$sscc18';
      }
    }
    final digits = (gcp + serialRef).padLeft(18, '0');
    return Gs1Converter.ssccToEpc(digits) ?? 'https://id.gs1.org/00/$digits';
  }

  static String _generateRandomSerialNumber(int length) {
    final random = Random();
    final buffer = StringBuffer();

    for (int i = 0; i < length; i++) {
      buffer.write(random.nextInt(10));
    }

    return buffer.toString();
  }

  static String gtinToSGTIN(
    String gtin,
    String serialNumber,
    int companyPrefixLength,
  ) {
    return Gs1Converter.gtinSerialToEpc(gtin, serialNumber) ??
        'https://id.gs1.org/01/${gtin.padLeft(14, '0')}/21/$serialNumber';
  }

  static Map<String, String> parseGS1BarcodeData(String barcodeData) {
    final result = <String, String>{};
    int index = 0;

    while (index < barcodeData.length) {
      if (index + 2 > barcodeData.length) break;
      String ai = barcodeData.substring(index, index + 2);
      index += 2;

      if ('0123456789'.contains(ai) && index < barcodeData.length) {
        ai += barcodeData.substring(index, index + 2);
        index += 2;
      }

      String value = '';

      switch (ai) {
        case '01':
          value = barcodeData.substring(index, index + 14);
          index += 14;
          break;
        case '10':
          int endIndex = barcodeData.indexOf('\u001D', index);
          if (endIndex == -1) endIndex = barcodeData.length;
          value = barcodeData.substring(index, endIndex);
          index = endIndex + 1;
          break;
        case '21':
          int endIndex = barcodeData.indexOf('\u001D', index);
          if (endIndex == -1) endIndex = barcodeData.length;
          value = barcodeData.substring(index, endIndex);
          index = endIndex + 1;
          break;
        default:
          int length = min(10, barcodeData.length - index);
          value = barcodeData.substring(index, index + length);
          index += length;
      }

      result[ai] = value;
    }

    return result;
  }
}
