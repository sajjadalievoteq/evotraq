import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/features/shared/reference_data/cubit/reference_data_cubit.dart';

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
      return _productNameText(productName);
    }

    return FutureBuilder<String?>(
      future: context.read<ReferenceDataCubit>().resolveProductName(epc),
      builder: (context, snapshot) {
        return _productNameText(snapshot.data);
      },
    );
  }

  Widget _productNameText(String? name) {
    if (name == null || name.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        name,
        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
