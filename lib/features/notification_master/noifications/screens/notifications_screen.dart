// NotificationsScreen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/notification_master/noifications/controllers/notifications_controller.dart';
import 'package:shivay_construction/features/notification_master/noifications/widgets/notifications_card.dart';
import 'package:shivay_construction/features/notification_master/notification_recievers/screens/notification_recievers_screen.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/widgets/app_appbar.dart';
import 'package:shivay_construction/widgets/app_loading_overlay.dart';
import 'package:shivay_construction/widgets/app_text_form_field.dart';

class NotificationsScreen extends StatelessWidget {
  NotificationsScreen({super.key});

  final NotificationsController _controller = Get.put(
    NotificationsController(),
  );

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            backgroundColor: kColorWhite,
            appBar: AppAppbar(
              title: 'Notifications',
              leading: IconButton(
                onPressed: () => Get.back(),
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: tablet ? 30 : 25,
                  color: kColorTextPrimary,
                ),
              ),
            ),
            body: Padding(
              padding: tablet ? AppPaddings.p16 : AppPaddings.p10,
              child: Column(
                children: [
                  AppTextFormField(
                    controller: _controller.searchController,
                    hintText: 'Search',
                    onChanged: _controller.searchNotifications,
                    fontSize: tablet
                        ? FontSizes.k18FontSize
                        : FontSizes.k16FontSize,
                  ),
                  tablet ? AppSpaces.v16 : AppSpaces.v10,
                  Obx(() {
                    if (_controller.filteredNotifications.isEmpty &&
                        !_controller.isLoading.value) {
                      return Expanded(
                        child: Center(
                          child: Text(
                            'No notifications found.',
                            style: TextStyles.kRegularOutfit(
                              fontSize: tablet
                                  ? FontSizes.k18FontSize
                                  : FontSizes.k14FontSize,
                            ),
                          ),
                        ),
                      );
                    }
                    return Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _controller.filteredNotifications.length,
                        itemBuilder: (context, index) {
                          final notification =
                              _controller.filteredNotifications[index];

                          return NotificationsCard(
                            notification: notification,
                            onTap: () {
                              Get.to(
                                () => NotificationRecieversScreen(
                                  nid: notification.nid,
                                  nName: notification.nName,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
        Obx(() => AppLoadingOverlay(isLoading: _controller.isLoading.value)),
      ],
    );
  }
}
