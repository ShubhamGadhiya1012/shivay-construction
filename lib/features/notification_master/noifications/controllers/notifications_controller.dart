import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/features/notification_master/noifications/models/notification_dm.dart';
import 'package:shivay_construction/features/notification_master/noifications/repos/notifications_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';

class NotificationsController extends GetxController {
  var isLoading = false.obs;
  var notifications = <NotificationDm>[].obs;
  var filteredNotifications = <NotificationDm>[].obs;

  var searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    getNotifications();
  }

  Future<void> getNotifications() async {
    try {
      isLoading.value = true;
      final fetchedNotifications = await NotificationsRepo.getNotifications();
      notifications.assignAll(fetchedNotifications);
      filteredNotifications.assignAll(fetchedNotifications);
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void searchNotifications(String query) {
    if (query.isEmpty) {
      filteredNotifications.assignAll(notifications);
    } else {
      filteredNotifications.assignAll(
        notifications.where(
          (notification) =>
              notification.nName.toLowerCase().contains(query.toLowerCase()),
        ),
      );
    }
  }
}
