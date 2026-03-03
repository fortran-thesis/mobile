import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moldify/core/constants/route_names.dart';
import 'package:moldify/pages/misc/functions/app_drawer.dart';
import 'package:provider/provider.dart';
import 'package:moldify/providers/auth_provider.dart';
import 'routes/app_routes.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/home/home_page.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/pages/monitor/main_monitor.dart';
import 'package:moldify/pages/farmer/report/main_report.dart';
import 'dart:async';
import 'package:moldify/core/features/user/logic/user_bloc.dart';
import 'package:moldify/core/features/user/services/user_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Create provider and WAIT for cookie to load
  final authProvider = AppAuthProvider();
  await authProvider.loadCookie();  // <-- WAIT here!

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        BlocProvider(
          create: (_) => UserBloc(userService: UserService()),
        ),
      ],
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
    final authProvider = Provider.of<AppAuthProvider>(context);
    final bool isAuthenticated = authProvider.cookie != null && authProvider.cookie!.isNotEmpty;
    return MaterialApp(
      title: 'Moldify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      initialRoute: RouteNames.splash,
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

  // Bloc to fetch user profile and decide role-based layout
  late UserBloc _userBloc;
  StreamSubscription? _userSub;
  bool _isExpert = true; // mycologist/curator => true; farmer/user => false

  /// List of pages to be displayed in the main page. This is updated
  /// depending on the user's role (expert vs farmer).
  List<Widget> _pages = [
    const HomeScreen(),
    const MainMonitorScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _userBloc = UserBloc(userService: UserService());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final sessionCookie = authProvider.cookie;
      _userBloc.add(FetchUserProfile(sessionCookie: sessionCookie));
    });

    _userSub = _userBloc.stream.listen((state) {
      print('🔵 UserBloc state: $state');
      if (state is UserProfileLoaded) {
        final role = state.profile.role.toLowerCase();
        final isExpert = !(role == 'farmer' || role == 'user');
        print('🔵 User role from profile: ${state.profile.role} (lowercase: $role)');
        print('🔵 Is expert: $isExpert, Current _isExpert: $_isExpert');
        if (isExpert != _isExpert) {
          setState(() {
            _isExpert = isExpert;
            if (_isExpert) {
              _pages = [const HomeScreen(), const MainMonitorScreen()];
              print('🔵 Pages set to EXPERT mode (Home + Monitor)');
            } else {
              _pages = [const HomeScreen(), const MainReportScreen()];
              print('🔵 Pages set to FARMER mode (Home + Report)');
            }
            if (selectedPosition >= _pages.length) selectedPosition = 0;
          });
        } else {
          print('🔵 isExpert did not change, no setState called');
        }
      } else {
        print('🔵 UserBloc state is not UserProfileLoaded: ${state.runtimeType}');
      }
    });
  }

  @override
  void dispose() {
    _userSub?.cancel();
    _userBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserProfileLoaded) {
            final role = state.profile.role.toLowerCase();
            final isExpert = !(role == 'farmer' || role == 'user');

            if (isExpert != _isExpert) {
              setState(() {
                _isExpert = isExpert;
                _pages = isExpert
                    ? [const HomeScreen(), const MainMonitorScreen()]
                    : [const HomeScreen(), const MainReportScreen()];
                selectedPosition = 0;
              });
            }
          }
        },
        child: Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      drawer: selectedPosition == 0 ? const AppDrawer() : null,
      body: _pages[selectedPosition],
      floatingActionButton: SizedBox(
        height: 63.0,
        width: 63.0,
        child: FloatingActionButton(
          onPressed: null,
          backgroundColor: MoldifyColors.primaryColor,
          shape: const CircleBorder(),
          elevation: 0,
          focusElevation: 0,
          hoverElevation: 0,
          highlightElevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Image.asset(
              'assets/images/moldify-logo.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNavigationBar(),
    )
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
          mainAxisSize: MainAxisSize.max,
          children: _isExpert
              ? [
                  _tabItem(
                    icon: FontAwesomeIcons.house,
                    isSelected: selectedPosition == 0,
                    onTap: () => setState(() => selectedPosition = 0),
                  ),
                  _tabItem(
                    icon: FontAwesomeIcons.seedling,
                    isSelected: selectedPosition == 1,
                    onTap: () => setState(() => selectedPosition = 1),
                  ),
                ]
              : [
                  _tabItem(
                    icon: FontAwesomeIcons.house,
                    isSelected: selectedPosition == 0,
                    onTap: () => setState(() => selectedPosition = 0),
                  ),
                  _tabItem(
                    icon: FontAwesomeIcons.seedling,
                    isSelected: selectedPosition == 1,
                    onTap: () => setState(() => selectedPosition = 1),
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
