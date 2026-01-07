// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';

class AppWebInsufficientHeightPlaceHolder extends StatelessWidget {
  const AppWebInsufficientHeightPlaceHolder({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.height, size: 48, color: kColorPrimary.withOpacity(0.5)),
        AppSpaces.v16,
        Text(
          'Insufficient screen height',
          style: TextStyles.kSemiBoldOutfit(
            fontSize: FontSizes.k18FontSize,
            color: kColorPrimary,
          ),
        ),
        AppSpaces.v8,
        Text(
          'Please increase browser height to view the content',
          style: TextStyles.kMediumOutfit(
            fontSize: FontSizes.k14FontSize,
            color: kColorPrimary.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
