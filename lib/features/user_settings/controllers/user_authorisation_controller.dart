import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/features/user_settings/controllers/unauthorised_users_controller.dart';
import 'package:shivay_construction/features/user_settings/repos/user_authorisation_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';

class UserAuthorisationController extends GetxController {
  var isLoading = false.obs;
  final authUserFormKey = GlobalKey<FormState>();

  var userTypes = {0: 'Admin', 1: 'User'}.obs;

  var selectedUserType = Rxn<int>();

  void onUserTypeChanged(String selectedValue) async {
    final selectedIndex = userTypes.values.toList().indexOf(selectedValue);

    selectedUserType.value = selectedIndex == -1 ? null : selectedIndex;
  }

  final UnauthorisedUsersController unauthorisedUsersController =
      Get.find<UnauthorisedUsersController>();

  Future<void> authoriseUser({required int userId}) async {
    isLoading.value = true;

    try {
      var response = await UserAuthorisationRepo.authoriseUser(
        userId: userId,
        userType: selectedUserType.value!,
        pCodes: '',
        seCodes: '',
      );

      if (response != null && response.containsKey('message')) {
        String message = response['message'];
        await unauthorisedUsersController.getUnauthorisedUsers();
        Get.back();
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
