// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';

class AppSummaryBottomSheetButton extends StatelessWidget {
  const AppSummaryBottomSheetButton({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);
    final bool web = AppScreenUtils.isWeb;

    return Container(
      constraints: BoxConstraints(
        maxWidth: web
            ? 400
            : tablet
            ? 600
            : double.infinity,
      ),
      padding: web
          ? AppPaddings.p12
          : tablet
          ? AppPaddings.combined(horizontal: 20, vertical: 16)
          : AppPaddings.combined(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: kColorPrimary,
        borderRadius: BorderRadius.circular(
          web
              ? 10
              : tablet
              ? 20
              : 10,
        ),
        boxShadow: [
          BoxShadow(
            color: kColorPrimary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.calculate_outlined,
            color: kColorWhite,
            size: web
                ? 20
                : tablet
                ? 26
                : 20,
          ),
          tablet ? AppSpaces.h12 : AppSpaces.h6,
          Expanded(
            child: Text(
              title,
              style: TextStyles.kMediumOutfit(
                fontSize: web
                    ? FontSizes.k16FontSize
                    : tablet
                    ? FontSizes.k22FontSize
                    : FontSizes.k16FontSize,
                color: kColorWhite,
              ),
            ),
          ),
          Icon(
            Icons.keyboard_arrow_up,
            color: kColorWhite,
            size: tablet ? 25 : 20,
          ),
        ],
      ),
    );
  }
}
