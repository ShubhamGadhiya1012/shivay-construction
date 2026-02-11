import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/features/notification_master/notification_recievers/models/notification_reciever_dm.dart';
import 'package:shivay_construction/features/notification_master/notification_recievers/repos/notification_recievers_repo.dart';
import 'package:shivay_construction/features/user_settings/models/user_dm.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';

class NotificationRecieversController extends GetxController {
  var isLoading = false.obs;
  final notificationRecieverFormKey = GlobalKey<FormState>();

  var notificationRecievers = <NotificationRecieverDm>[].obs;
  var filteredNotificationRecievers = <NotificationRecieverDm>[].obs;
  var searchController = TextEditingController();

  var users = <UserDm>[].obs;
  var userNames = <String>[].obs;
  var selectedUser = ''.obs;
  var selectedUserId = 0.obs;

  Future<void> getNotificationRecievers({required String nid}) async {
    try {
      isLoading.value = true;
      final fetchedNotificationRecievers =
          await NotificationRecieversRepo.getNotificationRecievers(nid: nid);
      notificationRecievers.assignAll(fetchedNotificationRecievers);
      filteredNotificationRecievers.assignAll(fetchedNotificationRecievers);
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void searchNotificationRecievers(String query) {
    if (query.isEmpty) {
      filteredNotificationRecievers.assignAll(notificationRecievers);
    } else {
      filteredNotificationRecievers.assignAll(
        notificationRecievers.where(
          (notificationReciever) => notificationReciever.fullName
              .toLowerCase()
              .contains(query.toLowerCase()),
        ),
      );
    }
  }

  Future<void> getUsers() async {
    try {
      isLoading.value = true;

      final fetchedUsers = await NotificationRecieversRepo.getUsers();

      users.assignAll(fetchedUsers);
      userNames.assignAll(fetchedUsers.map((user) => user.fullName));
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void onUserSelected(String? name) {
    selectedUser.value = name!;
    final selectedUserObj = users.firstWhere((user) => user.fullName == name);

    selectedUserId.value = selectedUserObj.userId;
  }

  Future<void> addReciever({required String nid}) async {
    isLoading.value = true;

    try {
      var response = await NotificationRecieversRepo.addReciever(
        userId: selectedUserId.value.toString(),
        nid: nid,
      );

      if (response.containsKey('message')) {
        String message = response['message'];
        Get.back();
        await getNotificationRecievers(nid: nid);
        showSuccessSnackbar('Success', message);
      }
    } catch (e) {
      if (e is Map<String, dynamic>) {
        showErrorSnackbar('Error', e['message']);
      } else {
        showErrorSnackbar('Error', e.toString());
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeReciever({
    required String nid,
    required String userId,
  }) async {
    isLoading.value = true;

    try {
      var response = await NotificationRecieversRepo.removeReciever(
        userId: userId,
        nid: nid,
      );

      if (response.containsKey('message')) {
        String message = response['message'];

        await getNotificationRecievers(nid: nid);
        showSuccessSnackbar('Success', message);
      }
    } catch (e) {
      if (e is Map<String, dynamic>) {
        showErrorSnackbar('Error', e['message']);
      } else {
        showErrorSnackbar('Error', e.toString());
      }
    } finally {
      isLoading.value = false;
    }
  }
}
