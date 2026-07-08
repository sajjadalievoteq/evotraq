import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_model.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_input_parser.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_validators.dart';

abstract final class SsccCreateFormValidation {
  static List<String> collectErrors({
    required bool isCreating,
    required String? issuingGlnCode,
    required String extensionDigit,
    required String ssccCodeRaw,
    required String ssccMissingMessage,
    required ContentHomogeneity contentHomogeneity,
    required String containedGtin,
    required String containedQuantity,
    String? gsin,
    String? purchaseOrder,
  }) {
    final errors = <String>[];

    void add(String fieldLabel, String? message) {
      if (message != null && message.isNotEmpty) {
        errors.add('$fieldLabel: $message');
      }
    }

    if (isCreating) {
      add('Issuing GLN', validateIssuingGlnRequired(issuingGlnCode));
      add('Extension Digit', validateExtensionDigit(extensionDigit));

      if (ssccCodeRaw.trim().isEmpty) {
        errors.add('SSCC Code: $ssccMissingMessage');
      } else {
        final parsed = SsccInputParser.parseToSsccCode(ssccCodeRaw);
        add('SSCC Code', validateSsccCode(parsed ?? ssccCodeRaw.trim()));
      }
    }

    _validateContentFields(
      errors: errors,
      contentHomogeneity: contentHomogeneity,
      containedGtin: containedGtin,
      containedQuantity: containedQuantity,
    );

    add('GSIN', validateGsin(gsin));
    add('Purchase Order Number', validatePurchaseOrderNumber(purchaseOrder));

    return errors;
  }

  static List<String> collectFormFieldErrors(GlobalKey<FormState> formKey) {
    final errors = <String>[];
    final formContext = formKey.currentContext;
    if (formContext == null) return errors;

    void visit(Element element) {
      final widget = element.widget;
      if (widget is FormField<String>) {
        final state = (element as StatefulElement).state as FormFieldState<String>;
        if (state.hasError) {
          final errorText = state.errorText;
          if (errorText != null && errorText.isNotEmpty) {
            final label = _labelForFormField(widget) ?? 'Field';
            final message = '$label: $errorText';
            if (!errors.contains(message)) {
              errors.add(message);
            }
          }
        }
      }
      element.visitChildren(visit);
    }

    formContext.visitChildElements(visit);
    return errors;
  }

  static String? _labelForFormField(FormField<String> field) {
    if (field is DropdownButtonFormField<String>) {
      return field.decoration.labelText;
    }
    final decoration = (field as dynamic).decoration;
    if (decoration is InputDecoration) {
      return decoration.labelText;
    }
    return null;
  }

  static void _validateContentFields({
    required List<String> errors,
    required ContentHomogeneity contentHomogeneity,
    required String containedGtin,
    required String containedQuantity,
  }) {
    final gtin = containedGtin.trim();
    final qtyText = containedQuantity.trim();
    final hasGtin = gtin.isNotEmpty;
    final hasQty = qtyText.isNotEmpty;

    if (contentHomogeneity != ContentHomogeneity.MIXED && hasGtin) {
      if (!RegExp(r'^\d{8,14}$').hasMatch(gtin)) {
        errors.add('Contained GTIN: must be 8–14 digits');
      }
    }

    if (contentHomogeneity == ContentHomogeneity.HOMOGENEOUS) {
      if (hasGtin != hasQty) {
        if (!hasGtin) {
          errors.add(
            'Contained GTIN: required when Contained Quantity is provided (XSC-004)',
          );
        }
        if (!hasQty) {
          errors.add(
            'Contained Quantity: required when Contained GTIN is provided (XSC-004)',
          );
        }
      }
      if (hasQty) {
        final qtyErr = validateContainedQuantity(qtyText);
        if (qtyErr != null) {
          errors.add('Contained Quantity: $qtyErr');
        }
      }
    }

    if (contentHomogeneity == ContentHomogeneity.MIXED && hasGtin) {
      errors.add(
        'Contained GTIN: must not be set when Content Homogeneity is MIXED (XSC-004)',
      );
    }
  }
}
