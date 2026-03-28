import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/textboxes/textboxes.dart';
import '../../colors.dart';

/// A reusable chip selection modal dialog that allows users to select
/// from predefined options or enter custom text.
///
/// This modal provides:
/// - A list of selectable chip options
/// - An "Others/Iba pa" option for custom input
/// - Clean, modern UI with consistent theming
/// - Validation and confirmation flow
///
/// Usage:
/// ```dart
/// final result = await showChipSelectionModal(
///   context: context,
///   title: 'Select Crop Name',
///   options: ['Tomato', 'Potato', 'Garlic'],
///   currentSelection: _cropNameController.text,
/// );
/// if (result != null) {
///   _cropNameController.text = result;
/// }
/// ```
class ChipSelectionModal extends StatefulWidget {
  /// The title displayed at the top of the modal
  final String title;
  
  /// List of predefined options to display as chips
  final List<String> options;
  
  /// Currently selected value (if any)
  final String? currentSelection;

  /// Currently selected values for multi-select mode
  final List<String>? currentSelections;
  
  /// Hint text for the custom input field
  final String customInputHint;
  
  /// Label for the "Others" option
  final String othersLabel;

  final bool isMultiLine;
  final bool allowMultiSelect;

  const ChipSelectionModal({
    super.key,
    required this.title,
    required this.options,
    this.currentSelection,
    this.currentSelections,
    this.customInputHint = 'Type your answer here',
    this.othersLabel = 'Others/Iba pa', 
    required this.isMultiLine,
    this.allowMultiSelect = false,
  });

  @override
  State<ChipSelectionModal> createState() => _ChipSelectionModalState();
}

class _ChipSelectionModalState extends State<ChipSelectionModal> {
  /// Currently selected option (null if custom input is selected)
  String? _selectedOption;

  final Set<String> _selectedOptions = <String>{};
  
  /// Whether the "Others" option is selected
  bool _isCustomInputSelected = false;
  
  /// Controller for custom input text field
  final TextEditingController _customInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeSelection();
  }

  /// Initialize selection based on current value
  void _initializeSelection() {
    if (widget.allowMultiSelect) {
      final currentSelections = widget.currentSelections ?? <String>[];
      if (currentSelections.isNotEmpty) {
        final optionSelections = currentSelections
            .where((selection) => widget.options.contains(selection))
            .toList();
        _selectedOptions.addAll(optionSelections);

        final customSelections = currentSelections
            .where((selection) => !widget.options.contains(selection))
            .toList();

        if (customSelections.isNotEmpty) {
          _isCustomInputSelected = true;
          _customInputController.text = customSelections.join(', ');
        }
      }
      return;
    }

    if (widget.currentSelection != null && widget.currentSelection!.isNotEmpty) {
      // Check if current selection matches any predefined option
      if (widget.options.contains(widget.currentSelection)) {
        _selectedOption = widget.currentSelection;
      } else {
        // Current selection is a custom value
        _isCustomInputSelected = true;
        _customInputController.text = widget.currentSelection!;
      }
    }
  }

  @override
  void dispose() {
    _customInputController.dispose();
    super.dispose();
  }

  /// Handle chip selection
  void _onChipSelected(String option) {
    if (widget.allowMultiSelect) {
      setState(() {
        if (_selectedOptions.contains(option)) {
          _selectedOptions.remove(option);
        } else {
          _selectedOptions.add(option);
        }
      });
      return;
    }

    setState(() {
      _selectedOption = option;
      _isCustomInputSelected = false;
      _customInputController.clear();
    });
  }

  /// Handle "Others" option selection
  void _onOthersSelected() {
    setState(() {
      if (widget.allowMultiSelect) {
        _isCustomInputSelected = !_isCustomInputSelected;
        if (!_isCustomInputSelected) {
          _customInputController.clear();
        }
      } else {
        _selectedOption = null;
        _isCustomInputSelected = true;
      }
    });
  }

  /// Validate and return the selected value
  void _onConfirm() {
    if (widget.allowMultiSelect) {
      final customText = _customInputController.text.trim();
      final results = <String>[..._selectedOptions];

      if (_isCustomInputSelected) {
        if (customText.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Please enter your custom input',
                style: TextStyle(
                  fontFamily: 'Bricolage-Grotesque-Regular',
                  color: MoldifyColors.backgroundColor,
                ),
              ),
              backgroundColor: MoldifyColors.primaryColor,
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }

        final customEntries = customText
            .split(',')
            .map((entry) => entry.trim())
            .where((entry) => entry.isNotEmpty);
        results.addAll(customEntries);
      }

      if (results.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please select at least one option',
              style: TextStyle(
                fontFamily: 'Bricolage-Grotesque-Regular',
                color: MoldifyColors.backgroundColor,
              ),
            ),
            backgroundColor: MoldifyColors.primaryColor,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      Navigator.of(context).pop(results.toList());
      return;
    }

    String? result;
    
    if (_isCustomInputSelected) {
      // Validate custom input
      final customText = _customInputController.text.trim();
      if (customText.isEmpty) {
        // Show validation error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please enter your custom input',
              style: TextStyle(
                fontFamily: 'Bricolage-Grotesque-Regular',
                color: MoldifyColors.backgroundColor,
              ),
            ),
            backgroundColor: MoldifyColors.primaryColor,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
      result = customText;
    } else if (_selectedOption != null) {
      result = _selectedOption;
    } else {
      // No selection made
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select an option',
            style: TextStyle(
              fontFamily: 'Bricolage-Grotesque-Regular',
              color: MoldifyColors.backgroundColor,
            ),
          ),
          backgroundColor: MoldifyColors.primaryColor,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Return the selected value
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: MoldifyColors.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      contentPadding: EdgeInsets.zero,
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Header with logo and app name
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/moldify-logo-v2.png',
                        width: 25,
                        height: 25,
                      ),
                      const SizedBox(width: 10),
                      const AutoSizeText(
                        'MOLDIFY',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Montserrat-Bold',
                          color: MoldifyColors.accentColor,
                        ),
                        maxLines: 1,
                        minFontSize: 10,
                      )
                    ],
                  ),
                ),

                /// Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: AutoSizeText(
                    widget.title,
                    style: const TextStyle(
                      fontFamily: 'Montserrat-Black',
                      fontSize: 20,
                      color: MoldifyColors.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    minFontSize: 14,
                  ),
                ),

                const SizedBox(height: 15),

                /// Chip options in a scrollable area
                Flexible(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Column(
                        children: [
                          /// Predefined option chips
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            alignment: WrapAlignment.center,
                            children: widget.options.map((option) {
                              final isSelected = widget.allowMultiSelect
                                  ? _selectedOptions.contains(option)
                                  : _selectedOption == option;
                              return _buildChip(
                                label: option,
                                isSelected: isSelected,
                                onTap: () => _onChipSelected(option),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 12),

                          /// "Others/Iba pa" chip
                          _buildChip(
                            label: widget.othersLabel,
                            isSelected: _isCustomInputSelected,
                            onTap: _onOthersSelected,
                            isOthersOption: true,
                          ),

                          /// Custom input field (shown when "Others" is selected)
                          if (_isCustomInputSelected) ...[
                            const SizedBox(height: 15),
                            BuildTextBox(
                              hintText: widget.customInputHint, 
                              controller: _customInputController, 
                              showPassword: false,
                              isMultiline: widget.isMultiLine,
                              )
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                /// Divider
                const Divider(
                  color: MoldifyColors.MoldifySoftGrey,
                  height: 1,
                ),

                /// Action buttons
                Row(
                  children: [
                    /// Cancel button
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10.0),
                            ),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontFamily: 'Bricolage-Grotesque-SemiBold',
                            fontSize: 16,
                            color: MoldifyColors.MoldifyGrey,
                          ),
                        ),
                      ),
                    ),

                    /// Vertical divider
                    Container(
                      width: 1,
                      height: 50,
                      color: MoldifyColors.MoldifySoftGrey,
                    ),

                    /// Confirm button
                    Expanded(
                      child: TextButton(
                        onPressed: _onConfirm,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(10.0),
                            ),
                          ),
                        ),
                        child: const Text(
                          'Confirm',
                          style: TextStyle(
                            fontFamily: 'Bricolage-Grotesque-ExtraBold',
                            fontSize: 16,
                            color: MoldifyColors.primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build a selectable chip widget
  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    bool isOthersOption = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.0),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 10.0,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? MoldifyColors.primaryColor
              : MoldifyColors.taupe,
          border: Border.all(
            color: isSelected
                ? MoldifyColors.primaryColor
                : MoldifyColors.taupe,
            width: isSelected ? 2.0 : 1.5,
          ),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: isSelected
                ? 'Bricolage-Grotesque-SemiBold'
                : 'Bricolage-Grotesque-Regular',
            fontSize: 14,
            color: isSelected
                ? MoldifyColors.backgroundColor
                : MoldifyColors.MoldifyBlack,
          ),
        ),
      ),
    );
  }
}

/// Helper function to show the chip selection modal
///
/// Returns the selected value, or null if cancelled
Future<String?> showChipSelectionModal({
  required BuildContext context,
  required String title,
  required List<String> options,
  String? currentSelection,
  String customInputHint = 'Type your answer here',
  String othersLabel = 'Others/Iba pa',
  required bool isMultiLine,
}) async {
  return await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return ChipSelectionModal(
        title: title,
        options: options,
        currentSelection: currentSelection,
        customInputHint: customInputHint,
        othersLabel: othersLabel,
        isMultiLine: isMultiLine,
      );
    },
  );
}

Future<List<String>?> showMultiChipSelectionModal({
  required BuildContext context,
  required String title,
  required List<String> options,
  List<String>? currentSelections,
  String customInputHint = 'Type your answer here',
  String othersLabel = 'Others/Iba pa',
  required bool isMultiLine,
}) async {
  return await showDialog<List<String>>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return ChipSelectionModal(
        title: title,
        options: options,
        currentSelections: currentSelections,
        customInputHint: customInputHint,
        othersLabel: othersLabel,
        isMultiLine: isMultiLine,
        allowMultiSelect: true,
      );
    },
  );
}

/// Searchable selection modal for multi-select with high item count.
/// Replaces chip-based modal when many items need to be searched.
Future<List<String>?> showSearchableSelectionModal({
  required BuildContext context,
  required String title,
  required List<String> options,
  List<String>? currentSelections,
  String searchHint = 'Search items...',
  String confirmButtonText = 'Confirm',
  String cancelButtonText = 'Cancel',
}) async {
  return await showDialog<List<String>>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return SearchableSelectionModal(
        title: title,
        options: options,
        currentSelections: currentSelections ?? [],
        searchHint: searchHint,
        confirmButtonText: confirmButtonText,
        cancelButtonText: cancelButtonText,
      );
    },
  );
}

/// Modal dialog with searchable multi-select functionality
class SearchableSelectionModal extends StatefulWidget {
  final String title;
  final List<String> options;
  final List<String> currentSelections;
  final String searchHint;
  final String confirmButtonText;
  final String cancelButtonText;

  const SearchableSelectionModal({
    super.key,
    required this.title,
    required this.options,
    required this.currentSelections,
    this.searchHint = 'Search items...',
    this.confirmButtonText = 'Confirm',
    this.cancelButtonText = 'Cancel',
  });

  @override
  State<SearchableSelectionModal> createState() =>
      _SearchableSelectionModalState();
}

class _SearchableSelectionModalState extends State<SearchableSelectionModal> {
  late TextEditingController _searchController;
  late Set<String> _selectedItems;
  late List<String> _filteredItems;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selectedItems = Set.from(widget.currentSelections);
    _filteredItems = List.from(widget.options);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateFilter(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = List.from(widget.options);
      } else {
        _filteredItems = widget.options
            .where((item) =>
                item.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _toggleSelection(String item) {
    setState(() {
      if (_selectedItems.contains(item)) {
        _selectedItems.remove(item);
      } else {
        _selectedItems.add(item);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontFamily: 'Bricolage-Grotesque-Bold',
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Search field
                  TextField(
                    controller: _searchController,
                    onChanged: _updateFilter,
                    decoration: InputDecoration(
                      hintText: widget.searchHint,
                      hintStyle: TextStyle(
                        color: MoldifyColors.primaryColor.withValues(alpha: 0.3),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: MoldifyColors.primaryColor.withValues(alpha: 0.5),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: MoldifyColors.primaryColor
                                    .withValues(alpha: 0.5),
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _updateFilter('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: MoldifyColors.primaryColor.withValues(alpha: 0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: MoldifyColors.primaryColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Selected: ${_selectedItems.length}',
                    style: TextStyle(
                      fontSize: 12,
                      color: MoldifyColors.primaryColor.withValues(alpha: 0.6),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            // Items list
            Expanded(
              child: _filteredItems.isEmpty
                  ? Center(
                      child: Text(
                        'No items found',
                        style: TextStyle(
                          color: MoldifyColors.primaryColor.withValues(alpha: 0.5),
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: List.generate(
                          _filteredItems.length,
                          (index) {
                            final item = _filteredItems[index];
                            final isSelected = _selectedItems.contains(item);
                            return GestureDetector(
                              onTap: () => _toggleSelection(item),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? MoldifyColors.primaryColor
                                          .withValues(alpha: 0.05)
                                      : Colors.transparent,
                                  border: Border(
                                    bottom: BorderSide(
                                      color: MoldifyColors.primaryColor
                                          .withValues(alpha: 0.05),
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: isSelected,
                                      onChanged: (value) =>
                                          _toggleSelection(item),
                                      activeColor: MoldifyColors.primaryColor,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        item,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontFamily:
                                              'Bricolage-Grotesque-Regular',
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
            ),
            // Footer buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color:
                              MoldifyColors.primaryColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        widget.cancelButtonText,
                        style: TextStyle(
                          color: MoldifyColors.primaryColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedItems.isEmpty
                          ? null
                          : () => Navigator.pop(
                                context,
                                _selectedItems.toList(),
                              ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MoldifyColors.primaryColor,
                        disabledBackgroundColor:
                            MoldifyColors.primaryColor.withValues(alpha: 0.3),
                      ),
                      child: Text(
                        widget.confirmButtonText,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
