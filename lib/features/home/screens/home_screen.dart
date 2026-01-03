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
                    vertical: tablet ? 14 : 10,
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
                  child: Obx(() {
                    if (!_controller.hasMenuAccess &&
                        !_controller.isLoading.value) {
                      return Center(
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
                      );
                    }

                    return _buildDashboardContent(tablet);
                  }),
                ),
              ],
            ),
          ),
        ),

        Obx(() => AppLoadingOverlay(isLoading: _controller.isLoading.value)),
      ],
    );
  }

  Widget _buildDashboardContent(bool tablet) {
    return SingleChildScrollView(
      padding: AppPaddings.combined(horizontal: tablet ? 20 : 16, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard',
            style: TextStyles.kSemiBoldOutfit(
              fontSize: tablet ? FontSizes.k30FontSize : FontSizes.k24FontSize,
              color: kColorPrimary,
            ),
          ),

          tablet ? AppSpaces.v20 : AppSpaces.v14,

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: tablet ? 16 : 12,
            mainAxisSpacing: tablet ? 16 : 12,
            childAspectRatio: tablet ? 1.5 : 1.3,
            children: [
              _buildStatCard(
                icon: Icons.inventory_2_outlined,
                title: 'Total Projects',
                value: '0',
                color: Colors.blue,
                tablet: tablet,
              ),
              _buildStatCard(
                icon: Icons.people_outline,
                title: 'Active Workers',
                value: '0',
                color: Colors.green,
                tablet: tablet,
              ),
              _buildStatCard(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Pending Payments',
                value: '₹0',
                color: Colors.orange,
                tablet: tablet,
              ),
              _buildStatCard(
                icon: Icons.construction_outlined,
                title: 'Materials',
                value: '0',
                color: Colors.purple,
                tablet: tablet,
              ),
            ],
          ),

          tablet ? AppSpaces.v30 : AppSpaces.v20,

          Text(
            'Quick Actions',
            style: TextStyles.kSemiBoldOutfit(
              fontSize: tablet ? FontSizes.k26FontSize : FontSizes.k20FontSize,
              color: kColorPrimary,
            ),
          ),

          tablet ? AppSpaces.v16 : AppSpaces.v12,

          _buildQuickActionCard(
            icon: Icons.add_circle_outline,
            title: 'New Entry',
            subtitle: 'Create a new project entry',
            onTap: () {},
            tablet: tablet,
          ),

          tablet ? AppSpaces.v12 : AppSpaces.v10,

          _buildQuickActionCard(
            icon: Icons.assessment_outlined,
            title: 'View Reports',
            subtitle: 'Check project reports',
            onTap: () {},
            tablet: tablet,
          ),

          tablet ? AppSpaces.v30 : AppSpaces.v20,
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required bool tablet,
  }) {
    return Container(
      padding: AppPaddings.combined(
        horizontal: tablet ? 16 : 12,
        vertical: tablet ? 16 : 12,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: tablet ? 32 : 28),
          tablet ? AppSpaces.v8 : AppSpaces.v6,
          Text(
            value,
            style: TextStyles.kBoldOutfit(
              fontSize: tablet ? FontSizes.k28FontSize : FontSizes.k22FontSize,
              color: color,
            ),
          ),
          AppSpaces.v2,
          Text(
            title,
            style: TextStyles.kRegularOutfit(
              fontSize: tablet ? FontSizes.k16FontSize : FontSizes.k14FontSize,
              color: kColorSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool tablet,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: AppPaddings.combined(
          horizontal: tablet ? 20 : 16,
          vertical: tablet ? 18 : 14,
        ),
        decoration: BoxDecoration(
          color: kColorPrimary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kColorPrimary.withOpacity(0.2), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(tablet ? 12 : 10),
              decoration: BoxDecoration(
                color: kColorPrimary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: kColorPrimary, size: tablet ? 28 : 24),
            ),
            tablet ? AppSpaces.h16 : AppSpaces.h12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyles.kSemiBoldOutfit(
                      fontSize: tablet
                          ? FontSizes.k22FontSize
                          : FontSizes.k18FontSize,
                      color: kColorPrimary,
                    ),
                  ),
                  AppSpaces.v2,
                  Text(
                    subtitle,
                    style: TextStyles.kRegularOutfit(
                      fontSize: tablet
                          ? FontSizes.k16FontSize
                          : FontSizes.k14FontSize,
                      color: kColorSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: kColorPrimary,
              size: tablet ? 20 : 16,
            ),
          ],
        ),
      ),
    );
  }
}
