import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/services/gs1/gln/gln_service.dart';
import 'package:traqtrace_app/features/gs1/gln/cubit/gln_cubit.dart';
import 'package:traqtrace_app/features/gs1/gln/cubit/gln_state.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_resolution.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

/// A reusable widget for selecting GLNs from available system GLNs
/// Provides a searchable dropdown interface with GLN code and location name
class GLNSelector extends StatelessWidget {
  final String label;
  final String? hintText;
  final GLN? initialValue;
  final Function(GLN?) onChanged;
  final bool isRequired;
  final String? errorText;

  /// When set, the selector uses this catalog instead of fetching GLNs again.
  final List<GLN>? pickerCatalog;

  const GLNSelector({
    Key? key,
    required this.label,
    this.hintText,
    this.initialValue,
    required this.onChanged,
    this.isRequired = false,
    this.errorText,
    this.pickerCatalog,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GLNCubit(glnService: getIt<GLNService>()),
      child: _GLNSelectorBody(
        label: label,
        hintText: hintText,
        initialValue: initialValue,
        onChanged: onChanged,
        isRequired: isRequired,
        errorText: errorText,
        pickerCatalog: pickerCatalog,
      ),
    );
  }
}

class _GLNSelectorBody extends StatefulWidget {
  final String label;
  final String? hintText;
  final GLN? initialValue;
  final Function(GLN?) onChanged;
  final bool isRequired;
  final String? errorText;
  final List<GLN>? pickerCatalog;

  const _GLNSelectorBody({
    required this.label,
    this.hintText,
    this.initialValue,
    required this.onChanged,
    this.isRequired = false,
    this.errorText,
    this.pickerCatalog,
  });

  @override
  State<_GLNSelectorBody> createState() => _GLNSelectorBodyState();
}

class _GLNSelectorBodyState extends State<_GLNSelectorBody> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isDropdownOpen = false;
  List<GLN> _filteredGLNs = [];
  List<GLN> _allGLNs = [];
  GLN? _selectedGLN;

  @override
  void initState() {
    super.initState();
    _applyInitialValue(widget.initialValue);
    if (widget.pickerCatalog != null && widget.pickerCatalog!.isNotEmpty) {
      _applyPickerCatalog(widget.pickerCatalog);
    } else {
      _loadGLNs();
    }
  }

  void _applyPickerCatalog(List<GLN>? catalog) {
    if (catalog == null || catalog.isEmpty) return;
    setState(() {
      _allGLNs = catalog.where((gln) => gln.active).toList();
      if (_filteredGLNs.isEmpty && _allGLNs.isNotEmpty) {
        _filteredGLNs = _allGLNs;
      }
    });
    _upgradeSelectedFromCatalog();
  }

  @override
  void didUpdateWidget(covariant _GLNSelectorBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue?.glnCode != oldWidget.initialValue?.glnCode) {
      final incoming = widget.initialValue;
      final keepCurrentSelection = incoming != null &&
          _selectedGLN != null &&
          incoming.glnCode == _selectedGLN!.glnCode &&
          isPlaceholderGlnLocation(incoming) &&
          !isPlaceholderGlnLocation(_selectedGLN!);
      if (!keepCurrentSelection) {
        _applyInitialValue(incoming);
      }
    }
    if (widget.pickerCatalog != oldWidget.pickerCatalog) {
      _applyPickerCatalog(widget.pickerCatalog);
    }
  }

  void _applyInitialValue(GLN? value) {
    _selectedGLN = value;
    if (_selectedGLN != null) {
      _searchController.text = _getDisplayText(_selectedGLN!);
    } else {
      _searchController.clear();
    }
  }

  void _upgradeSelectedFromCatalog() {
    if (_selectedGLN == null || _allGLNs.isEmpty) return;
    final resolved = resolveGlnForPicker(
      code: _selectedGLN!.glnCode,
      fallback: _selectedGLN,
      catalog: _allGLNs,
    );
    if (resolved == null || resolved.glnCode != _selectedGLN!.glnCode) return;
    if (resolved.locationName == _selectedGLN!.locationName &&
        !isPlaceholderGlnLocation(_selectedGLN!)) {
      return;
    }
    if (!isPlaceholderGlnLocation(resolved) ||
        isPlaceholderGlnLocation(_selectedGLN!)) {
      setState(() {
        _selectedGLN = resolved;
        _searchController.text = _getDisplayText(resolved);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _loadGLNs() {
    context.read<GLNCubit>().fetchGlnsForPicker().then((glns) {
      if (!mounted) return;
      setState(() {
        _allGLNs = glns.where((gln) => gln.active).toList();
        if (_filteredGLNs.isEmpty && _allGLNs.isNotEmpty) {
          _filteredGLNs = _allGLNs;
        }
      });
      _upgradeSelectedFromCatalog();
    }).catchError((_) {
      // Keep failures local to this selector; do not surface raw API bodies.
      if (mounted) {
        setState(() {
          _allGLNs = const [];
          _filteredGLNs = const [];
        });
      }
    });
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
          _upgradeSelectedFromCatalog();
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (widget.isRequired)
                      Text(
                        ' *',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
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
                    prefixIcon: TraqIcon(AppAssets.iconSearch),
                    suffixIcon: _selectedGLN != null
                        ? IconButton(
                            icon: TraqIcon(AppAssets.iconX),
                            onPressed: _clearSelection,
                          )
                        : IconButton(
                            icon: TraqIcon(_isDropdownOpen 
                                ? AppAssets.iconChevronU 
                                : AppAssets.iconChevronD),
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
                      leading: TraqIcon(AppAssets.iconGln, size: 20),
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
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: AppShimmer(
                  child: Column(
                    children: List.generate(
                      3,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
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
