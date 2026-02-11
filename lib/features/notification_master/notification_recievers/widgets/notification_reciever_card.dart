import 'package:flutter/material.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/notification_master/notification_recievers/models/notification_reciever_dm.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/widgets/app_card.dart';

class NotificationRecieverCard extends StatelessWidget {
  const NotificationRecieverCard({
    super.key,
    required this.notificationReciever,
    required this.onDelete,
    this.tablet = false,
  });

  final NotificationRecieverDm notificationReciever;
  final VoidCallback onDelete;
  final bool tablet;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: tablet ? AppPaddings.p16 : AppPaddings.p10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              notificationReciever.fullName,
              style: TextStyles.kRegularOutfit(
                fontSize: tablet
                    ? FontSizes.k18FontSize
                    : FontSizes.k16FontSize,
              ),
            ),
            InkWell(
              onTap: onDelete,
              child: Icon(
                Icons.delete,
                size: tablet ? 24 : 20,
                color: kColorRed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
