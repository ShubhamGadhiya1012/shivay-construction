// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    this.buttonHeight,
    this.buttonWidth,
    this.buttonColor,
    this.borderColor,
    required this.title,
    this.titleSize,
    this.titleColor,
    required this.onPressed,
    this.isLoading = false,
    this.loadingIndicatorColor,
  });

  final double? buttonHeight;
  final double? buttonWidth;
  final Color? buttonColor;
  final Color? borderColor;
  final String title;
  final double? titleSize;
  final Color? titleColor;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? loadingIndicatorColor;

  @override
  Widget build(BuildContext context) {
    final bool web = AppScreenUtils.isWeb;
    final bool tablet = AppScreenUtils.isTablet(context);

    return MouseRegion(
      cursor: web ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: SizedBox(
        height:
            buttonHeight ??
            (web
                ? 45
                : tablet
                ? 65
                : 45),
        width: buttonWidth ?? double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: web
                ? AppPaddings.combined(horizontal: 24, vertical: 10)
                : AppPaddings.p2,
            backgroundColor: buttonColor ?? kColorPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                web ? 10 : (tablet ? 20 : 10),
              ),
              side: BorderSide(
                color: borderColor ?? (buttonColor ?? kColorPrimary),
              ),
            ),
            elevation: isLoading ? 0 : (web ? 2 : 0),
          ).copyWith(overlayColor: WidgetStateProperty.all(Colors.black26)),
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? (bool web, bool tablet) {
                  final double size = web ? 24 : (tablet ? 28 : 20);

                  return SizedBox(
                    height: size,
                    width: size,
                    child: CircularProgressIndicator(
                      color: loadingIndicatorColor ?? kColorWhite,
                      strokeWidth: web ? 2.5 : 2,
                    ),
                  );
                }(web, tablet)
              : Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyles.kMediumOutfit(
                    fontSize: titleSize ?? _font(web, tablet),
                    color: titleColor ?? kColorWhite,
                  ),
                ),
        ),
      ),
    );
  }

  double _font(bool web, bool tablet) {
    if (web) return FontSizes.k15FontSize;
    return tablet ? FontSizes.k25FontSize : FontSizes.k18FontSize;
  }
}
