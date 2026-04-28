import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/appbar/primary_app_bar.dart';
import 'package:moldify/pages/misc/colors.dart';

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
                      'Last updated: April 2026',
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Bricolage-Grotesque-Regular',
                        color: MoldifyColors.MoldifyBlack.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 30),

                    /// ----------- Terms Content -----------
                    _buildProfessionalSection(
                          index: '01',
                          title: 'Acceptance of Terms',
                          content: 'By creating a Moldify account and using the platform, you confirm that:\nYou are at least 18 years of age, or are using the platform under the supervision of a parent or legal guardian\nYou have read, understood, and agree to these Terms and the Moldify Privacy Policy\nThe information you provide during registration and use of the platform is accurate and complete',
                        ),
                        _buildProfessionalSection(
                          index: '02',
                          title: 'Description of Service',
                          content: 'Moldify is an AI-assisted mold investigation and case management system designed to facilitate the submission of mold-related crop concerns by clients and the conduct of official mold investigations by BPI mycologists. The platform provides the following core services:\n\n• Client Module — Submission of mold reports, case status tracking, access to WikiMold reference database, and access to FAQ and educational resources.\n• Mycologist Module — Investigation workflow management based on Koch\'s Postulates (in vitro and in vivo), mold classification using Convolutional Neural Networks (CNN) and Artificial Neural Networks (ANN), and findings documentation.\n• Administrator Module — Case assignment, user management, and administrative oversight\n• WikiMold — A reference database of mold information authored and validated by BPI mycologists',
                        ),
                        _buildProfessionalSection(
                          index: '03',
                          title: 'User Accounts and Registration',
                          content: '3.1 Account Accuracy\nYou are responsible for providing accurate, current, and complete information during registration and for keeping your account information updated. You may update your profile information through the Settings section of the application.\n\n3.2 Account Security\nYou are responsible for maintaining the confidentiality of your account credentials, including your password. You agree to notify Moldify immediately if you suspect any unauthorized access to or use of your account. Moldify and BPI shall not be liable for any loss or damage arising from your failure to safeguard your account credentials.\n\n3.3 Account Access\nMoldify accounts are personal and non-transferable. You may not share your account with or transfer your account to any other person.',
                        ),
                        _buildProfessionalSection(
                          index: '04',
                          title: 'Acceptable Use',
                          content: 'You agree to use Moldify only for its intended purposes as described in Section 2. You agree not to:\n• Submit false, misleading, or fabricated mold reports or information\n• Upload photographs or content that are irrelevant, offensive, or in violation of applicable Philippine law\n• Attempt to gain unauthorized access to any part of the Moldify system, including accounts belonging to other users\n• Interfere with or disrupt the technical operation of the Moldify platform\n• Use Moldify for any commercial purpose not authorized by BPI\n• Attempt to reverse engineer, decompile, or extract source code from the Moldify application\n\nMoldify and BPI reserve the right to suspend or terminate accounts that violate these Terms.',
                        ),
                        _buildProfessionalSection(
                          index: '05',
                          title: 'AI-Assisted Classification',
                          isHighlight: true,
                          content: 'Moldify incorporates an AI-powered image classification system designed to support mold genus identification. By using this feature, you acknowledge and agree to the following:\n\n1. AI classification results are provided as decision-support tools only. They are not a substitute for professional mycological assessment.\n2. All AI-generated classification outputs must be reviewed and validated by a qualified BPI mycologist before any findings are considered official.\n3. Moldify does not guarantee the accuracy of AI classification results. Classification is limited to six mold genera: Alternaria, Aspergillus flavus, Aspergillus niger, Fusarium, Penicillium, and Rhizopus.\n4. Moldify shall not be held liable for any decisions made solely on the basis of AI classification outputs without professional mycologist validation.',
                        ),
                        _buildProfessionalSection(
                          index: '06',
                          title: 'Reports & Investigation Workflow',
                          content: 'When you submit a mold report through Moldify:\nYour report will be reviewed by a BPI administrator and assigned to an appropriate BPI mycologist for investigation.\nThe investigation process follows Koch\'s Postulates methodology and involves laboratory procedures that require a minimum biological incubation period. The duration of a mold investigation is determined by biological constraints and cannot be shortened by the platform.\nMoldify serves as a workflow facilitation tool. The completeness and accuracy of investigation findings depend on the quality of information and samples provided.\nFindings and recommendations delivered through Moldify are issued by BPI mycologists and reflect professional judgment. For financial assistance or further on-site support, you are encouraged to contact your Municipal or City Agriculture Office (MAO/CAO) or the Philippine Crop Insurance Corporation (PCIC).',
                        ),
                        _buildProfessionalSection(
                          index: '07',
                          title: 'WikiMold Content',
                          content: 'The WikiMold database contains reference information on mold genera authored and validated by BPI mycologists. You agree that:\nWikiMold content is provided for general educational and reference purposes only.\nWikiMold content does not constitute a formal diagnosis of any specific crop disease or condition.\nOnly authorized BPI mycologists may create or modify WikiMold content. Client users may not submit or edit WikiMold articles.',
                        ),
                        _buildProfessionalSection(
                          index: '08',
                          title: 'Intellectual Property',
                          content: 'All content, software, design, and materials comprising the Moldify platform, including but not limited to the application code, UI design, AI model architecture, and WikiMold content, are the intellectual property of the Moldify development team and the Bureau of Plant Industry, as applicable. You may not reproduce, distribute, modify, or create derivative works from any Moldify content without prior written authorization.',
                        ),
                        _buildProfessionalSection(
                          index: '09',
                          title: 'Data Privacy',
                          content: 'Your use of Moldify is also governed by the Moldify Privacy Policy, which is incorporated into these Terms by reference. By agreeing to these Terms, you also acknowledge and accept the Moldify Privacy Policy. The Privacy Policy describes how we collect, use, store, and protect your personal data in compliance with Republic Act No. 10173 (Data Privacy Act of 2012).',
                        ),
                        _buildProfessionalSection(
                          index: '10',
                          title: 'Limitation of Liability',
                          content: 'To the fullest extent permitted by applicable Philippine law, Moldify and BPI shall not be liable for:\nAny indirect, incidental, or consequential damages arising from your use of or inability to use the platform\nAny loss or damage to crops, harvests, or agricultural output based on mold investigation findings delivered through Moldify\nAny inaccuracy in AI-assisted mold classification results\nSystem downtime, technical errors, or interruptions in service\nMoldify is provided on an \'as is\' and \'as available\' basis. BPI and the Moldify development team make no warranties, express or implied, regarding the platform\'s fitness for any particular purpose beyond those explicitly stated herein.',
                        ),
                        _buildProfessionalSection(
                          index: '11',
                          title: 'Modification of Terms',
                          content: 'Moldify and BPI reserve the right to modify these Terms at any time. Updated Terms will be posted within the application with a revised Effective Date. Continued use of the platform following any modification constitutes your acceptance of the revised Terms.',
                        ),
                        _buildProfessionalSection(
                          index: '12',
                          title: 'Governing Law',
                          content: 'These Terms shall be governed by and construed in accordance with the laws of the Republic of the Philippines. Any disputes arising from these Terms or your use of Moldify shall be subject to the jurisdiction of the appropriate courts of the Philippines.',
                        ),
                        _buildProfessionalSection(
                          index: '13',
                          title: 'Contact Information',
                          content: 'For questions or concerns regarding these Terms, please contact:\n\nBureau of Plant Industry (BPI)\n692 San Andres Street, Malate, Manila 1004, Philippines\nWebsite: www.bpi.da.gov.ph',
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