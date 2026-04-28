import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/appbar/primary_app_bar.dart';
import 'package:moldify/pages/misc/colors.dart';

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
                        color: MoldifyColors.MoldifyBlack.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 30),

                    /// ----------- Policy Content -----------
                    _buildProfessionalSection(
                          index: '01',
                          title: 'Scope of This Policy',
                          content: 'This Privacy Policy applies to all users of the Moldify platform, including:\n• Clients (farmers, horticulturists, students, gardeners, and other individuals interacting with both website and mobile application)\n• Mycologists (BPI personnel conducting mold investigations)\n• Administrators (BPI personnel managing cases and users)\n\nThis policy covers both the Moldify mobile application and the Moldify web platform.',
                        ),
                        _buildProfessionalSection(
                          index: '02',
                          title: 'Information We Collect',
                          content: '2.1 Account Registration Information\nWhen you create an account, we collect: First Name, Last Name, Username, Email Address, Phone Number, Occupation, Location (City/Province), and encrypted Passwords.\n\n2.2 Mold Report Submission Information\nWhen a Client submits a report, we collect: Host plant affected, location of the affected plant, date first observed, photographs, and the problem description.',
                        ),
                        _buildProfessionalSection(
                          index: '03',
                          title: 'How We Use Your Information',
                          content: 'Moldify processes your personal data for purposes tied to mold investigation services, including:\n• Account management and report routing to BPI mycologists.\n• Facilitating the investigation workflow (case assignment, laboratory work, and recommendations).\n• Enabling contact regarding your mold case.\n• Maintaining official BPI diagnostic records and generating AI-assisted classification.\n• Improving system performance and reliability.\n\nMoldify does not use your personal data for marketing, advertising, or any commercial purposes unrelated to these services.',
                        ),
                        _buildProfessionalSection(
                          index: '04',
                          title: 'Data Sharing and Disclosure',
                          content: '4.1 Sharing with BPI Personnel\nInformation is made visible to assigned mycologists and administrators to conduct investigations, follow-up, and deliver recommendations. This is consistent with existing BPI diagnostic procedures.\n\n4.2 No Third-Party Commercial Sharing\nMoldify does not sell, rent, or trade your personal information. Data is used exclusively within the platform by authorized personnel.\n\n4.3 Legal Disclosure\nWe may disclose information if required by Philippine law, lawful order, or government regulation.',
                        ),
                        _buildProfessionalSection(
                          index: '05',
                          title: 'Data Storage and Security',
                          isHighlight: true,
                          content: '5.1 Storage Platform\nData is stored on Firebase Firestore and Firebase Cloud Storage. Access is restricted to authorized components and BPI personnel.\n\n5.2 Security Measures\nWe implement technical and organizational measures, including encrypted password storage and role-based access controls.\n\n5.3 Data Retention\nRecords are retained as official BPI diagnostic records and historical reference for research. Report images and corrections are retained to support the future retraining of the Moldify AI classification model for accuracy.',
                        ),
                        _buildProfessionalSection(
                          index: '06',
                          title: 'Your Rights as a Data Subject',
                          content: 'Under RA 10173, you have the following rights:\n• Right to be Informed and Right to Access.\n• Right to Rectification (update via Settings).\n• Right to Object and Right to Data Portability.\n• Right to Erasure: Please note that Moldify does not offer self-service deletion because case records form part of official BPI diagnostic records. Requests for deletion are handled case-by-case via the contact information in Section 9.\n• Right to Lodge a Complaint with the National Privacy Commission (NPC).',
                        ),
                        _buildProfessionalSection(
                          index: '07',
                          title: 'Cookies and Tracking',
                          content: 'The Moldify mobile application does not use tracking cookies. The web platform may use session-based cookies strictly for authentication and session management purposes.',
                        ),
                        _buildProfessionalSection(
                          index: '08',
                          title: 'Changes to This Policy',
                          content: 'Moldify reserves the right to modify this Privacy Policy at any time. Continued use of the platform after modifications constitutes acceptance of the updated policy.',
                        ),
                        _buildProfessionalSection(
                          index: '09',
                          title: 'Contact Information',
                          content: 'Bureau of Plant Industry (BPI)\n692 San Andres Street, Malate, Manila 1004, Philippines\nWebsite: www.bpi.da.gov.ph\n\nFor privacy-related concerns, you may also contact the National Privacy Commission (NPC) at: www.privacy.gov.ph',
                        ),
                        const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalSection({
    required String index,
    required String title,
    required String content,
    bool isHighlight = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32.0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MoldifyColors.primaryColor.withValues(alpha: 0.03),
            
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlight 
              ? MoldifyColors.primaryColor.withValues(alpha: 0.2) 
              : MoldifyColors.MoldifyBlack.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                index,
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Montserrat-Black',
                  color: MoldifyColors.accentColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Montserrat-Black',
                    color: MoldifyColors.primaryColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(height: 1, thickness: 0.5),
          ),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Bricolage-Grotesque-Regular',
              color: MoldifyColors.MoldifyBlack.withValues(alpha: 0.8),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}