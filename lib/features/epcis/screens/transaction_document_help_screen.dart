import 'package:flutter/material.dart';

/// Help screen for Transaction Document operations
class TransactionDocumentHelpScreen extends StatelessWidget {
  /// Constructor
  const TransactionDocumentHelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Document Help'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: 'What are Transaction Documents?',
              content: 'Transaction documents are business documents used in supply chain operations that are referenced '
                  'in EPCIS Transaction Events. These can include invoices, purchase orders, shipping notices, bills of lading, '
                  'and other business documents that track the transfer of ownership or custody of items.'
            ),
            
            _buildSection(
              title: 'Document Type and ID Format',
              content: 'Document types are typically standardized identifiers for the kind of document being referenced. '
                  'Common document types include:\n\n'
                  '• invoice - Commercial invoice\n'
                  '• po - Purchase order\n'
                  '• desadv - Despatch advice / Shipping notice\n'
                  '• packing-list - Packing list\n'
                  '• receiving - Receiving advice\n'
                  '• bill-of-lading - Transportation document\n\n'
                  'Document IDs are typically business-specific identifiers, such as invoice numbers, '
                  'purchase order numbers, etc.'
            ),
            
            _buildSection(
              title: 'Find Events by Document',
              content: 'This function allows you to find all EPCIS Transaction Events that reference a specific document.\n\n'
                  'Example inputs:\n'
                  '• Document Type: invoice\n'
                  '• Document ID: INV-12345\n\n'
                  'This will return all transaction events where this invoice was referenced, allowing you to '
                  'track which products were included in the invoice and when they changed ownership.'
            ),
            
            _buildSection(
              title: 'Validate Document Reference',
              content: 'This function checks if a document reference exists in the system and is valid.\n\n'
                  'Example inputs:\n'
                  '• Document Type: po\n'
                  '• Document ID: PO-67890\n\n'
                  'This is useful when you want to verify if a document has been properly registered '
                  'in the system before attempting to link it to other documents or events.'
            ),
            
            _buildSection(
              title: 'Get Document Status',
              content: 'This function retrieves the current status and metadata about a document.\n\n'
                  'Example inputs:\n'
                  '• Document Type: desadv\n'
                  '• Document ID: SHP-54321\n\n'
                  'This will return information such as:\n'
                  '• Document status (e.g., ACTIVE, COMPLETED, CANCELLED)\n'
                  '• Creation date\n'
                  '• Last updated date\n'
                  '• Document owner/issuer'
            ),
            
            _buildSection(
              title: 'Get Related Documents',
              content: 'This function finds other documents that are related to the specified document.\n\n'
                  'Example inputs:\n'
                  '• Document Type: invoice\n'
                  '• Document ID: INV-12345\n\n'
                  'This might return related documents such as:\n'
                  '• Purchase orders that this invoice fulfills\n'
                  '• Shipping notices related to this invoice\n'
                  '• Payment receipts for this invoice'
            ),
            
            _buildSection(
              title: 'Create Document Link',
              content: 'This function creates a relationship between two documents.\n\n'
                  'Example inputs:\n'
                  '• Source Type: po\n'
                  '• Source ID: PO-67890\n'
                  '• Target Type: invoice\n'
                  '• Target ID: INV-12345\n'
                  '• Relationship Type: fulfills\n\n'
                  'Common relationship types include:\n'
                  '• references - General reference to another document\n'
                  '• replaces - Indicates a document that supersedes another\n'
                  '• fulfills - Indicates a document that fulfills a request in another document\n'
                  '• contains - Indicates a document that contains items from another document'
            ),
            
            _buildSection(
              title: 'Find Original Document for EPC',
              content: 'This function finds the original document where a specific item (identified by its EPC) '
                  'first appeared in the system.\n\n'
                  'Example inputs:\n'
                  '• EPC: urn:epc:id:sgtin:0614141.107346.2017\n'
                  '• Document Type (optional): po\n\n'
                  'This is useful for tracing the provenance of an item back to its original '
                  'documentation, which can be important for authenticity verification or recall situations.'
            ),
            
            _buildSection(
              title: 'Real-World Example Workflow',
              content: '1. A manufacturer creates a purchase order (PO-67890)\n\n'
                  '2. When goods are produced, they are assigned EPCs and associated with a shipping notice (SHP-54321)\n\n'
                  '3. You can create a document link between them:\n'
                  '   • Source: po, PO-67890\n'
                  '   • Target: desadv, SHP-54321\n'
                  '   • Relationship: fulfills\n\n'
                  '4. When an invoice is generated, you can link it to the shipping notice:\n'
                  '   • Source: invoice, INV-12345\n'
                  '   • Target: desadv, SHP-54321\n'
                  '   • Relationship: references\n\n'
                  '5. Later, you can query the system to find all documents related to a specific EPC '
                  'or to trace the relationships between business documents.'
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
