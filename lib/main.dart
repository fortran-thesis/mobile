import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:moldify/core/constants/route_names.dart';
import 'package:provider/provider.dart';
import 'package:moldify/providers/auth_provider.dart';
import 'routes/app_routes.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/home/home_page.dart';
import 'package:moldify/pages/identification/main_camera.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/pages/monitor/main_monitor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppAuthProvider()..loadCookie(),
      child: const MyApp(),
    ),
  );
}

final tabs = ['Home', 'Monitor'];

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moldify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
      ),
      initialRoute: RouteNames.intro,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedPosition = 0;

  /// List of pages to be displayed in the main page.
  /// The first page is the HomeScreen, the second is the MainCameraScreen,
  /// and the third is the MainMonitorScreen.
  final List<Widget> _pages = [
    const HomeScreen(),
    const MainCameraScreen(),
    const MainMonitorScreen(),
  ];

  /// This method is called when the widget is first created.
  /// It initializes the selectedPosition to 0, which means the first page (HomeScreen)
  /// will be displayed initially.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[selectedPosition],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            selectedPosition = 1;
          });
        },
        backgroundColor: MoldifyColors.primaryColor,
        shape: const CircleBorder(),
        child: Icon(
          FontAwesomeIcons.camera,
          size: 24,
          color: selectedPosition == 1
              ? MoldifyColors.accentColor
              : MoldifyColors.backgroundColor,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  /// This method builds the bottom navigation bar with two items:
  /// - Home icon that navigates to the HomeScreen when tapped.
  /// - Monitor icon that navigates to the MainMonitorScreen when tapped.
  /// The selected icon is highlighted based on the selectedPosition.
  Widget _buildBottomNavigationBar() {
    return SizedBox(
      height: 52.0,
      child: BottomAppBar(
        color: MoldifyColors.primaryColor,
        shape: const CircularNotchedRectangle(),
        notchMargin: 5.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _tabItem(
              icon: FontAwesomeIcons.house,
              isSelected: selectedPosition == 0,
              onTap: () => setState(() => selectedPosition = 0),
            ),
            _tabItem(
              icon: FontAwesomeIcons.chartSimple,
              isSelected: selectedPosition == 2,
              onTap: () => setState(() => selectedPosition = 2),
            ),
          ],
        ),
      ),
    );
  }

  /// This method creates a tab item for the bottom navigation bar.
  /// It takes an icon, a boolean indicating if it is selected,
  /// and a callback function to be executed when the item is tapped.
  Widget _tabItem({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? MoldifyColors.accentColor
                  : MoldifyColors.backgroundColor,
              size: 20.0,
            ),
          ],
        ),
      ),
    );
  }
}
