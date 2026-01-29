import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/misc/appbar/primary_app_bar.dart';
import 'package:provider/provider.dart';

import '../../misc/colors.dart';
import '../../misc/functions/empty_state.dart';
import '../../misc/textboxes/textboxes.dart';
import '../../misc/tiles/expansion_tile.dart';
import '../../../core/features/faq/models/faq.dart';
import '../../../core/features/faq/service/faq_service.dart';
import '../../../providers/auth_provider.dart';

class MainFAQSCreen extends StatefulWidget {
  const MainFAQSCreen({super.key});

  @override
  State<MainFAQSCreen> createState() => _MainFAQSCreenState();
}

class _MainFAQSCreenState extends State<MainFAQSCreen> {
  final TextEditingController searchController = TextEditingController();
  late final FAQService _faqService;
  
  bool _isLoading = true;
  String? _error;
  List<FAQ> _allFAQs = [];
  List<FAQ> _filteredFAQs = [];

  @override
  void initState() {
    super.initState();
    _faqService = FAQService();
    _loadFAQs();

    // Add search listener
    searchController.addListener(_filterFAQs);
  }

  Future<void> _loadFAQs() async {
    try {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final sessionCookie = authProvider.cookie;

      final response = await _faqService.getAllFAQ(
        sessionCookie: sessionCookie,
        pageSize: 100,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          // Handle the response structure
          if (response['data'] is List) {
            _allFAQs = (response['data'] as List)
                .map((e) => FAQ.fromJson(e as Map<String, dynamic>))
                .toList();
          } else if (response is List) {
            _allFAQs = (response as List)
                .map((e) => FAQ.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          _filteredFAQs = List.from(_allFAQs);
          _error = null;
        });
      }
    } catch (e) {
      print('Failed to load FAQs: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to load FAQs';
          // Keep existing FAQs if available
        });
      }
    }
  }

  void _filterFAQs() {
    final query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredFAQs = List.from(_allFAQs);
      } else {
        _filteredFAQs = _allFAQs.where((faq) {
          final question = faq.question.toLowerCase();
          final answer = faq.answer.toLowerCase();
          return question.contains(query) || answer.contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: const PrimaryAppBar(title: 'FAQ'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// FAQ Header
                    const Text(
                      'FAQ',
                      style: TextStyle(
                        fontSize: 36,
                        fontFamily: 'Montserrat-Black',
                        color: MoldifyColors.primaryColor,
                      ),
                    ),
                    const Text(
                      'Got a question? Find quick answers here.',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Bricolage-Grotesque-Regular',
                        color: MoldifyColors.MoldifyBlack,
                      ),
                    ),
                    /// End of Header

                    /// Search Box
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                      child: BuildTextBox(
                        hintText: 'Search FAQ',
                        controller: searchController,
                        showPassword: false,
                        rightIcon: FontAwesomeIcons.magnifyingGlass,
                      ),
                    ),

                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Text(
                          _error ?? '',
                          style: const TextStyle(
                            color: Colors.red,
                            fontFamily: 'Bricolage-Grotesque-Regular',
                          ),
                        ),
                      ),

                    if (_filteredFAQs.isEmpty)
                      EmptyState(
                        message: searchController.text.isEmpty
                            ? 'No FAQs available.'
                            : 'No FAQs matched your search.',
                        height: MediaQuery.of(context).size.height - 300,
                        icon: FontAwesomeIcons.solidCircleXmark,
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredFAQs.length,
                        itemBuilder: (context, index) {
                          final faq = _filteredFAQs[index];
                          return Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: CustomExpansionTile(
                              title: faq.question,
                              content: faq.answer,
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
