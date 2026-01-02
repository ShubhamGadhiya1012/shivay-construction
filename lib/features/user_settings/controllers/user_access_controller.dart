import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/features/home/controllers/home_controller.dart';
import 'package:shivay_construction/features/user_settings/controllers/users_controller.dart';
import 'package:shivay_construction/features/user_settings/models/user_access_dm.dart';
import 'package:shivay_construction/features/user_settings/repos/user_access_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';
import 'package:shivay_construction/utils/helpers/date_format_helper.dart';

class UserAccessController extends GetxController {
  var isLoading = false.obs;

  var menuAccess = <MenuAccessDm>[].obs;
  var ledgerDate = LedgerDateDm(ledgerStart: '', ledgerEnd: '').obs;

  var ledgerStartDateController = TextEditingController();
  var ledgerEndDateController = TextEditingController();

  Future<void> getUserAccess({required int userId}) async {
    try {
      isLoading.value = true;

      final fetchedUserAccess = await UserAccessRepo.getUserAccess(
        userId: userId,
      );

      menuAccess.assignAll(fetchedUserAccess.menuAccess);
      ledgerDate.value = fetchedUserAccess.ledgerDate;

      ledgerStartDateController.text = fetchedUserAccess.ledgerDate.ledgerStart;
      ledgerEndDateController.text = fetchedUserAccess.ledgerDate.ledgerEnd;
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  final UsersController usersController = Get.find<UsersController>();
  final HomeController homeController = Get.find<HomeController>();

  Future<void> setAppAccess({
    required int userId,
    required bool appAccess,
  }) async {
    isLoading.value = true;

    try {
      var response = await UserAccessRepo.setAppAccess(
        userId: userId,
        appAccess: appAccess,
      );

      if (response != null && response.containsKey('message')) {
        String message = response['message'];

        usersController.getUsers();

        showSuccessSnackbar('Success', message);
      }
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setMenuAccess({
    required int userId,
    required int menuId,
    int? subMenuId,
    required bool menuAccess,
  }) async {
    isLoading.value = true;

    try {
      var response = await UserAccessRepo.setMenuAccess(
        userId: userId,
        menuId: menuId,
        subMenuId: subMenuId,
        menuAccess: menuAccess,
      );

      if (response != null && response.containsKey('message')) {
        // String message = response['message'];

        getUserAccess(userId: userId);
      }
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setLedger({required int userId}) async {
    isLoading.value = true;

    try {
      var response = await UserAccessRepo.setLedger(
        userId: userId,
        ledgerStart: ledgerStartDateController.text.isNotEmpty
            ? convertToApiDateFormat(ledgerStartDateController.text)
            : null,
        ledgerEnd: ledgerEndDateController.text.isNotEmpty
            ? convertToApiDateFormat(ledgerEndDateController.text)
            : null,
      );

      if (response != null && response.containsKey('message')) {
        // String message = response['message'];

        getUserAccess(userId: userId);

        // showSuccessSnackbar(
        //   'Success',
        //   message,
        // );
      }
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
