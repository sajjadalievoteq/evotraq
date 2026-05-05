import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/services/gs1/gln/gln_service.dart';
import 'package:traqtrace_app/features/gs1/gln/cubit/gln_cubit.dart';
import 'package:traqtrace_app/features/gs1/gln/cubit/gln_state.dart';
import 'package:traqtrace_app/features/gs1/gln/presentation/screens/gln_detail_screen.dart';
import 'package:traqtrace_app/features/gs1/gln/presentation/screens/gln_list_screen.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/gs1_split_view_screen.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/split_or_list_indexed_stack.dart';

/// Main screen for GLN (Global Location Number) functionality
class GLNScreen extends StatefulWidget {
  const GLNScreen({super.key});

  @override
  State<GLNScreen> createState() => _GLNScreenState();
}

class _GLNScreenState extends State<GLNScreen> {
  late final GLNCubit _glnCubit;

  @override
  void initState() {
    super.initState();
    _glnCubit = GLNCubit(glnService: getIt<GLNService>());
  }

  @override
  void dispose() {
    _glnCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _glnCubit,
      child: SplitOrListIndexedStack(
        split: Gs1SplitViewScreen<GLNCubit, GLNState>(
          appBarTitle: GlnUiConstants.appBarManagement,
          fabHeroTag: 'gln_split_view_add_fab',
          fabAddTooltip: 'Add New GLN',
          fabCloseTooltip: 'Close create form',
          createHeaderText: GlnUiConstants.splitCreateHeader,
          closeCreateTooltip: GlnUiConstants.tooltipClose,
          emptyNoMatchText: GlnUiConstants.emptyNoMatchSearch,
          listenWhenListChanged: (previous, current) =>
              previous.glns != current.glns,
          idsFromState: (s) => s.glns.map((g) => g.glnCode),
          createdIdFromState: (s) => s.selectedGLN?.glnCode,
          isEmptyNoMatch: (s) => s.status == GLNStatus.success && s.glns.isEmpty,
          listBuilder: (context,
                  {required onSelect,
                  required bindRefresh,
                  required onRequestCreate}) =>
              GLNListScreen(
            embedded: true,
            onBindRefresh: bindRefresh,
            onEmbeddedCreate: onRequestCreate,
            onSelectGln: onSelect,
          ),
          detailViewBuilder: (context, code) => GLNDetailScreen(
            key: ValueKey(code),
            glnId: code,
            isEditing: false,
            embedded: true,
          ),
          detailCreateBuilder: (context, onSuccess) => GLNDetailScreen(
            key: const ValueKey('__gln_embedded_new__'),
            isEditing: true,
            embedded: true,
            onEmbeddedActionSuccess: onSuccess,
          ),
          detailAwaitBuilder: (context) => const GLNDetailScreen(
            key: ValueKey('__gln_split_await_list__'),
            glnId: null,
            isEditing: false,
            embedded: true,
            awaitingListSelection: true,
          ),
        ),
        fallback: const GLNListScreen(),
      ),
    );
  }
}
