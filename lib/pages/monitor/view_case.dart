import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/core/constants/route_names.dart';
import 'package:moldify/pages/misc/buttons/primary_button.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/pages/misc/functions/tab_bar.dart';
import 'package:moldify/pages/monitor/content_tab/case_details.dart';
import 'package:moldify/pages/monitor/content_tab/in_vitro.dart';
import 'package:moldify/pages/monitor/content_tab/in_vivo.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../misc/appbar/primary_app_bar.dart';
import '../misc/images/cover_image.dart';
import '../misc/tiles/status_tile.dart';
import '../../../core/features/mold_case/models/mold_case.dart';
import '../../../core/features/mold_case/repository/mold_case_repository.dart';
import '../../../providers/auth_provider.dart';

class ViewCaseScreen extends StatefulWidget {

  const ViewCaseScreen({super.key});

  @override
  _ViewCaseScreenState createState() => _ViewCaseScreenState();
}
class _ViewCaseScreenState extends State<ViewCaseScreen> {
  String? caseImageUrl = "https://aggie-horticulture.tamu.edu/wp-content/uploads/sites/10/2012/01/black_mold.jpg";
  String caseStatus = 'Pending';

  // Backend-driven state
  bool _isLoading = true;
  String? _error;
  MoldCase? _case;

  // Static fallback data
  final String farmerName = 'Juan Dela Cruz';
  final String dateFirstObserved = 'October 30, 2025';
  final String emailAddress = 'juan.delacruz@example.com';
  final String contactNumber = '+63 917 123 4567';
  final List<Map<String, dynamic>> caseEntries = [
    {
      'date': 'October 30, 2025',
      'notes': 'Initial report. Small, dark spots observed on the lower leaves of several tomato plants. The area is humid and has poor air circulation.',
      'images': [
        'https://worldofplants.ai/wp-content/uploads/2024/03/word-image-81042-3.jpeg',
        'https://worldofplants.ai/wp-content/uploads/2024/03/word-image-81042-3.jpeg',
        'https://worldofplants.ai/wp-content/uploads/2024/03/word-image-81042-3.jpeg',
        'https://worldofplants.ai/wp-content/uploads/2024/03/word-image-81042-3.jpeg',
      ],
    },
    {
      'date': 'November 2, 2025',
      'notes': 'Follow-up. The spots have enlarged and now have a dark border with a lighter tan center. Some lower leaves are starting to turn yellow and drop.',
      'images': [
        'https://worldofplants.ai/wp-content/uploads/2024/03/word-image-81042-3.jpeg',
        'https://worldofplants.ai/wp-content/uploads/2024/03/word-image-81042-3.jpeg',
      ],
    },
    {
      'date': 'November 2, 2025',
      'notes': 'Follow-up. The spots have enlarged and now have a dark border with a lighter tan center. Some lower leaves are starting to turn yellow and drop.',
      'images': [
        'https://worldofplants.ai/wp-content/uploads/2024/03/word-image-81042-3.jpeg',
        'https://worldofplants.ai/wp-content/uploads/2024/03/word-image-81042-3.jpeg',
        'https://worldofplants.ai/wp-content/uploads/2024/03/word-image-81042-3.jpeg',
      ],
    },
  ];

  // Data for In-Vitro Tab
  final String inVitroDateTime = 'November 01, 2025 – 10:00 AM';
  final String inVitroGrowthMedium = 'Potato Dextrose Agar';
  final String inVitroIncubationTemperature = '25°C';
  final List<Map<String, String>> inVitroEntries = [
    {
      'date': 'November 01, 2025 – 10:00 AM',
      'imagePath': 'https://www.researchgate.net/profile/Upma-Narain/publication/302458334/figure/fig2/AS:360578246823939@1462979961979/Macroscopic-picture-of-Penicillium-crysogeniam.png',
      'sizeValue': '10 mm',
      'colorValue': 'White',
      'notes': 'Initial growth observed. Colony is circular and small.',
    },
    {
      'date': 'November 03, 2025 – 10:00 AM',
      'imagePath': 'https://www.researchgate.net/profile/Upma-Narain/publication/302458334/figure/fig2/AS:360578246823939@1462979961979/Macroscopic-picture-of-Penicillium-crysogeniam.png',
      'sizeValue': '25 mm',
      'colorValue': 'Greenish-blue',
      'notes': 'Color changing to a greenish-blue. Mycelium is spreading.',
    },
    {
      'date': 'November 05, 2025 – 10:00 AM',
      'imagePath': 'https://www.researchgate.net/profile/Upma-Narain/publication/302458334/figure/fig2/AS:360578246823939@1462979961979/Macroscopic-picture-of-Penicillium-crysogeniam.png',
      'sizeValue': '50 mm',
      'colorValue': 'Dark Green',
      'notes': 'Colony has almost covered the plate. Spores are visible.',
    },
  ];

  // Data for In-Vivo Tab
  final String inVivoDateTime = 'November 01, 2025 – 10:00 AM';
  final String inVivoEnvironmentalTemperature = '28°C';
  final List<Map<String, String>> inVivoEntries = [
    {
      'date': 'November 02, 2025 – 9:00 AM',
      'imagePath': 'https://extension.usu.edu/vegetableguide/images/solanaceae-images/black-mold-tomato.jpg',
      'sizeValue': '5 mm',
      'colorValue': 'Yellowish',
      'notes': 'Small lesions appeared on the leaves. No significant wilting.',
    },
    {
      'date': 'November 04, 2025 – 9:00 AM',
      'imagePath': 'https://extension.usu.edu/vegetableguide/images/solanaceae-images/black-mold-tomato.jpg',
      'sizeValue': '15 mm',
      'colorValue': 'Brown with yellow halo',
      'notes': 'Lesions have enlarged and developed a distinct yellow halo. Some leaf curling observed.',
    },
  ];

  String _getCaseCropName() {
    if (_case == null) return 'Kamatis Tagalog';
    return _case!.cultivationDetails?.growthMedium ?? 'Kamatis Tagalog';
  }

  Future<void> _loadCaseFromArgs() async {
    final args = ModalRoute.of(context)?.settings.arguments;
    print('ViewCase: args = $args');
    String? id;
    if (args is Map<String, dynamic>) {
      id = args['id']?.toString();
    } else if (args is String) {
      id = args;
    }

    print('ViewCase: extracted id = $id');

    if (id == null || id.isEmpty) {
      setState(() {
        _error = 'No case id provided';
        _isLoading = false;
      });
      return;
    }

    try {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final sessionCookie = authProvider.cookie;
      print('ViewCase: sessionCookie = ${sessionCookie?.substring(0, 20)}...');

      // Create a local repository
      final repo = MoldCaseRepository(pageSize: 10);

      print('ViewCase: calling getCaseById($id)');
      final MoldCase? moldCase = await repo.getCaseById(id, sessionCookie: sessionCookie);
      print('ViewCase: getCaseById returned: $moldCase');

      if (moldCase == null) {
        setState(() {
          _error = 'Case not found';
          _isLoading = false;
        });
        return;
      }

      print('ViewCase: case.mycologistId = ${moldCase.mycologistId}');
      print('ViewCase: case.name = ${moldCase.name}');
      print('ViewCase: case.priority = ${moldCase.priority}');

      setState(() {
        _case = moldCase;
        caseStatus = _case!.priority[0].toUpperCase() + _case!.priority.substring(1);
        caseImageUrl = _case!.photoUrl ?? caseImageUrl;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      print('ViewCase: ERROR - $e');
      print('ViewCase: stackTrace - $stackTrace');
      setState(() {
        _error = 'Failed to load case: $e';
        _isLoading = false;
      });
    }
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCaseFromArgs();
    });
  }

  @override
  Widget build(BuildContext context) {
    //Determine if the case is closed. This boolean will control the UI.
    final bool isCaseClosed = caseStatus == 'Closed';
    
    // Use API data if available, otherwise use fallback defaults
    String priorityLevel = _case?.priority != null 
        ? _case!.priority[0].toUpperCase() + _case!.priority.substring(1) + ' Priority'
        : 'Low Priority';
    
    String endDate = _case?.endDate != null
        ? DateFormat('MMMM dd, yyyy').format(_case!.endDate!)
        : 'December 15, 2025';


    //Dynamically build the list of menu items based on the case status.
    final List<String> popupMenuItems = [
      if (!isCaseClosed) 'Set Monitoring Details',
      'Identification History',
      'Treatment History',
      'Export PDF'
    ];

    final List<IconData> popupMenuIcons = [
      if (!isCaseClosed) FontAwesomeIcons.circleInfo,
      FontAwesomeIcons.clockRotateLeft,
      FontAwesomeIcons.sprayCan,
      FontAwesomeIcons.solidFilePdf,
    ];


    return Scaffold(
        backgroundColor: MoldifyColors.backgroundColor,
        appBar: PrimaryAppBar(
            title: 'View Case',
            showPopupMenu: true,
            popupMenuItems: popupMenuItems,
            popupMenuIcons: popupMenuIcons,
            onPopupMenuItemSelected: (index) {
              // The selected item is now correctly determined from the same list used by the menu.
              final selectedItem = popupMenuItems[index];

              if (selectedItem == 'Set Monitoring Details') {
                Navigator.pushNamed(context, '/set-monitoring-details');
              }
              else if (selectedItem == 'Identification History') {
                Navigator.pushNamed(context, '/identification-history');
              }
              else if (selectedItem == 'Treatment History') {
                Navigator.pushNamed(context, '/treatment-history');
              }
              else if (selectedItem == 'Export PDF') {
                // Implement export PDF functionality here
              }
            }
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            FontAwesomeIcons.exclamationTriangle,
                            size: 48,
                            color: MoldifyColors.accentColor,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Error Loading Case',
                            style: TextStyle(
                              fontFamily: 'Montserrat-Bold',
                              fontSize: 16,
                              color: MoldifyColors.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Bricolage-Grotesque-Regular',
                              fontSize: 12,
                              color: MoldifyColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
          child: Stack(
            children: [

              ///1. Cover image for the case
              BuildCoverImage(
                imageUrl: caseImageUrl,
                borderRadiusContainer: 8,
                borderRadiusImage: 8,
                isHeader: true,
              ),

              ///2. Case details
              Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.23),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: MoldifyColors.backgroundColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0, bottom: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            StatusBox(status: priorityLevel, fontSize: 12,),
                            SizedBox(width: 5),
                            StatusBox(status: caseStatus, fontSize: 12,),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'End Date: ',
                                  style: const TextStyle(
                                    fontSize: 10.0,
                                    color: MoldifyColors.primaryColor,
                                    fontFamily: 'Bricolage-Grotesque-Regular',
                                  ),
                                ),
                                TextSpan(
                                  text: endDate,
                                  style: const TextStyle(
                                    fontSize: 10.0,
                                    color: MoldifyColors.primaryColor,
                                    fontFamily: 'Bricolage-Grotesque-Bold',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _case?.name ?? 'Tomato Mold',
                            style: TextStyle(
                              fontFamily: 'Montserrat-Black',
                              fontSize: 24,
                              color: MoldifyColors.primaryColor,
                              height: 1.2,
                            ),
                          ),
                        ),
                        /// Crop Name
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: RichText(
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                text: TextSpan(
                                  children: [
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: Icon(
                                        FontAwesomeIcons.seedling,
                                        size: 16,
                                        color: MoldifyColors.accentColor,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "			${_getCaseCropName()}",
                                      style: TextStyle(
                                        color: MoldifyColors.primaryColor,
                                        fontSize: 12,
                                        fontFamily:
                                        'Bricolage-Grotesque-Regular',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: RichText(
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                text: TextSpan(
                                  children: [
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: Icon(
                                        FontAwesomeIcons.locationDot,
                                        size: 16,
                                        color: MoldifyColors.accentColor,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "			${_case?.moldReportId ?? 'Ilocos Region'}",
                                      style: TextStyle(
                                        color: MoldifyColors.primaryColor,
                                        fontSize: 12,
                                        fontFamily:
                                        'Bricolage-Grotesque-Regular',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        if(!isCaseClosed)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Row(
                              children: [
                                Flexible(
                                  child: BuildButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        RouteNames.mainCamera,
                                        arguments: {'showAppBar': true},
                                      );
                                    },
                                    buttonText: 'Identify Mold',
                                    fontSize: 12,
                                    backgroundColor: MoldifyColors.primaryColor,
                                    textColor: MoldifyColors.backgroundColor,
                                    leftIcon: FontAwesomeIcons.camera,
                                    iconSize: 12,
                                    iconColor: MoldifyColors.backgroundColor,
                                    paddingIconText: 10,
                                    buttonHeight: 30,
                                    buttonRadius: 7,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: BuildButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/add-treatment',
                                      );
                                    },
                                    buttonText: 'Add Treatment',
                                    fontSize: 12,
                                    backgroundColor: MoldifyColors.accentColor,
                                    textColor: MoldifyColors.MoldifyBlack,
                                    leftIcon: FontAwesomeIcons.plus,
                                    iconSize: 12,
                                    iconColor: MoldifyColors.MoldifyBlack,
                                    paddingIconText: 10,
                                    buttonHeight: 30,
                                    buttonRadius: 7,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.7,
                            child: BuildTabBar(
                              tabs: ['Case Details', 'In Vitro', 'In Vivo'],
                              tabContents: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                  child: CaseDetailsTab(
                                    entries: caseEntries,
                                    farmerName: farmerName,
                                    dateFirstObserved: dateFirstObserved,
                                    emailAddress: emailAddress,
                                    contactNumber: contactNumber,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                  child: InVitroTab(
                                    isCaseClosed: isCaseClosed,
                                    dateTime: inVitroDateTime,
                                    growthMedium: inVitroGrowthMedium,
                                    incubationTemperature: inVitroIncubationTemperature,
                                    inVitroEntries: inVitroEntries,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                  child: InVivoTab(
                                    isCaseClosed: isCaseClosed,
                                    dateTime: inVivoDateTime,
                                    environmentalTemperature: inVivoEnvironmentalTemperature,
                                    inVivoEntries: inVivoEntries,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),

            ],
          ),
        )
                );
  }
}