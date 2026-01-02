// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';

void showAppSnackbar({
  required String title,
  required String message,
  required Color backgroundColor,
  IconData? icon,
}) {
  final bool isWeb = AppScreenUtils.isWeb;
  final bool tablet = !isWeb && AppScreenUtils.isTablet(Get.context!);

  Get.snackbar(
    '',
    '',
    snackPosition: isWeb ? SnackPosition.TOP : SnackPosition.BOTTOM,
    snackStyle: SnackStyle.FLOATING,
    backgroundColor: Colors.transparent,
    duration: Duration(seconds: isWeb ? 4 : 4),
    margin: isWeb
        ? AppPaddings.custom(top: 20, right: 20)
        : tablet
        ? AppPaddings.combined(horizontal: 20, vertical: 20)
        : AppPaddings.combined(horizontal: 16, vertical: 16),
    padding: EdgeInsets.zero,
    maxWidth: isWeb ? 400 : null,
    borderRadius: isWeb ? 16 : (tablet ? 24 : 16),
    isDismissible: true,
    animationDuration: const Duration(milliseconds: 600),
    forwardAnimationCurve: Curves.easeOutCubic,
    reverseAnimationCurve: Curves.easeInCubic,
    overlayBlur: 0,
    boxShadows: [
      BoxShadow(
        color: backgroundColor.withOpacity(0.3),
        blurRadius: 20,
        spreadRadius: 2,
        offset: const Offset(0, 8),
      ),
    ],
    titleText: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [backgroundColor, backgroundColor.withOpacity(0.85)],
        ),
        borderRadius: BorderRadius.circular(isWeb ? 16 : (tablet ? 24 : 16)),
        border: Border.all(color: kColorWhite.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isWeb ? 16 : (tablet ? 24 : 16)),
        child: Stack(
          children: [
            // Subtle shine effect
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [kColorWhite.withOpacity(0.15), Colors.transparent],
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: isWeb
                  ? AppPaddings.combined(horizontal: 16, vertical: 14)
                  : tablet
                  ? AppPaddings.combined(horizontal: 24, vertical: 20)
                  : AppPaddings.combined(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // Icon with background
                  if (icon != null) ...[
                    Container(
                      padding: EdgeInsets.all(isWeb ? 8 : (tablet ? 12 : 10)),
                      decoration: BoxDecoration(
                        color: kColorWhite.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(
                          isWeb ? 10 : (tablet ? 14 : 12),
                        ),
                        border: Border.all(
                          color: kColorWhite.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: kColorWhite,
                        size: isWeb ? 20 : (tablet ? 28 : 24),
                      ),
                    ),
                    SizedBox(width: isWeb ? 12 : (tablet ? 16 : 14)),
                  ],

                  // Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: TextStyles.kSemiBoldOutfit(
                            color: kColorWhite,
                            fontSize: isWeb
                                ? FontSizes.k15FontSize
                                : tablet
                                ? FontSizes.k26FontSize
                                : FontSizes.k18FontSize,
                          ),
                        ),
                        SizedBox(height: isWeb ? 2 : (tablet ? 4 : 3)),
                        Text(
                          message,
                          style: TextStyles.kRegularOutfit(
                            color: kColorWhite.withOpacity(0.95),
                            fontSize: isWeb
                                ? FontSizes.k12FontSize
                                : tablet
                                ? FontSizes.k20FontSize
                                : FontSizes.k15FontSize,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Close button
                  if (!isWeb) ...[
                    SizedBox(width: tablet ? 12 : 8),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: EdgeInsets.all(tablet ? 8 : 6),
                        decoration: BoxDecoration(
                          color: kColorWhite.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(tablet ? 10 : 8),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: kColorWhite,
                          size: tablet ? 20 : 16,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Bottom accent line
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      kColorWhite.withOpacity(0.6),
                      kColorWhite.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(
                      isWeb ? 16 : (tablet ? 24 : 16),
                    ),
                    bottomRight: Radius.circular(
                      isWeb ? 16 : (tablet ? 24 : 16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    messageText: const SizedBox.shrink(),
  );
}

void showErrorSnackbar(String title, String message) {
  showAppSnackbar(
    title: title,
    message: message,
    backgroundColor: kColorRed,
    icon: Icons.error_outline_rounded,
  );
}

void showSuccessSnackbar(String title, String message) {
  showAppSnackbar(
    title: title,
    message: message,
    backgroundColor: kColorGreen,
    icon: Icons.check_circle_outline_rounded,
  );
}

void showWarningSnackbar(String title, String message) {
  showAppSnackbar(
    title: title,
    message: message,
    backgroundColor: Colors.orange,
    icon: Icons.warning_amber_rounded,
  );
}

void showInfoSnackbar(String title, String message) {
  showAppSnackbar(
    title: title,
    message: message,
    backgroundColor: Colors.blue,
    icon: Icons.info_outline_rounded,
  );
}
