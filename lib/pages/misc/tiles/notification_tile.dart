// ignore_for_file: library_private_types_in_public_api
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../colors.dart';

/// This widget builds a notification tile that displays a title, subtitle, and options to view details or mark as read.
/// The tile's appearance changes based on whether the notification is read or unread.
/// Parameters:
/// - [title]: The title of the notification.
/// - [subtitle]: The subtitle of the notification.
/// - [isRead]: A boolean indicating whether the notification has been read.
/// - [onViewDetails]: Callback function to be called when the user taps on "View Details".
/// - [onMarkAsRead]: Callback function to be called when the user taps on "Mark As Read".

class BuildNotificationTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final bool isRead;
  final VoidCallback onViewDetails;
  final VoidCallback onMarkAsRead;

  const BuildNotificationTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.isRead = false,
    required this.onViewDetails,
    required this.onMarkAsRead,
  });

  @override
  _BuildNotificationTileState createState() => _BuildNotificationTileState();
}
class _BuildNotificationTileState extends State<BuildNotificationTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isRead ? MoldifyColors.taupe.withValues(alpha: 0.9) : MoldifyColors.MoldifyBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  FontAwesomeIcons.solidBell,
                  color: widget.isRead ? MoldifyColors.accentColor: MoldifyColors.MoldifyBlue,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AutoSizeText.rich(
                    TextSpan(
                      style: TextStyle(
                        fontFamily: 'Montserrat-Black',
                        fontSize: 16,
                        color: widget.isRead ? MoldifyColors.primaryColor: MoldifyColors.MoldifyBlack.withValues(alpha: 0.7),
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(
                            text: '${widget.title}\n',
                        ),
                        TextSpan(
                          text: widget.subtitle,
                          style: TextStyle(
                            fontFamily: 'Bricolage-Grotesque-Regular',
                            fontSize: 14,
                            color: widget.isRead ? MoldifyColors.MoldifyBlack: MoldifyColors.MoldifyBlack.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.start,
                    maxLines: 4,
                    minFontSize: 10,
                  )
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: widget.onViewDetails,
                    splashColor: widget.isRead ? MoldifyColors.MoldifyBlack : MoldifyColors.MoldifyBlack.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20.0),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                          'View Details',
                          style: TextStyle(
                            fontFamily: 'Bricolage-Grotesque-ExtraBold',
                            fontSize: 12,
                            color: MoldifyColors.MoldifyBlue,

                          )
                      ),
                    ),
                  ),
                  widget.isRead ? SizedBox() : SizedBox(width: 10.0),
                  widget.isRead ? Container() :
                  InkWell(
                    onTap: widget.onMarkAsRead,
                    splashColor: widget.isRead ? MoldifyColors.MoldifyBlack : MoldifyColors.MoldifyBlack.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20.0),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                          'Mark As Read',
                          style: TextStyle(
                            fontFamily: 'Bricolage-Grotesque-ExtraBold',
                            fontSize: 12,
                            color: MoldifyColors.primaryColor,

                          )
                      ),
                    ),
                  ),
                ],
              ),
            )
          ]
        ),
      )
    );
  }
}