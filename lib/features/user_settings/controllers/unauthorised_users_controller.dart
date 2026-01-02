import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/features/user_settings/models/unauthorised_user_dm.dart';
import 'package:shivay_construction/features/user_settings/repos/unauthorised_users_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';

class UnauthorisedUsersController extends GetxController {
  var isLoading = false.obs;
  var unAuthorisedUsers = <UnauthorisedUserDm>[].obs;
  var filteredUnAuthorisedUsers = <UnauthorisedUserDm>[].obs;
  var searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    getUnauthorisedUsers();
  }

  Future<void> getUnauthorisedUsers() async {
    try {
      isLoading.value = true;

      final fetchedUsers = await UnauthorisedUsersRepo.geUnauthorisedUsers();

      unAuthorisedUsers.assignAll(fetchedUsers);
      filteredUnAuthorisedUsers.assignAll(fetchedUsers);
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void filterUsers(String query) {
    filteredUnAuthorisedUsers.assignAll(
      unAuthorisedUsers.where((user) {
        return user.fullName.toLowerCase().contains(query.toLowerCase()) ||
            user.mobileNo.toLowerCase().contains(query.toLowerCase());
      }).toList(),
    );
  }
}
