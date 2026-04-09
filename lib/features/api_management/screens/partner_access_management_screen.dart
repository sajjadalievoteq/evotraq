import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/api_collection.dart';
import '../providers/partner_access_provider.dart';
import '../cubit/api_collection_cubit.dart';
import '../cubit/api_collection_state.dart';
import '../cubit/api_management_cubit.dart';

/// Screen for managing Partner API Access
/// Allows assigning collection-level and individual API access to partners
class PartnerAccessManagementScreen extends StatefulWidget {
  final String? initialPartnerId;

  const PartnerAccessManagementScreen({super.key, this.initialPartnerId});

  @override
  State<PartnerAccessManagementScreen> createState() =>
      _PartnerAccessManagementScreenState();
}

class _PartnerAccessManagementScreenState
    extends State<PartnerAccessManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedPartnerId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedPartnerId = widget.initialPartnerId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAndLoad();
    });
  }

  void _initializeAndLoad() {
    // Load partners and collections
    context.read<ApiManagementCubit>().loadPartners();
    context.read<ApiCollectionCubit>().loadCollections();

    if (_selectedPartnerId != null) {
      context.read<PartnerAccessCubit>().loadAccessSummary(_selectedPartnerId!);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partner API Access'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.summarize), text: 'Summary'),
            Tab(icon: Icon(Icons.folder_special), text: 'Collection Access'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _selectedPartnerId != null
                ? () => context.read<PartnerAccessCubit>().loadAccessSummary(
                    _selectedPartnerId!,
                  )
                : null,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildPartnerSelector(),
          const Divider(height: 1),
          Expanded(
            child: _selectedPartnerId == null
                ? _buildNoPartnerSelected()
                : TabBarView(
                    controller: _tabController,
                    children: [_buildSummaryTab(), _buildCollectionAccessTab()],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerSelector() {
    return BlocBuilder<ApiManagementCubit, ApiManagementState>(
      builder: (context, state) {
        final partners = state.partners;

        return Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Row(
            children: [
              const Icon(Icons.business),
              const SizedBox(width: 12),
              const Text(
                'Partner:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedPartnerId,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    isDense: true,
                  ),
                  hint: const Text('Select a partner'),
                  items: partners.map((p) {
                    return DropdownMenuItem(
                      value: p.id,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: p.active
                                ? Colors.green
                                : Colors.grey,
                            child: Text(
                              p.companyName.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(p.companyName),
                          if (!p.active) ...[
                            const SizedBox(width: 8),
                            const Chip(
                              label: Text(
                                'Inactive',
                                style: TextStyle(fontSize: 10),
                              ),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedPartnerId = value);
                    if (value != null) {
                      context.read<PartnerAccessCubit>().loadAccessSummary(
                        value,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNoPartnerSelected() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Select a partner to manage API access',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTab() {
    return BlocBuilder<PartnerAccessCubit, PartnerAccessState>(
      buildWhen: (previous, current) =>
          previous.isLoading != current.isLoading ||
          previous.error != current.error ||
          previous.accessSummary != current.accessSummary ||
          previous.collectionAccess != current.collectionAccess ||
          previous.apiAccess != current.apiAccess,
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text('Error: ${state.error}'),
              ],
            ),
          );
        }

        final summary = state.accessSummary;
        if (summary == null) {
          return const Center(child: Text('No access data available'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards
              Row(
                children: [
                  _buildSummaryCard(
                    'Collections',
                    summary.collectionAccessCount.toString(),
                    Icons.folder_special,
                    Colors.blue,
                  ),
                  const SizedBox(width: 16),
                  _buildSummaryCard(
                    'Individual APIs',
                    summary.individualApiAccessCount.toString(),
                    Icons.api,
                    Colors.green,
                  ),
                  const SizedBox(width: 16),
                  _buildSummaryCard(
                    'Total APIs',
                    summary.totalAccessibleApis.toString(),
                    Icons.check_circle,
                    Colors.purple,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick Actions
              const Text(
                'Quick Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      _tabController.animateTo(1);
                      _showGrantCollectionAccessDialog();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Grant Collection Access'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Collection Access Overview
              if (state.collectionAccess.isNotEmpty) ...[
                const Text(
                  'Collection Access',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...state.collectionAccess
                    .take(5)
                    .map(
                      (access) => Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                access.accessLevel == AccessLevel.full
                                ? Colors.green
                                : Colors.orange,
                            child: Icon(
                              access.accessLevel == AccessLevel.full
                                  ? Icons.lock_open
                                  : Icons.tune,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          title: Text(access.collectionName),
                          subtitle: Text(
                            '${access.accessLevel.displayName} • ${access.statusText}',
                          ),
                          trailing: access.isValid
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                )
                              : const Icon(Icons.warning, color: Colors.orange),
                        ),
                      ),
                    ),
                if (state.collectionAccess.length > 5)
                  TextButton(
                    onPressed: () => _tabController.animateTo(1),
                    child: Text(
                      'View all ${state.collectionAccess.length} collections',
                    ),
                  ),
                const SizedBox(height: 24),
              ],

              // Individual API Access Overview
              if (state.apiAccess.isNotEmpty) ...[
                const Text(
                  'Individual API Access',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...state.apiAccess
                    .take(5)
                    .map(
                      (access) => Card(
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getMethodColor(access.httpMethod),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              access.httpMethod,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          title: Text(access.apiName),
                          subtitle: Text(
                            access.externalPath,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                          trailing: access.isValid
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                )
                              : const Icon(Icons.warning, color: Colors.orange),
                        ),
                      ),
                    ),
                if (state.apiAccess.length > 5)
                  TextButton(
                    onPressed: () => _tabController.animateTo(1),
                    child: Text(
                      'View all ${state.apiAccess.length} APIs in Collection Access',
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(title, style: TextStyle(color: color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollectionAccessTab() {
    return BlocBuilder<PartnerAccessCubit, PartnerAccessState>(
      buildWhen: (previous, current) =>
          previous.isLoading != current.isLoading ||
          previous.collectionAccess != current.collectionAccess ||
          previous.apiAccess != current.apiAccess ||
          previous.error != current.error,
      builder: (context, accessState) {
        if (accessState.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Actions Bar
            Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Text(
                    'Collection Access (${accessState.collectionAccess.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _showGrantCollectionAccessDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Grant Access'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // List
            Expanded(
              child: accessState.collectionAccess.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.folder_off,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No collection access granted',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _showGrantCollectionAccessDialog,
                            child: const Text('Grant First Access'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: accessState.collectionAccess.length,
                      itemBuilder: (context, index) {
                        final access = accessState.collectionAccess[index];
                        final cubit = context.read<PartnerAccessCubit>();
                        return _ExpandableCollectionAccessCard(
                          access: access,
                          allApiAccess: accessState.apiAccess,
                          partnerId: _selectedPartnerId!,
                          onEdit: () {
                            // TODO: Implement edit
                          },
                          onRevoke: () =>
                              _confirmRevokeCollectionAccess(access),
                          onApiRevoke: (apiId) async {
                            await cubit.revokeApiAccess(
                              _selectedPartnerId!,
                              apiId,
                            );
                          },
                          onApisAdded: () async {
                            await cubit.loadAccessSummary(_selectedPartnerId!);
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  void _confirmRevokeCollectionAccess(PartnerCollectionAccess access) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revoke Collection Access'),
        content: Text(
          'Are you sure you want to revoke access to "${access.collectionName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Revoke', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true && _selectedPartnerId != null) {
      await context.read<PartnerAccessCubit>().revokeCollectionAccess(
        _selectedPartnerId!,
        access.collectionId,
      );
    }
  }

  Color _getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return Colors.blue;
      case 'POST':
        return Colors.green;
      case 'PUT':
        return Colors.orange;
      case 'PATCH':
        return Colors.teal;
      case 'DELETE':
        return Colors.red;
      default:
        return Colors.purple;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _showGrantCollectionAccessDialog() {
    if (_selectedPartnerId == null) return;

    // Get collections from cubit (already loaded when screen opened)
    final collectionCubit = context.read<ApiCollectionCubit>();
    final collections = collectionCubit.state.collections;

    String? selectedCollectionId;
    AccessLevel accessLevel = AccessLevel.full;
    final rateLimitController = TextEditingController();
    DateTime? validFrom;
    DateTime? validUntil;

    // For selective access - track APIs
    List<ApiDefinition> availableApis = [];
    List<String> selectedApiIds = [];
    bool isLoadingApis = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          // Function to load APIs when collection changes or access level changes to selective
          Future<void> loadApisForCollection(String collectionId) async {
            setState(() => isLoadingApis = true);
            await collectionCubit.loadApisInCollection(collectionId);
            setState(() {
              availableApis = collectionCubit.state.apis;
              // Pre-select all APIs when switching to selective
              selectedApiIds = availableApis.map((api) => api.id).toList();
              isLoadingApis = false;
            });
          }

          return AlertDialog(
            title: const Text('Grant Collection Access'),
            content: SizedBox(
              width: 500,
              height: accessLevel == AccessLevel.selective ? 500 : null,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (collections.isEmpty)
                      const Text(
                        'No collections available',
                        style: TextStyle(color: Colors.red),
                      )
                    else
                      DropdownButtonFormField<String>(
                        value: selectedCollectionId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Collection *',
                          border: OutlineInputBorder(),
                        ),
                        items: collections.map((c) {
                          return DropdownMenuItem(
                            value: c.id,
                            child: Text(
                              '${c.name} (${c.code})',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCollectionId = value;
                            availableApis = [];
                            selectedApiIds = [];
                          });
                          // If selective access, load APIs immediately
                          if (value != null &&
                              accessLevel == AccessLevel.selective) {
                            loadApisForCollection(value);
                          }
                        },
                      ),
                    const SizedBox(height: 16),
                    const Text(
                      'Access Level',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<AccessLevel>(
                            title: const Text('Full'),
                            subtitle: const Text('All APIs in collection'),
                            value: AccessLevel.full,
                            groupValue: accessLevel,
                            onChanged: (value) {
                              setState(() {
                                accessLevel = value!;
                                availableApis = [];
                                selectedApiIds = [];
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<AccessLevel>(
                            title: const Text('Selective'),
                            subtitle: const Text('Choose specific APIs'),
                            value: AccessLevel.selective,
                            groupValue: accessLevel,
                            onChanged: (value) {
                              setState(() => accessLevel = value!);
                              // Load APIs if collection already selected
                              if (selectedCollectionId != null) {
                                loadApisForCollection(selectedCollectionId!);
                              }
                            },
                          ),
                        ),
                      ],
                    ),

                    // Show API selection when Selective is chosen
                    if (accessLevel == AccessLevel.selective) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.api,
                                  size: 18,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Select APIs (${selectedApiIds.length}/${availableApis.length})',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue,
                                  ),
                                ),
                                const Spacer(),
                                if (availableApis.isNotEmpty) ...[
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        selectedApiIds = availableApis
                                            .map((api) => api.id)
                                            .toList();
                                      });
                                    },
                                    child: const Text('Select All'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() => selectedApiIds = []);
                                    },
                                    child: const Text('Clear'),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 200,
                              child: isLoadingApis
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : selectedCollectionId == null
                                  ? Center(
                                      child: Text(
                                        'Select a collection first',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    )
                                  : availableApis.isEmpty
                                  ? Center(
                                      child: Text(
                                        'No APIs in this collection',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: availableApis.length,
                                      itemBuilder: (context, index) {
                                        final api = availableApis[index];
                                        final isSelected = selectedApiIds
                                            .contains(api.id);

                                        return CheckboxListTile(
                                          dense: true,
                                          value: isSelected,
                                          onChanged: (value) {
                                            setState(() {
                                              if (value == true) {
                                                selectedApiIds.add(api.id);
                                              } else {
                                                selectedApiIds.remove(api.id);
                                              }
                                            });
                                          },
                                          title: Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: _getMethodColor(
                                                    api.httpMethod,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  api.httpMethod,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  api.name,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          subtitle: Text(
                                            api.externalPath,
                                            style: const TextStyle(
                                              fontFamily: 'monospace',
                                              fontSize: 10,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),
                    TextField(
                      controller: rateLimitController,
                      decoration: const InputDecoration(
                        labelText: 'Rate Limit Override (requests/min)',
                        hintText: 'Leave empty to use collection default',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365 * 5),
                                ),
                              );
                              if (date != null) {
                                setState(() => validFrom = date);
                              }
                            },
                            icon: const Icon(Icons.schedule),
                            label: Text(
                              validFrom != null
                                  ? _formatDate(validFrom!)
                                  : 'Valid From',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now().add(
                                  const Duration(days: 30),
                                ),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365 * 5),
                                ),
                              );
                              if (date != null) {
                                setState(() => validUntil = date);
                              }
                            },
                            icon: const Icon(Icons.event_busy),
                            label: Text(
                              validUntil != null
                                  ? _formatDate(validUntil!)
                                  : 'Valid Until',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed:
                    selectedCollectionId == null ||
                        (accessLevel == AccessLevel.selective &&
                            selectedApiIds.isEmpty)
                    ? null
                    : () async {
                        final cubit = this.context.read<PartnerAccessCubit>();

                        // 1. Grant collection access
                        final collectionResult = await cubit
                            .grantCollectionAccess(
                              _selectedPartnerId!,
                              selectedCollectionId!,
                              accessLevel: accessLevel,
                              rateLimitOverride: int.tryParse(
                                rateLimitController.text,
                              ),
                              validFrom: validFrom,
                              validUntil: validUntil,
                            );

                        // 2. If selective access, also grant individual API access
                        if (collectionResult != null &&
                            accessLevel == AccessLevel.selective &&
                            selectedApiIds.isNotEmpty) {
                          await cubit.grantBulkApiAccess(
                            _selectedPartnerId!,
                            selectedApiIds,
                            rateLimitOverride: int.tryParse(
                              rateLimitController.text,
                            ),
                            validFrom: validFrom,
                            validUntil: validUntil,
                          );
                        }

                        if (collectionResult != null) {
                          Navigator.pop(context);
                          final message = accessLevel == AccessLevel.selective
                              ? 'Collection access granted with ${selectedApiIds.length} API(s)'
                              : 'Full collection access granted';
                          ScaffoldMessenger.of(
                            this.context,
                          ).showSnackBar(SnackBar(content: Text(message)));
                        }
                      },
                child: Text(
                  accessLevel == AccessLevel.selective &&
                          selectedApiIds.isNotEmpty
                      ? 'Grant Access (${selectedApiIds.length} APIs)'
                      : 'Grant Access',
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Expandable Collection Access Card - shows APIs inline for selective access
class _ExpandableCollectionAccessCard extends StatefulWidget {
  final PartnerCollectionAccess access;
  final List<PartnerApiAccess> allApiAccess;
  final String partnerId;
  final VoidCallback onEdit;
  final VoidCallback onRevoke;
  final Future<void> Function(String apiId) onApiRevoke;
  final Future<void> Function() onApisAdded;

  const _ExpandableCollectionAccessCard({
    required this.access,
    required this.allApiAccess,
    required this.partnerId,
    required this.onEdit,
    required this.onRevoke,
    required this.onApiRevoke,
    required this.onApisAdded,
  });

  @override
  State<_ExpandableCollectionAccessCard> createState() =>
      _ExpandableCollectionAccessCardState();
}

class _ExpandableCollectionAccessCardState
    extends State<_ExpandableCollectionAccessCard> {
  bool _isExpanded = false;
  bool _isLoadingApis = false;
  List<ApiDefinition> _collectionApis = [];

  @override
  Widget build(BuildContext context) {
    final access = widget.access;
    final isSelective = access.accessLevel == AccessLevel.selective;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: access.accessLevel == AccessLevel.full
                          ? Colors.green
                          : Colors.orange,
                      child: Icon(
                        access.accessLevel == AccessLevel.full
                            ? Icons.lock_open
                            : Icons.tune,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            access.collectionName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            access.collectionCode,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Chip(
                      label: Text(access.accessLevel.displayName),
                      backgroundColor: access.accessLevel == AccessLevel.full
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      avatar: Icon(
                        access.isValid ? Icons.check : Icons.warning,
                        size: 16,
                        color: access.isValid ? Colors.green : Colors.orange,
                      ),
                      label: Text(access.statusText),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          widget.onEdit();
                        } else if (value == 'revoke') {
                          widget.onRevoke();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: 'revoke',
                          child: Text(
                            'Revoke Access',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Expandable section for selective access
                if (isSelective) ...[
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _toggleExpand,
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isExpanded ? Icons.expand_less : Icons.expand_more,
                            size: 20,
                            color: Colors.orange[700],
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.api, size: 16, color: Colors.orange[700]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _isExpanded
                                  ? 'Hide granted APIs'
                                  : 'View granted APIs for this collection',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.orange[700],
                              ),
                            ),
                          ),
                          if (_isLoadingApis)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Metadata chips
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    if (access.rateLimitOverride != null)
                      Chip(
                        avatar: const Icon(Icons.speed, size: 16),
                        label: Text('${access.rateLimitOverride}/min'),
                        visualDensity: VisualDensity.compact,
                      ),
                    if (access.validFrom != null)
                      Chip(
                        avatar: const Icon(Icons.schedule, size: 16),
                        label: Text('From: ${_formatDate(access.validFrom!)}'),
                        visualDensity: VisualDensity.compact,
                      ),
                    if (access.validUntil != null)
                      Chip(
                        avatar: const Icon(Icons.event_busy, size: 16),
                        label: Text(
                          'Until: ${_formatDate(access.validUntil!)}',
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Expanded API list
          if (_isExpanded && isSelective) ...[
            const Divider(height: 1),
            _buildExpandedApiList(),
          ],
        ],
      ),
    );
  }

  void _toggleExpand() async {
    if (!_isExpanded && _collectionApis.isEmpty) {
      // Load APIs for this collection when first expanding
      setState(() => _isLoadingApis = true);
      try {
        final collectionCubit = context.read<ApiCollectionCubit>();
        await collectionCubit.loadApisInCollection(widget.access.collectionId);
        setState(() {
          _collectionApis = collectionCubit.state.apis;
          _isLoadingApis = false;
        });
      } catch (e) {
        setState(() => _isLoadingApis = false);
      }
    }
    setState(() => _isExpanded = !_isExpanded);
  }

  Widget _buildExpandedApiList() {
    // Get the granted API IDs for this partner
    final grantedApiIds = widget.allApiAccess
        .map((a) => a.apiDefinitionId)
        .toSet();

    // Filter to only show APIs from this collection that are granted
    final grantedApis = _collectionApis
        .where((api) => grantedApiIds.contains(api.id))
        .toList();

    // APIs available but not granted yet
    final availableApis = _collectionApis
        .where((api) => !grantedApiIds.contains(api.id))
        .toList();

    if (_isLoadingApis) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      color: Colors.grey.withOpacity(0.03),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Add button
          Row(
            children: [
              Text(
                'Granted APIs (${grantedApis.length}/${_collectionApis.length})',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const Spacer(),
              if (availableApis.isNotEmpty)
                TextButton.icon(
                  onPressed: () => _showAddApisDialog(availableApis),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add APIs'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Empty state
          if (grantedApis.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.api, size: 32, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'No APIs granted yet',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    if (availableApis.isNotEmpty)
                      ElevatedButton.icon(
                        onPressed: () => _showAddApisDialog(availableApis),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add APIs'),
                      ),
                  ],
                ),
              ),
            )
          else
            // API list with delete buttons
            ...grantedApis.map((api) {
              final apiAccess = widget.allApiAccess.firstWhere(
                (a) => a.apiDefinitionId == api.id,
                orElse: () => widget.allApiAccess.first,
              );

              return Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getMethodColor(api.httpMethod),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        api.httpMethod,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            api.name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            api.externalPath,
                            style: TextStyle(
                              fontSize: 11,
                              fontFamily: 'monospace',
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      apiAccess.isValid ? Icons.check_circle : Icons.warning,
                      size: 16,
                      color: apiAccess.isValid ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _confirmRevokeApi(api, apiAccess),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      color: Colors.red[400],
                      tooltip: 'Revoke API access',
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  void _confirmRevokeApi(ApiDefinition api, PartnerApiAccess apiAccess) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revoke API Access'),
        content: Text(
          'Are you sure you want to revoke access to "${api.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Revoke', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await widget.onApiRevoke(api.id);
    }
  }

  void _showAddApisDialog(List<ApiDefinition> availableApis) {
    List<String> selectedApiIds = [];

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Add APIs to ${widget.access.collectionName}'),
          content: SizedBox(
            width: 450,
            height: 350,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Select APIs to add (${selectedApiIds.length}/${availableApis.length})',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedApiIds = availableApis
                              .map((a) => a.id)
                              .toList();
                        });
                      },
                      child: const Text('Select All'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() => selectedApiIds = []);
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: availableApis.length,
                    itemBuilder: (context, index) {
                      final api = availableApis[index];
                      final isSelected = selectedApiIds.contains(api.id);

                      return CheckboxListTile(
                        dense: true,
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              selectedApiIds.add(api.id);
                            } else {
                              selectedApiIds.remove(api.id);
                            }
                          });
                        },
                        title: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getMethodColor(api.httpMethod),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                api.httpMethod,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                api.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          api.externalPath,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
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
            ElevatedButton(
              onPressed: selectedApiIds.isEmpty
                  ? null
                  : () async {
                      // Grant the selected APIs
                      await context
                          .read<PartnerAccessCubit>()
                          .grantBulkApiAccess(widget.partnerId, selectedApiIds);
                      Navigator.pop(context);
                      await widget.onApisAdded();
                      if (mounted) {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${selectedApiIds.length} API(s) added',
                            ),
                          ),
                        );
                      }
                    },
              child: Text('Add (${selectedApiIds.length})'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return Colors.blue;
      case 'POST':
        return Colors.green;
      case 'PUT':
        return Colors.orange;
      case 'PATCH':
        return Colors.teal;
      case 'DELETE':
        return Colors.red;
      default:
        return Colors.purple;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
