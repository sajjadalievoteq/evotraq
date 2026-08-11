import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/empty_state/app_empty_detail.dart';
import 'package:traqtrace_app/features/gs1/gtin/cubit/gtin_state.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/gtin_detail_form_skeleton.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_form_shimmer_layer.dart';

class GtinAwaitingSelectionPane extends StatelessWidget {
  const GtinAwaitingSelectionPane({super.key, required this.state});

  final GTINState state;

  @override
  Widget build(BuildContext context) {
    final listLoading =
        state.isGtinListLoading || state.status == GTINStatus.initial;
    if (listLoading) {
      return SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          context.padding.top,
          context.padding.top,
          context.padding.top,
          0,
        ),
        child: Gs1FormShimmerLayer(
          show: true,
          formColumn: const SizedBox.shrink(),
          skeleton: const GtinDetailFormSkeleton(),
        ),
      );
    }
    return const AppEmptyDetail(
      title: GtinUiConstants.awaitingSelectionTitle,
      subtitle: GtinUiConstants.awaitingSelectionSubtitle,
      iconAsset: NavIcons.gtin,
    );
  }
}
