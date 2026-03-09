import 'package:flutter/material.dart';

class ActionTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback onTap;

  const ActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  State<ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<ActionTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return GestureDetector(
    onTapDown: (_) => _controller.forward(),
    onTapUp: (_) => _controller.reverse(),
    onTapCancel: () => _controller.reverse(),
    onTap: widget.onTap,
    child: ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(16.0),
        ),
        // Adding Padding here creates the inner "buffer" you're missing
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0), 
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Keeps the column compact
            children: [
              Icon(
                widget.icon,
                color: widget.iconColor,
                size: 18, // Slightly reduced to ensure it fits comfortably
              ),
              const SizedBox(height: 12),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Bricolage-Grotesque-Regular',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: widget.iconColor.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}