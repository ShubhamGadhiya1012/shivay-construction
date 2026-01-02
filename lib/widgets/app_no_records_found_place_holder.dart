// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';

class AppNoRecordsFoundPlaceHolder extends StatelessWidget {
  const AppNoRecordsFoundPlaceHolder({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.receipt_long_outlined,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);
    final bool web = AppScreenUtils.isWeb;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: web
              ? 60
              : tablet
              ? 80
              : 60,

          color: kColorPrimary.withOpacity(0.75),
        ),
        web
            ? AppSpaces.v10
            : tablet
            ? AppSpaces.v16
            : AppSpaces.v10,
        Text(
          title,
          style: TextStyles.kSemiBoldOutfit(
            fontSize: web
                ? FontSizes.k16FontSize
                : tablet
                ? FontSizes.k20FontSize
                : FontSizes.k16FontSize,
            color: kColorPrimary,
          ),
        ),
        if (subtitle != null && subtitle!.isNotEmpty)
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: TextStyles.kRegularOutfit(
              fontSize: web
                  ? FontSizes.k14FontSize
                  : tablet
                  ? FontSizes.k16FontSize
                  : FontSizes.k12FontSize,
              color: kColorPrimary.withOpacity(0.75),
            ),
          ),
      ],
    );
  }
}
