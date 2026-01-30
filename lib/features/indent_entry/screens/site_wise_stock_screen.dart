import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/indent_entry/controllers/site_wise_stock_controller.dart';
import 'package:shivay_construction/features/indent_entry/widgets/site_wise_stock_card.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_appbar.dart';
import 'package:shivay_construction/widgets/app_loading_overlay.dart';

class SiteWiseStockScreen extends StatefulWidget {
  final String? iCode;

  const SiteWiseStockScreen({super.key, this.iCode});

  @override
  State<SiteWiseStockScreen> createState() => _SiteWiseStockScreenState();
}

class _SiteWiseStockScreenState extends State<SiteWiseStockScreen> {
  final SiteWiseStockController _controller = Get.put(
    SiteWiseStockController(),
  );

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() {
    if (widget.iCode != null && widget.iCode!.isNotEmpty) {
      _controller.getSiteWiseStock(iCode: widget.iCode);
    } else {
      _controller.getSiteWiseStock();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);

    return Stack(
      children: [
        GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            appBar: AppAppbar(
              title: 'Site Wise Stock',
              leading: IconButton(
                onPressed: () => Get.back(),
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: tablet ? 25 : 20,
                  color: kColorPrimary,
                ),
              ),
            ),
            body: RefreshIndicator(
              elevation: 0,
              backgroundColor: kColorWhite,
              color: kColorPrimary,
              onRefresh: () =>
                  _controller.getSiteWiseStock(iCode: widget.iCode),
              child: Padding(
                padding: tablet
                    ? AppPaddings.combined(horizontal: 24, vertical: 12)
                    : AppPaddings.p12,
                child: Column(
                  children: [
                    // Item Summary Card
                    Obx(() {
                      if (_controller.isSingleItemMode.value &&
                          _controller.itemName.value.isNotEmpty) {
                        return Container(
                          margin: tablet
                              ? AppPaddings.custom(bottom: 12)
                              : AppPaddings.custom(bottom: 10),
                          padding: tablet
                              ? AppPaddings.combined(
                                  horizontal: 16,
                                  vertical: 14,
                                )
                              : AppPaddings.combined(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                kColorPrimary.withOpacity(0.1),
                                kColorPrimary.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: kColorPrimary.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: tablet
                                    ? AppPaddings.p10
                                    : AppPaddings.p8,
                                decoration: BoxDecoration(
                                  color: kColorPrimary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.inventory_2,
                                  color: kColorWhite,
                                  size: tablet ? 22 : 20,
                                ),
                              ),
                              tablet ? AppSpaces.h12 : AppSpaces.h10,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _controller.itemName.value,
                                      style: TextStyles.kBoldOutfit(
                                        fontSize: tablet
                                            ? FontSizes.k16FontSize
                                            : FontSizes.k14FontSize,
                                        color: kColorPrimary,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    AppSpaces.v4,
                                    Text(
                                      _controller.itemUnit.value,
                                      style: TextStyles.kRegularOutfit(
                                        fontSize: tablet
                                            ? FontSizes.k12FontSize
                                            : FontSizes.k10FontSize,
                                        color: kColorDarkGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              tablet ? AppSpaces.h12 : AppSpaces.h10,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Total Stock',
                                    style: TextStyles.kRegularOutfit(
                                      fontSize: tablet
                                          ? FontSizes.k12FontSize
                                          : FontSizes.k10FontSize,
                                      color: kColorDarkGrey,
                                    ),
                                  ),
                                  AppSpaces.v4,
                                  Text(
                                    '${_controller.totalItemStock.value.toStringAsFixed(2)} ${_controller.itemUnit.value}',
                                    style: TextStyles.kBoldOutfit(
                                      fontSize: tablet
                                          ? FontSizes.k18FontSize
                                          : FontSizes.k16FontSize,
                                      color: kColorGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),

                    // Site Stock List
                    Expanded(
                      child: Obx(() {
                        if (_controller.groupedStockList.isEmpty &&
                            !_controller.isLoading.value) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: tablet ? 80 : 64,
                                  color: kColorLightGrey,
                                ),
                                tablet ? AppSpaces.v16 : AppSpaces.v12,
                                Text(
                                  'No stock data found',
                                  style: TextStyles.kMediumOutfit(
                                    fontSize: tablet
                                        ? FontSizes.k18FontSize
                                        : FontSizes.k16FontSize,
                                    color: kColorDarkGrey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: _controller.groupedStockList.length,
                          itemBuilder: (context, siteIndex) {
                            final siteGroup =
                                _controller.groupedStockList[siteIndex];

                            return Obx(() {
                              final isExpanded = _controller.expandedSiteIndices
                                  .contains(siteIndex);

                              return SiteStockCard(
                                siteGroup: siteGroup,
                                siteIndex: siteIndex,
                                isExpanded: isExpanded,
                                onTap: () =>
                                    _controller.toggleSiteExpansion(siteIndex),
                                isSingleItemMode:
                                    _controller.isSingleItemMode.value,
                                tablet: tablet,
                              );
                            });
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Obx(() => AppLoadingOverlay(isLoading: _controller.isLoading.value)),
      ],
    );
  }
}
