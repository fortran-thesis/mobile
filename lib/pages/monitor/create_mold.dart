import 'package:flutter/material.dart';
import 'package:moldify/core/features/mold/service/mold_service.dart';
import 'package:moldify/pages/misc/appbar/primary_app_bar.dart';
import 'package:moldify/pages/misc/buttons/primary_button.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/pages/misc/textboxes/dropdwon.dart';
import 'package:moldify/pages/misc/textboxes/textboxes.dart';
import 'package:provider/provider.dart';
import 'package:moldify/providers/auth_provider.dart';
import 'package:moldify/core/utils/logger.dart';

class CreateMoldScreen extends StatefulWidget {
  const CreateMoldScreen({super.key});

  @override
  State<CreateMoldScreen> createState() => _CreateMoldScreenState();
}

class _CreateMoldScreenState extends State<CreateMoldScreen> {
  static const Map<String, String> _infoFieldKeys = {
    'Description': 'description',
    'Overview': 'overview',
    'Health Risks': 'health_risks',
    'Affected Hosts': 'affected_hosts',
    'Symptoms & Signs': 'symptoms_and_signs',
    'Disease Cycle / Spread / Impact': 'disease_cycle_spread_impact',
    'Prevention Summary': 'prevention_summary',
  };

  static const Map<String, String> _preventionFieldKeys = {
    'Physical Control': 'physicalControl',
    'Mechanical Control': 'mechanicalControl',
    'Cultural Control': 'culturalControl',
    'Biological Control': 'biologicalControl',
    'Chemical Control': 'chemicalControl',
  };

  late final TextEditingController _nameController;
  late List<String> _availableFields;
  final List<MapEntry<String, TextEditingController>> _addedFields = [];
  String? _selectedField;
  bool _isSubmitting = false;
  int _dropdownKey = 0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _availableFields = [..._infoFieldKeys.keys, ..._preventionFieldKeys.keys];
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final field in _addedFields) {
      field.value.dispose();
    }
    super.dispose();
  }

  void _addField(String label) {
    if (!_availableFields.contains(label)) return;

    setState(() {
      _availableFields.remove(label);
      _addedFields.add(MapEntry(label, TextEditingController()));
      _selectedField = null;
      _dropdownKey++;
    });
  }

  void _removeField(String label) {
    setState(() {
      final index = _addedFields.indexWhere((e) => e.key == label);
      if (index >= 0) {
        _addedFields[index].value.dispose();
        _addedFields.removeAt(index);
        _availableFields.add(label);
        _availableFields.sort((a, b) => a.compareTo(b));
      }
    });
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a mold name.')),
      );
      return;
    }

    final info = <String, dynamic>{};
    final prevention = <String, dynamic>{};

    for (final field in _addedFields) {
      final value = field.value.text.trim();
      if (value.isEmpty) continue;

      if (_infoFieldKeys.containsKey(field.key)) {
        info[_infoFieldKeys[field.key]!] = value;
      } else if (_preventionFieldKeys.containsKey(field.key)) {
        prevention[_preventionFieldKeys[field.key]!] = value;
      }
    }

    setState(() => _isSubmitting = true);

    try {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final service = MoldService();

      AppLogger.d('CreateMold: Submitting name=$name, info keys=${info.keys}, prevention keys=${prevention.keys}');

      final entry = await service.createMold(
        moldName: name,
        info: info.isNotEmpty ? info : null,
        prevention: prevention.isNotEmpty ? prevention : null,
        sessionCookie: authProvider.cookie,
      );

      if (entry == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create mold. Please try again.')),
          );
        }
        setState(() => _isSubmitting = false);
        return;
      }

      AppLogger.d('CreateMold: Success! Created mold=${entry.name} id=${entry.id}');

      if (!mounted) return;
      Navigator.of(context).pop(entry);
    } catch (e, s) {
      AppLogger.e('CreateMold: Exception', error: e, stackTrace: s);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Widget _buildFormLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Bricolage-Grotesque-Bold',
        fontSize: 12,
        letterSpacing: 1.5,
        color: MoldifyColors.primaryColor.withValues(alpha: 0.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: const PrimaryAppBar(title: 'Add New Mold'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create Mold Draft',
              style: const TextStyle(
                fontSize: 36,
                fontFamily: 'Montserrat-Black',
                color: MoldifyColors.primaryColor,
              ),
            ),
            Text(
              'Fill in at least the mold name. Add other fields as needed.',
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Bricolage-Grotesque-Regular',
                color: MoldifyColors.MoldifyBlack,
              ),
            ),
            const SizedBox(height: 40),

            // Mold Name
            _buildFormLabel('MOLD NAME'),
            const SizedBox(height: 12),
            BuildTextBox(
              hintText: 'Enter mold genus or common name...',
              controller: _nameController,
              showPassword: false,
              fontSize: 16,
            ),
            const SizedBox(height: 35),

            // Add Field dropdown
            _buildFormLabel('ADD INFORMATION'),
            const SizedBox(height: 12),
            BuildDropdown(
              key: ValueKey(_dropdownKey),
              hintText: 'Select a field to add',
              items: _availableFields,
              initialValue: _selectedField,
              onChanged: (value) {
                if (value != null && value.isNotEmpty) {
                  _addField(value);
                }
              },
            ),
            const SizedBox(height: 24),

            // Added fields
            if (_addedFields.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No fields added yet. Select a field above to add information.',
                  style: TextStyle(
                    fontFamily: 'Bricolage-Grotesque-Regular',
                    fontSize: 14,
                    color: MoldifyColors.MoldifyGrey,
                  ),
                ),
              )
            else
              ..._addedFields.asMap().entries.map((entry) {
                final label = entry.value.key;
                final controller = entry.value.value;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              fontFamily: 'Bricolage-Grotesque-Bold',
                              fontSize: 12,
                              letterSpacing: 1.0,
                              color: MoldifyColors.primaryColor.withValues(alpha: 0.7),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            color: MoldifyColors.MoldifyGrey,
                            onPressed: () => _removeField(label),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 24,
                              minHeight: 24,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: controller,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Enter information...',
                          hintStyle: const TextStyle(
                            color: MoldifyColors.MoldifyGrey,
                            fontFamily: 'Bricolage-Grotesque-Regular',
                          ),
                          filled: true,
                          fillColor: MoldifyColors.taupe,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                        style: const TextStyle(
                          fontFamily: 'Bricolage-Grotesque-Regular',
                          fontSize: 16,
                          color: MoldifyColors.MoldifyBlack,
                        ),
                      ),
                    ],
                  ),
                );
              }),

            const SizedBox(height: 40),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: Opacity(
                opacity: _isSubmitting ? 0.5 : 1.0,
                child: BuildButton(
                  onPressed: _isSubmitting ? () {} : _submit,
                  buttonText: _isSubmitting ? 'Saving...' : 'Save Draft',
                  fontSize: 16,
                  backgroundColor: MoldifyColors.primaryColor,
                  textColor: MoldifyColors.backgroundColor,
                  buttonHeight: 56,
                  buttonRadius: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
