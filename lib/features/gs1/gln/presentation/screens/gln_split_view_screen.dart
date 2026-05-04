import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/config/constants.dart';
import 'package:traqtrace_app/core/theme/color_manager.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/features/gs1/gln/cubit/gln_cubit.dart';
import 'package:traqtrace_app/features/gs1/gln/cubit/gln_state.dart';
import 'package:traqtrace_app/features/gs1/gln/presentation/screens/gln_detail_screen.dart';
import 'package:traqtrace_app/features/gs1/gln/presentation/screens/gln_list_screen.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/master_detail_split_layout.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_ui_constants.dart';

class GLNSplitViewScreen extends StatefulWidget {
  const GLNSplitViewScreen({super.key});

  @override
  State<GLNSplitViewScreen> createState() => _GLNSplitViewScreenState();
}

class _GLNSplitViewScreenState extends State<GLNSplitViewScreen> {
  String? _selectedGlnCode;
  bool _isAddingGln = false;
  VoidCallback? _refreshList;

  void _onFabPressed() {
    if (_isAddingGln) {
      setState(() => _isAddingGln = false);
      return;
    }
    setState(() => _isAddingGln = true);
  }

  void _onEmbeddedSaveSuccess() {
    final cubit = context.read<GLNCubit>();
    final newCode = cubit.state.selectedGLN?.glnCode;
    setState(() {
      _isAddingGln = false;
      if (newCode != null) {
        _selectedGlnCode = newCode;
      }
    });
    _refreshList?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(GlnUiConstants.appBarManagement)),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: _onFabPressed,
        tooltip: _isAddingGln ? 'Close create form' : 'Add New GLN',
        child: Icon(_isAddingGln ? Icons.close : Icons.add),
      ),
      body: BlocListener<GLNCubit, GLNState>(
        listenWhen: (previous, current) => previous.glns != current.glns,
        listener: (context, state) {
          if (_isAddingGln) return;
          final glns = state.glns;

          if (glns.isEmpty) {
            if (_selectedGlnCode != null) {
              setState(() => _selectedGlnCode = null);
            }
            return;
          }

          if (_selectedGlnCode == null) {
            setState(() => _selectedGlnCode = glns.first.glnCode);
            return;
          }

          final stillInResults =
              glns.any((g) => g.glnCode == _selectedGlnCode);
          if (!stillInResults) {
            setState(() => _selectedGlnCode = glns.first.glnCode);
          }
        },
        child: MasterDetailSplitLayout(
          isCreateMode: _isAddingGln,
          list: GLNListScreen(
            embedded: true,
            onBindRefresh: (fn) => _refreshList = fn,
            onEmbeddedCreate: () => setState(() => _isAddingGln = true),
            onSelectGln: (glnCode) {
              if (glnCode == _selectedGlnCode && !_isAddingGln) {
                return;
              }
              setState(() {
                _isAddingGln = false;
                _selectedGlnCode = glnCode;
              });
            },
          ),
          detail: _buildRightPane(),
        ),
      ),
    );
  }

  Widget _buildRightPane() {
    if (_isAddingGln) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: ColorManager.primary(context),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: Constants.spacing),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      GlnUiConstants.splitCreateHeader,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    tooltip: GlnUiConstants.tooltipClose,
                    color: Colors.white,
                    onPressed: () {
                      setState(() => _isAddingGln = false);
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: GLNDetailScreen(
              key: const ValueKey('__gln_embedded_new__'),
              isEditing: true,
              embedded: true,
              onEmbeddedActionSuccess: _onEmbeddedSaveSuccess,
            ),
          ),
        ],
      );
    }

    return BlocBuilder<GLNCubit, GLNState>(
      builder: (context, state) {
        if (state.status == GLNStatus.success && state.glns.isEmpty) {
          return Center(
            child: Text(GlnUiConstants.emptyNoMatchSearch),
          );
        }

        final effectiveCode = _selectedGlnCode ??
            (state.glns.isNotEmpty ? state.glns.first.glnCode : null);

        if (effectiveCode != null) {
          return GLNDetailScreen(
            key: ValueKey(effectiveCode),
            glnId: effectiveCode,
            isEditing: false,
            embedded: true,
          );
        }

        return GLNDetailScreen(
          key: const ValueKey('__gln_split_await_list__'),
          glnId: null,
          isEditing: false,
          embedded: true,
          awaitingListSelection: true,
        );
      },
    );
  }
}
