/// Mixin for screens that should refresh data when the user navigates back to them.
///
/// Usage:
/// ```dart
/// class MainReportScreen extends StatefulWidget {
///   @override
///   State<MainReportScreen> createState() => _MainReportScreenState();
/// }
///
/// class _MainReportScreenState extends State<MainReportScreen>
///     with RouteAware, RefreshOnPopMixin {
///   late final AppRouteObserver _routeObserver;
///
///   @override
///   void initState() {
///     super.initState();
///     _routeObserver = context.read<AppRouteObserver>(); // or get from elsewhere
///     WidgetsBinding.instance.addPostFrameCallback((_) {
///       _routeObserver.subscribe(this, ModalRoute.of(context)!);
///     });
///   }
///
///   @override
///   void didPopNext() {
///     onScreenResumedFromBack();
///   }
///
///   @override
///   void onScreenResumedFromBack() {
///     // Refresh your data here
///     context.read<MoldReportBloc>().add(RefreshMoldReports(...));
///   }
/// }
/// ```
mixin RefreshOnPopMixin {
  /// Called when the screen is resumed after a detail screen is popped.
  /// Override this in your State class to refresh data.
  void onScreenResumedFromBack() {}
}
