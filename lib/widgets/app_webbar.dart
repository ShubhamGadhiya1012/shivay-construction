// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';

class AppWebbar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showBack;
  final List<Widget>? actions;
  final Widget? centerWidget;
  final VoidCallback? onBackTap;

  const AppWebbar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = true,
    this.actions,
    this.centerWidget,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppPaddings.combined(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          if (showBack) ...[
            IconButton(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              onPressed: onBackTap ?? () => Get.back(),
              icon: Icon(Icons.arrow_back_ios, size: 20, color: kColorPrimary),
            ),
            AppSpaces.h20,
          ],

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyles.kMediumOutfit(
                    fontSize: FontSizes.k18FontSize,
                    color: kColorPrimary,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyles.kRegularOutfit(
                      fontSize: FontSizes.k12FontSize,
                      color: kColorDarkGrey,
                    ),
                  ),
              ],
            ),
          ),

          if (centerWidget != null) Expanded(child: centerWidget!),

          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}
