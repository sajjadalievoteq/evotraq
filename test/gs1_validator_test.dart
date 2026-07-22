import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/utils/gs1_validator.dart';

void main() {
  group('GS1Validator Tests', () {
    test('GTIN Validation', () {
      
      expect(GS1Validator.isValidGTIN('12345678901231'), true);
      expect(GS1Validator.isValidGTIN('50614141123458'), true);
      
      
      expect(GS1Validator.isValidGTIN('1234567890123'), false); 
      expect(GS1Validator.isValidGTIN('123456789012345'), false); 
      expect(GS1Validator.isValidGTIN('1234567890123A'), false); 
      expect(GS1Validator.isValidGTIN('12345678901232'), false); 
      expect(GS1Validator.isValidGTIN(null), false); 
      expect(GS1Validator.isValidGTIN(''), false); 
    });
    
    test('GLN Validation', () {
      
      expect(GS1Validator.isValidGLN('1234567890128'), true);
      expect(GS1Validator.isValidGLN('6141411000005'), true);
      
      
      expect(GS1Validator.isValidGLN('123456789012'), false); 
      expect(GS1Validator.isValidGLN('12345678901234'), false); 
      expect(GS1Validator.isValidGLN('123456789012A'), false); 
      expect(GS1Validator.isValidGLN('1234567890127'), false); 
      expect(GS1Validator.isValidGLN(null), false); 
      expect(GS1Validator.isValidGLN(''), false); 
    });
    
    test('SSCC Validation', () {
      
      expect(GS1Validator.isValidSSCC('106141411234567895'), true);
      
      
      expect(GS1Validator.isValidSSCC('10614141123456789'), false); 
      expect(GS1Validator.isValidSSCC('1061414112345678956'), false); 
      expect(GS1Validator.isValidSSCC('10614141123456789A'), false); 
      expect(GS1Validator.isValidSSCC('106141411234567896'), false); 
      expect(GS1Validator.isValidSSCC(null), false); 
      expect(GS1Validator.isValidSSCC(''), false); 
    });
    
    test('SGTIN Validation', () {
      
      expect(GS1Validator.isValidSGTIN('50614141123458', 'ABC123'), true);
      expect(GS1Validator.isValidSGTIN('12345678901231', '123456789'), true);
      
      
      expect(GS1Validator.isValidSGTIN('12345678901232', 'ABC123'), false); 
      expect(GS1Validator.isValidSGTIN('12345678901231', ''), false); 
      expect(GS1Validator.isValidSGTIN('12345678901231', null), false); 
      expect(GS1Validator.isValidSGTIN('12345678901231', '123456789012345678901'), false); 
    });
    
    test('EPC URI Validation', () {
      
      expect(GS1Validator.isValidEPCURI('urn:epc:id:sgtin:0614141.112345.ABC123'), true);
      expect(GS1Validator.isValidEPCURI('urn:epc:id:sscc:0614141.1234567890'), true);
      expect(GS1Validator.isValidEPCURI('urn:epc:idpat:sgtin:0614141.112345.*'), true);
      
      
      expect(GS1Validator.isValidEPCURI('urn:gs1:id:sgtin:0614141.112345.ABC123'), false); 
      expect(GS1Validator.isValidEPCURI('urn:epc:id:invalid:0614141.112345.ABC123'), false); 
      expect(GS1Validator.isValidEPCURI('sgtin:0614141.112345.ABC123'), false); 
      expect(GS1Validator.isValidEPCURI(null), false); 
      expect(GS1Validator.isValidEPCURI(''), false); 
    });
    
    test('Barcode Data Validation', () {
      
      expect(GS1Validator.validateBarcodeData('(01)12345678901231(21)ABC123'), null);
      expect(GS1Validator.validateBarcodeData('(00)106141411234567895(10)LOT123'), null);
      
      
      expect(GS1Validator.validateBarcodeData(null), 'Barcode data cannot be empty');
      expect(GS1Validator.validateBarcodeData(''), 'Barcode data cannot be empty');
      expect(GS1Validator.validateBarcodeData('0112345678901231'), 
             'Invalid barcode format: missing Application Identifiers');
    });
    
    test('Check Digit Calculation', () {
      
      expect(GS1Validator.isValidGTIN('12345678901231'), true);
      expect(GS1Validator.isValidGTIN('12345678901232'), false);
    });
  });
}
