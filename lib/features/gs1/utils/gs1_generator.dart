import 'dart:math';
import 'package:uuid/uuid.dart';

class GS1Generator {
  static final Uuid _uuid = Uuid();

  static String generateUUID() {
    return _uuid.v4();
  }

  static String generateSGTIN(String companyPrefix, String itemReference, String serialNumber) {
    return 'urn:epc:id:sgtin:$companyPrefix.$itemReference.$serialNumber';
  }
  
  static String generateRandomSGTIN(String companyPrefix, String itemReference, {int serialLength = 7}) {
    final serialNumber = _generateRandomSerialNumber(serialLength);
    return generateSGTIN(companyPrefix, itemReference, serialNumber);
  }
  
  static List<String> generateBatchSGTINs(
    String companyPrefix, 
    String itemReference, 
    int count, 
    {int startSerial = 1}
  ) {
    final List<String> sgtins = [];
    
    for (int i = 0; i < count; i++) {
      final serialNumber = (startSerial + i).toString().padLeft(7, '0');
      sgtins.add(generateSGTIN(companyPrefix, itemReference, serialNumber));
    }
    
    return sgtins;
  }
  
  static String generateGLN(String companyPrefix, String locationReference) {
    return 'urn:epc:id:sgln:$companyPrefix.$locationReference.0';
  }
  
  static String generateSSCC(String companyPrefix, String serialReference) {
    return 'urn:epc:id:sscc:$companyPrefix.$serialReference';
  }
  
  static String _generateRandomSerialNumber(int length) {
    final random = Random();
    final buffer = StringBuffer();
    
    for (int i = 0; i < length; i++) {
      buffer.write(random.nextInt(10));
    }
    
    return buffer.toString();
  }
  
  static String gtinToSGTIN(String gtin, String serialNumber, int companyPrefixLength) {
    final gtinWithoutCheck = gtin.substring(0, gtin.length - 1);
    
    final companyPrefix = gtinWithoutCheck.substring(0, companyPrefixLength);
    final itemReference = gtinWithoutCheck.substring(companyPrefixLength);
    
    return generateSGTIN(companyPrefix, itemReference, serialNumber);
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
