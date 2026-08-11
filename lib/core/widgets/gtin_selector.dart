import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/gtin_selector_body.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_model.dart';
import 'package:traqtrace_app/data/services/gs1/gtin/gtin_service.dart';
import 'package:traqtrace_app/features/gs1/gtin/cubit/gtin_cubit.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

class GtinSelector extends StatelessWidget {
  final String label;
  final String? hintText;
  final GTIN? initialValue;
  final String? initialGtinCode;
  final List<GTIN>? initialGtins;
  final Function(GTIN?) onChanged;
  final bool isRequired;
  final String? errorText;
  final bool readOnly;

  const GtinSelector({
    super.key,
    required this.label,
    this.hintText,
    this.initialValue,
    this.initialGtinCode,
    this.initialGtins,
    required this.onChanged,
    this.isRequired = false,
    this.errorText,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    if (readOnly) {
      final code = initialValue?.gtinCode ?? initialGtinCode ?? '';
      final productName = initialValue?.productName ?? '';
      final displayText = code.isNotEmpty
          ? (productName.isNotEmpty ? '$code — $productName' : code)
          : '';
      return TextFormField(
        initialValue: displayText,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label + (isRequired ? ' *' : ''),
          border: const OutlineInputBorder(),
          prefixIcon: TraqIcon(AppAssets.iconQr),
        ),
      );
    }

    return BlocProvider(
      create: (_) => GTINCubit(gtinService: getIt<GTINService>()),
      child: GtinSelectorBody(
        label: label,
        hintText: hintText,
        initialValue: initialValue,
        initialGtins: initialGtins,
        onChanged: onChanged,
        isRequired: isRequired,
        errorText: errorText,
      ),
    );
  }
}
