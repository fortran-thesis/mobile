import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:moldify/core/constants/api_url.dart';
import 'package:moldify/core/constants/route_names.dart';
import 'package:moldify/core/utils/auth_navigation.dart';
import 'package:moldify/pages/misc/functions/app_drawer.dart';
import 'package:provider/provider.dart';
import 'package:moldify/providers/auth_provider.dart';
import 'package:moldify/providers/language_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moldify/l10n/app_localizations.dart';
import 'routes/app_routes.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/home/home_page.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/pages/monitor/main_monitor.dart';
import 'package:moldify/pages/farmer/report/main_report.dart';
import 'package:moldify/core/features/user/logic/user_bloc.dart';
import 'package:moldify/core/features/user/services/user_services.dart';
import 'package:moldify/core/features/notification/logic/notification_bloc.dart';
import 'package:moldify/core/features/notification/repository/notification_repository.dart';
import 'package:moldify/core/services/fcm_service.dart';
import 'package:moldify/core/services/cache_sync_service.dart';
import 'package:moldify/core/utils/notification_navigation.dart';
import 'package:moldify/core/utils/route_observer.dart';
import 'package:moldify/core/utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ApiUrl.logConfig();
  await Firebase.initializeApp();

  // Create provider and WAIT for cookie to load
  final authProvider = AppAuthProvider();
  await authProvider.loadCookie(); // <-- WAIT here!

  // Initialise FCM (request permission, get token, register with backend)
  await FCMService.instance.initialise(sessionCookie: authProvider.cookie);

  // Initialize cache sync service to listen for invalidation events
  CacheSyncService.instance.initialize();

  final prefs = await SharedPreferences.getInstance();
  final languageProvider = LanguageProvider(prefs);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: languageProvider),
        BlocProvider(create: (_) => UserBloc(userService: UserService())),
        BlocProvider(
          create: (_) => NotificationBloc(repository: NotificationRepository()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

final tabs = ['Home', 'Monitor'];

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();
  late final AppAuthProvider _authProvider;
  late final AppRouteObserver _routeObserver;
  StreamSubscription<NotificationTapEvent>? _notificationTapSubscription;
  bool _wasAuthenticated = false;

  @override
  void initState() {
    super.initState();
    // Initialize route observer for back-navigation refresh support
    _routeObserver = AppRouteObserver();

    // Listen to auth changes once and only redirect when session transitions
    // from authenticated -> unauthenticated.
    _authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    _wasAuthenticated =
        _authProvider.cookie != null && _authProvider.cookie!.isNotEmpty;
    _authProvider.addListener(_onAuthStateChanged);
    _subscribeToNotificationTaps();
  }

  @override
  void dispose() {
    _notificationTapSubscription?.cancel();
    _authProvider.removeListener(_onAuthStateChanged);
    _routeObserver.dispose();
    super.dispose();
  }

  void _subscribeToNotificationTaps() {
    _notificationTapSubscription = FCMService.instance.notificationTaps.listen(
      _handleNotificationTap,
    );

    final pending = FCMService.instance.consumePendingNotificationTap();
    if (pending != null) {
      _handleNotificationTap(pending);
    }
  }

  String? _resolveCurrentUserRole() {
    final userState = context.read<UserBloc>().state;
    if (userState is UserProfileLoaded) {
      return userState.profile.role;
    }
    return null;
  }

  void _handleNotificationTap(NotificationTapEvent event) {
    final hasSession =
        _authProvider.cookie != null && _authProvider.cookie!.isNotEmpty;
    if (!hasSession) {
      AppLogger.w('Skipping notification navigation: no active session');
      return;
    }

    final target = resolveNotificationNavigationTarget(
      referenceType: event.referenceType,
      referenceId: event.referenceId,
      userRole: _resolveCurrentUserRole(),
    );

    if (target == null) {
      AppLogger.w(
        'No navigation target for notification type=${event.referenceType} id=${event.referenceId}',
      );
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final navigator = _rootNavigatorKey.currentState;
      if (navigator == null) return;

      navigator.pushNamed(target.routeName, arguments: target.arguments);
    });
  }

  void _onAuthStateChanged() {
    final isAuthenticated =
        _authProvider.cookie != null && _authProvider.cookie!.isNotEmpty;

    final shouldRedirectToLogin = _wasAuthenticated && !isAuthenticated;
    _wasAuthenticated = isAuthenticated;

    // Redirect only when a previously authenticated session is invalidated.
    if (!shouldRedirectToLogin) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final navigator = _rootNavigatorKey.currentState;
      if (navigator == null) return;
      AuthNavigation.resetToLoginFromNavigator(navigator);
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, langProvider, _) {
        return MaterialApp(
          title: 'Moldify',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            snackBarTheme: SnackBarThemeData(
              behavior: SnackBarBehavior.floating,
              backgroundColor: MoldifyColors.primaryColor,
              contentTextStyle: const TextStyle(
                fontFamily: 'Bricolage-Grotesque-Regular',
                fontSize: 14,
                color: MoldifyColors.backgroundColor,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          locale: langProvider.effectiveLocale,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('fil'),
          ],
          initialRoute: RouteNames.splash,
          onGenerateRoute: AppRoutes.generateRoute,
          navigatorKey: _rootNavigatorKey,
          navigatorObservers: [_routeObserver],
        );
      },
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
  DateTime? _lastBackPressedAt;
  GlobalKey<NavigatorState> _homeTabNavigatorKey = GlobalKey<NavigatorState>();
  GlobalKey<NavigatorState> _workTabNavigatorKey = GlobalKey<NavigatorState>();
  late final NavigatorObserver _homeTabObserver;
  late final NavigatorObserver _workTabObserver;
  bool _homeTabAtRoot = true;
  bool _workTabAtRoot = true;

  static const Duration _backExitWindow = Duration(seconds: 2);

  bool _isExpert = false; // mycologist/curator => true; farmer/user => false

  @override
  void initState() {
    super.initState();
    _homeTabObserver = _TabRouteObserver(
      onAtRootChanged: (atRoot) {
        if (!mounted || _homeTabAtRoot == atRoot) return;
        setState(() => _homeTabAtRoot = atRoot);
      },
    );
    _workTabObserver = _TabRouteObserver(
      onAtRootChanged: (atRoot) {
        if (!mounted || _workTabAtRoot == atRoot) return;
        setState(() => _workTabAtRoot = atRoot);
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final sessionCookie = authProvider.cookie;
      context.read<UserBloc>().add(
        FetchUserProfile(sessionCookie: sessionCookie),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final showNavChrome = selectedPosition == 0 ? _homeTabAtRoot : _workTabAtRoot;

    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserProfileLoaded) {
          final role = state.profile.role.toLowerCase();
          final isExpert = !(role == 'farmer' || role == 'user');

          // Notify LanguageProvider so it can gate Filipino locale to farmers only.
          context.read<LanguageProvider>().setRole(isFarmer: !isExpert);

          if (isExpert != _isExpert) {
            setState(() {
              _isExpert = isExpert;
              selectedPosition = 0;
              // Reset tab stacks when role changes to avoid stale tab routes.
              _homeTabNavigatorKey = GlobalKey<NavigatorState>();
              _workTabNavigatorKey = GlobalKey<NavigatorState>();
            });
          }
        }
      },
        child: PopScope(
        // Keep pop handling centralized so tab-back and app-exit behavior is predictable.
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          _handleNativeBack();
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: false,
            extendBody: true,
          drawer: showNavChrome && selectedPosition == 0 ? const AppDrawer() : null,
          body: IndexedStack(
            index: selectedPosition,
            children: [
              _buildTabNavigator(tabIndex: 0),
              _buildTabNavigator(tabIndex: 1),
            ],
          ),
          floatingActionButton: showNavChrome
              ? SizedBox(
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
                )
              : null,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: showNavChrome ? _buildBottomNavigationBar() : null,
        ),
      ),
    );
  }

  Widget _buildTabNavigator({required int tabIndex}) {
    final rootPage = tabIndex == 0
        ? const HomeScreen()
        : (_isExpert ? const MainMonitorScreen() : const MainReportScreen());

    return Navigator(
      key: tabIndex == 0 ? _homeTabNavigatorKey : _workTabNavigatorKey,
      observers: [tabIndex == 0 ? _homeTabObserver : _workTabObserver],
      onGenerateRoute: (settings) {
        if (settings.name == Navigator.defaultRouteName) {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => rootPage,
          );
        }
        return AppRoutes.generateRoute(settings);
      },
    );
  }

  /// This method builds the bottom navigation bar with two items:
  /// - Home icon that navigates to the HomeScreen when tapped.
  /// - Monitor icon that navigates to the MainMonitorScreen when tapped.
  /// The selected icon is highlighted based on the selectedPosition.
  Widget _buildBottomNavigationBar() {
    final mediaQuery = MediaQuery.of(context);
    final safeBottom = mediaQuery.viewPadding.bottom;
    final screenWidth = mediaQuery.size.width;
    final isNarrowPhone = mediaQuery.size.width < 360;
    final iconSize = isNarrowPhone ? 18.0 : 21.0;
    final tabHorizontalPadding = isNarrowPhone ? 10.0 : 16.0;
    final baseFabGap = screenWidth * (isNarrowPhone ? 0.30 : 0.36);
    final fabGap = baseFabGap.clamp(112.0, 170.0);
    const navContentHeight = 56.0;

    return SizedBox(
      height: navContentHeight + safeBottom,
      child: BottomAppBar(
        color: MoldifyColors.primaryColor,
        shape: const CircularNotchedRectangle(),
        notchMargin: 5.0,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: EdgeInsets.only(bottom: safeBottom),
          child: SizedBox(
            height: navContentHeight,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _tabItem(
                      icon: FontAwesomeIcons.house,
                      isSelected: selectedPosition == 0,
                      onTap: () => setState(() => selectedPosition = 0),
                      iconSize: iconSize,
                      horizontalPadding: tabHorizontalPadding,
                    ),
                  ),
                ),
                SizedBox(width: fabGap),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _tabItem(
                      icon: FontAwesomeIcons.seedling,
                      isSelected: selectedPosition == 1,
                      onTap: () => setState(() => selectedPosition = 1),
                      iconSize: iconSize,
                      horizontalPadding: tabHorizontalPadding,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
    required double iconSize,
    required double horizontalPadding,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.0),
      radius: 22,
      splashColor: MoldifyColors.accentColor.withValues(alpha: 0.18),
      highlightColor: MoldifyColors.accentColor.withValues(alpha: 0.10),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Center(
            child: Icon(
              icon,
              color: isSelected
                  ? MoldifyColors.accentColor
                  : MoldifyColors.backgroundColor,
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleNativeBack() async {
    // First try to pop inside the active tab stack.
    final currentNavigator = selectedPosition == 0
        ? _homeTabNavigatorKey.currentState
        : _workTabNavigatorKey.currentState;
    final didPopInTab =
        await (currentNavigator?.maybePop() ?? Future.value(false));
    if (didPopInTab) return;

    // If active tab is at root and it is not Home, return to Home.
    if (selectedPosition != 0) {
      setState(() => selectedPosition = 0);
      return;
    }

    final now = DateTime.now();
    final shouldExit =
        _lastBackPressedAt != null &&
        now.difference(_lastBackPressedAt!) <= _backExitWindow;

    if (shouldExit) {
      SystemNavigator.pop();
      return;
    }

    _lastBackPressedAt = now;
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
        ),
      );
  }
}

class _TabRouteObserver extends NavigatorObserver {
  _TabRouteObserver({required this.onAtRootChanged});

  final ValueChanged<bool> onAtRootChanged;

  void _notify() {
    final nav = navigator;
    if (nav == null) return;
    onAtRootChanged(!nav.canPop());
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _notify();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _notify();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _notify();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _notify();
  }
}
