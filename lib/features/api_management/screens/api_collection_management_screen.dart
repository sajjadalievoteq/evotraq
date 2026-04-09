import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import '../models/api_collection.dart';
import '../cubit/api_collection_cubit.dart';
import '../cubit/api_collection_state.dart';

/// Screen for managing API Collections
/// Allows creating, editing, and managing API collections and their API definitions
class ApiCollectionManagementScreen extends StatefulWidget {
  const ApiCollectionManagementScreen({super.key});

  @override
  State<ApiCollectionManagementScreen> createState() => _ApiCollectionManagementScreenState();
}

class _ApiCollectionManagementScreenState extends State<ApiCollectionManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filterCategory = 'All';
  bool _showActiveOnly = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAndLoad();
    });
  }

  void _initializeAndLoad() {
    context.read<ApiCollectionCubit>().loadCollections();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Collections'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ApiCollectionCubit>().loadCollections(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: BlocBuilder<ApiCollectionCubit, ApiCollectionState>(
        builder: (context, state) {
          if (state.status == ApiCollectionStatus.loading && state.collections.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null && state.collections.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text('Error: ${state.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<ApiCollectionCubit>().loadCollections(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Row(
            children: [
              // Collections List (Left Panel)
              SizedBox(
                width: 400,
                child: Column(
                  children: [
                    _buildCollectionHeader(state),
                    _buildSearchAndFilter(state),
                    Expanded(child: _buildCollectionsList(state)),
                  ],
                ),
              ),
              const VerticalDivider(width: 1),
              // API Details (Right Panel)
              Expanded(
                child: state.selectedCollection != null
                    ? _buildApiDetailsPanel(state)
                    : _buildEmptyDetailsPanel(),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateCollectionDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New Collection'),
      ),
    );
  }

  Widget _buildCollectionHeader(ApiCollectionState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.folder_special, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              const Text(
                'API Collections',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatChip('Total', state.totalCollections.toString(), Colors.blue),
              const SizedBox(width: 8),
              _buildStatChip('Active', state.activeCollections.toString(), Colors.green),
              const SizedBox(width: 8),
              _buildStatChip('Public', state.publicCollections.toString(), Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(ApiCollectionState state) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search collections...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              isDense: true,
            ),
            onChanged: (value) => setState(() {}),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _filterCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    isDense: true,
                  ),
                  items: ['All', ...state.categories].map((c) {
                    return DropdownMenuItem(value: c, child: Text(c));
                  }).toList(),
                  onChanged: (value) => setState(() => _filterCategory = value ?? 'All'),
                ),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Active Only'),
                selected: _showActiveOnly,
                onSelected: (value) => setState(() => _showActiveOnly = value),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionsList(ApiCollectionState state) {
    var collections = state.collections;

    // Apply filters
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      collections = collections.where((c) =>
          c.name.toLowerCase().contains(query) ||
          c.code.toLowerCase().contains(query) ||
          (c.description?.toLowerCase().contains(query) ?? false)).toList();
    }

    if (_filterCategory != 'All') {
      collections = collections.where((c) => c.category == _filterCategory).toList();
    }

    if (_showActiveOnly) {
      collections = collections.where((c) => c.isActive).toList();
    }

    if (collections.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No collections found', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: collections.length,
      itemBuilder: (context, index) {
        final collection = collections[index];
        final isSelected = state.selectedCollection?.id == collection.id;

        return Card(
          elevation: isSelected ? 4 : 1,
          margin: const EdgeInsets.symmetric(vertical: 4),
          color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: collection.isActive ? Colors.green : Colors.grey,
              child: Text(
                collection.code.substring(0, 2).toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(collection.name, style: const TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(collection.code, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildMiniChip(collection.version, Colors.blue),
                    const SizedBox(width: 4),
                    if (collection.category != null)
                      _buildMiniChip(collection.category!, Colors.purple),
                    const SizedBox(width: 4),
                    _buildMiniChip('${collection.apiCount} APIs', Colors.teal),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (collection.isPublic)
                  const Icon(Icons.public, size: 16, color: Colors.orange),
                const SizedBox(width: 4),
                Icon(
                  collection.isActive ? Icons.check_circle : Icons.cancel,
                  size: 16,
                  color: collection.isActive ? Colors.green : Colors.red,
                ),
              ],
            ),
            onTap: () => context.read<ApiCollectionCubit>().selectCollection(collection),
          ),
        );
      },
    );
  }

  Widget _buildMiniChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: TextStyle(fontSize: 10, color: color)),
    );
  }

  Widget _buildEmptyDetailsPanel() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.touch_app, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Select a collection to view details',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Or create a new collection to get started',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildApiDetailsPanel(ApiCollectionState state) {
    final collection = state.selectedCollection!;
    final apis = state.apis;

    return Column(
      children: [
        // Collection Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          collection.name,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          collection.code,
                          style: TextStyle(color: Colors.grey[600], fontFamily: 'monospace'),
                        ),
                        if (collection.description != null) ...[
                          const SizedBox(height: 8),
                          Text(collection.description!),
                        ],
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleCollectionAction(value, collection),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit Collection')),
                      PopupMenuItem(
                        value: collection.isActive ? 'deactivate' : 'activate',
                        child: Text(collection.isActive ? 'Deactivate' : 'Activate'),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Chip(
                    avatar: Icon(
                      collection.isActive ? Icons.check : Icons.close,
                      size: 16,
                      color: collection.isActive ? Colors.green : Colors.red,
                    ),
                    label: Text(collection.statusText),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    avatar: Icon(
                      collection.isPublic ? Icons.public : Icons.lock,
                      size: 16,
                    ),
                    label: Text(collection.visibilityText),
                  ),
                  const SizedBox(width: 8),
                  Chip(label: Text('v${collection.version}')),
                  if (collection.rateLimitPerMinute != null) ...[
                    const SizedBox(width: 8),
                    Chip(
                      avatar: const Icon(Icons.speed, size: 16),
                      label: Text('${collection.rateLimitPerMinute}/min'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        // APIs Section
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.api),
              const SizedBox(width: 8),
              Text(
                'APIs (${apis.length})',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () => _downloadPostmanCollection(context, collection),
                icon: const Icon(Icons.download),
                label: const Text('Postman'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _showCreateApiDialog(context, collection.id),
                icon: const Icon(Icons.add),
                label: const Text('Add API'),
              ),
            ],
          ),
        ),
        // APIs List
        Expanded(
          child: apis.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.api, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text('No APIs in this collection', style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => _showCreateApiDialog(context, collection.id),
                        child: const Text('Add First API'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: apis.length,
                  itemBuilder: (context, index) => _buildApiCard(apis[index], collection.id),
                ),
        ),
      ],
    );
  }

  Widget _buildApiCard(ApiDefinition api, String collectionId) {
    final methodColor = _getMethodColor(api.httpMethod);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: methodColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            api.httpMethod,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        title: Text(api.name),
        subtitle: Text(
          api.externalPath,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              api.isActive ? Icons.check_circle : Icons.cancel,
              size: 16,
              color: api.isActive ? Colors.green : Colors.red,
            ),
            PopupMenuButton<String>(
              onSelected: (value) => _handleApiAction(value, api, collectionId),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(
                  value: api.isActive ? 'deactivate' : 'activate',
                  child: Text(api.isActive ? 'Deactivate' : 'Activate'),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (api.description != null) ...[
                  Text(api.description!, style: TextStyle(color: Colors.grey[700])),
                  const SizedBox(height: 12),
                ],
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip('Timeout', '${api.timeoutSeconds}s', Icons.timer),
                    if (api.cacheTtlSeconds != null)
                      _buildInfoChip('Cache', '${api.cacheTtlSeconds}s', Icons.cached),
                    if (api.rateLimitPerMinute != null)
                      _buildInfoChip('Rate Limit', '${api.rateLimitPerMinute}/min', Icons.speed),
                    if (api.requestContentType != null)
                      _buildInfoChip('Request', api.requestContentType!, Icons.upload),
                    if (api.responseContentType != null)
                      _buildInfoChip('Response', api.responseContentType!, Icons.download),
                  ],
                ),
                if (api.tags != null && api.tags!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 4,
                    children: api.tags!.map((tag) {
                      return Chip(
                        label: Text(tag, style: const TextStyle(fontSize: 11)),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text('$label: ', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
        ],
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

  void _handleCollectionAction(String action, ApiCollection collection) async {
    final cubit = context.read<ApiCollectionCubit>();
    switch (action) {
      case 'edit':
        _showEditCollectionDialog(context, collection);
        break;
      case 'activate':
        await cubit.activateCollection(collection.id);
        break;
      case 'deactivate':
        await cubit.deactivateCollection(collection.id);
        break;
      case 'delete':
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Collection'),
            content: Text('Are you sure you want to delete "${collection.name}"? This action cannot be undone.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
        if (confirm == true) {
          await cubit.deleteCollection(collection.id);
        }
        break;
    }
  }

  Future<void> _downloadPostmanCollection(BuildContext context, ApiCollection collection) async {
    try {
      final cubit = context.read<ApiCollectionCubit>();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text('Downloading ${collection.name} Postman collection...'),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      await cubit.exportPostmanCollection(collection.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('${collection.name} Postman collection downloaded!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Failed to download: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _handleApiAction(String action, ApiDefinition api, String collectionId) async {
    final cubit = context.read<ApiCollectionCubit>();
    switch (action) {
      case 'edit':
        _showEditApiDialog(context, collectionId, api);
        break;
      case 'activate':
        await cubit.activateApi(collectionId, api.id);
        break;
      case 'deactivate':
        await cubit.deactivateApi(collectionId, api.id);
        break;
      case 'delete':
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete API'),
            content: Text('Are you sure you want to delete "${api.name}"?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
        if (confirm == true) {
          await cubit.deleteApi(collectionId, api.id);
        }
        break;
    }
  }

  void _showCreateCollectionDialog(BuildContext context) {
    final codeController = TextEditingController();
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final versionController = TextEditingController(text: '1.0');
    final categoryController = TextEditingController();
    final rateLimitController = TextEditingController();
    bool isPublic = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create API Collection'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: codeController,
                    decoration: const InputDecoration(
                      labelText: 'Code *',
                      hintText: 'e.g., EPCIS_EVENTS',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name *',
                      hintText: 'e.g., EPCIS Event APIs',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: versionController,
                          decoration: const InputDecoration(labelText: 'Version'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: categoryController,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            hintText: 'e.g., Core',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: rateLimitController,
                    decoration: const InputDecoration(
                      labelText: 'Rate Limit (requests/min)',
                      hintText: 'Leave empty for no limit',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Public'),
                    subtitle: const Text('Allow discovery without authentication'),
                    value: isPublic,
                    onChanged: (value) => setState(() => isPublic = value),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (codeController.text.isEmpty || nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Code and Name are required')),
                  );
                  return;
                }

                final cubit = context.read<ApiCollectionCubit>();
                final result = await cubit.createCollection(
                  code: codeController.text,
                  name: nameController.text,
                  description: descController.text.isEmpty ? null : descController.text,
                  version: versionController.text,
                  category: categoryController.text.isEmpty ? null : categoryController.text,
                  isPublic: isPublic,
                  rateLimitPerMinute: int.tryParse(rateLimitController.text),
                );

                if (result != null) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Collection "${result.name}" created')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${cubit.state.error}')),
                  );
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCollectionDialog(BuildContext context, ApiCollection collection) {
    final nameController = TextEditingController(text: collection.name);
    final descController = TextEditingController(text: collection.description ?? '');
    final versionController = TextEditingController(text: collection.version);
    final categoryController = TextEditingController(text: collection.category ?? '');
    final rateLimitController = TextEditingController(
      text: collection.rateLimitPerMinute?.toString() ?? '',
    );
    bool isPublic = collection.isPublic;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Collection'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name *'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: versionController,
                          decoration: const InputDecoration(labelText: 'Version'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: categoryController,
                          decoration: const InputDecoration(labelText: 'Category'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: rateLimitController,
                    decoration: const InputDecoration(labelText: 'Rate Limit (requests/min)'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Public'),
                    value: isPublic,
                    onChanged: (value) => setState(() => isPublic = value),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final cubit = context.read<ApiCollectionCubit>();
                final success = await cubit.updateCollection(
                  collection.id,
                  name: nameController.text,
                  description: descController.text.isEmpty ? null : descController.text,
                  version: versionController.text,
                  category: categoryController.text.isEmpty ? null : categoryController.text,
                  isPublic: isPublic,
                  rateLimitPerMinute: int.tryParse(rateLimitController.text),
                );

                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Collection updated')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateApiDialog(BuildContext context, String collectionId) {
    final codeController = TextEditingController();
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final pathController = TextEditingController();
    final timeoutController = TextEditingController(text: '30');
    final rateLimitController = TextEditingController();
    String httpMethod = 'GET';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add API'),
          content: SizedBox(
            width: 450,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: codeController,
                    decoration: const InputDecoration(
                      labelText: 'Code *',
                      hintText: 'e.g., CREATE_EVENT',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name *',
                      hintText: 'e.g., Create EPCIS Event',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: DropdownButtonFormField<String>(
                          value: httpMethod,
                          decoration: const InputDecoration(labelText: 'Method'),
                          items: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'].map((m) {
                            return DropdownMenuItem(value: m, child: Text(m));
                          }).toList(),
                          onChanged: (value) => setState(() => httpMethod = value ?? 'GET'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: pathController,
                          decoration: const InputDecoration(
                            labelText: 'Path Pattern *',
                            hintText: '/partner/v1/events/{eventId}',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: timeoutController,
                          decoration: const InputDecoration(labelText: 'Timeout (seconds)'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: rateLimitController,
                          decoration: const InputDecoration(labelText: 'Rate Limit (/min)'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (codeController.text.isEmpty ||
                    nameController.text.isEmpty ||
                    pathController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Code, Name, and Path are required')),
                  );
                  return;
                }

                final cubit = context.read<ApiCollectionCubit>();
                final result = await cubit.createApi(
                  collectionId,
                  code: codeController.text,
                  name: nameController.text,
                  description: descController.text.isEmpty ? null : descController.text,
                  httpMethod: httpMethod,
                  pathPattern: pathController.text,
                  timeoutSeconds: int.tryParse(timeoutController.text) ?? 30,
                  rateLimitPerMinute: int.tryParse(rateLimitController.text),
                );

                if (result != null) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('API "${result.name}" created')),
                  );
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditApiDialog(BuildContext context, String collectionId, ApiDefinition api) {
    final nameController = TextEditingController(text: api.name);
    final descController = TextEditingController(text: api.description ?? '');
    final pathController = TextEditingController(text: api.pathPattern);
    final timeoutController = TextEditingController(text: api.timeoutSeconds.toString());
    final rateLimitController = TextEditingController(
      text: api.rateLimitPerMinute?.toString() ?? '',
    );
    String httpMethod = api.httpMethod;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit API'),
          content: SizedBox(
            width: 450,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name *'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: DropdownButtonFormField<String>(
                          value: httpMethod,
                          decoration: const InputDecoration(labelText: 'Method'),
                          items: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'].map((m) {
                            return DropdownMenuItem(value: m, child: Text(m));
                          }).toList(),
                          onChanged: (value) => setState(() => httpMethod = value ?? 'GET'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: pathController,
                          decoration: const InputDecoration(labelText: 'Path Pattern *'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: timeoutController,
                          decoration: const InputDecoration(labelText: 'Timeout (seconds)'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: rateLimitController,
                          decoration: const InputDecoration(labelText: 'Rate Limit (/min)'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final cubit = context.read<ApiCollectionCubit>();
                final success = await cubit.updateApi(
                  collectionId,
                  api.id,
                  name: nameController.text,
                  description: descController.text.isEmpty ? null : descController.text,
                  httpMethod: httpMethod,
                  pathPattern: pathController.text,
                  timeoutSeconds: int.tryParse(timeoutController.text),
                  rateLimitPerMinute: int.tryParse(rateLimitController.text),
                );

                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('API updated')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
