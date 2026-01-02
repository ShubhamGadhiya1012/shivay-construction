// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';

class WebPageIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const WebPageIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 4,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: AppPaddings.custom(bottom: 10, left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalSteps, (index) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: _getHorizontalSpacing(screenWidth),
            ),
            child: _buildDot(index, screenWidth),
          );
        }),
      ),
    );
  }

  double _getHorizontalSpacing(double screenWidth) {
    if (screenWidth >= 1200) return 6.0;
    if (screenWidth >= 800) return 5.0;
    return 4.0;
  }

  Widget _buildDot(int index, double screenWidth) {
    final isActive = index == currentStep;
    final isCompleted = index < currentStep;

    // Get responsive sizing
    final dotSize = _getDotSize(screenWidth, isActive);
    final dotWidth = _getDotWidth(screenWidth, isActive);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: dotWidth,
      height: dotSize,
      decoration: BoxDecoration(
        color: _getDotColor(isActive, isCompleted),
        borderRadius: BorderRadius.circular(dotSize / 2),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: kColorPrimary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
    );
  }

  double _getDotSize(double screenWidth, bool isActive) {
    if (screenWidth >= 1200) {
      return isActive ? 12.0 : 10.0;
    } else if (screenWidth >= 800) {
      return isActive ? 10.0 : 8.0;
    } else {
      return isActive ? 10.0 : 8.0;
    }
  }

  double _getDotWidth(double screenWidth, bool isActive) {
    if (screenWidth >= 1200) {
      return isActive ? 40.0 : 10.0;
    } else if (screenWidth >= 800) {
      return isActive ? 35.0 : 8.0;
    } else {
      return isActive ? 30.0 : 8.0;
    }
  }

  Color _getDotColor(bool isActive, bool isCompleted) {
    if (isActive) return kColorPrimary;
    if (isCompleted) return kColorPrimary.withOpacity(0.6);
    return kColorGrey;
  }
}
