import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/features/admin/user_management/cubit/user_management_cubit.dart';
import 'package:traqtrace_app/features/admin/user_management/cubit/user_management_state.dart';
import 'package:traqtrace_app/data/models/user_management/user_management_models.dart';
import '../../../../../../core/consts/app_consts.dart';
import '../widgets/user_approval_card.dart';
import '../widgets/user_approvals_loading_view.dart';
import '../widgets/user_approval_reject_dialog.dart';
import '../widgets/user_approvals_header_section.dart';
import '../../users/widgets/user_management_constants.dart';
import '../../users/widgets/user_management_section_width.dart';
import 'package:traqtrace_app/core/widgets/background_container_widget.dart';
import 'package:traqtrace_app/shared/layout/layout_manager.dart';
import 'package:traqtrace_app/shared/widgets/custom_snackbar_widget.dart';
import 'dart:async';

class ApprovalsScreen extends StatefulWidget {
  const ApprovalsScreen({super.key});

  @override
  State<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends State<ApprovalsScreen> {
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
    context.showSuccess(UserManagementConstants.approveUserSuccess);
  }

  Future<void> _rejectUser(UserResponse user) async {
    final cubit = context.read<UserManagementCubit>();
    await cubit.rejectUser(user.id);
    if (!mounted || cubit.state.status == UserManagementStatus.error) {
      return;
    }
    context.showSuccess(UserManagementConstants.rejectUserSuccess);
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

  bool _matchesSearch(UserResponse user, String query) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase();
    return user.username.toLowerCase().contains(q) ||
        user.email.toLowerCase().contains(q) ||
        user.firstName.toLowerCase().contains(q) ||
        user.lastName.toLowerCase().contains(q) ||
        ('${user.firstName} ${user.lastName}').toLowerCase().contains(q);
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundContainerWidget(
      showAppBar: true,
      appBarTitle: UserManagementConstants.approvalsPageTitle,
      showDrawer: true,
      child: BlocConsumer<UserManagementCubit, UserManagementState>(
        listener: (context, state) {
          if (state.status == UserManagementStatus.error) {
            if (_isRefreshing) {
              setState(() => _isRefreshing = false);
            }
            context.showError(
              state.error ?? UserManagementConstants.approvalsErrorMessage,
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
                      .where((user) => _matchesSearch(user, query))
                      .toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  UserManagementSectionWidth(
                    child: UserApprovalsHeaderSection(
                      pendingCount: filteredApprovals.length,
                      searchController: _searchController,
                      onRefresh: _refreshApprovalsList,
                      isRefreshing: _isRefreshing,
                    ),
                  ),
                  const SizedBox(height: Constants.spacing),
                  Expanded(
                    child: _ApprovalsContent(
                      approvals: filteredApprovals,
                      onApprove: _approveUser,
                      onReject: _showRejectDialog,
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

class _ApprovalsContent extends StatelessWidget {
  const _ApprovalsContent({
    required this.approvals,
    required this.onApprove,
    required this.onReject,
  });

  final List<UserResponse> approvals;
  final ValueChanged<UserResponse> onApprove;
  final ValueChanged<UserResponse> onReject;

  @override
  Widget build(BuildContext context) {
    if (approvals.isEmpty) {
      return Center(
        child: Text(
          UserManagementConstants.noPendingApprovals,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[700],
              ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      itemCount: approvals.length,
      padding: const EdgeInsets.all(0),

      itemBuilder: (context, index) {
        final approval = approvals[index];
        return UserManagementSectionWidth(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Column(
              children: [
                if (index == 0)
                  const SizedBox(height:Constants.spacing),
                UserApprovalCard(
                  user: approval,
                  onApprove: onApprove,
                  onReject: onReject,
                ),
                SizedBox(
                  height: index == approvals.length - 1
                      ? 0
                      : Constants.spacing,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
