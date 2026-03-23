import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/colors.dart';

/// A widget that displays a step indicator with a specified number of steps
/// and highlights the current step.
/// Parameters:
/// - [totalSteps]: The total number of steps in the process.
/// - [currentStep]: The index of the current step (0-based).

class StepIndicator extends StatelessWidget {
  final int totalSteps;
  final int currentStep;

  const StepIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        return Container(
          height: 4,
          width: 50,
          margin: EdgeInsets.only(right: index == totalSteps - 1 ? 0 : 4),
          decoration: BoxDecoration(
            color: currentStep >= index ? MoldifyColors.accentColor : MoldifyColors.MoldifySoftGrey,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}
