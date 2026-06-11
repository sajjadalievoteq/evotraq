import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

/// Help screen for Transaction Events
class TransactionEventsHelpScreen extends StatelessWidget {
  /// Constructor
  const TransactionEventsHelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Events Help'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Markdown(
          data: _helpText,
          styleSheet: MarkdownStyleSheet(
            h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            h3: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            p: const TextStyle(fontSize: 16),
            strong: const TextStyle(fontWeight: FontWeight.bold),
          ),
          onTapLink: (text, href, title) {
            if (href != null) {
              _launchUrl(href);
            }
          },
        ),
      ),
    );
  }

  /// Launch a URL
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  /// Help text content in Markdown format
  static const String _helpText = '''
# Transaction Events

## Overview
Transaction Events are part of the EPCIS (Electronic Product Code Information Services) standard that record the association or disassociation of physical objects with business transactions. These events are crucial for maintaining the product chain of custody and documenting business processes in the pharmaceutical supply chain.

## Purpose
Transaction Events allow you to:
- Associate products with business transactions like purchase orders, invoices, etc.
- Track when products are added to or removed from transactions
- Document the observation of products within a transaction context
- Maintain compliance with GS1 and regulatory traceability requirements

## EPCIS Standard
This implementation follows the GS1 EPCIS standard (version 2.0 with backward compatibility to 1.3), which provides a standardized way to share supply chain event data between trading partners.

## Event Types
Transaction Events are one of the four core EPCIS event types:
1. **Object Events** - capture information about physical objects
2. **Aggregation Events** - record hierarchical relationships between objects
3. **Transaction Events** - associate objects with business transactions
4. **Transformation Events** - track objects that are transformed into other objects

## Fields Explanation

### Required Fields

* **Action** - Specifies the relationship between the objects and the business transaction:
  * `ADD` - Objects are being associated with the transaction
  * `OBSERVE` - The association is being observed
  * `DELETE` - Objects are being disassociated from the transaction

* **Event Time** - The date and time when the event occurred.

* **Event Time Zone Offset** - The time zone offset from UTC where the event took place (+/- hours:minutes format).

* **Business Transaction Type & ID** - The type and identifier of the business transaction.
  * Common types include Purchase Order (PO), Invoice (INV), Despatch Advice (DESADV), etc.
  * The system provides standard GS1 CBV (Core Business Vocabulary) transaction types.

### Product Identifiers

* **EPCs (Electronic Product Codes)** - List of unique product identifiers involved in the transaction.
  * Format: urn:epc:id:sgtin:CompanyPrefix.ItemReference.SerialNumber
  * Example: urn:epc:id:sgtin:0614141.112345.400

### Location Information

* **Location GLN** - Global Location Number identifying where the event took place
  * Format: A 13-digit number used in GS1 standards

### Event Context

* **Business Step** - Defines the business process step
  * Examples: shipping, receiving, accepting, dispensing
  * Standard GS1 CBV business steps are provided in dropdown

* **Disposition** - Indicates the status of the objects
  * Examples: in_transit, active, in_progress, sold
  * Standard GS1 CBV dispositions are provided in dropdown

### Additional Data

* **Business Data** - Custom key-value pairs for additional business information

## Actions

* **Create New Event** - Use the floating action button (+ icon) to create a new Transaction Event
* **View Event Details** - Tap on an event in the list to view its complete details
* **Filter Events** - Use the filter icon to search for events by various criteria
* **Refresh List** - Pull down to refresh the list of events

## References

* [GS1 EPCIS Standard](https://www.gs1.org/standards/epcis)
* [GS1 Core Business Vocabulary](https://www.gs1.org/standards/epcis-and-cbv)
''';
}
