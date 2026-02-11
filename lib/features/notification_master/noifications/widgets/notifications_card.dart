// NotificationsCard.dart
import 'package:flutter/material.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/notification_master/noifications/models/notification_dm.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/widgets/app_card.dart';

class NotificationsCard extends StatelessWidget {
  const NotificationsCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final NotificationDm notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        child: Padding(
          padding: tablet ? AppPaddings.p16 : AppPaddings.p10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                notification.nName,
                style: TextStyles.kRegularOutfit(
                  fontSize: tablet
                      ? FontSizes.k20FontSize
                      : FontSizes.k16FontSize,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: tablet ? 24 : 20,
                color: kColorTextPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
