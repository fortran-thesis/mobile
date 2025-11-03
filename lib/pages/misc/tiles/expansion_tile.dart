import 'package:flutter/material.dart';


import '../colors.dart';

class CustomExpansionTile extends StatefulWidget {
  String title;
  String content;

   CustomExpansionTile({
    required this.title,
    required this.content,
    super.key
  });

  @override
  CustomExpansionTileState createState() => CustomExpansionTileState();
}

class CustomExpansionTileState extends State<CustomExpansionTile> {
  bool customIcon = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: ExpansionTile(
            title: Text(
              widget.title,
              style: TextStyle(
                fontFamily: 'Bricolage-Grotesque-SemiBold',
                color: MoldifyColors.primaryColor,
                fontSize: 16,
              ),
            ),
            trailing: Icon(customIcon
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded),
            collapsedIconColor: MoldifyColors.accentColor,
            iconColor: MoldifyColors.accentColor,
            onExpansionChanged: (bool expanded) {
              setState(() {
                customIcon = expanded;
              });
            },
            tilePadding: const EdgeInsets.symmetric(horizontal: 15),
            backgroundColor: MoldifyColors.taupe,
            collapsedBackgroundColor: MoldifyColors.taupe,
            collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: MoldifyColors.backgroundColor),
            ),
            children:  <Widget>[
              ListTile(
                title: Text(
                  widget.content,
                  style: TextStyle(
                    fontFamily: 'Bricolage-Grotesque-Regular',
                    color: MoldifyColors.MoldifyBlack,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
