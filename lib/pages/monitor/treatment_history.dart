import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/misc/tiles/treatment_history_tile.dart';

import '../misc/appbar/primary_app_bar.dart';
import '../misc/colors.dart';
import '../misc/functions/empty_state.dart';
import '../misc/textboxes/textboxes.dart';

class TreatmentHistoryScreen extends StatefulWidget {
  const TreatmentHistoryScreen({super.key});

  @override
  State<TreatmentHistoryScreen> createState() => _TreatmentHistoryScreenState();

}

class _TreatmentHistoryScreenState extends State<TreatmentHistoryScreen> {
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> treatmentData = [
      {
        "date": "October 30, 2025",
        "recommendedFungicides": [
          "Carbendazim",
          "Propiconazole",
          "Tebuconazole",
          "Azoxystrobin",
          "Mancozeb",
        ],
        "additionalNotes":
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut et massa mi. Aliquam in hendrerit urna.",
      },
      {
        "date": "November 2, 2025",
        "recommendedFungicides": [
          "Chlorothalonil",
          "Thiophanate-methyl",
        ],
        "additionalNotes":
        "Suspendisse potenti. Donec vel eros at sapien pharetra fringilla.",
      },
    ];

    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: PrimaryAppBar(
        title: 'Treatment History',
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ----------- Identification History Header -----------
              Text(
                  'Treatment History',
                  style: TextStyle(
                    fontSize: 36,
                    fontFamily: 'Montserrat-Black',
                    color: MoldifyColors.primaryColor,
                  )
              ),
              Text(
                  'Track treatment made for this case overtime.',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Bricolage-Grotesque-Regular',
                    color: MoldifyColors.MoldifyBlack,
                  )
              ),
              /// ----------- End of Identification History Header -----------

              /// Search Box
              Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                child: BuildTextBox(
                  hintText: 'Search History',
                  controller: searchController,
                  showPassword: false,
                  rightIcon: FontAwesomeIcons.magnifyingGlass,
                ),
              ),

              treatmentData.isEmpty
                  ? EmptyState(
                message: 'No treatment history available.',
                icon: FontAwesomeIcons.clockRotateLeft,
                height: MediaQuery.of(context).size.height - 300,
              ):
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: treatmentData.length,
                itemBuilder: (context, index) {
                  final treatment = treatmentData[index];
                  return TreatmentHistoryTile(
                    date: treatment['date'],
                    recommendedFungicides: List<String>.from(treatment['recommendedFungicides']),
                    additionalNotes: treatment['additionalNotes'],
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