
import 'package:flutter/material.dart';

/// Utility class for formatting and displaying GS1 data
class GS1DataFormatter {
  
  /// Format GS1 data into a human-readable format
  static Map<String, String> formatGS1Data(Map<dynamic, dynamic> data) {
    final result = <String, String>{};
    
    try {
      // Convert AI codes to human-readable labels
      if (data.containsKey('GTIN')) {
        result['Product Code (GTIN)'] = data['GTIN'].toString();
      }
      
      if (data.containsKey('serialNumber')) {
        result['Serial Number'] = data['serialNumber'].toString();
      }
      
      if (data.containsKey('expiryDate')) {
        final expiryStr = data['expiryDate'].toString();
        try {
          final expiry = DateTime.parse(expiryStr);
          result['Expiry Date'] = '${expiry.year}-${expiry.month.toString().padLeft(2, '0')}-${expiry.day.toString().padLeft(2, '0')}';
        } catch (e) {
          result['Expiry Date'] = expiryStr;
        }
      }
      
      if (data.containsKey('batchNumber') || data.containsKey('lotNumber')) {
        result['Batch/Lot Number'] = (data['batchNumber'] ?? data['lotNumber'] ?? '').toString();
      }
      
      if (data.containsKey('productionDate')) {
        final prodDateStr = data['productionDate'].toString();
        try {
          final prodDate = DateTime.parse(prodDateStr);
          result['Production Date'] = '${prodDate.year}-${prodDate.month.toString().padLeft(2, '0')}-${prodDate.day.toString().padLeft(2, '0')}';
        } catch (e) {
          result['Production Date'] = prodDateStr;
        }
      }
      
      // Add any other GS1 elements that might be present
      data.forEach((key, value) {
        if (!result.containsKey(key.toString()) && 
            key.toString() != 'barcodeType' && 
            key.toString() != 'rawData') {
          result[key.toString()] = value.toString();
        }
      });
      
    } catch (e) {
      result['Error'] = 'Failed to parse GS1 data: $e';
    }
    
    return result;
  }
  
  /// Build a list of widget to display GS1 data
  static List<Widget> buildGS1DataWidgets(Map<dynamic, dynamic>? data, {Color textColor = Colors.white}) {
    if (data == null) {
      return [Text('No data available', style: TextStyle(color: textColor))];
    }
    
    final formattedData = formatGS1Data(data);
    final widgets = <Widget>[];
    
    formattedData.forEach((key, value) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$key: ',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(color: textColor),
                ),
              ),
            ],
          ),
        ),
      );
    });
    
    return widgets;
  }
  
  /// Get the primary GS1 identifier (GTIN, SSCC, GLN, etc.)
  static String getPrimaryIdentifier(Map<dynamic, dynamic>? data) {
    if (data == null) return 'Unknown';
    
    if (data.containsKey('GTIN')) {
      return 'GTIN: ${data['GTIN']}';
    } else if (data.containsKey('SSCC')) {
      return 'SSCC: ${data['SSCC']}';
    } else if (data.containsKey('GLN')) {
      return 'GLN: ${data['GLN']}';
    } else {
      return 'Barcode: ${data['rawData'] ?? 'Unknown'}';
    }
  }
  
  /// Determine the barcode type from the data structure
  static String getBarcodeType(Map<dynamic, dynamic>? data) {
    if (data == null) return 'Unknown';
    
    if (data.containsKey('barcodeType')) {
      return data['barcodeType'].toString();
    }
    
    if (data.containsKey('GTIN') && data.containsKey('serialNumber')) {
      return 'SGTIN';
    } else if (data.containsKey('GTIN')) {
      return 'GTIN';
    } else if (data.containsKey('SSCC')) {
      return 'SSCC';
    } else if (data.containsKey('GLN')) {
      return 'GLN';
    } else {
      return 'GS1 Element String';
    }
  }
}
