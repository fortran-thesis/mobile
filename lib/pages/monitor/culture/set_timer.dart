import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moldify/pages/misc/appbar/primary_app_bar.dart';
import 'package:moldify/pages/misc/buttons/primary_button.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/pages/misc/overlays/modals/confirmation_dialog.dart';
import 'package:moldify/pages/misc/textboxes/textboxes.dart';
import 'package:moldify/core/features/culture/services/culture_session_service.dart';
import 'package:moldify/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class InitializeCulturePage extends StatefulWidget {
  final String? caseId;

  const InitializeCulturePage({super.key, this.caseId});

  @override
  State<InitializeCulturePage> createState() => _InitializeCulturePageState();
}

class _InitializeCulturePageState extends State<InitializeCulturePage> {
  final TextEditingController _nameController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 3));
  int? _activePreset = 3;
  bool _isSubmitting = false;

  void _handlePreset(int days) {
    setState(() {
      _activePreset = days;
      _selectedDate = DateTime.now().add(Duration(days: days));
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: MoldifyColors.primaryColor),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        _activePreset = null;
        _selectedDate = picked;
      });
    }
  }

  void _submitCulture() {
    final name = _nameController.text.trim();
    final caseId = (widget.caseId ?? '').trim();

    if (caseId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Case ID is required to create a timer.')),
      );
      return;
    }

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a culture identifier.')),
      );
      return;
    }

    final targetDate = _selectedDate.toUtc();
    final targetDateLabel = DateFormat('MMM dd, yyyy').format(_selectedDate);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return BuildConfirmationDialog(
          title: 'Set Culture Timer?',
          subtitle: 'Confirm timer for "$name" on $targetDateLabel.',
          onConfirm: () async {
            Navigator.of(dialogContext).pop();
            setState(() => _isSubmitting = true);

            try {
              final authProvider = Provider.of<AppAuthProvider>(
                context,
                listen: false,
              );
              final created = await CultureSessionService.instance.createCulture(
                caseId: caseId,
                name: name,
                targetAt: targetDate,
                sessionCookie: authProvider.cookie,
              );

              if (!mounted) return;
              setState(() => _isSubmitting = false);

              if (created == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to create culture timer.')),
                );
                return;
              }

              Navigator.of(context).pop({
                'id': created.id,
                'name': created.name,
                'targetDate': created.targetAt.toIso8601String(),
                'createdAt': created.createdAt.toIso8601String(),
                'caseId': created.caseId,
              });
            } catch (_) {
              if (!mounted) return;
              setState(() => _isSubmitting = false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to create culture timer.')),
              );
            }
          },
          onCancel: () {
            Navigator.of(dialogContext).pop();
          },
          cancelText: 'No',
          confirmText: 'Yes',
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: const PrimaryAppBar(title: 'Set Culture Timer'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set Culture \nTimer',
              style: TextStyle(
                fontFamily: 'Montserrat-Black',
                fontSize: 36,
                height: 1.1,
                letterSpacing: -2,
                color: MoldifyColors.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            _buildTargetPreview(),
            const SizedBox(height: 60),
            _buildLabel('CULTURE IDENTIFIER'),
            const SizedBox(height: 15),
            BuildTextBox(
              hintText: 'Enter sample name...',
              controller: _nameController,
              showPassword: false,
              fontSize: 16,
            ),
            const SizedBox(height: 45),
            _buildLabel('INCUBATION PERIOD'),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(child: _buildChip(3, '3D')),
                const SizedBox(width: 10),
                Expanded(child: _buildChip(7, '7D')),
                const SizedBox(width: 10),
                Expanded(child: _buildChip(14, '14D')),
                const SizedBox(width: 10),
                Expanded(child: _buildCustomChip()),
              ],
            ),
            const SizedBox(height: 80),
            SizedBox(
              width: double.infinity,
              child: BuildButton(
                onPressed: _isSubmitting ? () {} : _submitCulture,
                buttonText: _isSubmitting ? 'Saving...' : 'Set Timer',
                backgroundColor: MoldifyColors.primaryColor,
                textColor: Colors.white,
                buttonHeight: 60,
                buttonRadius: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetPreview() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: MoldifyColors.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'REMINDER SET: ${DateFormat('EEEE, MMM dd').format(_selectedDate).toUpperCase()}',
        style: const TextStyle(
          fontFamily: 'Bricolage-Grotesque-Bold',
          fontSize: 11,
          letterSpacing: 1,
          color: MoldifyColors.primaryColor,
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Bricolage-Grotesque-Bold',
        fontSize: 11,
        letterSpacing: 2,
        color: MoldifyColors.primaryColor.withValues(alpha: 0.4),
      ),
    );
  }

  Widget _buildChip(int val, String label) {
    final bool isSel = _activePreset == val;
    return GestureDetector(
      onTap: () => _handlePreset(val),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSel ? MoldifyColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSel ? MoldifyColors.primaryColor : MoldifyColors.primaryColor.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSel ? Colors.white : MoldifyColors.primaryColor,
            fontFamily: 'Bricolage-Grotesque-Bold',
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomChip() {
    final bool isSel = _activePreset == null;
    return GestureDetector(
      onTap: _pickDate,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSel ? MoldifyColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSel ? MoldifyColors.primaryColor : MoldifyColors.primaryColor.withValues(alpha: 0.1),
          ),
        ),
        child: Icon(
          Icons.calendar_today_rounded,
          size: 18,
          color: isSel ? Colors.white : MoldifyColors.primaryColor,
        ),
      ),
    );
  }
}
