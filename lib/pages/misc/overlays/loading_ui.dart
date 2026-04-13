import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/misc/colors.dart';

class AppLoadingSpinner extends StatefulWidget {
  const AppLoadingSpinner({
    super.key,
    this.size = 80,
    this.color = MoldifyColors.accentColor, // Using your Gold/Yellow accent
  });

  final double size;
  final Color color;

  @override
  State<AppLoadingSpinner> createState() => _AppLoadingSpinnerState();
}

class _AppLoadingSpinnerState extends State<AppLoadingSpinner>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Editorial Thin Ring
          RotationTransition(
            turns: _rotationController,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: MoldifyColors.primaryColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
          ),
          
          // 2. Fragmented Accent Ring
          RotationTransition(
            turns: Tween(begin: 1.0, end: 0.0).animate(_rotationController),
            child: SizedBox(
              width: widget.size - 10,
              height: widget.size - 10,
              child: CircularProgressIndicator(
                strokeWidth: 1,
                value: 0.2, // Fragmented look
                valueColor: AlwaysStoppedAnimation<Color>(widget.color),
              ),
            ),
          ),

          // 3. Sprouting Plant Icon
          ScaleTransition(
            scale: Tween(begin: 0.8, end: 1.1).animate(
              CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
            ),
            child: FaIcon(
              FontAwesomeIcons.seedling,
              color: widget.color,
              size: widget.size * 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class AppLoadingOverlay extends StatelessWidget {
  const AppLoadingOverlay({
    super.key,
    this.message = "Processing Crop Data...",
    this.barrierColor,
  });

  final String? message;
  final Color? barrierColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: barrierColor ?? MoldifyColors.backgroundColor,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppLoadingSpinner(),
                const SizedBox(height: 40),
                
                // Main Header (Montserrat Black tracking)
                Text(
                  message!.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Montserrat-Black',
                    fontSize: 24,
                    letterSpacing: -0.5,
                    color: MoldifyColors.primaryColor,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Editorial Metadata Label
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 20, height: 1, color: MoldifyColors.primaryColor.withOpacity(0.2)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        'SYNC IN PROGRESS',
                        style: TextStyle(
                          fontFamily: 'Bricolage-Grotesque',
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                          color: MoldifyColors.MoldifyGrey.withOpacity(0.4),
                        ),
                      ),
                    ),
                    Container(width: 20, height: 1, color: MoldifyColors.primaryColor.withOpacity(0.2)),
                  ],
                ),
              ],
            ),
          ),

          // Bottom Shimmer (Editorial detail)
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 120,
                height: 2,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: MoldifyColors.primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const _BottomShimmerLine(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppLoadingDialog extends StatelessWidget {
  const AppLoadingDialog({
    super.key,
    this.message = 'Loading...',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 26),
          decoration: BoxDecoration(
            color: MoldifyColors.backgroundColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppLoadingSpinner(size: 72),
              const SizedBox(height: 20),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Bricolage-Grotesque-SemiBold',
                  fontSize: 16,
                  color: MoldifyColors.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomShimmerLine extends StatefulWidget {
  const _BottomShimmerLine();

  @override
  State<_BottomShimmerLine> createState() => _BottomShimmerLineState();
}

class _BottomShimmerLineState extends State<_BottomShimmerLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FractionalTranslation(
          translation: Offset(_controller.value * 2 - 1, 0),
          child: Container(
            width: 60,
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  MoldifyColors.accentColor.withOpacity(0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}