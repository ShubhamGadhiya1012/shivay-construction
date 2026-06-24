import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/company_master/screens/company_master_list_screen.dart';
import 'package:shivay_construction/features/dlr_entry/screens/dlr_list_screen.dart';
import 'package:shivay_construction/features/grn_entry/screens/grns_screen.dart';
import 'package:shivay_construction/features/home/controllers/home_controller.dart';
import 'package:shivay_construction/features/home/widgets/app_drawer.dart';
import 'package:shivay_construction/features/indent_entry/screens/indents_screen.dart';
import 'package:shivay_construction/features/issue_entry/screens/issues_screen.dart';
import 'package:shivay_construction/features/item_help/screens/item_help_search_screen.dart';
import 'package:shivay_construction/features/category_master/screens/category_master_screen.dart';
import 'package:shivay_construction/features/department_master/screens/department_master_screen.dart';
import 'package:shivay_construction/features/godown_master/screens/godown_master_screen.dart';
import 'package:shivay_construction/features/hsn_master/screens/hsn_master_list_screen.dart';
import 'package:shivay_construction/features/item_group_master/screens/item_group_master_screen.dart';
import 'package:shivay_construction/features/item_master/screens/item_master_list_screen.dart';
import 'package:shivay_construction/features/item_sub_group_master/screens/item_sub_group_master_screen.dart';
import 'package:shivay_construction/features/notification_master/noifications/screens/notifications_screen.dart';
import 'package:shivay_construction/features/opening_stock_entry/screens/opening_stocks_screen.dart';
import 'package:shivay_construction/features/party_masters/screens/party_master_list_screen.dart';
import 'package:shivay_construction/features/profile/screens/profile_screen.dart';
import 'package:shivay_construction/features/purchase_order_entry/screens/purchase_order_list_screen.dart';
import 'package:shivay_construction/features/repair_entry/screens/repair_issue_list_screen.dart';
import 'package:shivay_construction/features/reports/screens/dlr_report_screen.dart';
import 'package:shivay_construction/features/reports/screens/grn_report_screen.dart';
import 'package:shivay_construction/features/reports/screens/indent_report_screen.dart';
import 'package:shivay_construction/features/reports/screens/issue_repair_report_screen.dart';
import 'package:shivay_construction/features/reports/screens/issue_report_screen.dart';
import 'package:shivay_construction/features/reports/screens/opening_stock_report_screen.dart';
import 'package:shivay_construction/features/reports/screens/purchase_order_report_screen.dart';
import 'package:shivay_construction/features/reports/screens/site_transfer_report_screen.dart';
import 'package:shivay_construction/features/site_master/screens/site_master_list_screen.dart';
import 'package:shivay_construction/features/site_transfer/screens/site_transfer_list_screen.dart';
import 'package:shivay_construction/features/stock_reports/screens/stock_report_screen.dart';
import 'package:shivay_construction/features/tax_master/screens/tax_master_list_screen.dart';
import 'package:shivay_construction/features/term_master/screens/term_master_list_screen.dart';
import 'package:shivay_construction/features/user_settings/screens/unauthorised_users_screen.dart';
import 'package:shivay_construction/features/user_settings/screens/users_screen.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_loading_overlay.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final HomeController _controller = Get.put(HomeController());

  static const List<Map<String, dynamic>> _sections = [
    {
      'title': 'Entry',
      'icon': Icons.edit_note_rounded,
      'menuName': 'entry',
      'items': [
        {
          'label': 'Opening Stock\nEntry',
          'submenu': 'opening stock entry',
          'icon': Icons.inventory_2_rounded,
        },
        {
          'label': 'Indent\nEntry',
          'submenu': 'indent entry',
          'icon': Icons.description_rounded,
        },
        {
          'label': 'Purchase Order\nEntry',
          'submenu': 'purchase order entry',
          'icon': Icons.shopping_cart_rounded,
        },
        {
          'label': 'GRN\nEntry',
          'submenu': 'grn entry',
          'icon': Icons.receipt_long_rounded,
        },
        {
          'label': 'Issue\nEntry',
          'submenu': 'issue entry',
          'icon': Icons.output_rounded,
        },
        {
          'label': 'Site Transfer\nEntry',
          'submenu': 'site transfer entry',
          'icon': Icons.swap_horiz_rounded,
        },
        {
          'label': 'Repair\nEntry',
          'submenu': 'repair entry',
          'icon': Icons.build_rounded,
        },
        {
          'label': 'DLR\nEntry',
          'submenu': 'dlr entry',
          'icon': Icons.list_alt_rounded,
        },
      ],
    },
    {
      'title': 'Reports',
      'icon': Icons.assessment_rounded,
      'menuName': 'reports',
      'items': [
        {
          'label': 'Opening Stock\nReport',
          'submenu': 'opening stock report',
          'icon': Icons.inventory_rounded,
        },
        {
          'label': 'Indent\nReport',
          'submenu': 'indent report',
          'icon': Icons.bar_chart_rounded,
        },
        {
          'label': 'Purchase Order\nReport',
          'submenu': 'purchase order report',
          'icon': Icons.assessment_rounded,
        },
        {
          'label': 'GRN\nReport',
          'submenu': 'grn report',
          'icon': Icons.analytics_rounded,
        },
        {
          'label': 'Issue\nReport',
          'submenu': 'issue report',
          'icon': Icons.summarize_rounded,
        },
        {
          'label': 'Site Transfer\nReport',
          'submenu': 'site transfer report',
          'icon': Icons.compare_arrows_rounded,
        },
        {
          'label': 'Issue Repair\nReport',
          'submenu': 'issue repair report',
          'icon': Icons.handyman_rounded,
        },
        {
          'label': 'DLR\nReport',
          'submenu': 'dlr report',
          'icon': Icons.feed_rounded,
        },
      ],
    },
    {
      'title': 'Stock Reports',
      'icon': Icons.stacked_bar_chart_rounded,
      'menuName': 'stock reports',
      'items': [
        {
          'label': 'Stock\nStatement',
          'submenu': 'stock statement report',
          'icon': Icons.summarize_rounded,
        },
        {
          'label': 'FIFO\nValuation',
          'submenu': 'fifo - stock valuation',
          'icon': Icons.trending_up_rounded,
        },
        {
          'label': 'LIFO\nValuation',
          'submenu': 'lifo - stock valuation',
          'icon': Icons.trending_down_rounded,
        },
        {
          'label': 'LP\nValuation',
          'submenu': 'lp - stock valuation',
          'icon': Icons.price_change_rounded,
        },
        {
          'label': 'Stock\nLedger',
          'submenu': 'stock ledger',
          'icon': Icons.book_rounded,
        },
        {
          'label': 'Group\nStock',
          'submenu': 'group stock report',
          'icon': Icons.view_module_rounded,
        },
        {
          'label': 'Site\nStock',
          'submenu': 'site stock report',
          'icon': Icons.location_on_rounded,
        },
      ],
    },
    {
      'title': 'Masters',
      'icon': Icons.folder_rounded,
      'menuName': 'masters',
      'items': [
        {
          'label': 'Department\nMaster',
          'submenu': 'department master',
          'icon': Icons.apartment_rounded,
        },
        {
          'label': 'Category\nMaster',
          'submenu': 'category master',
          'icon': Icons.category_rounded,
        },
        {
          'label': 'Vendor\nMaster',
          'submenu': 'vendor master',
          'icon': Icons.store_rounded,
        },
        {
          'label': 'Site\nMaster',
          'submenu': 'site master',
          'icon': Icons.location_city_rounded,
        },
        {
          'label': 'Item\nMaster',
          'submenu': 'item master',
          'icon': Icons.inventory_2_outlined,
        },
        {
          'label': 'Item Group\nMaster',
          'submenu': 'item group master',
          'icon': Icons.view_list_rounded,
        },
        {
          'label': 'Item Sub Group\nMaster',
          'submenu': 'item sub group master',
          'icon': Icons.view_agenda_rounded,
        },
        {
          'label': 'Company\nMaster',
          'submenu': 'company master',
          'icon': Icons.business_rounded,
        },
        {
          'label': 'Head\nMaster',
          'submenu': 'head master',
          'icon': Icons.warehouse_rounded,
        },
        {
          'label': 'HSN\nMaster',
          'submenu': 'hsn master',
          'icon': Icons.tag_rounded,
        },
        {
          'label': 'Tax\nMaster',
          'submenu': 'tax master',
          'icon': Icons.percent_rounded,
        },
        {
          'label': 'Terms\nMaster',
          'submenu': 'terms master',
          'icon': Icons.gavel_rounded,
        },
      ],
    },
    {
      'title': 'User Settings',
      'icon': Icons.manage_accounts_rounded,
      'menuName': 'user settings',
      'items': [
        {
          'label': 'User\nAuthorization',
          'submenu': 'user authorization',
          'icon': Icons.verified_user_rounded,
        },
        {
          'label': 'User\nManagement',
          'submenu': 'user management',
          'icon': Icons.people_rounded,
        },
        {
          'label': 'User\nRights',
          'submenu': 'user rights',
          'icon': Icons.admin_panel_settings_rounded,
        },
        {
          'label': 'Notification\nMaster',
          'submenu': 'notification master',
          'icon': Icons.notifications_rounded,
        },
      ],
    },
    {
      'title': 'Other',
      'icon': Icons.apps_rounded,
      'menuName': 'item help',
      'items': [
        {
          'label': 'Item\nHelp',
          'submenu': 'item help',
          'icon': Icons.help_outline_rounded,
        },
      ],
    },
  ];

  List<Map<String, dynamic>> _getAccessibleItems(
    Map<String, dynamic> section,
    HomeController controller,
  ) {
    final String menuName = section['menuName'] as String;
    final List items = section['items'] as List;

    if (menuName == 'item help') {
      if (!controller.hasAccessToMenu('Item Help')) return [];
      return items.cast<Map<String, dynamic>>();
    }

    if (!controller.hasAccessToMenu(menuName)) return [];

    return items
        .where((item) {
          final String key = (item['submenu'] as String).toLowerCase();
          return controller.menuAccess.any(
            (menu) =>
                menu.menuName.toLowerCase() == menuName &&
                menu.subMenu.any(
                  (sub) =>
                      sub.subMenuName.toLowerCase() == key && sub.subMenuAccess,
                ),
          );
        })
        .cast<Map<String, dynamic>>()
        .toList();
  }

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
                        builder: (ctx) => IconButton(
                          icon: Icon(
                            Icons.menu_rounded,
                            color: kColorPrimary,
                            size: tablet ? 32 : 26,
                          ),
                          onPressed: () => Scaffold.of(ctx).openDrawer(),
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
                        onPressed: () => Get.to(() => ProfileScreen()),
                      ),
                    ],
                  ),
                ),
                tablet ? AppSpaces.v20 : AppSpaces.v10,

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => CarouselSlider(
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
                              onPageChanged: (index, _) =>
                                  _controller.updateBannerIndex(index),
                            ),
                            items: _controller.bannerImages.map((imagePath) {
                              return Builder(
                                builder: (BuildContext ctx) => Container(
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
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        tablet ? AppSpaces.v12 : AppSpaces.v8,

                        Obx(
                          () => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: _controller.bannerImages
                                .asMap()
                                .entries
                                .map((entry) {
                                  final bool active =
                                      _controller.currentBannerIndex.value ==
                                      entry.key;
                                  return Container(
                                    width: active
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
                                      color: active
                                          ? kColorPrimary
                                          : kColorPrimary.withOpacity(0.3),
                                    ),
                                  );
                                })
                                .toList(),
                          ),
                        ),
                        tablet ? AppSpaces.v30 : AppSpaces.v16,

                        Obx(() {
                          final visibleSections = _sections
                              .map(
                                (sec) => {
                                  'section': sec,
                                  'items': _getAccessibleItems(
                                    sec,
                                    _controller,
                                  ),
                                },
                              )
                              .where((s) => (s['items'] as List).isNotEmpty)
                              .toList();

                          if (visibleSections.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: visibleSections.map((s) {
                              return _buildSection(
                                section: s['section'] as Map<String, dynamic>,
                                items: s['items'] as List<Map<String, dynamic>>,
                                tablet: tablet,
                              );
                            }).toList(),
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

  Widget _buildSection({
    required Map<String, dynamic> section,
    required List<Map<String, dynamic>> items,
    required bool tablet,
  }) {
    final int crossAxisCount = tablet ? 4 : 3;
    final double spacing = tablet ? 12.0 : 8.0;

    return Padding(
      padding: AppPaddings.combined(horizontal: tablet ? 16 : 12, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(tablet ? 8 : 6),
                decoration: BoxDecoration(
                  color: kColorPrimary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(tablet ? 10 : 8),
                ),
                child: Icon(
                  section['icon'] as IconData,
                  color: kColorPrimary,
                  size: tablet ? 22 : 18,
                ),
              ),
              SizedBox(width: tablet ? 10 : 8),
              Text(
                section['title'] as String,
                style: TextStyles.kSemiBoldOutfit(
                  fontSize: tablet
                      ? FontSizes.k22FontSize
                      : FontSizes.k18FontSize,
                  color: kColorPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: tablet ? 14 : 10),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              childAspectRatio: tablet ? 1.05 : 1.0,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildMenuCard(
                title: item['label'] as String,
                icon: item['icon'] as IconData,
                submenu: item['submenu'] as String,
                tablet: tablet,
              );
            },
          ),
          SizedBox(height: tablet ? 24 : 16),
          Divider(color: kColorPrimary.withOpacity(0.1), thickness: 1),
          SizedBox(height: tablet ? 20 : 14),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required IconData icon,
    required String submenu,
    required bool tablet,
  }) {
    return InkWell(
      onTap: () => _navigateToSubmenu(submenu),
      borderRadius: BorderRadius.circular(tablet ? 14 : 10),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              kColorPrimary.withOpacity(0.09),
              kColorPrimary.withOpacity(0.04),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(tablet ? 14 : 10),
          border: Border.all(color: kColorPrimary.withOpacity(0.18), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(tablet ? 10 : 8),
              decoration: BoxDecoration(
                color: kColorPrimary.withOpacity(0.13),
                borderRadius: BorderRadius.circular(tablet ? 10 : 8),
              ),
              child: Icon(icon, color: kColorPrimary, size: tablet ? 26 : 22),
            ),
            SizedBox(height: tablet ? 8 : 6),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: tablet ? 6 : 4),
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyles.kMediumOutfit(
                  fontSize: tablet
                      ? FontSizes.k12FontSize
                      : FontSizes.k10FontSize,
                  color: kColorTextPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToSubmenu(String submenuName) {
    switch (submenuName.toLowerCase()) {
      case 'opening stock entry':
        Get.to(() => OpeningStocksScreen());
        break;
      case 'indent entry':
        Get.to(() => IndentsScreen());
        break;
      case 'purchase order entry':
        Get.to(() => PurchaseOrderListScreen());
        break;
      case 'grn entry':
        Get.to(() => GrnsScreen());
        break;
      case 'issue entry':
        Get.to(() => IssuesScreen());
        break;
      case 'site transfer entry':
        Get.to(() => SiteTransferListScreen());
        break;
      case 'repair entry':
        Get.to(() => RepairIssueListScreen());
        break;
      case 'dlr entry':
        Get.to(() => DlrListScreen());
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
      case 'issue report':
        Get.to(() => IssueReportScreen());
        break;
      case 'site transfer report':
        Get.to(() => SiteTransferReportScreen());
        break;
      case 'issue repair report':
        Get.to(() => IssueRepairReportScreen());
        break;
      case 'dlr report':
        Get.to(() => DlrReportScreen());
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
      case 'fifo - stock valuation':
        Get.to(
          () => const StockReportScreen(
            reportName: 'FIFO',
            reportTitle: 'FIFO - Stock Valuation',
            rType: 'STATEMENT',
            method: 'FIFO',
          ),
        );
        break;
      case 'lifo - stock valuation':
        Get.to(
          () => const StockReportScreen(
            reportName: 'LIFO',
            reportTitle: 'LIFO - Stock Valuation',
            rType: 'STATEMENT',
            method: 'LIFO',
          ),
        );
        break;
      case 'lp - stock valuation':
        Get.to(
          () => const StockReportScreen(
            reportName: 'LP',
            reportTitle: 'LP - Stock Valuation',
            rType: 'STATEMENT',
            method: 'LP',
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
      case 'company master':
        Get.to(() => CompanyMasterListScreen());
        break;
      case 'head master':
        Get.to(() => GodownMasterScreen());
        break;
      case 'hsn master':
        Get.to(() => HsnMasterListScreen());
        break;
      case 'tax master':
        Get.to(() => TaxMasterListScreen());
        break;
      case 'terms master':
        Get.to(() => TermMasterListScreen());
        break;

      case 'user authorization':
        Get.to(() => UnauthorisedUsersScreen());
        break;
      case 'user management':
        Get.to(() => UsersScreen(fromWhere: 'M'));
        break;
      case 'user rights':
        Get.to(() => UsersScreen(fromWhere: 'R'));
        break;
      case 'notification master':
        Get.to(() => NotificationsScreen());
        break;

      case 'item help':
        Get.to(() => ItemHelpSearchScreen());
        break;
    }
  }
}
