// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/auth/controllers/select_company_controller.dart';
import 'package:shivay_construction/features/auth/models/company_dm.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/extensions/app_size_extensions.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_button.dart';
import 'package:shivay_construction/widgets/app_dropdown.dart';
import 'package:shivay_construction/widgets/app_loading_overlay.dart';

class SelectCompanyScreen extends StatefulWidget {
  const SelectCompanyScreen({
    super.key,
    required this.companies,
    required this.mobileNumber,
  });

  final RxList<CompanyDm> companies;
  final String mobileNumber;

  @override
  State<SelectCompanyScreen> createState() => _SelectCompanyScreenState();
}

class _SelectCompanyScreenState extends State<SelectCompanyScreen>
    with TickerProviderStateMixin {
  final SelectCompanyController _controller = Get.put(
    SelectCompanyController(),
  );

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
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

    // Set initial company if only one exists
    if (widget.companies.length == 1) {
      _controller.selectedCoName.value = widget.companies.first.coName;
      _controller.selectedCoCode.value = widget.companies.first.coCode;
      _controller.selectedCid.value = widget.companies.first.cid;
      _controller.getYears();
    }
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
                        key: _controller.selectCompanyFormKey,
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
                                    'Select Company',
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
                                    'Choose your company and financial year.',
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

                                // Company Dropdown
                                Obx(
                                  () => AppDropdown(
                                    items: widget.companies
                                        .map((company) => company.coName)
                                        .toList(),
                                    hintText: 'Select Company',
                                    onChanged: (value) {
                                      _controller.selectedCoName.value = value!;
                                      _controller.selectedCoCode.value = widget
                                          .companies
                                          .firstWhere(
                                            (company) =>
                                                company.coName == value,
                                          )
                                          .coCode;
                                      _controller.selectedCid.value = widget
                                          .companies
                                          .firstWhere(
                                            (company) =>
                                                company.coName == value,
                                          )
                                          .cid;
                                      if (widget.companies.length > 1) {
                                        _controller.getYears();
                                      }
                                    },
                                    selectedItem:
                                        _controller
                                            .selectedCoName
                                            .value
                                            .isNotEmpty
                                        ? _controller.selectedCoName.value
                                        : null,
                                    validatorText: 'Please select a company',
                                  ),
                                ),

                                web
                                    ? AppSpaces.v10
                                    : tablet
                                    ? AppSpaces.v20
                                    : AppSpaces.v16,

                                // Financial Year Dropdown
                                Obx(
                                  () => AppDropdown(
                                    items: _controller.finYears,
                                    hintText: 'Financial Year',
                                    onChanged: _controller.onYearSelected,
                                    selectedItem:
                                        _controller
                                            .selectedFinYear
                                            .value
                                            .isNotEmpty
                                        ? _controller.selectedFinYear.value
                                        : null,
                                    validatorText:
                                        'Please select a financial year',
                                  ),
                                ),

                                web
                                    ? AppSpaces.v20
                                    : tablet
                                    ? AppSpaces.v30
                                    : AppSpaces.v30,

                                // Continue Button
                                AppButton(
                                  title: 'Continue',
                                  onPressed: () {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    if (_controller
                                        .selectCompanyFormKey
                                        .currentState!
                                        .validate()) {
                                      _controller.getToken(
                                        mobileNumber: widget.mobileNumber,
                                        cid: _controller.selectedCid.value!,
                                        yearId:
                                            _controller.selectedYearId.value,
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
