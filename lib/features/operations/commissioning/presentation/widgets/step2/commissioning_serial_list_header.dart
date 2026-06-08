import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';
import 'package:traqtrace_app/shared/widgets/custom_text_button_widget.dart';

class CommissioningSerialListHeader extends StatelessWidget {
  const CommissioningSerialListHeader({
    super.key,
    required this.count,
    required this.onClearAll,
  });

  final int count;
  final VoidCallback? onClearAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SectionLabel('Serial Numbers ($count)', padding: EdgeInsets.zero),
        if (onClearAll != null)
          CustomTextButtonWidget(
            title: 'Clear All',
            onTap: onClearAll!,
          ),
      ],
    );
  }
}
