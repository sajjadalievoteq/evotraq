import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/transaction_events/screens/transaction_document/utils/transaction_document_type_formatter.dart';

class TransactionDocumentDropdownField extends StatelessWidget {
  const TransactionDocumentDropdownField({
    required this.controller,
    required this.options,
    required this.hint,
    this.formatDocumentTypes = false,
    this.includeAnyOption = false,
    super.key,
  });

  final TextEditingController controller;
  final List<String> options;
  final String hint;
  final bool formatDocumentTypes;
  final bool includeAnyOption;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: FormField<String>(
        initialValue: controller.text,
        builder: (state) {
          return InputDecorator(
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              errorText: state.errorText,
            ),
            isEmpty: controller.text.isEmpty,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.text.isNotEmpty ? controller.text : null,
                isDense: true,
                isExpanded: true,
                hint: Text(hint),
                onChanged: (value) {
                  if (value != null) {
                    controller.text = value;
                    state.didChange(value);
                  }
                },
                items: [
                  if (includeAnyOption)
                    const DropdownMenuItem<String>(
                      value: '',
                      child: Text('Any document type'),
                    ),
                  ...options.map(
                    (value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        formatDocumentTypes
                            ? TransactionDocumentTypeFormatter.displayName(
                                value,
                              )
                            : value,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
