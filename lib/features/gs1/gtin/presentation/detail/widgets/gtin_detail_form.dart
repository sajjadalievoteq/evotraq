import 'package:flutter/material.dart';
import 'package:traqtrace_app/shared/widgets/custom_button_widget.dart';

/// Core GTIN master-data form: identity, product, packaging, status, dates, and footer button.
/// Industry extensions are supplied via [industrySection].
class GtinDetailForm extends StatelessWidget {
  const GtinDetailForm({
    super.key,
    required this.formKey,
    required this.gtinFieldLocked,
    this.unboundSpecSection,
    required this.industrySection,
    required this.showSubmitButton,
    required this.isSubmitting,
    required this.onSubmit,
    required this.submitButtonTitle,
  });

  final GlobalKey<FormState> formKey;
  final bool gtinFieldLocked;
  final Widget? unboundSpecSection;
  final Widget industrySection;
  final bool showSubmitButton;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final String submitButtonTitle;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(

      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            if (unboundSpecSection != null) ...[
              const SizedBox(height: 24),
              unboundSpecSection!,
            ],
            const SizedBox(height: 32),
            industrySection,
            const SizedBox(height: 32),
            if (showSubmitButton)
              CustomButtonWidget(
                onTap: isSubmitting ? null : onSubmit,
                title: submitButtonTitle,
              ),
          ],
        ),
      ),
    );
  }
}
