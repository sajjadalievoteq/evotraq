import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/shared/utils/gs1_validator.dart';

void main() {
  group('GS1Validator Tests', () {
    test('GTIN Validation', () {
      // Valid GTIN-14
      expect(GS1Validator.isValidGTIN('12345678901231'), true);
      expect(GS1Validator.isValidGTIN('50614141123458'), true);
      
      // Invalid GTINs
      expect(GS1Validator.isValidGTIN('1234567890123'), false); // Too short
      expect(GS1Validator.isValidGTIN('123456789012345'), false); // Too long
      expect(GS1Validator.isValidGTIN('1234567890123A'), false); // Non-numeric
      expect(GS1Validator.isValidGTIN('12345678901232'), false); // Invalid check digit
      expect(GS1Validator.isValidGTIN(null), false); // Null value
      expect(GS1Validator.isValidGTIN(''), false); // Empty value
    });
    
    test('GLN Validation', () {
      // Valid GLN
      expect(GS1Validator.isValidGLN('1234567890128'), true);
      expect(GS1Validator.isValidGLN('6141411000005'), true);
      
      // Invalid GLNs
      expect(GS1Validator.isValidGLN('123456789012'), false); // Too short
      expect(GS1Validator.isValidGLN('12345678901234'), false); // Too long
      expect(GS1Validator.isValidGLN('123456789012A'), false); // Non-numeric
      expect(GS1Validator.isValidGLN('1234567890127'), false); // Invalid check digit
      expect(GS1Validator.isValidGLN(null), false); // Null value
      expect(GS1Validator.isValidGLN(''), false); // Empty value
    });
    
    test('SSCC Validation', () {
      // Valid SSCC
      expect(GS1Validator.isValidSSCC('106141411234567895'), true);
      
      // Invalid SSCCs
      expect(GS1Validator.isValidSSCC('10614141123456789'), false); // Too short
      expect(GS1Validator.isValidSSCC('1061414112345678956'), false); // Too long
      expect(GS1Validator.isValidSSCC('10614141123456789A'), false); // Non-numeric
      expect(GS1Validator.isValidSSCC('106141411234567896'), false); // Invalid check digit
      expect(GS1Validator.isValidSSCC(null), false); // Null value
      expect(GS1Validator.isValidSSCC(''), false); // Empty value
    });
    
    test('SGTIN Validation', () {
      // Valid SGTIN
      expect(GS1Validator.isValidSGTIN('50614141123458', 'ABC123'), true);
      expect(GS1Validator.isValidSGTIN('12345678901231', '123456789'), true);
      
      // Invalid SGTINs
      expect(GS1Validator.isValidSGTIN('12345678901232', 'ABC123'), false); // Invalid GTIN
      expect(GS1Validator.isValidSGTIN('12345678901231', ''), false); // Empty serial number
      expect(GS1Validator.isValidSGTIN('12345678901231', null), false); // Null serial number
      expect(GS1Validator.isValidSGTIN('12345678901231', '123456789012345678901'), false); // Serial number too long
    });
    
    test('EPC URI Validation', () {
      // Valid EPC URIs
      expect(GS1Validator.isValidEPCURI('urn:epc:id:sgtin:0614141.112345.ABC123'), true);
      expect(GS1Validator.isValidEPCURI('urn:epc:id:sscc:0614141.1234567890'), true);
      expect(GS1Validator.isValidEPCURI('urn:epc:idpat:sgtin:0614141.112345.*'), true);
      
      // Invalid EPC URIs
      expect(GS1Validator.isValidEPCURI('urn:gs1:id:sgtin:0614141.112345.ABC123'), false); // Wrong namespace
      expect(GS1Validator.isValidEPCURI('urn:epc:id:invalid:0614141.112345.ABC123'), false); // Invalid scheme
      expect(GS1Validator.isValidEPCURI('sgtin:0614141.112345.ABC123'), false); // Missing urn
      expect(GS1Validator.isValidEPCURI(null), false); // Null value
      expect(GS1Validator.isValidEPCURI(''), false); // Empty value
    });
    
    test('Barcode Data Validation', () {
      // Valid barcode data
      expect(GS1Validator.validateBarcodeData('(01)12345678901231(21)ABC123'), null);
      expect(GS1Validator.validateBarcodeData('(00)106141411234567895(10)LOT123'), null);
      
      // Invalid barcode data
      expect(GS1Validator.validateBarcodeData(null), 'Barcode data cannot be empty');
      expect(GS1Validator.validateBarcodeData(''), 'Barcode data cannot be empty');
      expect(GS1Validator.validateBarcodeData('0112345678901231'), 
             'Invalid barcode format: missing Application Identifiers');
    });
    
    test('Check Digit Calculation', () {
      // Private method testing is done via the public methods that use them
      expect(GS1Validator.isValidGTIN('12345678901231'), true);
      expect(GS1Validator.isValidGTIN('12345678901232'), false);
    });
  });
}
