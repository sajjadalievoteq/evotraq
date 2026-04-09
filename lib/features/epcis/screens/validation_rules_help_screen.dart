import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

/// Help screen for Validation Rules Management
class ValidationRulesHelpScreen extends StatelessWidget {
  /// Constructor
  const ValidationRulesHelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Validation Rules Help'),
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
            code: const TextStyle(
              fontFamily: 'monospace',
              backgroundColor: Color(0xFFF5F5F5),
              fontSize: 14,
            ),
            codeblockDecoration: const BoxDecoration(
              color: Color(0xFFF5F5F5),
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
            ),
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
# Validation Rules Management

## Overview
Validation Rules are powerful tools that allow you to define custom business logic to validate EPCIS events. The TraqTrace system includes a **Dynamic Rule Engine** that executes JavaScript expressions against EPCIS events to ensure data quality and compliance.

## Key Features
- **17 Pre-defined Rules**: Standard GS1 EPCIS compliance rules
- **Custom Rules**: Create your own validation logic
- **JavaScript Expressions**: Powerful expression engine for complex validation
- **Event Type Specific**: Rules can target specific EPCIS event types
- **Severity Levels**: ERROR, WARNING, and INFO classifications
- **Real-time Validation**: Rules execute during event processing

---

## Understanding Validation Rules

### Rule Components
Every validation rule consists of:

- **Name**: Descriptive name for the rule
- **Description**: Detailed explanation of what the rule validates
- **Event Type**: Which EPCIS events this rule applies to (All, ObjectEvent, TransactionEvent, etc.)
- **Severity**: ERROR (blocks processing), WARNING (logs issue), INFO (informational)
- **Rule Expression**: JavaScript code that returns true/false
- **Error Message**: Message displayed when rule fails
- **Priority**: Execution order (lower numbers run first)

### Event Types
- **All**: Rule applies to all EPCIS event types
- **ObjectEvent**: Rules for object tracking events
- **TransactionEvent**: Rules for business transaction events
- **AggregationEvent**: Rules for packaging/aggregation events
- **TransformationEvent**: Rules for manufacturing transformation events

---

## JavaScript Expression Engine

### Available Context Variables
When writing rule expressions, you have access to these event properties:

#### Common Properties (All Events)
```javascript
eventId          // Unique event identifier
eventTime        // When the event occurred
businessStep     // Business process step
disposition      // Current state/disposition
readPoint        // Location where event was captured
businessLocation // Business location
action           // Event action (ADD, OBSERVE, DELETE)
```

#### Object/Transaction Event Properties
```javascript
epcList          // Array of EPC identifiers
epcCount         // Number of EPCs (helper)
quantityList     // Array of quantity objects
quantityCount    // Number of quantities (helper)
sourceList       // Array of source locations
destinationList  // Array of destination locations
```

#### Transaction Event Specific
```javascript
bizTransactionList // Array of business transactions
parentID          // Parent identifier
```

#### Aggregation Event Specific
```javascript
parentID         // Parent container identifier
childEPCs        // Array of child EPC identifiers
```

#### Transformation Event Specific
```javascript
inputEPCList        // Input EPC identifiers
outputEPCList       // Output EPC identifiers
inputQuantityList   // Input quantities
outputQuantityList  // Output quantities
transformationID    // Transformation identifier
```

### Helper Functions
The system provides built-in helper functions:

```javascript
// Null/empty checks
isEmpty(value)           // Returns true if null, undefined, or empty
isNotEmpty(value)        // Returns true if not null/undefined/empty

// Format validation
isValidGLN(gln)         // Validates 13-digit GLN format
isValidEPC(epc)         // Validates GS1 EPC URI format

// Date/time validation
isInFuture(dateTime)    // Checks if date is in the future
isInPast(dateTime)      // Checks if date is in the past

// Collection helpers
contains(array, value)   // Checks if array contains value
stringContains(str, sub) // Checks if string contains substring

// Business validation
isValidBusinessStep(step)   // Validates against GS1 CBV vocabulary
isValidDisposition(disp)    // Validates against GS1 CBV vocabulary
```

---

## Rule Expression Examples

### Basic Validation Examples

#### Required Field Validation
```javascript
// Event time is required
eventTime != null && eventTime != undefined

// Business step is required and not empty
isNotEmpty(businessStep)

// EPC list must have at least one item
isNotEmpty(epcList) && epcList.length > 0
```

#### Format Validation
```javascript
// Valid GLN format for read point
isEmpty(readPoint) || isValidGLN(readPoint)

// All EPCs must be valid format
isEmpty(epcList) || epcList.every(epc => isValidEPC(epc))

// Business step must be valid GS1 vocabulary
isEmpty(businessStep) || isValidBusinessStep(businessStep)
```

#### Range and Logic Validation
```javascript
// EPC count must be reasonable
epcCount >= 1 && epcCount <= 1000

// Event time cannot be in future
eventTime != null && !isInFuture(eventTime)

// Record time must be after event time
recordTime != null && eventTime != null && recordTime >= eventTime
```

### Advanced Validation Examples

#### Conditional Logic
```javascript
// If action is ADD, then EPC list is required
action === 'ADD' ? isNotEmpty(epcList) : true

// Commissioning events must have ILMD data
businessStep && businessStep.includes('commissioning') 
  ? isNotEmpty(ilmd) : true

// Transaction events must have business transactions
eventType === 'TransactionEvent' 
  ? isNotEmpty(bizTransactionList) : true
```

#### Complex Business Rules
```javascript
// Shipping events must have destination
businessStep && businessStep.includes('shipping')
  ? isNotEmpty(destinationList) && destinationList.length > 0
  : true

// Aggregation events require parent and children
action === 'ADD' 
  ? isNotEmpty(parentID) && isNotEmpty(childEPCs)
  : true

// Transformation must have input or output
isNotEmpty(inputEPCList) || isNotEmpty(outputEPCList) ||
isNotEmpty(inputQuantityList) || isNotEmpty(outputQuantityList)
```

#### String and Pattern Validation
```javascript
// GLN must be specific format
isEmpty(readPoint) || (
  readPoint.length === 13 && 
  /^[0-9]+\$/.test(readPoint)
)

// EPC must be for specific company
isEmpty(epcList) || epcList.every(epc => 
  epc.includes('0614141') // Company prefix
)

// Business step must be from approved list
isEmpty(businessStep) || [
  'commissioning', 'packing', 'shipping', 'receiving'
].some(step => businessStep.includes(step))
```

---

## Creating Custom Rules

### Step-by-Step Guide

1. **Click the + button** in the floating menu
2. **Choose "Add Custom Rule"**
3. **Fill in basic information**:
   - Name: Descriptive rule name
   - Description: What the rule validates
   - Event Type: Which events to apply to
   - Severity: How critical failures are

4. **Write the JavaScript expression**:
   - Use available context variables
   - Leverage helper functions
   - Return true for valid, false for invalid

5. **Set error message**: Clear message for when rule fails
6. **Test the rule**: Use the expression tester
7. **Save and enable**: Rule will be active immediately

### Best Practices

#### Expression Writing
- **Keep it simple**: Start with basic expressions
- **Use helpers**: Leverage built-in functions
- **Handle nulls**: Always check for null/undefined values
- **Be specific**: Target exact validation needs
- **Comment complex logic**: Use descriptive variable names

#### Error Messages
- **Be specific**: Clearly state what's wrong
- **Provide guidance**: Suggest how to fix the issue
- **Use proper terminology**: Use EPCIS/GS1 terms
- **Keep it concise**: Short, actionable messages

#### Performance
- **Avoid complex loops**: Use built-in array methods
- **Cache calculations**: Store complex calculations in variables
- **Early returns**: Use conditional logic efficiently
- **Test thoroughly**: Validate with real data

---

## Pre-defined Rules Reference

The system includes 17 pre-defined validation rules covering:

### Required Field Rules
- Event Time Required (REQ_001)
- EPC List Required for Object Events (REQ_002)
- Action Required (REQ_003)
- Parent ID Required for Aggregation Events (REQ_004)
- Business Transaction Required for Transaction Events (REQ_005)
- Input/Output Required for Transformation Events (REQ_006)

### Format Validation Rules
- Valid GLN References (REF_001)
- Valid EPC Format (REF_002)
- EPC Existence Check (REF_003)
- Location Authorization (REF_004)

### Business Logic Rules
- Valid Business Step (BIZ_001)
- Valid Disposition (BIZ_002)
- Logical Action Sequence (BIZ_003)
- Mass Balance Validation (BIZ_004)

### Temporal Rules
- Event Time Logic (TIM_001)
- Record Time Validation (TIM_002)
- Event Sequence Validation (TIM_003)

---

## Troubleshooting

### Common Expression Errors
- **Undefined variables**: Check available context
- **Syntax errors**: Validate JavaScript syntax
- **Type mismatches**: Ensure proper type checking
- **Null pointer exceptions**: Use isEmpty() helper

### Rule Not Executing
- **Check if enabled**: Rules must be enabled to execute
- **Verify event type**: Rule must match event type
- **Check priority**: Lower numbers execute first
- **Review expression**: Must return boolean value

### Performance Issues
- **Simplify expressions**: Break complex rules into simpler ones
- **Avoid heavy operations**: Use efficient algorithms
- **Test with data**: Validate with real event data
- **Monitor execution**: Check application logs

---

## Support and Resources

### Documentation
- [GS1 EPCIS Standard](https://www.gs1.org/standards/epcis)
- [GS1 CBV Vocabulary](https://www.gs1.org/standards/cbv)
- [JavaScript Expression Guide](https://developer.mozilla.org/en-US/docs/Web/JavaScript)

### Getting Help
- Check application logs for detailed error messages
- Use the rule expression tester for debugging
- Review existing pre-defined rules for examples
- Contact system administrator for assistance

---

*Last updated: July 17, 2025*
''';
}
