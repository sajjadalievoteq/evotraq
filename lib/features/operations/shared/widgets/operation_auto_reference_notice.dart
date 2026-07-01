import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

/// Read-only notice shown on operation create wizards where the GINC reference
/// is assigned by the backend at submit time.
class OperationAutoReferenceNotice extends StatelessWidget {
  const OperationAutoReferenceNotice({
    super.key,
    required this.operationLabel,
  });

  final String operationLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: TraqIcon(AppAssets.iconSparkle, color: colorScheme.primary),
      title:  Text(
        'Reference will be generated automatically when you submit.',
        style: TextStyle(color: colorScheme.onSurfaceVariant,),
      ),

    );
  }
}
