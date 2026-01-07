// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/auth/controllers/register_controller.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/extensions/app_size_extensions.dart';
import 'package:shivay_construction/utils/formatters/text_input_formatters.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_button.dart';
import 'package:shivay_construction/widgets/app_loading_overlay.dart';
import 'package:shivay_construction/widgets/app_text_form_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final RegisterController _controller = Get.put(RegisterController());

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startAnimations();
  }

  void _startAnimations() async {
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);
    final bool web = AppScreenUtils.isWeb;

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: kColorWhite,
            body: Stack(
              children: [
                _buildAnimatedBackground(),

                Center(
                  child: SingleChildScrollView(
                    padding: _buildPadding(web, tablet),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: web ? 480 : double.infinity,
                      ),
                      child: Form(
                        key: _controller.registerFormKey,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Text(
                                    'Create Account',
                                    style: TextStyles.kSemiBoldOutfit(
                                      color: kColorPrimary,
                                      fontSize: web
                                          ? FontSizes.k26FontSize
                                          : tablet
                                          ? FontSizes.k40FontSize
                                          : FontSizes.k30FontSize,
                                    ),
                                  ),
                                ),

                                Center(
                                  child: Text(
                                    'Please fill in the details to register.',
                                    style: TextStyles.kRegularOutfit(
                                      fontSize: web
                                          ? FontSizes.k14FontSize
                                          : tablet
                                          ? FontSizes.k24FontSize
                                          : FontSizes.k16FontSize,
                                      color: kColorSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),

                                web
                                    ? AppSpaces.v30
                                    : tablet
                                    ? AppSpaces.v40
                                    : AppSpaces.v40,

                                Row(
                                  children: [
                                    Expanded(
                                      child: AppTextFormField(
                                        controller:
                                            _controller.firstNameController,
                                        hintText: 'First Name',
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Enter first name';
                                          }
                                          return null;
                                        },
                                        inputFormatters: [
                                          TitleCaseTextInputFormatter(),
                                        ],
                                      ),
                                    ),
                                    web
                                        ? AppSpaces.h10
                                        : tablet
                                        ? AppSpaces.h16
                                        : AppSpaces.h10,
                                    Expanded(
                                      child: AppTextFormField(
                                        controller:
                                            _controller.lastNameController,
                                        hintText: 'Last Name',
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Enter last name';
                                          }
                                          return null;
                                        },
                                        inputFormatters: [
                                          TitleCaseTextInputFormatter(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                web
                                    ? AppSpaces.v10
                                    : tablet
                                    ? AppSpaces.v20
                                    : AppSpaces.v16,

                                AppTextFormField(
                                  controller:
                                      _controller.mobileNumberController,
                                  hintText: 'Mobile Number',
                                  keyboardType: TextInputType.phone,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a mobile number';
                                    }
                                    if (value.length != 10) {
                                      return 'Mobile number must be 10 digits';
                                    }
                                    return null;
                                  },
                                  inputFormatters: [
                                    MobileNumberInputFormatter(),
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(10),
                                  ],
                                ),

                                web
                                    ? AppSpaces.v10
                                    : tablet
                                    ? AppSpaces.v20
                                    : AppSpaces.v16,

                                Obx(
                                  () => AppTextFormField(
                                    controller: _controller.passwordController,
                                    hintText: 'Password',
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a password';
                                      }

                                      return null;
                                    },
                                    isObscure:
                                        _controller.obscuredPassword.value,
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        _controller.togglePasswordVisibility();
                                      },
                                      icon: Icon(
                                        _controller.obscuredPassword.value
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        size: web ? 20 : (tablet ? 25 : 20),
                                      ),
                                    ),
                                  ),
                                ),

                                web
                                    ? AppSpaces.v10
                                    : tablet
                                    ? AppSpaces.v20
                                    : AppSpaces.v16,

                                Obx(
                                  () => AppTextFormField(
                                    controller:
                                        _controller.confirmPasswordController,
                                    hintText: 'Confirm Password',
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please confirm your password';
                                      }
                                      if (value !=
                                          _controller.passwordController.text) {
                                        return 'Passwords do not match';
                                      }
                                      return null;
                                    },
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
                                        size: web ? 20 : (tablet ? 25 : 20),
                                      ),
                                    ),
                                  ),
                                ),

                                web
                                    ? AppSpaces.v20
                                    : tablet
                                    ? AppSpaces.v30
                                    : AppSpaces.v30,

                                AppButton(
                                  title: 'Register',
                                  onPressed: () {
                                    _controller.hasAttemptedRegister.value =
                                        true;
                                    if (_controller
                                        .registerFormKey
                                        .currentState!
                                        .validate()) {
                                      _controller.registerUser();
                                    }
                                  },
                                ),

                                web
                                    ? AppSpaces.v20
                                    : tablet
                                    ? AppSpaces.v24
                                    : AppSpaces.v30,

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Already have an account?  ',
                                      style: TextStyles.kRegularOutfit(
                                        color: kColorTextPrimary,
                                        fontSize: web
                                            ? FontSizes.k12FontSize
                                            : tablet
                                            ? FontSizes.k18FontSize
                                            : FontSizes.k16FontSize,
                                      ).copyWith(height: 1),
                                    ),
                                    MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () {
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                          Get.back();
                                        },
                                        child: Text(
                                          'Sign In',
                                          style:
                                              TextStyles.kSemiBoldOutfit(
                                                fontSize: web
                                                    ? FontSizes.k12FontSize
                                                    : tablet
                                                    ? FontSizes.k18FontSize
                                                    : FontSizes.k16FontSize,
                                                color: kColorPrimary,
                                              ).copyWith(
                                                decoration:
                                                    TextDecoration.underline,
                                                decorationColor: kColorPrimary,
                                                height: 1,
                                              ),
                                        ),
                                      ),
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
                ),
              ],
            ),
          ),
        ),

        Obx(() => AppLoadingOverlay(isLoading: _controller.isLoading.value)),
      ],
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: -100,
              right: -100,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kColorPrimary.withOpacity(0.05),
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: -150,
              left: -150,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Transform.scale(
                  scale: _pulseAnimation.value * 0.95,
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kColorPrimary.withOpacity(0.05),
                    ),
                  ),
                ),
              ),
            ),

            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Transform.scale(
                  scale: _pulseAnimation.value * 1.5,
                  child: Container(
                    width: 500,
                    height: 500,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kColorPrimary.withOpacity(0.03),
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              top: 150,
              left: -50,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Transform.scale(
                  scale: _pulseAnimation.value * 0.9,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kColorPrimary.withOpacity(0.04),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  EdgeInsets _buildPadding(bool web, bool tablet) {
    if (web) {
      return AppPaddings.combined(horizontal: 24, vertical: 40);
    } else if (tablet) {
      return AppPaddings.combined(
        horizontal: 0.08.screenWidth,
        vertical: 0.04.screenHeight,
      );
    } else {
      return AppPaddings.ph30;
    }
  }
}
