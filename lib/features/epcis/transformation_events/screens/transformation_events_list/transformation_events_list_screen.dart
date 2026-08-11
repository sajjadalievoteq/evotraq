import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/data/models/epcis/transformation_event.dart';
import 'package:traqtrace_app/features/epcis/cubit/transformation_events_cubit.dart';
import 'package:traqtrace_app/features/epcis/widgets/help_widgets/transformation_events_help.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/features/epcis/transformation_events/screens/transformation_events_list/widgets/transformation_events_list.dart';
import 'package:traqtrace_app/features/epcis/transformation_events/screens/transformation_events_list/widgets/transformation_events_quick_info_card.dart';

import '../../../../../core/utils/cbv_display_utils.dart';

part 'transformation_events_list_actions.dart';

class TransformationEventsListScreen extends StatefulWidget {
  const TransformationEventsListScreen({Key? key}) : super(key: key);

  @override
  State<TransformationEventsListScreen> createState() =>
      _TransformationEventsListScreenState();
}

class _TransformationEventsListScreenState
    extends State<TransformationEventsListScreen> {
  String? _filterTransformationId;
  String? _filterBizStep;
  String? _filterDisposition;
  String? _filterLocationGLN;
  String? _filterInputEPC;
  String? _filterOutputEPC;
  DateTimeRange? _filterDateRange;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTransformationEvents();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String? transformationId = _filterTransformationId;
        String? bizStep = _filterBizStep;
        String? disposition = _filterDisposition;
        String? locationGLN = _filterLocationGLN;
        String? inputEPC = _filterInputEPC;
        String? outputEPC = _filterOutputEPC;
        DateTimeRange? dateRange = _filterDateRange;

        return AlertDialog(
          title: const Text('Filter Transformation Events'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Transformation ID',
                  ),
                  onChanged: (value) =>
                      transformationId = value.isEmpty ? null : value,
                  controller: TextEditingController(
                    text: _filterTransformationId ?? '',
                  ),
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Input EPC'),
                  onChanged: (value) => inputEPC = value.isEmpty ? null : value,
                  controller: TextEditingController(
                    text: _filterInputEPC ?? '',
                  ),
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Output EPC'),
                  onChanged: (value) =>
                      outputEPC = value.isEmpty ? null : value,
                  controller: TextEditingController(
                    text: _filterOutputEPC ?? '',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _filterTransformationId = transformationId;
                  _filterBizStep = bizStep;
                  _filterDisposition = disposition;
                  _filterLocationGLN = locationGLN;
                  _filterInputEPC = inputEPC;
                  _filterOutputEPC = outputEPC;
                  _filterDateRange = dateRange;
                });
                Navigator.pop(context);
                _loadTransformationEvents();
              },
              child: const Text('Apply'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _filterTransformationId = null;
                  _filterBizStep = null;
                  _filterDisposition = null;
                  _filterLocationGLN = null;
                  _filterInputEPC = null;
                  _filterOutputEPC = null;
                  _filterDateRange = null;
                });
                Navigator.pop(context);
                _loadTransformationEvents();
              },
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => const Dialog(
        insetPadding: EdgeInsets.all(16),
        child: SingleChildScrollView(child: TransformationEventsHelp()),
      ),
    );
  }

  Future<void> _showTrackEPCDialog() async {
    final TextEditingController epcController = TextEditingController();
    bool isSearching = false;
    List<TransformationEvent>? results;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Track EPC Transformations'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: epcController,
                      decoration: const InputDecoration(
                        labelText: 'Enter EPC to track',
                        hintText: 'e.g., https://id.gs1.org/01/…/21/…',
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (isSearching)
                      const Center(child: CircularProgressIndicator())
                    else if (results != null)
                      results!.isEmpty
                          ? const Text(
                              'No transformation events found for this EPC',
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Found ${results!.length} transformation events:',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...results!.map((event) {
                                  return Card(
                                    child: ListTile(
                                      title: Text(
                                        'ID: ${event.transformationID}',
                                      ),
                                      subtitle: Text(
                                        'Date: ${DateFormat.yMMMd().format(event.eventTime)}\n'
                                        'Input EPCs: ${event.inputEPCList.length}\n'
                                        'Output EPCs: ${event.outputEPCList.length}',
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _viewEventDetails(event);
                                      },
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Track'),
                  onPressed: () async {
                    if (epcController.text.isEmpty) return;

                    setState(() {
                      isSearching = true;
                      results = null;
                    });

                    try {
                      final events = await context
                          .read<TransformationEventsCubit>()
                          .trackTransformationsByEPC(epcController.text.trim());

                      setState(() {
                        isSearching = false;
                        results = events;
                      });
                    } catch (e) {
                      setState(() {
                        isSearching = false;
                      });
                      context.showError('Error tracking EPC: $e');
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showInputOutputTrackingDialog() async {
    final TextEditingController inputEpcController = TextEditingController();
    final TextEditingController outputEpcController = TextEditingController();
    bool isSearching = false;
    List<TransformationEvent>? results;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Track Input-Output Relationship'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: inputEpcController,
                      decoration: const InputDecoration(
                        labelText: 'Input EPC',
                        hintText: 'e.g., https://id.gs1.org/01/…/21/…',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: outputEpcController,
                      decoration: const InputDecoration(
                        labelText: 'Output EPC',
                        hintText: 'e.g., https://id.gs1.org/01/…/21/…',
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (isSearching)
                      const Center(child: CircularProgressIndicator())
                    else if (results != null)
                      results!.isEmpty
                          ? const Text('No transformation relationship found')
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Found ${results!.length} linking transformation events:',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...results!.map((event) {
                                  return Card(
                                    child: ListTile(
                                      title: Text(
                                        'ID: ${event.transformationID}',
                                      ),
                                      subtitle: Text(
                                        'Date: ${DateFormat.yMMMd().format(event.eventTime)}\n'
                                        'Step: ${event.businessStep ?? "N/A"}',
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _viewEventDetails(event);
                                      },
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Find Relationship'),
                  onPressed: () async {
                    if (inputEpcController.text.isEmpty ||
                        outputEpcController.text.isEmpty) {
                      return;
                    }

                    setState(() {
                      isSearching = true;
                      results = null;
                    });

                    try {
                      final events = await context
                          .read<TransformationEventsCubit>()
                          .findTransformationsByInputOutput(
                            inputEpcController.text.trim(),
                            outputEpcController.text.trim(),
                          );

                      setState(() {
                        isSearching = false;
                        results = events;
                      });
                    } catch (e) {
                      setState(() {
                        isSearching = false;
                      });
                      context.showError('Error finding relationship: $e');
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _viewEventDetails(TransformationEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Transformation ID: ${event.transformationID}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Event ID: ${event.eventId}'),
              Text(
                'Event Time: ${DateFormat.yMMMd().add_Hms().format(event.eventTime)}',
              ),
              Text(
                'Business Step: ${CbvDisplayUtils.displayBizStep(event.businessStep, fallback: 'N/A')}',
              ),
              Text(
                'Disposition: ${CbvDisplayUtils.displayDisposition(event.disposition, fallback: 'N/A')}',
              ),
              Text(
                'Business Location: ${event.readPoint != null ? event.readPoint.toString() : "N/A"}',
              ),
              const Divider(),
              Text('Input EPCs (${event.inputEPCList.length}):'),
              ...event.inputEPCList.map(
                (epc) => Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text('• $epc', style: const TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(height: 8),
              Text('Output EPCs (${event.outputEPCList.length}):'),
              ...event.outputEPCList.map(
                (epc) => Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text('• $epc', style: const TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transformation Events'),
        actions: [
          IconButton(
            icon: TraqIcon(AppAssets.iconInfo),
            onPressed: _showHelpDialog,
            tooltip: 'Help',
          ),
          IconButton(
            icon: const TraqIcon(AppAssets.iconTarget),
            onPressed: _showTrackEPCDialog,
            tooltip: 'Track EPC',
          ),
          IconButton(
            icon: TraqIcon(AppAssets.iconTransform),
            onPressed: _showInputOutputTrackingDialog,
            tooltip: 'Track Input-Output',
          ),
          IconButton(
            icon: const TraqIcon(AppAssets.iconFilter),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
          IconButton(
            icon: TraqIcon(AppAssets.iconPlus),
            onPressed: _navigateToCreateEvent,
            tooltip: 'Create Transformation Event',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TransformationEventsQuickInfoCard(onLearnMore: _showHelpDialog),
          Expanded(
            child: TransformationEventsList(
              scrollController: _scrollController,
              onRefresh: _refreshData,
              onCreateEvent: _navigateToCreateEvent,
              onOpenEvent: _navigateToEventDetails,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateEvent,
        tooltip: 'Create Transformation Event',
        child: TraqIcon(AppAssets.iconPlus),
      ),
    );
  }
}
