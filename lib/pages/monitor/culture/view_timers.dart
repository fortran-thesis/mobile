import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moldify/core/features/culture/services/culture_session_service.dart';
import 'package:moldify/pages/misc/appbar/primary_app_bar.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class CultureDashboard extends StatefulWidget {
  final String? caseId;

  const CultureDashboard({super.key, this.caseId});

  @override
  State<CultureDashboard> createState() => _CultureDashboardState();
}

class _CultureDashboardState extends State<CultureDashboard> {
  List<CultureSession> _cultures = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshCultures();
  }

  Future<void> _refreshCultures() async {
    final caseId = (widget.caseId ?? '').trim();
    if (caseId.isEmpty) {
      setState(() {
        _cultures = const [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final sessions = await CultureSessionService.instance.getAll(
      caseId: caseId,
      sessionCookie: authProvider.cookie,
    );

    if (!mounted) return;
    setState(() {
      _cultures = sessions;
      _isLoading = false;
    });
  }

  String _remainingLabel(CultureSession culture) {
    if (culture.isEndedEarly) return 'Ended early';
    if (culture.isTimerElapsed) return 'Ready';

    final now = DateTime.now().toUtc();
    final diff = culture.targetAt.toUtc().difference(now);
    if (diff.inDays > 0) {
      final hours = diff.inHours % 24;
      return '${diff.inDays}d ${hours}h remaining';
    }
    if (diff.inHours > 0) {
      final minutes = diff.inMinutes % 60;
      return '${diff.inHours}h ${minutes}m remaining';
    }
    return '${diff.inMinutes.clamp(0, 59)}m remaining';
  }

  Future<void> _reassignTimer(CultureSession culture) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: culture.targetAt.toLocal().isAfter(now)
          ? culture.targetAt.toLocal()
          : now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    if (!mounted) return;

    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final updated = await CultureSessionService.instance.reassignTimer(
      culture.id,
      DateTime(picked.year, picked.month, picked.day).toUtc(),
      caseId: (widget.caseId ?? '').trim(),
      sessionCookie: authProvider.cookie,
    );
    if (!updated) return;

    await _refreshCultures();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Timer updated for "${culture.name}".')),
    );
  }

  Future<void> _endEarly(CultureSession culture) async {
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final updated = await CultureSessionService.instance.endEarly(
      culture.id,
      caseId: (widget.caseId ?? '').trim(),
      sessionCookie: authProvider.cookie,
    );
    if (!updated) return;
    await _refreshCultures();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: const PrimaryAppBar(title: "Active Incubation Timer"),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Active Incubation Timer",
                  style: TextStyle(
                    fontFamily: 'Montserrat-Black',
                    fontSize: 36,
                    height: 1.1,
                    letterSpacing: -2,
                    color: MoldifyColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  "Monitor your ongoing growth samples and track time remaining for each culture timer.",
                  style: TextStyle(
                    fontFamily: 'Bricolage-Grotesque-Regular',
                    fontSize: 16,
                    height: 1.5,
                    color: MoldifyColors.MoldifyBlack,
                  ),
                ),
              ],
            ),
          ),

          // Dynamic List Section
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: MoldifyColors.primaryColor,
                    ),
                  )
                : _cultures.isEmpty
                ? const Center(
                    child: Text(
                      'No culture timers yet.',
                      style: TextStyle(
                        fontFamily: 'Bricolage-Grotesque-Regular',
                        fontSize: 14,
                        color: MoldifyColors.MoldifyGrey,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    itemCount: _cultures.length,
                    itemBuilder: (context, index) {
                      return _buildCultureCard(_cultures[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCultureCard(CultureSession culture) {
    final setOnLabel = DateFormat('MMM dd, yyyy • hh:mm a').format(culture.createdAt.toLocal());
    final targetLabel = DateFormat('MMM dd, yyyy').format(culture.targetAt.toLocal());
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: MoldifyColors.taupe.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: MoldifyColors.primaryColor.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            culture.name,
            style: const TextStyle(
              fontFamily: 'Bricolage-Grotesque-Bold',
              fontSize: 22,
              letterSpacing: -0.5,
              color: MoldifyColors.primaryColor,
            ),
          ),
          const SizedBox(height: 30),
          _buildStat("STATUS", culture.availabilityLabel),
          const SizedBox(height: 10),
          _buildStat("REMAINING", _remainingLabel(culture)),
          const SizedBox(height: 10),
          _buildStat("SET ON", setOnLabel),
          const SizedBox(height: 10),
          _buildStat("TARGET", targetLabel),
          if (!culture.isEndedEarly) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                TextButton(
                  onPressed: () async => _endEarly(culture),
                  child: const Text(
                    'End Early',
                    style: TextStyle(
                      fontFamily: 'Bricolage-Grotesque-SemiBold',
                      color: MoldifyColors.MoldifyRed,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _reassignTimer(culture),
                  child: const Text(
                    'Reassign Timer',
                    style: TextStyle(
                      fontFamily: 'Bricolage-Grotesque-SemiBold',
                      color: MoldifyColors.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStat(String label, String val) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Bricolage-Grotesque-Bold',
              fontSize: 10,
              letterSpacing: 1,
              color: MoldifyColors.MoldifyGrey,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            val,
            style: const TextStyle(
              fontFamily: 'Bricolage-Grotesque-SemiBold',
              fontSize: 18,
              color: MoldifyColors.primaryColor,
            ),
          ),
        ],
      );
}