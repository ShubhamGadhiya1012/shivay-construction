import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/features/user_settings/models/user_dm.dart';
import 'package:shivay_construction/features/user_settings/repos/users_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';

class UsersController extends GetxController {
  var isLoading = false.obs;

  var users = <UserDm>[].obs;
  var filteredUsers = <UserDm>[].obs;
  var searchController = TextEditingController();

  @override
  void onInit() async {
    super.onInit();
    await getUsers();
  }

  Future<void> getUsers() async {
    try {
      isLoading.value = true;

      final fetchedUsers = await UsersRepo.getUsers();

      users.assignAll(fetchedUsers);
      filteredUsers.assignAll(fetchedUsers);
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void filterUsers(String query) {
    filteredUsers.assignAll(
      users.where((user) {
        return user.fullName.toLowerCase().contains(query.toLowerCase());
      }).toList(),
    );
  }

  String getUserDesignation(int userType) {
    switch (userType) {
      case 0:
        return 'Admin';
      case 1:
        return 'User';
      default:
        return 'Unknown role';
    }
  }
}
