import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moldify/core/features/notification/logic/notification_bloc.dart';
import 'package:moldify/core/features/notification/models/notification.dart';
import 'package:moldify/core/features/user/logic/user_bloc.dart';
import 'package:moldify/l10n/app_localizations.dart';
import 'package:moldify/pages/misc/appbar/primary_app_bar.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/pages/misc/overlays/loading_ui.dart';
import 'package:moldify/pages/misc/tiles/notification_tile.dart';
import 'package:moldify/core/utils/notification_navigation.dart';
import 'package:moldify/core/utils/logger.dart';
import 'package:provider/provider.dart';
import 'package:moldify/providers/auth_provider.dart';

/// This screen displays a list of notifications for the user.
/// It consumes [NotificationBloc] for data and actions (mark-read, delete).

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cookie = Provider.of<AppAuthProvider>(context, listen: false).cookie;
      context.read<NotificationBloc>().add(RefreshNotifications(sessionCookie: cookie));
    });
  }

  @override
  Widget build(BuildContext context) {
    final cookie = Provider.of<AppAuthProvider>(context, listen: false).cookie;

    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: PrimaryAppBar(
          title: 'Notification'
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: AppLoadingSpinner());
          }

          if (state is NotificationError) {
            final l10n = AppLocalizations.of(context)!;
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Failed to load notifications',
                    style: TextStyle(
                      fontFamily: 'Bricolage-Grotesque-Regular',
                      fontSize: 16,
                      color: MoldifyColors.MoldifyBlack,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      context.read<NotificationBloc>().add(
                        RefreshNotifications(sessionCookie: cookie),
                      );
                    },
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          final notifications = state is NotificationLoaded
              ? state.notifications
              : <AppNotification>[];

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: MoldifyColors.MoldifyGrey),
                  const SizedBox(height: 12),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      fontFamily: 'Montserrat-Black',
                      fontSize: 18,
                      color: MoldifyColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'You\'re all caught up!',
                    style: TextStyle(
                      fontFamily: 'Bricolage-Grotesque-Regular',
                      fontSize: 14,
                      color: MoldifyColors.MoldifyGrey,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<NotificationBloc>().add(
                RefreshNotifications(sessionCookie: cookie),
              );
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 20.0, bottom: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// ----------- Notification Header -----------
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Notification',
                          style: TextStyle(
                            fontSize: 36,
                            fontFamily: 'Montserrat-Black',
                            color: MoldifyColors.primaryColor,
                          ),
                        ),
                        if (state is NotificationLoaded && state.unreadCount > 0)
                          GestureDetector(
                            onTap: () {
                              context.read<NotificationBloc>().add(
                                MarkAllNotificationsRead(sessionCookie: cookie),
                              );
                            },
                            child: Text(
                              'Mark All Read',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Bricolage-Grotesque-ExtraBold',
                                color: MoldifyColors.MoldifyBlue,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Text(
                      'All received notifications can be viewed here.',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Bricolage-Grotesque-Regular',
                        color: MoldifyColors.MoldifyBlack,
                      ),
                    ),
                    /// ----------- End of Notification Header -----------

                    /// ----------- Notification List -----------
                    Padding(
                      padding: const EdgeInsets.only(top: 30.0),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notif = notifications[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Dismissible(
                              key: Key(notif.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: MoldifyColors.MoldifyRed.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.delete, color: MoldifyColors.MoldifyRed),
                              ),
                              onDismissed: (_) {
                                context.read<NotificationBloc>().add(
                                  DeleteNotificationEvent(
                                    notificationId: notif.id,
                                    sessionCookie: cookie,
                                  ),
                                );
                              },
                              child: BuildNotificationTile(
                                onViewDetails: () {
                                  AppLogger.d('View details of notification ${notif.id}: referenceType=${notif.referenceType}, referenceId=${notif.referenceId}');

                                  // Mark as read
                                  context.read<NotificationBloc>().add(
                                    MarkNotificationRead(
                                      notificationId: notif.id,
                                      sessionCookie: cookie,
                                    ),
                                  );

                                  // Navigate based on reference_type
                                  if (notif.referenceId != null && notif.referenceType != null) {
                                    final userState = context.read<UserBloc>().state;
                                    final userRole = (userState is UserProfileLoaded)
                                        ? userState.profile.role
                                        : null;
                                    final target = resolveNotificationNavigationTarget(
                                      referenceType: notif.referenceType,
                                      referenceId: notif.referenceId,
                                      userRole: userRole,
                                    );

                                    if (target != null) {
                                      Navigator.pushNamed(
                                        context,
                                        target.routeName,
                                        arguments: target.arguments,
                                      );
                                    } else {
                                      AppLogger.w(
                                        'Notification tap ignored: type=${notif.referenceType}, id=${notif.referenceId}, role=$userRole',
                                      );
                                    }
                                  }
                                },
                                onMarkAsRead: () {
                                  context.read<NotificationBloc>().add(
                                    MarkNotificationRead(
                                      notificationId: notif.id,
                                      sessionCookie: cookie,
                                    ),
                                  );
                                },
                                title: notif.title,
                                subtitle: notif.body,
                                isRead: notif.isRead,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    /// ----------- End of Notification List -----------
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}