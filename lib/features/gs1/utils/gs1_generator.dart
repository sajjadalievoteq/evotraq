import 'dart:math';
import 'package:uuid/uuid.dart';

/// Utility class for generating GS1 identifiers like SGTIN and GLN
/// according to GS1 standards.
class GS1Generator {
  // Static instance of Uuid for generating UUIDs
  static final Uuid _uuid = Uuid();

  /// Generates a UUID (Universally Unique Identifier)
  /// 
  /// Returns: A UUID string in standard format
  static String generateUUID() {
    return _uuid.v4();
  }

  /// Generates a SGTIN (Serialized Global Trade Item Number) in EPC URI format
  /// 
  /// Parameters:
  /// - companyPrefix: The GS1 Company Prefix assigned to the company
  /// - itemReference: The item reference assigned by the company
  /// - serialNumber: A unique serial number for the individual item
  /// 
  /// Returns: An EPC URI format SGTIN
  static String generateSGTIN(String companyPrefix, String itemReference, String serialNumber) {
    return 'urn:epc:id:sgtin:$companyPrefix.$itemReference.$serialNumber';
  }
  
  /// Generates a SGTIN with a random serial number
  /// 
  /// Parameters:
  /// - companyPrefix: The GS1 Company Prefix assigned to the company
  /// - itemReference: The item reference assigned by the company
  /// - serialLength: The length of the random serial number (default: 7)
  /// 
  /// Returns: An EPC URI format SGTIN with random serial number
  static String generateRandomSGTIN(String companyPrefix, String itemReference, {int serialLength = 7}) {
    final serialNumber = _generateRandomSerialNumber(serialLength);
    return generateSGTIN(companyPrefix, itemReference, serialNumber);
  }
  
  /// Generates a batch of SGTINs with sequential serial numbers
  /// 
  /// Parameters:
  /// - companyPrefix: The GS1 Company Prefix assigned to the company
  /// - itemReference: The item reference assigned by the company
  /// - count: The number of SGTINs to generate
  /// - startSerial: The starting serial number (default: 1)
  /// 
  /// Returns: A list of EPC URI format SGTINs
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
  
  /// Generates a GLN (Global Location Number) in EPC URI format
  /// 
  /// Parameters:
  /// - companyPrefix: The GS1 Company Prefix assigned to the company
  /// - locationReference: The location reference assigned by the company
  /// 
  /// Returns: An EPC URI format GLN
  static String generateGLN(String companyPrefix, String locationReference) {
    return 'urn:epc:id:sgln:$companyPrefix.$locationReference.0';
  }
  
  /// Generates a SSCC (Serial Shipping Container Code) in EPC URI format
  /// 
  /// Parameters:
  /// - companyPrefix: The GS1 Company Prefix assigned to the company
  /// - serialReference: The serial reference for the container
  /// 
  /// Returns: An EPC URI format SSCC
  static String generateSSCC(String companyPrefix, String serialReference) {
    return 'urn:epc:id:sscc:$companyPrefix.$serialReference';
  }
  
  /// Generates a random serial number of specified length
  static String _generateRandomSerialNumber(int length) {
    final random = Random();
    final buffer = StringBuffer();
    
    for (int i = 0; i < length; i++) {
      buffer.write(random.nextInt(10));
    }
    
    return buffer.toString();
  }
  
  /// Converts a GTIN to SGTIN EPC URI format
  /// 
  /// Parameters:
  /// - gtin: The GTIN code (e.g., from a barcode)
  /// - serialNumber: The serial number for the item
  /// - companyPrefixLength: The length of the company prefix (varies by organization)
  /// 
  /// Returns: An EPC URI format SGTIN
  static String gtinToSGTIN(String gtin, String serialNumber, int companyPrefixLength) {
    // Remove check digit
    final gtinWithoutCheck = gtin.substring(0, gtin.length - 1);
    
    // Extract company prefix and item reference
    final companyPrefix = gtinWithoutCheck.substring(0, companyPrefixLength);
    final itemReference = gtinWithoutCheck.substring(companyPrefixLength);
    
    return generateSGTIN(companyPrefix, itemReference, serialNumber);
  }
  
  /// Parses barcode data to extract GS1 elements (AI)
  /// 
  /// Parameters:
  /// - barcodeData: The data scanned from a GS1 barcode
  /// 
  /// Returns: A map of Application Identifiers (AI) to their values
  static Map<String, String> parseGS1BarcodeData(String barcodeData) {
    final result = <String, String>{};
    int index = 0;
    
    while (index < barcodeData.length) {
      // Get the AI
      if (index + 2 > barcodeData.length) break;
      String ai = barcodeData.substring(index, index + 2);
      index += 2;
      
      // Check if it's a 4-digit AI
      if ('0123456789'.contains(ai) && index < barcodeData.length) {
        ai += barcodeData.substring(index, index + 2);
        index += 2;
      }
      
      // Get the value based on AI length definitions
      String value = '';
      
      // AI-specific logic (simplified)
      switch (ai) {
        case '01': // GTIN
          value = barcodeData.substring(index, index + 14);
          index += 14;
          break;
        case '10': // Batch/Lot
          // Variable length, look for separator or end
          int endIndex = barcodeData.indexOf('\u001D', index);
          if (endIndex == -1) endIndex = barcodeData.length;
          value = barcodeData.substring(index, endIndex);
          index = endIndex + 1;
          break;
        case '21': // Serial
          // Variable length, look for separator or end
          int endIndex = barcodeData.indexOf('\u001D', index);
          if (endIndex == -1) endIndex = barcodeData.length;
          value = barcodeData.substring(index, endIndex);
          index = endIndex + 1;
          break;
        default:
          // Generic case - take next 10 chars or until end
          int length = min(10, barcodeData.length - index);
          value = barcodeData.substring(index, index + length);
          index += length;
      }
      
      result[ai] = value;
    }
    
    return result;
  }
}
