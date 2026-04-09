import 'package:flutter/material.dart';

/// Help widget for Object Event Form that explains GS1 EPCIS Object Event fields
class ObjectEventHelpWidget extends StatelessWidget {
  /// Constructor
  const ObjectEventHelpWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Object Event Overview',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'An Object Event represents an observation of, or action upon, one or more physical or digital objects identified by EPCs (Electronic Product Codes) or EPC classes in a GS1 EPCIS system.',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Required Fields',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            _buildRequiredFieldsSection(),
            const SizedBox(height: 16.0),
            const Text(
              'Object Identification Options',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            _buildObjectIdentificationSection(),
            const SizedBox(height: 16.0),
            const Text(
              'Actions Explained',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            _buildActionsSection(),
            const SizedBox(height: 16.0),
            const Text(
              'Business Steps and Dispositions',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            _buildBusinessStepsSection(),
            const SizedBox(height: 16.0),
            _buildDispositionsSection(),
            const SizedBox(height: 16.0),
            const Text(
              'Instance/Lot Master Data (ILMD)',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            _buildILMDSection(),
            const SizedBox(height: 16.0),
            const Text(
              'Additional Information',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'For more information on EPCIS Object Events, refer to the GS1 EPCIS 2.0 standard documentation at gs1.org/standards/epcis.',
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequiredFieldsSection() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRequiredField(
              'Event Time & Time Zone',
              'The date, time, and time zone when the event occurred. Must be specified in ISO 8601 format.',
            ),
            _buildRequiredField(
              'Action',
              'Specifies how this event relates to the lifecycle of the objects. Must be one of: ADD, OBSERVE, or DELETE.',
            ),
            _buildRequiredField(
              'Business Step',
              'Identifies the specific business step within a business process that this event represents. Standard values are defined in the GS1 Core Business Vocabulary (CBV).',
            ),
            _buildRequiredField(
              'Disposition',
              'Indicates the business condition of the objects following the event. Standard values are defined in the GS1 Core Business Vocabulary (CBV).',
            ),
            _buildRequiredField(
              'Business Location GLN',
              'The location where the objects are after the event occurred, specified as a Global Location Number (GLN).',
            ),
            _buildRequiredField(
              'EPCs, EPC Classes, or Quantity',
              'At least one of these must be present to identify what objects the event pertains to.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObjectIdentificationSection() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpItem(
              'EPCs (Instance-Level)',
              'Electronic Product Codes that uniquely identify individual items. Use this for serialized items like SGTINs (Serialized GTINs). Format example: urn:epc:id:sgtin:0614141.107346.2017',
            ),
            _buildHelpItem(
              'EPC Classes (Class-Level)',
              'Identifies a class of objects without serialization. Used for product classes. Format example: urn:epc:idpat:sgtin:0614141.107346.*',
            ),
            _buildHelpItem(
              'Quantities',
              'Used for class-level identification with a specific quantity and unit of measure. Useful when tracking quantities of non-serialized products.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpItem(
              'ADD',
              'Objects have physically become part of the visible universe of objects that can be tracked. Used for commissioning events, when an object gets its unique identifier or enters the supply chain.',
            ),
            _buildHelpItem(
              'OBSERVE',
              'Objects have been observed during a business process step. This is the most common action for regular tracking events.',
            ),
            _buildHelpItem(
              'DELETE',
              'Objects have physically disappeared from the visible universe. Used for product decommissioning or consumption events.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessStepsSection() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Common Business Steps for Object Events:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            _buildHelpItem(
              'commissioning',
              'The process of associating an instance-level identifier with a specific physical object or starting the life of an object.',
            ),
            _buildHelpItem(
              'shipping',
              'The process of moving objects from one location to another.',
            ),
            _buildHelpItem(
              'receiving',
              'The process of accepting responsibility for objects that have arrived at a location.',
            ),
            _buildHelpItem(
              'inspecting',
              'The process of examining objects for compliance, quality, or other characteristics.',
            ),
            _buildHelpItem(
              'storing',
              'The process of placing objects into inventory or storage.',
            ),
            _buildHelpItem(
              'dispensing',
              'The process of providing objects to a consumer or end user.',
            ),
            _buildHelpItem(
              'decommissioning',
              'The process of ending the life of an object identifier or removing it from the supply chain.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDispositionsSection() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Common Dispositions for Object Events:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            _buildHelpItem(
              'active',
              'The object is in operational use.',
            ),
            _buildHelpItem(
              'available',
              'The object is available for future processing.',
            ),
            _buildHelpItem(
              'in_progress',
              'The object is undergoing processing.',
            ),
            _buildHelpItem(
              'in_transit',
              'The object is in the process of being transported from one location to another.',
            ),
            _buildHelpItem(
              'sold',
              'The object has been sold.',
            ),
            _buildHelpItem(
              'expired',
              'The object has expired.',
            ),
            _buildHelpItem(
              'recalled',
              'The object has been recalled by the manufacturer, government, etc.',
            ),
            _buildHelpItem(
              'damaged',
              'The object has been damaged during handling.',
            ),
            _buildHelpItem(
              'destroyed',
              'The object has been permanently destroyed.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildILMDSection() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Instance/Lot Master Data (ILMD) is information that describes a specific instance or lot of products at the time of commissioning. ILMD is typically only included with ADD actions.',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Examples of common ILMD attributes:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            _buildHelpItem(
              'lotNumber',
              'A lot or batch number associated with the product.',
            ),
            _buildHelpItem(
              'expirationDate',
              'The date when the product expires.',
            ),
            _buildHelpItem(
              'productionDate',
              'The date when the product was manufactured.',
            ),
            _buildHelpItem(
              'bestBeforeDate',
              'The date until which the product maintains its best quality.',
            ),
            _buildHelpItem(
              'serialLotNumber',
              'A combined serial and lot number, for tracking both batch and individual items.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequiredField(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(description),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(description),
          const SizedBox(height: 4.0),
        ],
      ),
    );
  }
}
