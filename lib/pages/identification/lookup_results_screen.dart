import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/misc/appbar/primary_app_bar.dart';
import 'package:moldify/pages/misc/buttons/primary_button.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/core/utils/logger.dart';

/// Display ranked mold lookup results in a scrollable list
///
/// Parameters:
/// - [lookupResults]: List of mold lookup results from the API, already sorted by confidence
/// - [onSelectMold]: Callback when user taps a result (passes moldId, moldName, confidence)
/// - [onBack]: Callback for back button
class LookupResultsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> lookupResults;
  final Function(String moldId, String moldName, double confidence)? onSelectMold;
  final VoidCallback? onBack;

  const LookupResultsScreen({
    super.key,
    required this.lookupResults,
    this.onSelectMold,
    this.onBack,
  });

  @override
  State<LookupResultsScreen> createState() => _LookupResultsScreenState();
}

class _LookupResultsScreenState extends State<LookupResultsScreen> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    AppLogger.d('[LookupResults] Building screen with ${widget.lookupResults.length} results');

    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: PrimaryAppBar(
        title: 'Lookup Results',
      ),
      body: widget.lookupResults.isEmpty
          ? _buildEmptyState()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderSection(),
                    const SizedBox(height: 20),
                    _buildResultsList(),
                    const SizedBox(height: 30),
                    if (_selectedIndex != null) _buildActionButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
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
              'No Matches Found',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Montserrat-Black',
                color: MoldifyColors.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No molds matched your reported symptoms, signs, or characteristics. Please review your inputs and try again.',
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

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lookup Complete',
          style: TextStyle(
            fontSize: 28,
            fontFamily: 'Montserrat-Black',
            color: MoldifyColors.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Found ${widget.lookupResults.length} potential matches ranked by confidence score.',
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

  Widget _buildResultsList() {
    return Column(
      children: List.generate(
        widget.lookupResults.length,
        (index) => _buildResultCard(index),
      ),
    );
  }

  Widget _buildResultCard(int index) {
    final result = widget.lookupResults[index];
    final moldId = result['moldId']?.toString() ?? '';
    final moldName = result['moldName']?.toString() ?? 'Unknown';
    final confidence = (result['confidence'] as num?)?.toDouble() ?? 0.0;
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = isSelected ? null : index;
        });
        AppLogger.d('[LookupResults] Selected: $moldName ($confidence%)');
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isSelected
              ? MoldifyColors.primaryColor.withValues(alpha: 0.08)
              : MoldifyColors.primaryColor.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? MoldifyColors.primaryColor
                : MoldifyColors.primaryColor.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rank + Name + Confidence
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rank badge
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getConfidenceColor(confidence).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Montserrat-Black',
                        color: _getConfidenceColor(confidence),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Name + Confidence
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        moldName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Bricolage-Grotesque-SemiBold',
                          color: MoldifyColors.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Confidence: ${confidence.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Bricolage-Grotesque-Regular',
                          color: MoldifyColors.MoldifyGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                // Chevron icon
                Icon(
                  isSelected ? Icons.expand_less : Icons.expand_more,
                  color: MoldifyColors.primaryColor.withValues(alpha: 0.5),
                ),
              ],
            ),
            // Confidence progress bar
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: confidence / 100,
                minHeight: 6,
                backgroundColor: MoldifyColors.primaryColor.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation(
                  _getConfidenceColor(confidence),
                ),
              ),
            ),
            // Expanded details (shown when selected)
            if (isSelected) ...[
              const SizedBox(height: 16),
              Divider(
                color: MoldifyColors.primaryColor.withValues(alpha: 0.1),
                height: 1,
              ),
              const SizedBox(height: 16),
              _buildConfidenceBadge(confidence),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceBadge(double confidence) {
    String confidenceLabel;
    Color badgeColor;

    if (confidence >= 80) {
      confidenceLabel = 'High Match';
      badgeColor = Colors.green;
    } else if (confidence >= 50) {
      confidenceLabel = 'Moderate Match';
      badgeColor = Colors.orange;
    } else {
      confidenceLabel = 'Low Match';
      badgeColor = Colors.amber;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            confidence >= 80
                ? FontAwesomeIcons.checkCircle
                : confidence >= 50
                    ? FontAwesomeIcons.infoCircle
                    : FontAwesomeIcons.exclamationCircle,
            size: 14,
            color: badgeColor,
          ),
          const SizedBox(width: 8),
          Text(
            confidenceLabel,
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'Bricolage-Grotesque-SemiBold',
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    final selectedResult = widget.lookupResults[_selectedIndex!];
    final moldId = selectedResult['moldId']?.toString() ?? '';
    final moldName = selectedResult['moldName']?.toString() ?? '';
    final confidence = (selectedResult['confidence'] as num?)?.toDouble() ?? 0.0;

    return Column(
      children: [
        const SizedBox(height: 20),
        BuildButton(
          onPressed: () {
            if (widget.onSelectMold != null) {
              widget.onSelectMold!(moldId, moldName, confidence);
            }
            AppLogger.d('[LookupResults] Confirmed selection: $moldName');
          },
          buttonText: 'Confirm Selection',
          backgroundColor: MoldifyColors.primaryColor,
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
