import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/gs1/gln/cubit/gln_cubit.dart';

/// A reusable widget for selecting GLNs from available system GLNs
/// Provides a searchable dropdown interface with GLN code and location name
class GLNSelector extends StatefulWidget {
  final String label;
  final String? hintText;
  final GLN? initialValue;
  final Function(GLN?) onChanged;
  final bool isRequired;
  final String? errorText;

  const GLNSelector({
    Key? key,
    required this.label,
    this.hintText,
    this.initialValue,
    required this.onChanged,
    this.isRequired = false,
    this.errorText,
  }) : super(key: key);

  @override
  State<GLNSelector> createState() => _GLNSelectorState();
}

class _GLNSelectorState extends State<GLNSelector> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isDropdownOpen = false;
  List<GLN> _filteredGLNs = [];
  List<GLN> _allGLNs = [];
  GLN? _selectedGLN;

  @override
  void initState() {
    super.initState();
    _selectedGLN = widget.initialValue;
    if (_selectedGLN != null) {
      _searchController.text = _getDisplayText(_selectedGLN!);
    }
    _loadGLNs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _loadGLNs() {
    context.read<GLNCubit>().fetchGLNs();
  }

  String _getDisplayText(GLN gln) {
    return '${gln.glnCode} - ${gln.locationName}';
  }

  void _filterGLNs(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredGLNs = _allGLNs;
      } else {
        _filteredGLNs = _allGLNs.where((gln) {
          final lowerQuery = query.toLowerCase();
          return gln.glnCode.toLowerCase().contains(lowerQuery) ||
                 gln.locationName.toLowerCase().contains(lowerQuery) ||
                 (gln.contactName?.toLowerCase().contains(lowerQuery) ?? false);
        }).toList();
      }
    });
  }

  void _selectGLN(GLN gln) {
    setState(() {
      _selectedGLN = gln;
      _searchController.text = _getDisplayText(gln);
      _isDropdownOpen = false;
    });
    _focusNode.unfocus();
    widget.onChanged(gln);
  }

  void _clearSelection() {
    setState(() {
      _selectedGLN = null;
      _searchController.clear();
      _isDropdownOpen = false;
    });
    widget.onChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GLNCubit, GLNState>(
      listener: (context, state) {
        // Update GLN list when state changes to success
        if (state.status == GLNStatus.success) {
          _allGLNs = state.glns.where((gln) => gln.active).toList();
          if (_filteredGLNs.isEmpty && _allGLNs.isNotEmpty) {
            _filteredGLNs = _allGLNs;
          }
        }
      },
      builder: (context, state) {

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label
            if (widget.label.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  widget.label + (widget.isRequired ? ' *' : ''),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            
            // Search Field
            Stack(
              children: [
                TextFormField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: widget.hintText ?? 'Search GLN or location name...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _selectedGLN != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _clearSelection,
                          )
                        : IconButton(
                            icon: Icon(_isDropdownOpen 
                                ? Icons.keyboard_arrow_up 
                                : Icons.keyboard_arrow_down),
                            onPressed: () {
                              setState(() {
                                _isDropdownOpen = !_isDropdownOpen;
                              });
                              if (_isDropdownOpen) {
                                _focusNode.requestFocus();
                              } else {
                                _focusNode.unfocus();
                              }
                            },
                          ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    errorText: widget.errorText,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _isDropdownOpen = true;
                    });
                    _filterGLNs(value);
                  },
                  onTap: () {
                    setState(() {
                      _isDropdownOpen = true;
                    });
                  },
                  readOnly: false,
                ),
              ],
            ),
            
            // Dropdown List
            if (_isDropdownOpen && _filteredGLNs.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filteredGLNs.length,
                  itemBuilder: (context, index) {
                    final gln = _filteredGLNs[index];
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.location_on, size: 20),
                      title: Text(
                        gln.glnCode,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            gln.locationName,
                            style: const TextStyle(fontSize: 13),
                          ),
                          if (gln.city.isNotEmpty)
                            Text(
                              '${gln.city}, ${gln.stateProvince}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                        ],
                      ),
                      onTap: () => _selectGLN(gln),
                      selected: _selectedGLN?.glnCode == gln.glnCode,
                      selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    );
                  },
                ),
              ),
            
            // Loading/Error States
            if (state.status == GLNStatus.loading)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            
            if (state.status == GLNStatus.error && state.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Error loading GLNs: ${state.error}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
            
            // No results message
            if (_isDropdownOpen && _filteredGLNs.isEmpty && _allGLNs.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).cardColor,
                ),
                child: const Text(
                  'No GLNs found matching your search',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}