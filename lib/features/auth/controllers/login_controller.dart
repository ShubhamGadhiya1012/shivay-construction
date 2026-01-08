import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/features/auth/models/company_dm.dart';
import 'package:shivay_construction/features/auth/repos/login_repo.dart';
import 'package:shivay_construction/features/auth/screens/select_company_screen.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';
import 'package:shivay_construction/utils/helpers/device_helper.dart';

class LoginController extends GetxController {
  var isLoading = false.obs;
  final loginFormKey = GlobalKey<FormState>();

  var mobileNumberController = TextEditingController();
  var passwordController = TextEditingController();

  var hasAttemptedLogin = false.obs;
  var obscuredPassword = true.obs;
  var companies = <CompanyDm>[].obs;

  @override
  void onInit() {
    super.onInit();
    setupValidationListeners();
  }

  void setupValidationListeners() {
    mobileNumberController.addListener(validateForm);
    passwordController.addListener(validateForm);
  }

  void validateForm() {
    if (hasAttemptedLogin.value) {
      loginFormKey.currentState?.validate();
    }
  }

  void togglePasswordVisibility() {
    obscuredPassword.value = !obscuredPassword.value;
  }

  Future<void> loginUser() async {
    isLoading.value = true;
    String? deviceId = await DeviceHelper().getDeviceId();

    if (deviceId == null) {
      showErrorSnackbar('Login Failed', 'Unable to fetch device ID.');
      isLoading.value = false;
      return;
    }

    String? fcmToken;
    if (Platform.isAndroid) {
      fcmToken = await FirebaseMessaging.instance.getToken();

      if (fcmToken == null) {
        showErrorSnackbar('Login Failed', 'Unable to fetch FCM Token.');
        isLoading.value = false;
        return;
      }
    } else {
      fcmToken = '';
    }

    try {
      final fetchedCompanies = await LoginRepo.loginUser(
        mobileNo: mobileNumberController.text,
        password: passwordController.text,
        fcmToken: fcmToken,
        deviceId: deviceId,
      );

      companies.assignAll(fetchedCompanies);
      Get.to(
        () => SelectCompanyScreen(
          companies: companies,
          mobileNumber: mobileNumberController.text,
        ),
      );
    } catch (e) {
      if (e is Map<String, dynamic>) {
        showErrorSnackbar('Login Error', e['message']);
      } else {
        showErrorSnackbar('Login Error', e.toString());
      }
    } finally {
      isLoading.value = false;
    }
  }
}
