// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';

class AppTextButtonWithIcon extends StatelessWidget {
  const AppTextButtonWithIcon({
    super.key,
    required this.onPressed,
    required this.title,
    required this.icon,
    this.color,
    this.fontSize,
    this.style,
  });

  final VoidCallback onPressed;
  final String title;
  final Color? color;
  final double? fontSize;
  final TextStyle? style;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);
    final bool web = AppScreenUtils.isWeb;

    return MouseRegion(
      cursor: web ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: TextButton.icon(
        onPressed: onPressed,
        style:
            TextButton.styleFrom(
              padding: AppPaddings.ph4,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ).copyWith(
              overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
                if (web && states.contains(WidgetState.hovered)) {
                  return (color ?? kColorPrimary).withOpacity(0.1);
                }
                if (states.contains(WidgetState.pressed)) {
                  return (color ?? kColorPrimary).withOpacity(0.2);
                }
                return null;
              }),
            ),
        icon: Icon(
          icon,
          size: web ? 20 : (tablet ? 25 : 20),
          color: color ?? kColorPrimary,
        ),
        label: Text(
          title,
          textAlign: TextAlign.center,
          style:
              style ??
              TextStyles.kMediumOutfit(
                color: color ?? kColorPrimary,
                fontSize:
                    fontSize ??
                    (web
                        ? FontSizes.k16FontSize
                        : (tablet
                              ? FontSizes.k25FontSize
                              : FontSizes.k18FontSize)),
              ).copyWith(
                height: 1,
                decoration: TextDecoration.underline,
                decorationColor: color ?? kColorPrimary,
                decorationThickness: web ? 1.2 : 1,
              ),
        ),
      ),
    );
  }
}
