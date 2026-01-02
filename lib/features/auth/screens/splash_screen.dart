import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/constants/image_constants.dart';
import 'package:shivay_construction/features/auth/screens/login_screen.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';
import 'package:shivay_construction/utils/helpers/version_helper.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  String appVersion = '';

  // Multiple animation controllers
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _pulseController;

  // Animations
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Scale animation with bounce
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    // Pulse animation - continuous subtle pulse
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startAnimations();
    _initialize();
  }

  void _startAnimations() async {
    // Start fade and scale together
    _fadeController.forward();
    _scaleController.forward();

    await Future.delayed(const Duration(milliseconds: 1400));

    // Start pulse loop
    _pulseController.repeat(reverse: true);
  }

  Future<void> _initialize() async {
    appVersion = await VersionHelper.getVersion();
    setState(() {});
    await Future.delayed(const Duration(seconds: 3));
    String? token = await SecureStorageHelper.read('token');

    Future.delayed(const Duration(seconds: 1), () {
      if (token != null && token.isNotEmpty) {
        // Get.offAll(() => HomeScreen());
      } else {
        Get.offAll(() => LoginScreen());
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);

    return Scaffold(
      backgroundColor: kColorWhite,
      body: SafeArea(
        child: Stack(
          children: [
            // Animated background circles
            _buildAnimatedBackground(),

            // Logo with animations
            Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _scaleController,
                  _fadeController,
                  _pulseController,
                ]),
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value * _pulseAnimation.value,
                      child: Image.asset(
                        kImagelogo,
                        width: tablet
                            ? MediaQuery.of(context).size.width * 0.5
                            : MediaQuery.of(context).size.width * 0.7,
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Version text - simple display
            Positioned(
              bottom: tablet ? 60 : 40,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: Text(
                    'v$appVersion',
                    style: TextStyles.kRegularOutfit(
                      fontSize: tablet
                          ? FontSizes.k18FontSize
                          : FontSizes.k16FontSize,
                      color: kColorGrey,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _scaleController,
      builder: (context, child) {
        return Stack(
          children: [
            // Top right circle
            Positioned(
              top: -100,
              right: -100,
              child: Opacity(
                opacity: 0.05 * _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kColorPrimary,
                    ),
                  ),
                ),
              ),
            ),
            // Bottom left circle
            Positioned(
              bottom: -150,
              left: -150,
              child: Opacity(
                opacity: 0.05 * _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kColorPrimary,
                    ),
                  ),
                ),
              ),
            ),
            // Center large circle with pulse
            Center(
              child: Opacity(
                opacity: 0.03 * _fadeAnimation.value,
                child: Transform.scale(
                  scale: _pulseAnimation.value * 2,
                  child: Container(
                    width: 500,
                    height: 500,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kColorPrimary,
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
}
