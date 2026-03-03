import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/appbar/primary_app_bar.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/pages/misc/tiles/notification_tile.dart';
import 'package:moldify/core/utils/logger.dart';

/// This screen displays a list of notifications for the user.
/// It includes a header and a list of notifications that can be marked as read.

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {

  ///Temporary list of notifications
  ///This list can be replaced with a dynamic list fetched from a database or API.
  List <Map<String, dynamic>> notifications = [
    {
      'title': 'LOG YOUR GROWTH UPDATE!',
      'subtitle': 'Aspergillus || Next log is in 4 hours. ',
      'isRead': false,
    },
    {
      'title': 'FLAG REPORT CORRECTED!',
      'subtitle': 'Aspergillus was changed to Penicillium.',
      'isRead': false,
    },
    {
      'title': 'FLAG REPORT DISMISSED!',
      'subtitle': 'The curator found no issues.',
      'isRead': false,
    },
    {
      'title': 'REPORT REVIEWED!',
      'subtitle': 'Your report led to the curator\'s suspension.',
      'isRead': true,
    },
    {
      'title': 'REPORT REVIEWED!',
      'subtitle': 'The curator was asked to revise the content.',
      'isRead': true,
    },
    {
      'title': 'REPORT REVIEWED!',
      'subtitle': 'No violation was found in the report.',
      'isRead': true,
    },
  ];

  /// Function to mark a notification as read
  /// This function updates the notification's 'isRead' status to true.
  void _markAsRead(int index) {
    setState(() {
      notifications[index]['isRead'] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: PrimaryAppBar(
          title: 'Notification'
      ),
      body: SingleChildScrollView(
        child: Padding (padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 20.0, bottom: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ----------- Notification Header -----------
              Text(
                  'Notification',
                  style: TextStyle(
                    fontSize: 36,
                    fontFamily: 'Montserrat-Black',
                    color: MoldifyColors.primaryColor,
                  )
              ),
              Text(
                  'All received notifications can be viewed here.',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Bricolage-Grotesque-Regular',
                    color: MoldifyColors.MoldifyBlack,
                  )
              ),
              /// ----------- End of Notification Header -----------

              /// ----------- Notification List -----------
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    /// BuildNotificationTile is a custom widget that displays the notification tile
                    child: BuildNotificationTile(
                      onViewDetails: () {
                        AppLogger.d('View details of notification');
                      },
                      onMarkAsRead: () {
                        _markAsRead(index);
                      },
                      title: notifications[index]['title'],
                      subtitle: notifications[index]['subtitle'],
                      isRead: notifications[index]['isRead'],
                    ),
                  ),
                )
              ),
              /// ----------- End of Notification List -----------
            ],
          ),
        ),
      )
    );
  }
}