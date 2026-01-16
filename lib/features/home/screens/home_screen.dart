// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/home/controllers/home_controller.dart';
import 'package:shivay_construction/features/home/widgets/app_drawer.dart';
import 'package:shivay_construction/features/profile/screens/profile_screen.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_loading_overlay.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final HomeController _controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);
    final bool web = AppScreenUtils.isWeb;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: kColorWhite,
          drawer: AppDrawer(controller: _controller, tablet: tablet, web: web),
          body: SafeArea(
            child: Column(
              children: [
                tablet ? AppSpaces.v16 : AppSpaces.v10,
                Container(
                  margin: AppPaddings.combined(
                    horizontal: tablet ? 16 : 12,
                    vertical: tablet ? 12 : 8,
                  ),
                  padding: AppPaddings.combined(
                    horizontal: tablet ? 20 : 14,
                    vertical: tablet ? 7 : 5,
                  ),
                  decoration: BoxDecoration(
                    color: kColorPrimary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: kColorPrimary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Builder(
                        builder: (context) => IconButton(
                          icon: Icon(
                            Icons.menu_rounded,
                            color: kColorPrimary,
                            size: tablet ? 32 : 26,
                          ),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                      ),

                      Expanded(
                        child: Obx(
                          () => Text(
                            _controller.company.value.isNotEmpty
                                ? _controller.company.value
                                : 'Shivay Construction',
                            textAlign: TextAlign.center,
                            style: TextStyles.kSemiBoldOutfit(
                              fontSize: tablet
                                  ? FontSizes.k26FontSize
                                  : FontSizes.k20FontSize,
                              color: kColorPrimary,
                            ),
                          ),
                        ),
                      ),

                      IconButton(
                        icon: Icon(
                          Icons.person_rounded,
                          color: kColorPrimary,
                          size: tablet ? 32 : 26,
                        ),
                        onPressed: () {
                          Get.to(() => ProfileScreen());
                        },
                      ),
                    ],
                  ),
                ),
                tablet ? AppSpaces.v30 : AppSpaces.v20,
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: AppPaddings.combined(
                        horizontal: tablet ? 40 : 24,
                        vertical: 0,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.business_center_outlined,
                            size: tablet ? 100 : 80,
                            color: kColorPrimary.withOpacity(0.3),
                          ),
                          tablet ? AppSpaces.v24 : AppSpaces.v16,
                          Text(
                            'Welcome to Shivay Construction',
                            textAlign: TextAlign.center,
                            style: TextStyles.kSemiBoldOutfit(
                              fontSize: tablet
                                  ? FontSizes.k28FontSize
                                  : FontSizes.k22FontSize,
                              color: kColorPrimary,
                            ),
                          ),
                          tablet ? AppSpaces.v12 : AppSpaces.v8,
                          Text(
                            'Please open the menu to access your modules',
                            textAlign: TextAlign.center,
                            style: TextStyles.kRegularOutfit(
                              fontSize: tablet
                                  ? FontSizes.k22FontSize
                                  : FontSizes.k16FontSize,
                              color: kColorSecondary,
                            ),
                          ),
                        ],
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
}
