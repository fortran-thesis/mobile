import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/colors.dart';

class BuildTabBar extends StatefulWidget {
  final List<String> tabs;
  final List<Widget> tabContents;
  final int initialIndex;

  const BuildTabBar({
    super.key,
    required this.tabs,
    required this.tabContents,
    this.initialIndex = 0,
  });

  @override
  State<BuildTabBar> createState() => _BuildTabBarState();
}

class _BuildTabBarState extends State<BuildTabBar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    assert(widget.tabs.length == widget.tabContents.length,
    'Tabs and contents must have the same length.');
    _tabController = TabController(
      length: widget.tabs.length,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- TAB HEADER ---
        TabBar(
          controller: _tabController,
          isScrollable: false,
          labelColor: MoldifyColors.primaryColor,
          unselectedLabelColor: MoldifyColors.MoldifyGrey,
          labelStyle: const TextStyle(
            fontFamily: 'Bricolage-Grotesque-SemiBold',
            fontSize: 16,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Bricolage-Grotesque-Regular',
            fontSize: 16,
          ),
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(
              color: MoldifyColors.accentColor,
              width: 4,
            ),
            insets: EdgeInsets.zero,
          ),
          tabs: widget.tabs.map((t) => Tab(
            child: AutoSizeText(
              t,
              style: TextStyle(
                fontFamily: 'Bricolage-Grotesque-SemiBold',
                fontSize: 16,
                color: MoldifyColors.primaryColor,
              ),
              maxLines: 1,
              minFontSize: 10,
              overflow: TextOverflow.ellipsis,
            ),
          )).toList(),
        ),

        const Divider(
          color: Color(0xFFE0E0E0),
          height: 1,
          thickness: 1,
        ),

        // --- TAB CONTENTS ---
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: widget.tabContents,
          ),
        ),
      ],
    );
  }
}
