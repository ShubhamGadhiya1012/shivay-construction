// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/home/controllers/home_controller.dart';
import 'package:shivay_construction/features/home/widgets/version_and_developer_info.dart';
import 'package:shivay_construction/features/user_settings/models/user_access_dm.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/extensions/app_size_extensions.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';

class AppDrawer extends StatelessWidget {
  final HomeController controller;
  final bool tablet;
  final bool web;

  const AppDrawer({
    super.key,
    required this.controller,
    required this.tablet,
    required this.web,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: kColorPrimary,
      width: web
          ? 320
          : tablet
          ? 0.5.screenWidth
          : 0.75.screenWidth,
      child: SafeArea(
        child: Column(
          children: [
            tablet ? AppSpaces.v20 : AppSpaces.v16,

            Padding(
              padding: AppPaddings.combined(
                horizontal: tablet ? 16 : 12,
                vertical: tablet ? 12 : 8,
              ),
              child: Column(
                children: [
                  // Logo placeholder - replace with your actual logo
                  Container(
                    height: tablet ? 80 : 60,
                    width: tablet ? 80 : 60,
                    decoration: BoxDecoration(
                      color: kColorWhite,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.construction,
                      size: tablet ? 40 : 32,
                      color: kColorPrimary,
                    ),
                  ),
                  tablet ? AppSpaces.v16 : AppSpaces.v12,
                  Text(
                    'Shivay Construction',
                    style: TextStyles.kBoldOutfit(
                      fontSize: tablet
                          ? FontSizes.k26FontSize
                          : FontSizes.k20FontSize,
                      color: kColorWhite,
                    ),
                  ),
                ],
              ),
            ),

            tablet ? AppSpaces.v20 : AppSpaces.v16,

            Obx(() {
              final accessibleMenus = controller.menuAccess
                  .where((menu) => menu.access)
                  .toList();

              if (accessibleMenus.isEmpty) {
                return Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.menu_book_outlined,
                          size: tablet ? 64 : 48,
                          color: kColorWhite.withOpacity(0.6),
                        ),
                        tablet ? AppSpaces.v16 : AppSpaces.v12,
                        Text(
                          'No menu data available',
                          style: TextStyles.kMediumOutfit(
                            fontSize: tablet
                                ? FontSizes.k22FontSize
                                : FontSizes.k18FontSize,
                            color: kColorWhite,
                          ),
                        ),
                        tablet ? AppSpaces.v8 : AppSpaces.v6,
                        Padding(
                          padding: AppPaddings.combined(
                            horizontal: tablet ? 32 : 24,
                            vertical: 0,
                          ),
                          child: Text(
                            'Please contact administrator for menu access',
                            textAlign: TextAlign.center,
                            style: TextStyles.kRegularOutfit(
                              fontSize: tablet
                                  ? FontSizes.k18FontSize
                                  : FontSizes.k14FontSize,
                              color: kColorWhite.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Expanded(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: AppPaddings.combined(
                    horizontal: tablet ? 8 : 6,
                    vertical: 4,
                  ),
                  itemCount: controller.menuAccess.length,
                  separatorBuilder: (context, index) {
                    final menu = controller.menuAccess[index];
                    if (!menu.access) return const SizedBox.shrink();
                    return SizedBox(height: tablet ? 10 : 6);
                  },
                  itemBuilder: (context, index) {
                    final menu = controller.menuAccess[index];
                    if (!menu.access) return const SizedBox.shrink();

                    return _buildMenuItem(context, menu, tablet);
                  },
                ),
              );
            }),

            VersionAndDeveloperInfo(tablet: tablet),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, MenuAccessDm menu, bool tablet) {
    final bool hasSubMenu = menu.subMenu.isNotEmpty;
    final accessibleSubMenus = menu.subMenu
        .where((sub) => sub.subMenuAccess)
        .toList();

    if (hasSubMenu && accessibleSubMenus.isNotEmpty) {
      return Container(
        margin: AppPaddings.combined(horizontal: tablet ? 6 : 4, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(tablet ? 14 : 12),
          color: kColorWhite.withOpacity(0.1),
        ),
        child: ExpansionTile(
          clipBehavior: Clip.none,
          shape: const Border(),
          collapsedShape: const Border(),
          leading: _getMenuIcon(menu.menuName, tablet),
          title: Text(
            menu.menuName,
            style: TextStyles.kMediumOutfit(
              fontSize: tablet ? FontSizes.k22FontSize : FontSizes.k16FontSize,
              color: kColorWhite,
            ),
          ),
          iconColor: kColorWhite,
          collapsedIconColor: kColorWhite,
          tilePadding: AppPaddings.combined(
            horizontal: tablet ? 14 : 10,
            vertical: tablet ? 8 : 6,
          ),
          children: accessibleSubMenus.map((subMenu) {
            return Container(
              margin: EdgeInsets.only(
                left: tablet ? 20 : 16,
                right: tablet ? 8 : 6,
                bottom: tablet ? 6 : 4,
              ),
              child: ListTile(
                leading: Icon(
                  Icons.chevron_right_rounded,
                  color: kColorWhite,
                  size: tablet ? 22 : 18,
                ),
                title: Text(
                  subMenu.subMenuName,
                  style: TextStyles.kRegularOutfit(
                    fontSize: tablet
                        ? FontSizes.k20FontSize
                        : FontSizes.k15FontSize,
                    color: kColorWhite,
                  ),
                ),
                contentPadding: AppPaddings.combined(
                  horizontal: tablet ? 10 : 8,
                  vertical: 2,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _navigateToSubMenu(subMenu);
                },
              ),
            );
          }).toList(),
        ),
      );
    } else {
      return Container(
        margin: AppPaddings.combined(horizontal: tablet ? 6 : 4, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(tablet ? 14 : 12),
          color: kColorWhite.withOpacity(0.1),
        ),
        child: ListTile(
          leading: _getMenuIcon(menu.menuName, tablet),
          title: Text(
            menu.menuName,
            style: TextStyles.kMediumOutfit(
              fontSize: tablet ? FontSizes.k22FontSize : FontSizes.k16FontSize,
              color: kColorWhite,
            ),
          ),
          contentPadding: AppPaddings.combined(
            horizontal: tablet ? 14 : 10,
            vertical: tablet ? 8 : 6,
          ),
          onTap: () {
            Navigator.of(context).pop();
            _navigateToMenu(menu);
          },
        ),
      );
    }
  }

  Widget _getMenuIcon(String menuName, bool tablet) {
    IconData iconData;

    switch (menuName.toLowerCase()) {
      case 'dashboard':
        iconData = Icons.dashboard_rounded;
        break;
      case 'projects':
        iconData = Icons.business_center_rounded;
        break;
      case 'entry':
        iconData = Icons.edit_note_rounded;
        break;
      case 'reports':
        iconData = Icons.assessment_rounded;
        break;
      case 'materials':
        iconData = Icons.inventory_2_rounded;
        break;
      case 'workers':
        iconData = Icons.people_rounded;
        break;
      case 'payments':
        iconData = Icons.payment_rounded;
        break;
      case 'user settings':
        iconData = Icons.settings_rounded;
        break;
      default:
        iconData = Icons.menu_book_rounded;
    }

    return Container(
      padding: EdgeInsets.all(tablet ? 10 : 8),
      decoration: BoxDecoration(
        color: kColorWhite.withOpacity(0.15),
        borderRadius: BorderRadius.circular(tablet ? 10 : 8),
        border: Border.all(color: kColorWhite.withOpacity(0.3), width: 1),
      ),
      child: Icon(iconData, color: kColorWhite, size: tablet ? 22 : 18),
    );
  }

  void _navigateToMenu(MenuAccessDm menu) {
    switch (menu.menuName.toLowerCase()) {
      case 'dashboard':
        // Already on home screen
        break;
      case 'projects':
        // Get.to(() => ProjectsScreen());
        break;
      case 'entry':
        if (menu.subMenu.isNotEmpty) {
          final firstAccessible = menu.subMenu.firstWhere(
            (sub) => sub.subMenuAccess,
            orElse: () => menu.subMenu.first,
          );
          _navigateToSubMenu(firstAccessible);
        }
        break;
      case 'reports':
        if (menu.subMenu.isNotEmpty) {
          final firstAccessible = menu.subMenu.firstWhere(
            (sub) => sub.subMenuAccess,
            orElse: () => menu.subMenu.first,
          );
          _navigateToSubMenu(firstAccessible);
        }
        break;
      case 'user settings':
        if (menu.subMenu.isNotEmpty) {
          final firstAccessible = menu.subMenu.firstWhere(
            (sub) => sub.subMenuAccess,
            orElse: () => menu.subMenu.first,
          );
          _navigateToSubMenu(firstAccessible);
        }
        break;
      default:
    }
  }

  void _navigateToSubMenu(SubMenuAccessDm subMenu) {
    switch (subMenu.subMenuName.toLowerCase()) {
      // Add your navigation cases here based on your app's features
      case 'project entry':
        // Get.to(() => ProjectEntryScreen());
        break;
      case 'material entry':
        // Get.to(() => MaterialEntryScreen());
        break;
      case 'worker entry':
        // Get.to(() => WorkerEntryScreen());
        break;
      case 'payment entry':
        // Get.to(() => PaymentEntryScreen());
        break;
      case 'project report':
        // Get.to(() => ProjectReportScreen());
        break;
      case 'user management':
        // Get.to(() => UserManagementScreen());
        break;
      default:
    }
  }
}
