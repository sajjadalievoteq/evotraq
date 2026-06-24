import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';
import 'package:traqtrace_app/core/widgets/background_container_widget.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/data/models/user_management/user_management_models.dart';
import 'package:traqtrace_app/features/admin/user_approval/screens/approvals/widgets/approvals_list_content.dart';
import 'package:traqtrace_app/features/admin/user_approval/screens/approvals/widgets/user_approval_reject_dialog.dart';
import 'package:traqtrace_app/features/admin/user_approval/screens/approvals/widgets/user_approvals_header_section.dart';
import 'package:traqtrace_app/features/admin/user_approval/screens/approvals/widgets/user_approvals_loading_view.dart';
import 'package:traqtrace_app/features/admin/user_approval/utils/user_approval_constants.dart';
import 'package:traqtrace_app/features/admin/user_approval/utils/user_approval_search_utils.dart';
import 'package:traqtrace_app/features/admin/user_management/cubit/user_management_cubit.dart';
import 'package:traqtrace_app/features/admin/user_management/cubit/user_management_state.dart';
import 'dart:async';

class ApprovalsScreen extends StatelessWidget {
  const ApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<UserManagementCubit>(),
      child: const _ApprovalsView(),
    );
  }
}

class _ApprovalsView extends StatefulWidget {
  const _ApprovalsView();

  @override
  State<_ApprovalsView> createState() => _ApprovalsViewState();
}

class _ApprovalsViewState extends State<_ApprovalsView> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    context.read<UserManagementCubit>().loadApprovals();

    _searchController.addListener(() {
      _searchDebounce?.cancel();
      _searchDebounce = Timer(const Duration(milliseconds: 450), () {
        if (mounted) setState(() {});
      });
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshApprovalsList() async {
    setState(() => _isRefreshing = true);
    try {
      await context.read<UserManagementCubit>().loadApprovals();
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  Future<void> _approveUser(UserResponse user) async {
    final cubit = context.read<UserManagementCubit>();
    await cubit.approveUser(user.id);
    if (!mounted || cubit.state.status == UserManagementStatus.error) {
      return;
    }
    context.showSuccess(UserApprovalConstants.approveUserSuccess);
  }

  Future<void> _rejectUser(UserResponse user) async {
    final cubit = context.read<UserManagementCubit>();
    await cubit.rejectUser(user.id);
    if (!mounted || cubit.state.status == UserManagementStatus.error) {
      return;
    }
    context.showSuccess(UserApprovalConstants.rejectUserSuccess);
  }

  Future<void> _showRejectDialog(UserResponse user) async {
    await showDialog<void>(
      context: context,
      builder: (context) => UserApprovalRejectDialog(
        user: user,
        onConfirm: () => _rejectUser(user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundContainerWidget(
      showAppBar: true,
      appBarTitle: UserApprovalConstants.pageTitle,
      showDrawer: true,
      child: BlocConsumer<UserManagementCubit, UserManagementState>(
        listener: (context, state) {
          if (state.status == UserManagementStatus.error) {
            if (_isRefreshing) {
              setState(() => _isRefreshing = false);
            }
            context.showError(
              state.error ?? UserApprovalConstants.errorMessage,
            );
          }
        },
        builder: (context, state) {
          return AppResponsiveBody.builder(
            safeArea: false,
            scrollable: false,
            builder: (context, layout) {
              if (state.status == UserManagementStatus.loading &&
                  state.pendingApprovals.isEmpty) {
                return const UserApprovalsLoadingView();
              }

              final query = _searchController.text.trim();
              final filteredApprovals = query.isEmpty
                  ? state.pendingApprovals
                  : state.pendingApprovals
                      .where((user) => userApprovalMatchesSearch(user, query))
                      .toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  UserApprovalsHeaderSection(
                    pendingCount: filteredApprovals.length,
                    searchController: _searchController,
                    onRefresh: _refreshApprovalsList,
                    isRefreshing: _isRefreshing,
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refreshApprovalsList,
                      child: ApprovalsListContent(
                        approvals: filteredApprovals,
                        onApprove: _approveUser,
                        onReject: _showRejectDialog,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
