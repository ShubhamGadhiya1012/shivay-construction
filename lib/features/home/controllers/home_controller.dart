// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/constants/image_constants.dart';
import 'package:shivay_construction/features/auth/screens/login_screen.dart';
import 'package:shivay_construction/features/home/repos/home_repo.dart';
import 'package:shivay_construction/features/user_settings/models/user_access_dm.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';
import 'package:shivay_construction/utils/helpers/device_helper.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';
import 'package:shivay_construction/utils/helpers/version_helper.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/widgets/app_text_button.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeController extends GetxController {
  var isLoading = false.obs;
  var company = ''.obs;
  var menuAccess = <MenuAccessDm>[].obs;

  var currentBannerIndex = 0.obs;
  final List<String> bannerImages = [
    kImagebanner1,
    kImagebanner2,
    kImagebanner3,
    kImagebanner4,
  ];

  void updateBannerIndex(int index) {
    currentBannerIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await loadCompany();
    await loadMenuFromAPI();
  }

  Future<void> loadCompany() async {
    try {
      String? companyName = await SecureStorageHelper.read('company');
      company.value = companyName ?? 'Shivay Construction';
    } catch (e) {
      company.value = 'Shivay Construction';
    }
  }

  List<Map<String, dynamic>> getQuickActions() {
    List<Map<String, dynamic>> actions = [];

    // Entry submenu items
    if (hasAccessToMenu('Entry')) {
      if (menuAccess.any(
        (menu) =>
            menu.menuName.toLowerCase() == 'entry' &&
            menu.subMenu.any(
              (sub) =>
                  sub.subMenuName.toLowerCase() == 'indent entry' &&
                  sub.subMenuAccess,
            ),
      )) {
        actions.add({
          'title': 'Indent Entry',
          'icon': Icons.description_rounded,
          'submenu': 'indent entry',
        });
      }
      if (menuAccess.any(
        (menu) =>
            menu.menuName.toLowerCase() == 'entry' &&
            menu.subMenu.any(
              (sub) =>
                  sub.subMenuName.toLowerCase() == 'purchase order entry' &&
                  sub.subMenuAccess,
            ),
      )) {
        actions.add({
          'title': 'Purchase Order Entry',
          'icon': Icons.shopping_cart_rounded,
          'submenu': 'purchase order entry',
        });
      }
      if (menuAccess.any(
        (menu) =>
            menu.menuName.toLowerCase() == 'entry' &&
            menu.subMenu.any(
              (sub) =>
                  sub.subMenuName.toLowerCase() == 'grn entry' &&
                  sub.subMenuAccess,
            ),
      )) {
        actions.add({
          'title': 'GRN Entry',
          'icon': Icons.receipt_long_rounded,
          'submenu': 'grn entry',
        });
      }
    }

    // Reports submenu items
    if (hasAccessToMenu('Reports')) {
      if (menuAccess.any(
        (menu) =>
            menu.menuName.toLowerCase() == 'reports' &&
            menu.subMenu.any(
              (sub) =>
                  sub.subMenuName.toLowerCase() == 'opening stock report' &&
                  sub.subMenuAccess,
            ),
      )) {
        actions.add({
          'title': 'Opening Stock Report',
          'icon': Icons.inventory_rounded,
          'submenu': 'opening stock report',
        });
      }
      if (menuAccess.any(
        (menu) =>
            menu.menuName.toLowerCase() == 'reports' &&
            menu.subMenu.any(
              (sub) =>
                  sub.subMenuName.toLowerCase() == 'indent report' &&
                  sub.subMenuAccess,
            ),
      )) {
        actions.add({
          'title': 'Indent Report',
          'icon': Icons.bar_chart_rounded,
          'submenu': 'indent report',
        });
      }
      if (menuAccess.any(
        (menu) =>
            menu.menuName.toLowerCase() == 'reports' &&
            menu.subMenu.any(
              (sub) =>
                  sub.subMenuName.toLowerCase() == 'purchase order report' &&
                  sub.subMenuAccess,
            ),
      )) {
        actions.add({
          'title': 'Purchase Report',
          'icon': Icons.assessment_rounded,
          'submenu': 'purchase order report',
        });
      }
      if (menuAccess.any(
        (menu) =>
            menu.menuName.toLowerCase() == 'reports' &&
            menu.subMenu.any(
              (sub) =>
                  sub.subMenuName.toLowerCase() == 'grn report' &&
                  sub.subMenuAccess,
            ),
      )) {
        actions.add({
          'title': 'GRN Report',
          'icon': Icons.analytics_rounded,
          'submenu': 'grn report',
        });
      }
    }

    // Stock Reports submenu items
    if (hasAccessToMenu('Stock Reports')) {
      if (menuAccess.any(
        (menu) =>
            menu.menuName.toLowerCase() == 'stock reports' &&
            menu.subMenu.any(
              (sub) =>
                  sub.subMenuName.toLowerCase() == 'stock statement report' &&
                  sub.subMenuAccess,
            ),
      )) {
        actions.add({
          'title': 'Stock Statement',
          'icon': Icons.summarize_rounded,
          'submenu': 'stock statement report',
        });
      }
      if (menuAccess.any(
        (menu) =>
            menu.menuName.toLowerCase() == 'stock reports' &&
            menu.subMenu.any(
              (sub) =>
                  sub.subMenuName.toLowerCase() == 'stock ledger' &&
                  sub.subMenuAccess,
            ),
      )) {
        actions.add({
          'title': 'Stock Ledger',
          'icon': Icons.book_rounded,
          'submenu': 'stock ledger',
        });
      }
      if (menuAccess.any(
        (menu) =>
            menu.menuName.toLowerCase() == 'stock reports' &&
            menu.subMenu.any(
              (sub) =>
                  sub.subMenuName.toLowerCase() == 'group stock report' &&
                  sub.subMenuAccess,
            ),
      )) {
        actions.add({
          'title': 'Group Stock',
          'icon': Icons.view_module_rounded,
          'submenu': 'group stock report',
        });
      }
      if (menuAccess.any(
        (menu) =>
            menu.menuName.toLowerCase() == 'stock reports' &&
            menu.subMenu.any(
              (sub) =>
                  sub.subMenuName.toLowerCase() == 'site stock report' &&
                  sub.subMenuAccess,
            ),
      )) {
        actions.add({
          'title': 'Site Stock',
          'icon': Icons.location_on_rounded,
          'submenu': 'site stock report',
        });
      }
    }

    return actions;
  }

  Future<void> loadMenuFromAPI() async {
    isLoading.value = true;
    try {
      String? userId = await SecureStorageHelper.read('userId');

      if (userId == null || userId.isEmpty) {
        menuAccess.clear();
        return;
      }

      final int userIdInt = int.parse(userId);
      final fetchedUserAccess = await HomeRepo.getUserAccess(userId: userIdInt);

      menuAccess.assignAll(fetchedUserAccess.menuAccess);
    } catch (e) {
      menuAccess.clear();
      showErrorSnackbar('Error', 'Failed to load menu data');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshMenuData() async {
    await loadMenuFromAPI();
  }

  bool get hasMenuAccess => menuAccess.isNotEmpty;

  bool hasAccessToMenu(String menuName) {
    return menuAccess.any(
      (menu) =>
          menu.menuName.toLowerCase() == menuName.toLowerCase() && menu.access,
    );
  }

  Future<void> redirectToPlayStore() async {
    const playStoreUrl =
        'https://play.google.com/store/apps/details?id=com.jinee.shivay_construction';

    final uri = Uri.parse(playStoreUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      showErrorSnackbar('Error', 'Could not launch the Play Store.');
    }
  }

  Future<void> checkAppVersion() async {
    isLoading.value = true;
    String? deviceId = await DeviceHelper().getDeviceId();

    if (deviceId == null) {
      showErrorSnackbar('Login Failed', 'Unable to fetch device ID.');
      isLoading.value = false;
      return;
    }

    try {
      String? version = await VersionHelper.getVersion();

      var result = await HomeRepo.checkVersion(
        version: version,
        deviceId: deviceId,
      );

      if (result is List && result.isEmpty) {
        return;
      }
    } catch (e) {
      final bool tablet = AppScreenUtils.isTablet(Get.context!);
      if (e.toString().contains('Please update your app with latest version')) {
        Get.dialog(
          WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              titlePadding: tablet
                  ? AppPaddings.custom(left: 25, right: 25, top: 25, bottom: 10)
                  : AppPaddings.custom(left: 20, right: 20, top: 20, bottom: 6),
              contentPadding: tablet
                  ? AppPaddings.custom(left: 25, right: 25, bottom: 14)
                  : AppPaddings.custom(left: 20, right: 20, bottom: 8),
              backgroundColor: kColorWhite,
              title: Text(
                'Update Required',
                style: TextStyles.kSemiBoldOutfit(
                  fontSize: tablet
                      ? FontSizes.k32FontSize
                      : FontSizes.k20FontSize,
                  color: kColorPrimary,
                ),
              ),
              content: Text(
                e.toString(),
                style: TextStyles.kRegularOutfit(
                  fontSize: tablet
                      ? FontSizes.k24FontSize
                      : FontSizes.k16FontSize,
                ),
              ),
              actions: [
                AppTextButton(
                  onPressed: () async {
                    await redirectToPlayStore();
                  },
                  title: 'Update',
                  fontSize: tablet
                      ? FontSizes.k24FontSize
                      : FontSizes.k16FontSize,
                ),
              ],
            ),
          ),
          barrierDismissible: false,
        );
      } else if (e.toString().contains('Please login again.')) {
        Get.dialog(
          WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              titlePadding: tablet
                  ? AppPaddings.custom(left: 25, right: 25, top: 25, bottom: 10)
                  : AppPaddings.custom(left: 20, right: 20, top: 20, bottom: 6),
              contentPadding: tablet
                  ? AppPaddings.custom(left: 25, right: 25, bottom: 14)
                  : AppPaddings.custom(left: 20, right: 20, bottom: 8),
              backgroundColor: kColorWhite,
              title: Text(
                'Session Expired',
                style: TextStyles.kSemiBoldOutfit(
                  fontSize: tablet
                      ? FontSizes.k32FontSize
                      : FontSizes.k20FontSize,
                  color: kColorPrimary,
                ),
              ),
              content: Text(
                e.toString(),
                style: TextStyles.kRegularOutfit(
                  fontSize: tablet
                      ? FontSizes.k24FontSize
                      : FontSizes.k16FontSize,
                ),
              ),
              actions: [
                AppTextButton(
                  onPressed: () {
                    Get.back();
                    logoutUser();
                  },
                  title: 'Login Again',
                  fontSize: tablet
                      ? FontSizes.k24FontSize
                      : FontSizes.k16FontSize,
                ),
              ],
            ),
          ),
          barrierDismissible: false,
        );
      } else {
        showErrorSnackbar('Error', e.toString());
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logoutUser() async {
    isLoading.value = true;
    try {
      await SecureStorageHelper.clearAll();

      Get.offAll(() => LoginScreen());

      showSuccessSnackbar(
        'Logged Out',
        'You have been successfully logged out.',
      );
    } catch (e) {
      showErrorSnackbar(
        'Logout Failed',
        'Something went wrong. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }
}
