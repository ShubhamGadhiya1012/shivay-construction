import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_text_button.dart';

class AppConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final Color confirmColor;
  final Color? titleColor;
  final Color? messageColor;
  final VoidCallback onConfirm;

  const AppConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.confirmText = "Confirm",
    this.cancelText = "Cancel",
    this.confirmColor = kColorRed,
    this.titleColor,
    this.messageColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);
    final bool web = AppScreenUtils.isWeb;

    return AlertDialog(
      backgroundColor: kColorWhite,
      titlePadding: AppPaddings.custom(
        left: tablet ? 25 : 20,
        right: tablet ? 25 : 20,
        top: tablet ? 25 : 20,
        bottom: tablet ? 10 : 6,
      ),
      contentPadding: AppPaddings.custom(
        left: tablet ? 25 : 20,
        right: tablet ? 25 : 20,
        bottom: tablet ? 14 : 8,
      ),
      title: Text(
        title,
        style: TextStyles.kSemiBoldOutfit(
          fontSize: web
              ? FontSizes.k20FontSize
              : tablet
              ? FontSizes.k32FontSize
              : FontSizes.k20FontSize,
          color: titleColor ?? kColorPrimary,
        ),
      ),
      content: Text(
        message,
        style: TextStyles.kRegularOutfit(
          fontSize: web
              ? FontSizes.k16FontSize
              : tablet
              ? FontSizes.k24FontSize
              : FontSizes.k16FontSize,
          color: messageColor!,
        ),
      ),
      actions: [
        AppTextButton(onPressed: () => Get.back(), title: cancelText),
        AppSpaces.h10,
        AppTextButton(
          onPressed: () {
            Get.back();
            onConfirm();
          },
          title: confirmText,
        ),
      ],
    );
  }
}
