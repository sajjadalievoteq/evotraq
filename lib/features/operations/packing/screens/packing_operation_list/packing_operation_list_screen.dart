import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_list/packing_operation_list_body.dart';
import 'package:traqtrace_app/features/auth/utils/auth_role_context.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_permissions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_mapper.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_metadata.dart';
import 'package:traqtrace_app/data/services/operations/packing/packing_operation_service.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_search_bar.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_master_list_body.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_list/utils/packing_operation_list_filter.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_list/widgets/packing_advanced_filters_panel.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_list/widgets/packing_quick_filter_dialog.dart';
import 'package:traqtrace_app/features/operations/packing/utils/packing_ui_constants.dart';
import 'package:traqtrace_app/features/operations/shared/cubit/operation_split_cubit.dart';
import 'package:traqtrace_app/features/operations/shared/cubit/operations_cubit.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/list/operation_list_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/list/operation_list_results.dart';

class PackingOperationListScreen extends StatelessWidget {
  const PackingOperationListScreen({
    super.key,
    this.embedded = false,
    this.onSelectOperation,
    this.selectedOperationId,
    this.onLoadingChanged,
    this.onBindRefresh,
    this.onEmbeddedCreate,
  });

  final bool embedded;
  final ValueChanged<String>? onSelectOperation;
  final String? selectedOperationId;
  final ValueChanged<bool>? onLoadingChanged;
  final void Function(VoidCallback refreshFn)? onBindRefresh;
  final VoidCallback? onEmbeddedCreate;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OperationsCubit<Operation>(
        loadErrorMessage:
            'Could not load packing operations. Check your connection and tap Retry.',
        loadMoreErrorMessage:
            'Could not load more operations. Check your connection and try again.',
        fetchList: ({required int page, required int size}) async {
          final pageResult = await getIt<PackingOperationService>()
              .getPackingOperationsPage(page: page, size: size);
          return pageResult.map((r) => r.toOperation());
        },
      )..loadInitial(),
      child: PackingOperationListBody(
        embedded: embedded,
        onSelectOperation: onSelectOperation,
        selectedOperationId: selectedOperationId,
        onLoadingChanged: onLoadingChanged,
        onBindRefresh: onBindRefresh,
        onEmbeddedCreate: onEmbeddedCreate,
      ),
    );
  }
}
