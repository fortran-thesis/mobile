import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/appbar/primary_app_bar.dart';
import 'package:moldify/pages/misc/colors.dart';
import '../misc/buttons/primary_button.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: const PrimaryAppBar(
        title: 'Privacy Policy',
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
                      'Privacy Policy',
                      style: TextStyle(
                        fontSize: 36,
                        fontFamily: 'Montserrat-Black',
                        color: MoldifyColors.primaryColor,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your privacy is our priority. This policy explains how Moldify handles your data.',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Bricolage-Grotesque-Regular',
                        color: MoldifyColors.MoldifyBlack,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Effective Date: January 2024',
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Bricolage-Grotesque-Regular',
                        color: MoldifyColors.MoldifyBlack.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 30),

                    /// ----------- Policy Content -----------
                    _buildSection(
                      title: '1. Information We Collect',
                      content: 'We collect information you provide directly to us, such as your name, email address, and 3D design files necessary for our molding services.',
                    ),
                    _buildSection(
                      title: '2. How We Use Data',
                      content: 'Your data is used to process orders, maintain your account, and improve the Moldify experience. We do not sell your personal information to third parties.',
                    ),
                    _buildSection(
                      title: '3. Data Storage & Security',
                      content: 'We implement industry-standard security measures to protect your designs and personal details from unauthorized access or disclosure.',
                    ),
                    _buildSection(
                      title: '4. Third-Party Services',
                      content: 'We may use trusted third-party partners for payment processing and analytics. These partners are required to protect your data according to their own privacy standards.',
                    ),
                    _buildSection(
                      title: '5. Your Rights',
                      content: 'You have the right to access, update, or delete your personal information at any time through your account settings or by contacting our support team.',
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