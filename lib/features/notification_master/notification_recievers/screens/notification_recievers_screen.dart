// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/notification_master/notification_recievers/controllers/notification_recievers_controller.dart';
import 'package:shivay_construction/features/notification_master/notification_recievers/widgets/notification_reciever_card.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_appbar.dart';
import 'package:shivay_construction/widgets/app_button.dart';
import 'package:shivay_construction/widgets/app_dropdown.dart';
import 'package:shivay_construction/widgets/app_loading_overlay.dart';
import 'package:shivay_construction/widgets/app_text_form_field.dart';

class NotificationRecieversScreen extends StatefulWidget {
  const NotificationRecieversScreen({
    super.key,
    required this.nid,
    required this.nName,
  });

  final int nid;
  final String nName;

  @override
  State<NotificationRecieversScreen> createState() =>
      _NotificationRecieversScreenState();
}

class _NotificationRecieversScreenState
    extends State<NotificationRecieversScreen> {
  final NotificationRecieversController _controller = Get.put(
    NotificationRecieversController(),
  );

  @override
  void initState() {
    super.initState();
    _controller.getNotificationRecievers(nid: widget.nid.toString());
    _controller.getUsers();
  }

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
            appBar: AppAppbar(
              title: widget.nName,
              leading: IconButton(
                onPressed: () => Get.back(),
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: tablet ? 25 : 20,
                  color: kColorTextPrimary,
                ),
              ),
            ),
            body: Padding(
              padding: tablet
                  ? AppPaddings.combined(horizontal: 24, vertical: 12)
                  : AppPaddings.p10,
              child: Column(
                children: [
                  AppTextFormField(
                    controller: _controller.searchController,
                    hintText: 'Search',
                    onChanged: _controller.searchNotificationRecievers,
                  ),
                  tablet ? AppSpaces.v16 : AppSpaces.v10,
                  Obx(() {
                    if (_controller.filteredNotificationRecievers.isEmpty &&
                        !_controller.isLoading.value) {
                      return Expanded(
                        child: Center(
                          child: Text(
                            'No Notifications Recievers found.',
                            style: TextStyles.kRegularOutfit(
                              fontSize: tablet
                                  ? FontSizes.k26FontSize
                                  : FontSizes.k18FontSize,
                            ),
                          ),
                        ),
                      );
                    }
                    return Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount:
                            _controller.filteredNotificationRecievers.length,
                        itemBuilder: (context, index) {
                          final notificationReciever =
                              _controller.filteredNotificationRecievers[index];

                          return NotificationRecieverCard(
                            notificationReciever: notificationReciever,
                            tablet: tablet,
                            onDelete: () {
                              _controller.removeReciever(
                                nid: widget.nid.toString(),
                                userId: notificationReciever.userId.toString(),
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
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(tablet ? 16 : 12),
                boxShadow: [
                  BoxShadow(
                    color: kColorPrimary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: () {
                  _showAddRecieverDialog(tablet);
                },
                backgroundColor: kColorPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(tablet ? 16 : 12),
                ),
                icon: Icon(
                  Icons.add,
                  color: kColorWhite,
                  size: tablet ? 24 : 20,
                ),
                label: Text(
                  'Add New',
                  style: TextStyles.kSemiBoldOutfit(
                    fontSize: tablet
                        ? FontSizes.k16FontSize
                        : FontSizes.k14FontSize,
                    color: kColorWhite,
                  ),
                ),
              ),
            ),
          ),
        ),
        Obx(() => AppLoadingOverlay(isLoading: _controller.isLoading.value)),
      ],
    );
  }

  void _showAddRecieverDialog(bool tablet) {
    _controller.selectedUser.value = '';
    _controller.selectedUserId.value = 0;
    Get.dialog(
      Dialog(
        backgroundColor: kColorWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tablet ? 12 : 10),
        ),
        child: Padding(
          padding: tablet ? AppPaddings.p16 : AppPaddings.p10,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 0.75 * Get.height),
            child: SingleChildScrollView(
              child: Form(
                key: _controller.notificationRecieverFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Add Reciever',
                        style: TextStyles.kMediumOutfit(
                          fontSize: tablet
                              ? FontSizes.k24FontSize
                              : FontSizes.k20FontSize,
                          color: kColorSecondary,
                        ),
                      ),
                    ),
                    tablet ? AppSpaces.v16 : AppSpaces.v10,
                    Obx(
                      () => AppDropdown(
                        items: _controller.userNames,
                        hintText: 'Reciever',
                        onChanged: _controller.onUserSelected,
                        selectedItem: _controller.selectedUser.value.isNotEmpty
                            ? _controller.selectedUser.value
                            : null,
                        validatorText: 'Please select a reciever',
                      ),
                    ),
                    tablet ? AppSpaces.v24 : AppSpaces.v20,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AppButton(
                          title: 'Cancel',
                          buttonColor: kColorWhite,
                          borderColor: kColorPrimary,
                          titleColor: kColorPrimary,
                          titleSize: tablet
                              ? FontSizes.k18FontSize
                              : FontSizes.k16FontSize,
                          buttonWidth: 0.2 * Get.width,
                          buttonHeight: tablet ? 45 : 40,
                          onPressed: () => Get.back(),
                        ),
                        tablet ? AppSpaces.h16 : AppSpaces.h10,
                        AppButton(
                          title: 'Add',
                          titleSize: tablet
                              ? FontSizes.k18FontSize
                              : FontSizes.k16FontSize,
                          buttonWidth: 0.2 * Get.width,
                          buttonHeight: tablet ? 45 : 40,
                          onPressed: () {
                            if (_controller
                                .notificationRecieverFormKey
                                .currentState!
                                .validate()) {
                              _controller.addReciever(
                                nid: widget.nid.toString(),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
