import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class Gs1SplitViewRightPane<TCubit extends StateStreamable<TState>, TState>
    extends StatelessWidget {
  const Gs1SplitViewRightPane({
    required this.selectedId,
    required this.useEmbeddedCreate,
    required this.isCreateMode,
    required this.isEmptyNoMatch,
    required this.idsFromState,
    required this.detailViewBuilder,
    required this.detailAwaitBuilder,
    required this.detailCreateBuilder,
    required this.isListLoading,
    required this.createHeaderText,
    required this.closeCreateTooltip,
    required this.onCloseCreate,
    required this.onEmbeddedCreateSuccess,
    super.key,
  });

  final String? selectedId;
  final bool useEmbeddedCreate;
  final bool isCreateMode;
  final bool Function(TState state) isEmptyNoMatch;
  final Iterable<String>? Function(TState state) idsFromState;
  final Widget Function(BuildContext context, String id) detailViewBuilder;
  final Widget Function(BuildContext context, {required bool listLoading})
  detailAwaitBuilder;
  final Widget Function(BuildContext context, VoidCallback onSuccess)?
  detailCreateBuilder;
  final bool Function(TState state)? isListLoading;
  final String createHeaderText;
  final String closeCreateTooltip;
  final VoidCallback onCloseCreate;
  final VoidCallback onEmbeddedCreateSuccess;

  @override
  Widget build(BuildContext context) {
    final viewPane = BlocBuilder<TCubit, TState>(
      builder: (context, state) {
        final listLoading = isListLoading?.call(state) ?? false;
        if (listLoading) {
          return detailAwaitBuilder(context, listLoading: true);
        }
        if (isEmptyNoMatch(state)) {
          return detailAwaitBuilder(context, listLoading: false);
        }
        final ids = idsFromState(state)?.toList(growable: false);
        final effective =
            selectedId ?? (ids != null && ids.isNotEmpty ? ids.first : null);
        if (effective == null) {
          return detailAwaitBuilder(context, listLoading: false);
        }
        return detailViewBuilder(context, effective);
      },
    );
    if (!useEmbeddedCreate) return viewPane;

    final colors = context.colors;
    final createPane = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          elevation: 2,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(2),
            bottomRight: Radius.circular(2),
          ),
          color: colors.primary,
          child: Padding(
            padding: EdgeInsets.only(
              top: kIsWeb ? 12 : 0,
              left: context.gutter,
              right: context.gutter,
              bottom: 8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    createHeaderText,
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  tooltip: closeCreateTooltip,
                  color: Colors.white,
                  onPressed: onCloseCreate,
                  icon: const TraqIcon(AppAssets.iconX),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(child: detailCreateBuilder!(context, onEmbeddedCreateSuccess)),
      ],
    );
    return IndexedStack(
      index: isCreateMode ? 1 : 0,
      children: [viewPane, createPane],
    );
  }
}
