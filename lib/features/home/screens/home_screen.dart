// ignore_for_file: deprecated_member_use

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/grn_entry/screens/grns_screen.dart';
import 'package:shivay_construction/features/home/controllers/home_controller.dart';
import 'package:shivay_construction/features/home/widgets/app_drawer.dart';
import 'package:shivay_construction/features/indent_entry/screens/indents_screen.dart';
import 'package:shivay_construction/features/item_help/screens/item_help_search_screen.dart';
import 'package:shivay_construction/features/profile/screens/profile_screen.dart';
import 'package:shivay_construction/features/purchase_order_entry/screens/purchase_order_list_screen.dart';
import 'package:shivay_construction/features/reports/screens/grn_report_screen.dart';
import 'package:shivay_construction/features/reports/screens/indent_report_screen.dart';
import 'package:shivay_construction/features/reports/screens/opening_stock_report_screen.dart';
import 'package:shivay_construction/features/reports/screens/purchase_order_report_screen.dart';
import 'package:shivay_construction/features/stock_reports/screens/stock_report_screen.dart';
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
                tablet ? AppSpaces.v30 : AppSpaces.v10,
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CarouselSlider(
                          options: CarouselOptions(
                            height: tablet ? 200 : 160,
                            autoPlay: true,
                            autoPlayInterval: const Duration(seconds: 3),
                            autoPlayAnimationDuration: const Duration(
                              milliseconds: 800,
                            ),
                            autoPlayCurve: Curves.fastOutSlowIn,
                            enlargeCenterPage: false,
                            viewportFraction: 1.0,
                            padEnds: false,
                            onPageChanged: (index, reason) {
                              _controller.updateBannerIndex(index);
                            },
                          ),
                          items: _controller.bannerImages.map((imagePath) {
                            return Builder(
                              builder: (BuildContext context) {
                                return Container(
                                  width: double.infinity,
                                  margin: AppPaddings.combined(
                                    horizontal: tablet ? 16 : 12,
                                    vertical: 0,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      tablet ? 16 : 12,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: kColorPrimary.withOpacity(0.2),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      tablet ? 16 : 12,
                                    ),
                                    child: Image.asset(
                                      imagePath,
                                      fit: BoxFit.contain,
                                      width: double.infinity,
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                        tablet ? AppSpaces.v12 : AppSpaces.v8,
                        Obx(
                          () => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: _controller.bannerImages
                                .asMap()
                                .entries
                                .map((entry) {
                                  return Container(
                                    width:
                                        _controller.currentBannerIndex.value ==
                                            entry.key
                                        ? (tablet ? 24 : 20)
                                        : (tablet ? 8 : 6),
                                    height: tablet ? 8 : 6,
                                    margin: AppPaddings.combined(
                                      horizontal: tablet ? 4 : 3,
                                      vertical: 0,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        tablet ? 4 : 3,
                                      ),
                                      color:
                                          _controller
                                                  .currentBannerIndex
                                                  .value ==
                                              entry.key
                                          ? kColorPrimary
                                          : kColorPrimary.withOpacity(0.3),
                                    ),
                                  );
                                })
                                .toList(),
                          ),
                        ),

                        tablet ? AppSpaces.v30 : AppSpaces.v10,

                        Obx(() {
                          final quickActions = _controller.getQuickActions();

                          if (quickActions.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: AppPaddings.combined(
                                  horizontal: tablet ? 24 : 16,
                                  vertical: 0,
                                ),
                                child: Text(
                                  'Quick Actions',
                                  style: TextStyles.kSemiBoldOutfit(
                                    fontSize: tablet
                                        ? FontSizes.k26FontSize
                                        : FontSizes.k20FontSize,
                                    color: kColorPrimary,
                                  ),
                                ),
                              ),
                              tablet ? AppSpaces.v16 : AppSpaces.v12,
                              Padding(
                                padding: AppPaddings.combined(
                                  horizontal: tablet ? 16 : 12,
                                  vertical: 0,
                                ),
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: tablet ? 4 : 3,
                                        crossAxisSpacing: tablet ? 16 : 12,
                                        mainAxisSpacing: tablet ? 16 : 12,
                                        childAspectRatio: tablet ? 1.1 : 1.0,
                                      ),
                                  itemCount: quickActions.length,
                                  itemBuilder: (context, index) {
                                    final action = quickActions[index];
                                    return _buildQuickActionCard(
                                      title: action['title'],
                                      icon: action['icon'],
                                      submenu: action['submenu'],
                                      tablet: tablet,
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        }),

                        tablet ? AppSpaces.v30 : AppSpaces.v20,
                      ],
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

  Widget _buildQuickActionCard({
    required String title,
    required IconData icon,
    required String submenu,
    required bool tablet,
  }) {
    return InkWell(
      onTap: () => _navigateToSubmenu(submenu),
      borderRadius: BorderRadius.circular(tablet ? 16 : 12),
      child: Container(
        padding: AppPaddings.combined(
          horizontal: tablet ? 12 : 8,
          vertical: tablet ? 16 : 12,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              kColorPrimary.withOpacity(0.1),
              kColorPrimary.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(tablet ? 16 : 12),
          border: Border.all(color: kColorPrimary.withOpacity(0.2), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(tablet ? 12 : 10),
              decoration: BoxDecoration(
                color: kColorPrimary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(tablet ? 12 : 10),
              ),
              child: Icon(icon, color: kColorPrimary, size: tablet ? 28 : 24),
            ),
            tablet ? AppSpaces.v8 : AppSpaces.v6,
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.kMediumOutfit(
                fontSize: tablet
                    ? FontSizes.k16FontSize
                    : FontSizes.k12FontSize,
                color: kColorTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToSubmenu(String submenuName) {
    switch (submenuName.toLowerCase()) {
      case 'indent entry':
        Get.to(() => IndentsScreen());
        break;
      case 'purchase order entry':
        Get.to(() => PurchaseOrderListScreen());
        break;
      case 'grn entry':
        Get.to(() => GrnsScreen());
        break;
      case 'opening stock report':
        Get.to(() => OpeningStockReportScreen());
        break;
      case 'indent report':
        Get.to(() => IndentReportScreen());
        break;
      case 'purchase order report':
        Get.to(() => PurchaseOrderReportScreen());
        break;
      case 'grn report':
        Get.to(() => GrnReportScreen());
        break;
      case 'stock statement report':
        Get.to(
          () => const StockReportScreen(
            reportName: 'STATEMENT',
            reportTitle: 'Stock Statement Report',
            rType: 'STATEMENT',
            method: '',
          ),
        );
        break;
      case 'stock ledger':
        Get.to(
          () => const StockReportScreen(
            reportName: 'LEDGER',
            reportTitle: 'Stock Ledger',
            rType: 'LEDGER',
            method: '',
          ),
        );
        break;
      case 'group stock report':
        Get.to(
          () => const StockReportScreen(
            reportName: 'GROUPSTOCK',
            reportTitle: 'Group Stock Report',
            rType: 'GROUPSTOCK',
            method: '',
          ),
        );
        break;
      case 'site stock report':
        Get.to(
          () => const StockReportScreen(
            reportName: 'SITESTOCK',
            reportTitle: 'Site Stock Report',
            rType: 'SITESTOCK',
            method: '',
          ),
        );
        break;
      case 'item help':
        Get.to(() => ItemHelpSearchScreen());
        break;
    }
  }
}
