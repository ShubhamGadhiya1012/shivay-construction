// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';

class AppTitleValueContainer extends StatelessWidget {
  final String title;
  final double? titleSize;
  final String value;
  final double? valueSize;
  final Color? color;
  final Color? titleColor;
  final VoidCallback? onTap;
  final bool? showIndicator;
  final CrossAxisAlignment? crossAxisAlignment;
  final AlignmentGeometry? alignment;

  final bool useContainer;

  const AppTitleValueContainer({
    super.key,
    required this.title,
    this.titleSize,
    required this.value,
    this.valueSize,
    this.color,
    this.titleColor,
    this.onTap,
    this.showIndicator,
    this.crossAxisAlignment,
    this.alignment,
    this.useContainer = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);
    final bool web = AppScreenUtils.isWeb;

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyles.kSemiBoldOutfit(
            fontSize:
                titleSize ??
                (web
                    ? FontSizes.k16FontSize
                    : tablet
                    ? FontSizes.k24FontSize
                    : FontSizes.k16FontSize),
            color: titleColor ?? kColorPrimary,
          ).copyWith(height: 1),
        ),
        web
            ? AppSpaces.v4
            : tablet
            ? AppSpaces.v10
            : AppSpaces.v4,
        Text(
          value,
          style: TextStyles.kRegularOutfit(
            fontSize:
                valueSize ??
                (web
                    ? FontSizes.k14FontSize
                    : tablet
                    ? FontSizes.k24FontSize
                    : FontSizes.k14FontSize),
            color: titleColor ?? kColorPrimary,
          ).copyWith(height: 1),
        ),
      ],
    );

    // If container is not required → return only the column
    if (!useContainer) return content;

    // Else return styled container
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        alignment: alignment ?? Alignment.centerLeft,
        width: double.infinity,
        padding: web
            ? AppPaddings.p10
            : tablet
            ? AppPaddings.combined(horizontal: 20, vertical: 12)
            : AppPaddings.p10,
        decoration: BoxDecoration(
          color: color ?? kColorLightGrey,
          borderRadius: BorderRadius.circular(
            web
                ? 10
                : tablet
                ? 20
                : 10,
          ),
        ),
        child: SizedBox(width: double.infinity, child: content),
      ),
    );
  }
}
