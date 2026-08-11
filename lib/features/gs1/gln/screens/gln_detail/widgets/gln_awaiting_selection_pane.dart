import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/empty_state/app_empty_detail.dart';
import 'package:traqtrace_app/features/gs1/gln/cubit/gln_state.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/gln/screens/gln_detail/widgets/gln_detail_form_skeleton.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_form_shimmer_layer.dart';

class GlnAwaitingSelectionPane extends StatelessWidget {
  const GlnAwaitingSelectionPane({super.key, required this.state});

  final GLNState state;

  @override
  Widget build(BuildContext context) {
    final listLoading =
        state.isGlnListLoading || state.status == GLNStatus.initial;
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
          skeleton: const GlnDetailFormSkeleton(),
        ),
      );
    }
    return const AppEmptyDetail(
      title: GlnUiConstants.awaitingSelectionTitle,
      subtitle: GlnUiConstants.awaitingSelectionSubtitle,
      iconAsset: NavIcons.gln,
    );
  }
}
