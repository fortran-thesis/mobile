import 'package:flutter/material.dart';
import '../colors.dart';

class ScrollableTabBar extends StatelessWidget {
  final List<String> tabs;
  final ValueChanged<int>? onTabSelected;
  final int currentIndex;

  const ScrollableTabBar({
    super.key,
    required this.tabs,
    this.onTabSelected,
    this.currentIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = index == currentIndex;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () => onTabSelected?.call(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? MoldifyColors.primaryColor
                      : MoldifyColors.taupe,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF3A5500),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
