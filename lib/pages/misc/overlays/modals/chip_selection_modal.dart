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
  
  /// Hint text for the custom input field
  final String customInputHint;
  
  /// Label for the "Others" option
  final String othersLabel;

  final bool isMultiLine;

  const ChipSelectionModal({
    super.key,
    required this.title,
    required this.options,
    this.currentSelection,
    this.customInputHint = 'Type your answer here',
    this.othersLabel = 'Others/Iba pa', 
    required this.isMultiLine,
  });

  @override
  State<ChipSelectionModal> createState() => _ChipSelectionModalState();
}

class _ChipSelectionModalState extends State<ChipSelectionModal> {
  /// Currently selected option (null if custom input is selected)
  String? _selectedOption;
  
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
    setState(() {
      _selectedOption = option;
      _isCustomInputSelected = false;
      _customInputController.clear();
    });
  }

  /// Handle "Others" option selection
  void _onOthersSelected() {
    setState(() {
      _selectedOption = null;
      _isCustomInputSelected = true;
    });
  }

  /// Validate and return the selected value
  void _onConfirm() {
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
                              final isSelected = _selectedOption == option;
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
