import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/features/user_settings/controllers/users_controller.dart';
import 'package:shivay_construction/features/user_settings/repos/user_management_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';

class UserManagementController extends GetxController {
  var isLoading = false.obs;
  final manageUserFormKey = GlobalKey<FormState>();

  var fullNameController = TextEditingController();
  var mobileNoController = TextEditingController();
  var passwordController = TextEditingController();

  var obscuredText = true.obs;
  void togglePasswordVisibility() {
    obscuredText.value = !obscuredText.value;
  }

  var hasAttemptedSubmit = false.obs;

  void setupValidationListeners() {
    fullNameController.addListener(validateForm);
    mobileNoController.addListener(validateForm);
    passwordController.addListener(validateForm);
  }

  void validateForm() {
    if (hasAttemptedSubmit.value) {
      manageUserFormKey.currentState?.validate();
    }
  }

  var userTypes = {0: 'Admin', 1: 'User'}.obs;
  var selectedUserType = Rxn<int>();

  void onUserTypeChanged(String selectedValue) async {
    final selectedIndex = userTypes.values.toList().indexOf(selectedValue);

    selectedUserType.value = selectedIndex == -1 ? null : selectedIndex;
  }

  final UsersController usersController = Get.find<UsersController>();

  Future<void> manageUser({required int userId}) async {
    isLoading.value = true;

    try {
      var response = await UserManagementRepo.manageUser(
        userId: userId,
        fullName: fullNameController.text,
        mobileNo: mobileNoController.text,
        password: passwordController.text,
        userType: selectedUserType.value!,
        pCodes: '',
        seCodes: '',
        eCodes: '',
      );

      if (response != null && response.containsKey('message')) {
        String message = response['message'];
        await usersController.getUsers();
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
