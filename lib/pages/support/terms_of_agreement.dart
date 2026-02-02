import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/appbar/primary_app_bar.dart';
import 'package:moldify/pages/misc/colors.dart';
import '../misc/buttons/primary_button.dart';

class TermsOfAgreementScreen extends StatefulWidget {
  const TermsOfAgreementScreen({super.key});

  @override
  State<TermsOfAgreementScreen> createState() => _TermsOfAgreementScreenState();
}

class _TermsOfAgreementScreenState extends State<TermsOfAgreementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: const PrimaryAppBar(
        title: 'Terms of Agreement',
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 20.0, bottom: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// ----------- Header -----------
                    Text(
                      'Terms of Agreement',
                      style: TextStyle(
                        fontSize: 36,
                        fontFamily: 'Montserrat-Black',
                        color: MoldifyColors.primaryColor,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Subtitle brought back here
                    Text(
                      'This agreement outlines the terms and conditions for using Moldify.',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Bricolage-Grotesque-Regular',
                        color: MoldifyColors.MoldifyBlack,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Last updated: October 2023',
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Bricolage-Grotesque-Regular',
                        color: MoldifyColors.MoldifyBlack.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 30),

                    /// ----------- Terms Content -----------
                    _buildSection(
                      title: '1. Acceptance of Terms',
                      content: 'By accessing and using Moldify, you agree to be bound by these terms. If you do not agree, please refrain from using our services.',
                    ),
                    _buildSection(
                      title: '2. User Responsibilities',
                      content: 'Users are responsible for maintaining the confidentiality of their account information and for all activities that occur under their account.',
                    ),
                    _buildSection(
                      title: '3. Data Privacy',
                      content: 'Your privacy is important to us. Moldify collects minimal data necessary to provide high-quality 3D molding services. Please review our Privacy Policy for more details.',
                    ),
                    _buildSection(
                      title: '4. Intellectual Property',
                      content: 'All designs, logos, and software used in Moldify are the property of Moldify Inc. or its licensors and are protected by copyright laws.',
                    ),
                    _buildSection(
                      title: '5. Limitations of Liability',
                      content: 'Moldify shall not be liable for any indirect, incidental, or consequential damages resulting from the use or inability to use the platform.',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'Montserrat-Black',
              color: MoldifyColors.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              fontFamily: 'Bricolage-Grotesque-Regular',
              color: MoldifyColors.MoldifyBlack,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}