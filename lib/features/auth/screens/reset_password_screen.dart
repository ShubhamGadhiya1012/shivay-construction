// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/auth/controllers/reset_password_controller.dart';
import 'package:shivay_construction/features/auth/screens/animated_background.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/extensions/app_size_extensions.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_button.dart';
import 'package:shivay_construction/widgets/app_loading_overlay.dart';
import 'package:shivay_construction/widgets/app_text_form_field.dart';

class ResetPasswordScreen extends StatelessWidget {
  ResetPasswordScreen({
    super.key,
    required this.mobileNumber,
    required this.fullName,
  });

  final String mobileNumber;
  final String fullName;

  final ResetPasswordController _controller = Get.put(
    ResetPasswordController(),
  );

  @override
  Widget build(BuildContext context) {
    if (AppScreenUtils.isWeb) {
      return _buildResetPasswordWeb();
    } else {
      final bool tablet = AppScreenUtils.isTablet(context);
      return _buildResetPasswordMobile(tablet);
    }
  }

  Widget _buildResetPasswordMobile(bool tablet) {
    return Stack(
      children: [
        const AnimatedBackground(),
        GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: tablet
                      ? AppPaddings.combined(
                          horizontal: 0.08.screenWidth,
                          vertical: 0.04.screenHeight,
                        )
                      : AppPaddings.p24,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(tablet ? 20 : 10),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        width: double.infinity,
                        padding: tablet ? AppPaddings.p20 : AppPaddings.p16,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(tablet ? 20 : 10),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.08),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 40,
                              spreadRadius: 5,
                              offset: const Offset(0, 15),
                            ),
                            BoxShadow(
                              color: Colors.white.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: -5,
                              offset: const Offset(0, -5),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _controller.resetPasswordFormKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reset Password',
                                style: TextStyles.kSemiBoldOutfit(
                                  fontSize: tablet
                                      ? FontSizes.k40FontSize
                                      : FontSizes.k30FontSize,
                                  color: kColorWhite,
                                ),
                              ),
                              tablet ? AppSpaces.v12 : AppSpaces.v6,
                              Text(
                                'Hi, $fullName',
                                style: TextStyles.kSemiBoldOutfit(
                                  fontSize: tablet
                                      ? FontSizes.k24FontSize
                                      : FontSizes.k18FontSize,
                                  color: kColorWhite.withOpacity(0.95),
                                ),
                              ),
                              AppSpaces.v4,
                              Text(
                                'Please enter a new password\nto continue.',
                                style: TextStyles.kRegularOutfit(
                                  fontSize: tablet
                                      ? FontSizes.k20FontSize
                                      : FontSizes.k16FontSize,
                                  color: kColorWhite.withOpacity(0.85),
                                ),
                              ),
                              tablet ? AppSpaces.v24 : AppSpaces.v18,
                              Obx(
                                () => AppTextFormField(
                                  controller: _controller.newPasswordController,
                                  hintText: 'New Password',
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please enter a valid new password';
                                    }
                                    return null;
                                  },
                                  floatingLabelRequired: false,
                                  isObscure:
                                      _controller.obscuredNewPassword.value,
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      _controller.toggleNewPasswordVisibility();
                                    },
                                    icon: Icon(
                                      _controller.obscuredNewPassword.value
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      size: tablet ? 25 : 20,
                                      color: kColorBlack,
                                    ),
                                  ),
                                ),
                              ),
                              tablet ? AppSpaces.v20 : AppSpaces.v14,
                              Obx(
                                () => AppTextFormField(
                                  controller:
                                      _controller.confirmPasswordController,
                                  hintText: 'Confirm Password',
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please confirm your password';
                                    }
                                    if (value !=
                                        _controller
                                            .newPasswordController
                                            .text) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                  floatingLabelRequired: false,
                                  isObscure:
                                      _controller.obscuredConfirmPassword.value,
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      _controller
                                          .toggleConfirmPasswordVisibility();
                                    },
                                    icon: Icon(
                                      _controller.obscuredConfirmPassword.value
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      size: tablet ? 25 : 20,
                                      color: kColorBlack,
                                    ),
                                  ),
                                ),
                              ),
                              tablet ? AppSpaces.v28 : AppSpaces.v20,
                              AppButton(
                                title: 'Reset Password',
                                onPressed: () {
                                  _controller.hasAttemptedSubmit.value = true;
                                  if (_controller
                                      .resetPasswordFormKey
                                      .currentState!
                                      .validate()) {
                                    _controller.resetPassword(
                                      mobileNumber: mobileNumber,
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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

  Widget _buildResetPasswordWeb() {
    return Stack(
      children: [
        const AnimatedBackground(),
        GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: AppPaddings.combined(horizontal: 24, vertical: 40),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          width: double.infinity,
                          padding: AppPaddings.p32,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.08),
                                Colors.white.withOpacity(0.05),
                              ],
                            ),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.4),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 40,
                                spreadRadius: 5,
                                offset: const Offset(0, 15),
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: -5,
                                offset: const Offset(0, -5),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _controller.resetPasswordFormKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Reset Password',
                                  style: TextStyles.kSemiBoldOutfit(
                                    fontSize: FontSizes.k26FontSize,
                                    color: kColorWhite,
                                  ),
                                ),
                                AppSpaces.v8,
                                Text(
                                  'Hi, $fullName',
                                  style: TextStyles.kSemiBoldOutfit(
                                    fontSize: FontSizes.k16FontSize,
                                    color: kColorWhite.withOpacity(0.95),
                                  ),
                                ),
                                AppSpaces.v2,
                                Text(
                                  'Please enter a new password to continue.',
                                  style: TextStyles.kRegularOutfit(
                                    fontSize: FontSizes.k14FontSize,
                                    color: kColorWhite.withOpacity(0.85),
                                  ),
                                ),
                                AppSpaces.v20,
                                Obx(
                                  () => AppTextFormField(
                                    controller:
                                        _controller.newPasswordController,
                                    hintText: 'New Password',
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter a valid new password';
                                      }
                                      return null;
                                    },
                                    floatingLabelRequired: false,
                                    isObscure:
                                        _controller.obscuredNewPassword.value,
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        _controller
                                            .toggleNewPasswordVisibility();
                                      },
                                      icon: Icon(
                                        _controller.obscuredNewPassword.value
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        size: 20,
                                        color: kColorBlack,
                                      ),
                                    ),
                                  ),
                                ),
                                AppSpaces.v10,
                                Obx(
                                  () => AppTextFormField(
                                    controller:
                                        _controller.confirmPasswordController,
                                    hintText: 'Confirm Password',
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please confirm your password';
                                      }
                                      if (value !=
                                          _controller
                                              .newPasswordController
                                              .text) {
                                        return 'Passwords do not match';
                                      }
                                      return null;
                                    },
                                    floatingLabelRequired: false,
                                    isObscure: _controller
                                        .obscuredConfirmPassword
                                        .value,
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        _controller
                                            .toggleConfirmPasswordVisibility();
                                      },
                                      icon: Icon(
                                        _controller
                                                .obscuredConfirmPassword
                                                .value
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        size: 20,
                                        color: kColorBlack,
                                      ),
                                    ),
                                  ),
                                ),
                                AppSpaces.v20,
                                AppButton(
                                  title: 'Reset Password',
                                  onPressed: () {
                                    _controller.hasAttemptedSubmit.value = true;
                                    if (_controller
                                        .resetPasswordFormKey
                                        .currentState!
                                        .validate()) {
                                      _controller.resetPassword(
                                        mobileNumber: mobileNumber,
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
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
}
