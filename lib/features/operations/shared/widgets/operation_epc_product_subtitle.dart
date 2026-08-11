import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/services/reference_data_service.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation_product_name_text.dart';

class OperationEpcProductSubtitle extends StatelessWidget {
  const OperationEpcProductSubtitle({
    super.key,
    required this.epc,
    this.productName,
  });

  final String epc;
  final String? productName;

  @override
  Widget build(BuildContext context) {
    if (productName != null) {
      return OperationProductNameText(name: productName);
    }

    return FutureBuilder<String?>(
      future: getIt<ReferenceDataService>().resolveProductName(epc),
      builder: (context, snapshot) {
        return OperationProductNameText(name: snapshot.data);
      },
    );
  }
}
