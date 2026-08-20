import 'package:traqtrace_app/features/gs1/sgtin/cubit/sgtin_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/empty_state/app_empty_detail.dart';
import 'package:traqtrace_app/features/gs1/sgtin/cubit/sgtin_cubit.dart';
import 'package:traqtrace_app/features/gs1/sgtin/utils/sgtin_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/sgtin/widgets/sgtin_detail_skeleton.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_form_shimmer_layer.dart';

class SgtinDetailBody extends StatelessWidget {
  const SgtinDetailBody({
    required this.awaitingListSelection,
    required this.embedded,
    required this.onStateChanged,
    required this.content,
    super.key,
  });

  final bool awaitingListSelection;
  final bool embedded;
  final BlocWidgetListener<SGTINState> onStateChanged;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    if (awaitingListSelection) {
      return BlocBuilder<SGTINCubit, SGTINState>(
        builder: (context, state) {
          final listLoading =
              state.status == SGTINStatus.loading ||
              state.status == SGTINStatus.initial;
          final body = listLoading
              ? SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    context.padding.top,
                    context.padding.top,
                    context.padding.top,
                    0,
                  ),
                  child: const Gs1FormShimmerLayer(
                    show: true,
                    formColumn: SizedBox.shrink(),
                    skeleton: SgtinDetailSkeleton(),
                  ),
                )
              : const AppEmptyDetail(
                  title: SgtinUiConstants.awaitingSelectionTitle,
                  subtitle: SgtinUiConstants.awaitingSelectionSubtitle,
                  iconAsset: NavIcons.sgtin,
                );
          return embedded ? body : Scaffold(body: body);
        },
      );
    }
    return BlocListener<SGTINCubit, SGTINState>(
      listenWhen: (previous, current) =>
          current.status != previous.status ||
          current.sgtin != previous.sgtin ||
          current.creationSuccessful != previous.creationSuccessful,
      listener: onStateChanged,
      child: content,
    );
  }
}
