import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/misc/appbar/primary_app_bar.dart';
import 'package:moldify/pages/misc/buttons/primary_button.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/pages/misc/textboxes/textboxes.dart';
import 'package:moldify/core/utils/logger.dart';
import 'package:moldify/core/features/mold_case/service/mold_case_service.dart';
import 'package:moldify/providers/auth_provider.dart';
import 'package:provider/provider.dart';

/// Mycologist verdict submission screen
///
/// Displays lookup results and allows mycologist to:
/// 1. Review and select final mold identification
/// 2. Add optional expert notes
/// 3. Submit final verdict to backend
///
/// Parameters:
/// - [lookupResults]: List of ranked mold matches from lookup algorithm
/// - [caseId]: The mold case ID to associate this verdict with
/// - [onVerdictSubmitted]: Callback with verdict data (moldId, moldName, confidence, notes)
class CaseVerdictScreen extends StatefulWidget {
  final List<Map<String, dynamic>> lookupResults;
  final String caseId;
  final Function(String verdictVerdictJson)? onVerdictSubmitted;

  const CaseVerdictScreen({
    super.key,
    required this.lookupResults,
    required this.caseId,
    this.onVerdictSubmitted,
  });

  @override
  State<CaseVerdictScreen> createState() => _CaseVerdictScreenState();
}

class _CaseVerdictScreenState extends State<CaseVerdictScreen> {
  int? _selectedIndex;
  final TextEditingController _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  /// Helper method to handle async verdict submission
  void _submitVerdictAndNavigate() {
    final selectedResult = widget.lookupResults[_selectedIndex!];
    final moldId = selectedResult['moldId']?.toString();
    final moldName = selectedResult['moldName']?.toString() ?? '';
    // Try 'confidence' first, then fallback to 'confidence_score'
    final confidenceRaw = selectedResult['confidence'] ?? selectedResult['confidence_score'];
    final confidence = (confidenceRaw as num?)?.toDouble() ?? 0.0;

    _performVerdictSubmission(moldId, moldName, confidence);
  }

  /// Perform the async verdict submission
  Future<void> _performVerdictSubmission(
    String? moldId,
    String moldName,
    double confidence,
  ) async {
    setState(() => _isSubmitting = true);

    try {
      final moldCaseService = MoldCaseService();
      final authProvider = Provider.of<AppAuthProvider>(
        context,
        listen: false,
      );

      AppLogger.d('[CaseVerdict] Submitting verdict: $moldName ($confidence%)');

      // Submit verdict to backend
      // moldId is optional - will be null for verdicts from predicted classes not in database
      final result = await moldCaseService.submitVerdict(
        widget.caseId,
        moldId: moldId,
        moldName: moldName,
        confidence: confidence,
        notes: _notesController.text.trim(),
        sessionCookie: authProvider.cookie,
      );

      AppLogger.d('[CaseVerdict] Verdict submitted successfully: $result');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verdict for $moldName submitted successfully'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Call optional callback if provided
        if (widget.onVerdictSubmitted != null) {
          final verdictJson =
              'moldId=$moldId&moldName=$moldName&confidence=$confidence&notes=${_notesController.text}';
          widget.onVerdictSubmitted!(verdictJson);
        }

        Navigator.of(context).pop();
      }
    } catch (e) {
      AppLogger.e('[CaseVerdict] Error submitting verdict', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting verdict: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.d('[CaseVerdict] Building with ${widget.lookupResults.length} results');

    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: PrimaryAppBar(
        title: 'Finalize Verdict',
      ),
      body: widget.lookupResults.isEmpty
          ? _buildNoResultsState()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildInstructionBox(),
                    const SizedBox(height: 24),
                    _buildResultsList(),
                    const SizedBox(height: 24),
                    if (_selectedIndex != null) _buildNotesSection(),
                    const SizedBox(height: 24),
                    if (_selectedIndex != null) _buildSubmitButton(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: MoldifyColors.primaryColor.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 20),
            Text(
              'No Lookup Results',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Montserrat-Black',
                color: MoldifyColors.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No mold matches were found. Please review the initial observations and add more diagnostic data.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Bricolage-Grotesque-Regular',
                color: MoldifyColors.MoldifyGrey,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Submit Final Verdict',
          style: TextStyle(
            fontSize: 28,
            fontFamily: 'Montserrat-Black',
            color: MoldifyColors.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Review the lookup results and select the identified mold species.',
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Bricolage-Grotesque-Regular',
            color: MoldifyColors.MoldifyGrey,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: MoldifyColors.primaryColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: MoldifyColors.primaryColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            FontAwesomeIcons.infoCircle,
            size: 18,
            color: MoldifyColors.primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Select the most likely mold species from the ranked results below. You can add expert notes to justify your selection.',
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'Bricolage-Grotesque-Regular',
                color: MoldifyColors.primaryColor.withValues(alpha: 0.8),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ranked Candidates',
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Bricolage-Grotesque-SemiBold',
            color: MoldifyColors.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: List.generate(
            widget.lookupResults.length,
            (index) => _buildVerdictCard(index),
          ),
        ),
      ],
    );
  }

  Widget _buildVerdictCard(int index) {
    final result = widget.lookupResults[index];
    final moldName = result['moldName']?.toString() ?? 'Unknown';
    // Try 'confidence' first, then fallback to 'confidence_score'
    final confidenceRaw = result['confidence'] ?? result['confidence_score'];
    final confidence = (confidenceRaw as num?)?.toDouble() ?? 0.0;
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = isSelected ? null : index;
        });
        AppLogger.d('[CaseVerdict] Selected candidate: $moldName');
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10.0),
        padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: isSelected
              ? MoldifyColors.accentColor.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? MoldifyColors.accentColor
                : MoldifyColors.primaryColor.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            // Selection radio
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? MoldifyColors.accentColor
                      : MoldifyColors.primaryColor.withValues(alpha: 0.3),
                  width: 2,
                ),
                color: isSelected ? MoldifyColors.accentColor : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            // Mold info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    moldName,
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: 'Bricolage-Grotesque-SemiBold',
                      color: MoldifyColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            // Rank badge
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _getConfidenceColor(confidence).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Montserrat-Black',
                    color: _getConfidenceColor(confidence),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Expert Notes (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Bricolage-Grotesque-SemiBold',
            color: MoldifyColors.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        BuildTextBox(
          controller: _notesController,
          hintText: 'Add notes justifying your identification decision...',
          showPassword: false,
          isMultiline: true,
        ),
        const SizedBox(height: 8),
        Text(
          'Notes help other team members understand your diagnosis.',
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'Bricolage-Grotesque-Regular',
            color: MoldifyColors.MoldifyGrey,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    final selectedResult = widget.lookupResults[_selectedIndex!];
    final moldId = selectedResult['moldId']?.toString() ?? '';
    final moldName = selectedResult['moldName']?.toString() ?? '';
    final confidence = (selectedResult['confidence'] as num?)?.toDouble() ?? 0.0;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14.0),
          decoration: BoxDecoration(
            color: MoldifyColors.accentColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: MoldifyColors.accentColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Final Selection',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Bricolage-Grotesque-SemiBold',
                  color: MoldifyColors.MoldifyGrey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                moldName,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Bricolage-Grotesque-SemiBold',
                  color: MoldifyColors.accentColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        BuildButton(
          onPressed: _isSubmitting
              ? () {} // Disabled state - callback does nothing
              : () {
                  // Using non-async wrapper to match BuildButton's VoidCallback signature
                  _submitVerdictAndNavigate();
                },
          buttonText: _isSubmitting ? 'Submitting...' : 'Submit Final Verdict',
          backgroundColor: MoldifyColors.accentColor,
          textColor: Colors.white,
          buttonHeight: 48,
          buttonRadius: 12,
        ),
      ],
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 80) {
      return Colors.green;
    } else if (confidence >= 50) {
      return Colors.orange;
    } else if (confidence > 0) {
      return Colors.amber;
    } else {
      return MoldifyColors.MoldifyGrey;
    }
  }
}
