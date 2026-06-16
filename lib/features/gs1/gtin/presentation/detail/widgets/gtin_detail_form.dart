import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_form_shimmer_layer.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_detail_form_skeleton.dart';
import 'package:traqtrace_app/core/widgets/custom_button_widget.dart';

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
    this.fullFormShimmer = false,
  });

  final GlobalKey<FormState> formKey;
  final bool gtinFieldLocked;
  final Widget? unboundSpecSection;
  final Widget industrySection;
  final bool showSubmitButton;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final String submitButtonTitle;

  final bool fullFormShimmer;

  @override
  Widget build(BuildContext context) {
    final formColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (unboundSpecSection != null) ...[unboundSpecSection!],
        const SizedBox(height: 32),
        industrySection,
        const SizedBox(height: 32),
        if (showSubmitButton)
          CustomButtonWidget(
            onTap: isSubmitting ? null : onSubmit,
            title: submitButtonTitle,
          ),
        const SizedBox(height: 32),
      ],
    );

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.only(
        top: context.padding.left,
        right: context.padding.left,
        left: context.padding.left,
      ),
      child: Form(
        key: formKey,
        child: fullFormShimmer
            ? Gs1FormShimmerLayer(
                show: true,
                formColumn: formColumn,
                skeleton: const GtinDetailFormSkeleton(),
              )
            : formColumn,
      ),
    );
  }
}
