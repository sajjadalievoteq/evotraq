import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/gs1/gln/services/gln_picker_catalog.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_resolution.dart';

class GLNSelector extends StatefulWidget {
  final String label;
  final String? hintText;
  final GLN? initialValue;
  final Function(GLN?) onChanged;
  final bool isRequired;
  final String? errorText;

  /// Optional override. When null, uses the session [GlnPickerCatalog]
  /// loaded at app auth/startup.
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
  State<GLNSelector> createState() => _GLNSelectorState();
}

class _GLNSelectorState extends State<GLNSelector> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isDropdownOpen = false;
  bool _isLoading = false;
  String? _loadError;
  List<GLN> _filteredGLNs = [];
  List<GLN> _allGLNs = [];
  GLN? _selectedGLN;

  @override
  void initState() {
    super.initState();
    _applyInitialValue(widget.initialValue);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncCatalog();
    });
  }

  @override
  void didUpdateWidget(covariant GLNSelector oldWidget) {
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _syncCatalog();
      });
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

  Future<void> _syncCatalog() async {
    final provided = widget.pickerCatalog;
    if (provided != null && provided.isNotEmpty) {
      _applyPickerCatalog(provided);
      return;
    }

    final catalog = getIt<GlnPickerCatalog>();
    if (catalog.isLoaded) {
      _applyPickerCatalog(catalog.activeItems);
      return;
    }

    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      await catalog.ensureLoaded();
      if (!mounted) return;
      _applyPickerCatalog(catalog.activeItems);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _allGLNs = const [];
        _filteredGLNs = const [];
        _loadError = e.toString();
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyPickerCatalog(List<GLN> catalog) {
    setState(() {
      _allGLNs = catalog.where((gln) => gln.active).toList();
      if (_filteredGLNs.isEmpty && _allGLNs.isNotEmpty) {
        _filteredGLNs = _allGLNs;
      }
      _isLoading = false;
      _loadError = null;
    });
    _upgradeSelectedFromCatalog();
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
      _filteredGLNs = _allGLNs;
      _isDropdownOpen = _allGLNs.isNotEmpty;
    });
    widget.onChanged(null);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                        icon: TraqIcon(
                          _isDropdownOpen
                              ? AppAssets.iconChevronU
                              : AppAssets.iconChevronD,
                        ),
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
                if (_selectedGLN != null) return;
                setState(() {
                  _isDropdownOpen = true;
                });
                _filterGLNs(value);
              },
              onTap: () {
                if (_selectedGLN != null) return;
                setState(() {
                  _isDropdownOpen = true;
                });
              },
              readOnly: _selectedGLN != null,
            ),
          ],
        ),
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
                final isSelected = _selectedGLN?.glnCode == gln.glnCode;
                return Material(
                  color: isSelected
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : Theme.of(context).cardColor,
                  child: ListTile(
                    dense: true,
                    leading: TraqIcon(AppAssets.iconGln, size: 20),
                    title: Text(
                      gln.glnCode,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gln.locationName,
                          style: const TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (gln.city.isNotEmpty)
                          Text(
                            '${gln.city}, ${gln.stateProvince}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                    onTap: () => _selectGLN(gln),
                    selected: isSelected,
                  ),
                );
              },
            ),
          ),
        if (_isLoading)
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
        if (_loadError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Error loading GLNs: $_loadError',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
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
  }
}
