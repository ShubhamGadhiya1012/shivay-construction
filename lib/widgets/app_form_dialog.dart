import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/widgets/app_text_button.dart';

class AppFormDialog extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final double? maxWidth;

  const AppFormDialog({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.maxWidth,
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
          color: kColorPrimary,
        ),
      ),

      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? (web ? 500 : double.infinity),
        ),
        child: SingleChildScrollView(child: child),
      ),

      actions:
          actions ??
          [AppTextButton(onPressed: () => Get.back(), title: 'Close')],
    );
  }
}
