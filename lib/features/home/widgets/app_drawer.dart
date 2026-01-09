// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/constants/image_constants.dart';
import 'package:shivay_construction/features/home/controllers/home_controller.dart';
import 'package:shivay_construction/features/home/widgets/version_and_developer_info.dart';
import 'package:shivay_construction/features/category_master/screens/category_master_screen.dart';
import 'package:shivay_construction/features/department_master/screens/department_master_screen.dart';
import 'package:shivay_construction/features/godown_master/screens/godown_master_screen.dart';
import 'package:shivay_construction/features/indent_entry/screens/indents_screen.dart';
import 'package:shivay_construction/features/item_group_master/screens/item_group_master_screen.dart';
import 'package:shivay_construction/features/item_sub_group_master/screens/item_sub_group_master_screen.dart';
import 'package:shivay_construction/features/item_master/screens/item_master_list_screen.dart';
import 'package:shivay_construction/features/opening_stock_entry/screens/opening_stocks_screen.dart';
import 'package:shivay_construction/features/party_masters/screens/party_master_list_screen.dart';
import 'package:shivay_construction/features/purchase_order_entry/screens/purchase_order_list_screen.dart';
import 'package:shivay_construction/features/repair_entry/screens/repair_issue_list_screen.dart';
import 'package:shivay_construction/features/site_master/screens/site_master_list_screen.dart';
import 'package:shivay_construction/features/site_transfer/screens/site_transfer_screen.dart';
import 'package:shivay_construction/features/user_settings/models/user_access_dm.dart';
import 'package:shivay_construction/features/user_settings/screens/unauthorised_users_screen.dart';
import 'package:shivay_construction/features/user_settings/screens/users_screen.dart';
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
      backgroundColor: kColorWhite,
      width: web
          ? 320
          : tablet
          ? 0.5.screenWidth
          : 0.75.screenWidth,
      child: SafeArea(
        child: Column(
          children: [
            tablet ? AppSpaces.v20 : AppSpaces.v16,

            Container(
              margin: AppPaddings.combined(
                horizontal: tablet ? 16 : 12,
                vertical: tablet ? 12 : 8,
              ),
              padding: AppPaddings.combined(
                horizontal: tablet ? 20 : 16,
                vertical: tablet ? 16 : 14,
              ),
              decoration: BoxDecoration(
                color: kColorWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: kColorPrimary.withOpacity(0.2),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: kColorPrimary.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    height: tablet ? 60 : 48,
                    width: tablet ? 60 : 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [kColorPrimary, kColorPrimary.withOpacity(0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.all(tablet ? 10 : 8),
                    child: Image.asset(
                      kImagelogo,
                      fit: BoxFit.contain,
                      color: kColorWhite,
                    ),
                  ),

                  tablet ? AppSpaces.h14 : AppSpaces.h10,

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Shivay Construction',
                          style: TextStyles.kBoldOutfit(
                            fontSize: tablet
                                ? FontSizes.k22FontSize
                                : FontSizes.k18FontSize,
                            color: kColorPrimary,
                          ),
                        ),
                        AppSpaces.v2,
                        Text(
                          'Mobile App',
                          style: TextStyles.kRegularOutfit(
                            fontSize: tablet
                                ? FontSizes.k14FontSize
                                : FontSizes.k12FontSize,
                            color: kColorSecondary,
                          ),
                        ),
                      ],
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
                  child: RefreshIndicator(
                    onRefresh: controller.refreshMenuData,
                    color: kColorPrimary,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: 0.6.screenHeight,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.menu_book_outlined,
                                size: tablet ? 64 : 48,
                                color: kColorPrimary.withOpacity(0.3),
                              ),
                              tablet ? AppSpaces.v16 : AppSpaces.v12,
                              Text(
                                'No menu data available',
                                style: TextStyles.kMediumOutfit(
                                  fontSize: tablet
                                      ? FontSizes.k22FontSize
                                      : FontSizes.k18FontSize,
                                  color: kColorPrimary,
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
                                    color: kColorSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }

              return Expanded(
                child: RefreshIndicator(
                  onRefresh: controller.refreshMenuData,
                  color: kColorPrimary,
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: AppPaddings.combined(
                      horizontal: tablet ? 12 : 8,
                      vertical: 4,
                    ),
                    itemCount: accessibleMenus.length,
                    separatorBuilder: (context, index) {
                      return tablet ? AppSpaces.v8 : AppSpaces.v6;
                    },
                    itemBuilder: (context, index) {
                      final menu = accessibleMenus[index];
                      return _buildMenuItem(context, menu, tablet);
                    },
                  ),
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
        margin: AppPaddings.combined(horizontal: tablet ? 6 : 4, vertical: 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(tablet ? 14 : 12),
          color: kColorPrimary.withOpacity(0.05),
          border: Border.all(color: kColorPrimary.withOpacity(0.1), width: 1),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            clipBehavior: Clip.none,
            shape: const Border(),
            collapsedShape: const Border(),
            leading: _getMenuIcon(menu.menuName, tablet),
            title: Text(
              menu.menuName,
              style: TextStyles.kMediumOutfit(
                fontSize: tablet
                    ? FontSizes.k22FontSize
                    : FontSizes.k16FontSize,
                color: kColorPrimary,
              ),
            ),
            iconColor: kColorPrimary,
            collapsedIconColor: kColorPrimary,
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
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(tablet ? 10 : 8),
                  color: kColorWhite,
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.chevron_right_rounded,
                    color: kColorSecondary,
                    size: tablet ? 22 : 18,
                  ),
                  title: Text(
                    subMenu.subMenuName,
                    style: TextStyles.kRegularOutfit(
                      fontSize: tablet
                          ? FontSizes.k20FontSize
                          : FontSizes.k15FontSize,
                      color: kColorTextPrimary,
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
        ),
      );
    } else {
      return Container(
        margin: AppPaddings.combined(horizontal: tablet ? 6 : 4, vertical: 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(tablet ? 14 : 12),
          color: kColorPrimary.withOpacity(0.05),
          border: Border.all(color: kColorPrimary.withOpacity(0.1), width: 1),
        ),
        child: ListTile(
          leading: _getMenuIcon(menu.menuName, tablet),
          title: Text(
            menu.menuName,
            style: TextStyles.kMediumOutfit(
              fontSize: tablet ? FontSizes.k22FontSize : FontSizes.k16FontSize,
              color: kColorPrimary,
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
        color: kColorPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(tablet ? 10 : 8),
        border: Border.all(color: kColorPrimary.withOpacity(0.2), width: 1),
      ),
      child: Icon(iconData, color: kColorPrimary, size: tablet ? 22 : 18),
    );
  }

  void _navigateToMenu(MenuAccessDm menu) {
    switch (menu.menuName.toLowerCase()) {
      case 'dashboard':
        Get.back();
        controller.refreshMenuData();
        break;
      case 'masters':
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
      case 'user authorization':
        Get.to(() => UnauthorisedUsersScreen());
        break;

      case 'user management':
        Get.to(() => UsersScreen(fromWhere: 'M'));
        break;
      case 'user rights':
        Get.to(() => UsersScreen(fromWhere: 'R'));
        break;
      case 'department master':
        Get.to(() => DepartmentMasterScreen());
        break;
      case 'category master':
        Get.to(() => CategoryMasterScreen());
        break;
      case 'vendor master':
        Get.to(() => PartyMasterListScreen());
        break;
      case 'site master':
        Get.to(() => SiteMasterListScreen());
        break;
      case 'item master':
        Get.to(() => ItemMasterListScreen());
        break;
      case 'item group master':
        Get.to(() => ItemGroupMasterScreen());
        break;
      case 'item sub group master':
        Get.to(() => ItemSubGroupMasterScreen());
        break;
      case 'godown master':
        Get.to(() => GodownMasterScreen());
        break;
      case 'opening stock entry':
        Get.to(() => OpeningStocksScreen());
        break;
      case 'indent entry':
        Get.to(() => IndentsScreen());
        break;
      case 'purchase order entry':
        Get.to(() => PurchaseOrderListScreen());
        break;
      case 'GRN entry':
        break;
      case 'site transfer entry':
        Get.to(() => SiteTransferScreen());
        break;
      case 'repair entry':
        Get.to(() => RepairIssueListScreen());
        break;
      default:
    }
  }
}
