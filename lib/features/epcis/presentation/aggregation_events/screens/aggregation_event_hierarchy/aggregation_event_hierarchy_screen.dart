import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/app_loading_indicator.dart';
import 'package:traqtrace_app/data/models/epcis/aggregation_event.dart';
import 'package:traqtrace_app/features/epcis/cubit/aggregation_events_cubit.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_hierarchy/widgets/aggregation_event_hierarchy_content.dart';

class AggregationEventHierarchyScreen extends StatefulWidget {
  const AggregationEventHierarchyScreen({
    super.key,
    required this.epc,
    this.isParent = true,
  });

  final String epc;
  final bool isParent;

  @override
  State<AggregationEventHierarchyScreen> createState() =>
      _AggregationEventHierarchyScreenState();
}

class _AggregationEventHierarchyScreenState
    extends State<AggregationEventHierarchyScreen> {
  bool _loading = false;
  String? _error;
  List<String> _hierarchyContents = [];
  List<AggregationEvent> _historyEvents = [];
  bool _isVerified = false;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final cubit = context.read<AggregationEventsCubit>();

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (widget.isParent) {
        _hierarchyContents = await cubit.loadContainerContents(widget.epc);
      } else {
        try {
          final parentEvent = await cubit.findCurrentParentOfChild(widget.epc);
          if (parentEvent != null) {
            _hierarchyContents = [parentEvent.parentID];
          }
        } catch (e) {
          _hierarchyContents = [];
        }
      }

      if (widget.isParent) {
        await cubit.trackParentHistory(widget.epc);
        _historyEvents = cubit.state.aggregationEvents;
      } else {
        await cubit.trackChildHistory(widget.epc);
        _historyEvents = cubit.state.aggregationEvents;
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _verifyHierarchy() async {
    setState(() {
      _isVerifying = true;
    });

    try {
      final cubit = context.read<AggregationEventsCubit>();
      _isVerified = await cubit.verifyHierarchy(widget.epc);

      if (mounted) {
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              _isVerified ? 'Verification Successful' : 'Verification Failed',
            ),
            content: Text(
              _isVerified
                  ? 'The hierarchy integrity for ${widget.epc} has been verified. All parent-child relationships are consistent.'
                  : 'Failed to verify hierarchy integrity. There may be missing or inconsistent events in the history.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error verifying hierarchy: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isVerifying = false;
      });
    }
  }

  void _navigateToEpc(String epc, {required bool isParent}) {
    context.push(
      '/epcis/aggregation-events/hierarchy/$epc',
      extra: {'epc': epc, 'isParent': isParent},
    );
  }

  void _viewEventDetails(String eventId) {
    context.push('/epcis/aggregation-events/$eventId');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text('${widget.isParent ? 'Container' : 'Item'} Hierarchy'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _loading
          ? const Center(child: AppLoadingIndicator())
          : AggregationEventHierarchyContent(
              epc: widget.epc,
              isParent: widget.isParent,
              error: _error,
              hierarchyContents: _hierarchyContents,
              historyEvents: _historyEvents,
              isVerified: _isVerified,
              onRetry: _loadData,
              onNavigateToEpc: _navigateToEpc,
              onViewEventDetails: _viewEventDetails,
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isVerifying ? null : _verifyHierarchy,
        label: _isVerifying
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              )
            : const Text('Verify Hierarchy'),
        icon: const Icon(Icons.verified),
      ),
    );
  }
}
