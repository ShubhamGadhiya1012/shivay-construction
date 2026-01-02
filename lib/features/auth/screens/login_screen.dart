// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/constants/image_constants.dart';
import 'package:shivay_construction/features/auth/controllers/login_controller.dart';
import 'package:shivay_construction/features/auth/screens/register_screen.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/extensions/app_size_extensions.dart';
import 'package:shivay_construction/utils/formatters/text_input_formatters.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_button.dart';
import 'package:shivay_construction/widgets/app_loading_overlay.dart';
import 'package:shivay_construction/widgets/app_text_button.dart';
import 'package:shivay_construction/widgets/app_text_form_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final LoginController _controller = Get.put(LoginController());

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _logoController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _logoScaleAnimation;
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

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
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
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _logoController.dispose();
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
                        key: _controller.loginFormKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: AnimatedBuilder(
                                animation: _logoController,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _logoScaleAnimation.value,
                                    child: Image.asset(
                                      kImagelogo,
                                      width: web
                                          ? 200
                                          : tablet
                                          ? 280
                                          : 220,
                                      fit: BoxFit.contain,
                                    ),
                                  );
                                },
                              ),
                            ),

                            web
                                ? AppSpaces.v30
                                : tablet
                                ? AppSpaces.v20
                                : AppSpaces.v10,

                            SlideTransition(
                              position: _slideAnimation,
                              child: FadeTransition(
                                opacity: _fadeAnimation,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: Text(
                                        'Welcome Back!',
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
                                        'Hello there! Please login to continue.',
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

                                    AppTextFormField(
                                      controller:
                                          _controller.mobileNumberController,
                                      hintText: 'Mobile Number',
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a mobile number';
                                        }
                                        if (value.length != 10) {
                                          return 'Please enter a 10-digit mobile number';
                                        }
                                        return null;
                                      },
                                      keyboardType: TextInputType.phone,
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
                                        controller:
                                            _controller.passwordController,
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
                                            _controller
                                                .togglePasswordVisibility();
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
                                        ? AppSpaces.v20
                                        : tablet
                                        ? AppSpaces.v30
                                        : AppSpaces.v30,

                                    AppButton(
                                      title: 'Login',
                                      onPressed: () {
                                        _controller.hasAttemptedLogin.value =
                                            true;
                                        if (_controller
                                            .loginFormKey
                                            .currentState!
                                            .validate()) {
                                          _controller.loginUser();
                                        }
                                      },
                                    ),

                                    web
                                        ? AppSpaces.v20
                                        : tablet
                                        ? AppSpaces.v24
                                        : AppSpaces.v30,

                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Don\'t have an account?  ',
                                          style: TextStyles.kRegularOutfit(
                                            color: kColorTextPrimary,
                                            fontSize: web
                                                ? FontSizes.k12FontSize
                                                : tablet
                                                ? FontSizes.k18FontSize
                                                : FontSizes.k16FontSize,
                                          ).copyWith(height: 1),
                                        ),
                                        AppTextButton(
                                          fontSize: web
                                              ? FontSizes.k12FontSize
                                              : tablet
                                              ? FontSizes.k18FontSize
                                              : FontSizes.k16FontSize,
                                          onPressed: () {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                            Get.to(() => RegisterScreen());
                                          },
                                          title: 'Register',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
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
