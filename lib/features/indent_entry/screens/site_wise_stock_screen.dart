import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/indent_entry/controllers/site_wise_stock_controller.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_appbar.dart';
import 'package:shivay_construction/widgets/app_loading_overlay.dart';
import 'package:shivay_construction/widgets/app_text_form_field.dart';

class SiteWiseStockScreen extends StatelessWidget {
  SiteWiseStockScreen({super.key});

  final SiteWiseStockController _controller = Get.put(
    SiteWiseStockController(),
  );

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
              onRefresh: () => _controller.getSiteWiseStock(),
              child: Padding(
                padding: tablet
                    ? AppPaddings.combined(horizontal: 24, vertical: 12)
                    : AppPaddings.p12,
                child: Column(
                  children: [
                    AppTextFormField(
                      controller: _controller.searchController,
                      hintText: 'Search by Site, Item name',
                      onChanged: (query) {
                        _controller.searchQuery.value = query;
                      },
                    ),
                    tablet ? AppSpaces.v16 : AppSpaces.v12,
                    Expanded(
                      child: Obx(() {
                        if (_controller.filteredStockList.isEmpty &&
                            !_controller.isLoading.value) {
                          return Center(
                            child: Text(
                              'No stock data found',
                              style: TextStyles.kMediumOutfit(
                                fontSize: tablet
                                    ? FontSizes.k18FontSize
                                    : FontSizes.k16FontSize,
                                color: kColorDarkGrey,
                              ),
                            ),
                          );
                        }

                        final groupedStock = _controller.groupedBySite;

                        return ListView.builder(
                          itemCount: groupedStock.length,
                          itemBuilder: (context, index) {
                            final siteCode = groupedStock.keys.elementAt(index);
                            final siteStocks = groupedStock[siteCode]!;
                            final siteName =
                                siteStocks.first.siteName.isNotEmpty
                                ? siteStocks.first.siteName
                                : 'Unknown Site';

                            return Container(
                              margin: tablet
                                  ? AppPaddings.custom(bottom: 16)
                                  : AppPaddings.custom(bottom: 12),
                              decoration: BoxDecoration(
                                color: kColorWhite,
                                borderRadius: BorderRadius.circular(
                                  tablet ? 16 : 12,
                                ),
                                border: Border.all(
                                  color: kColorLightGrey.withOpacity(0.3),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: kColorPrimary.withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: tablet
                                        ? AppPaddings.combined(
                                            horizontal: 18,
                                            vertical: 14,
                                          )
                                        : AppPaddings.combined(
                                            horizontal: 14,
                                            vertical: 12,
                                          ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          kColorPrimary.withOpacity(0.1),
                                          kColorPrimary.withOpacity(0.05),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(
                                          tablet ? 16 : 12,
                                        ),
                                        topRight: Radius.circular(
                                          tablet ? 16 : 12,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: tablet
                                              ? AppPaddings.p10
                                              : AppPaddings.p8,
                                          decoration: BoxDecoration(
                                            color: kColorPrimary.withOpacity(
                                              0.2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.location_on_rounded,
                                            color: kColorPrimary,
                                            size: tablet ? 24 : 20,
                                          ),
                                        ),
                                        tablet ? AppSpaces.h12 : AppSpaces.h10,
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                siteName,
                                                style: TextStyles.kBoldOutfit(
                                                  fontSize: tablet
                                                      ? FontSizes.k18FontSize
                                                      : FontSizes.k16FontSize,
                                                  color: kColorPrimary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: tablet
                                              ? AppPaddings.combined(
                                                  horizontal: 12,
                                                  vertical: 6,
                                                )
                                              : AppPaddings.combined(
                                                  horizontal: 10,
                                                  vertical: 5,
                                                ),
                                          decoration: BoxDecoration(
                                            color: kColorPrimary,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            '${siteStocks.length} Items',
                                            style: TextStyles.kSemiBoldOutfit(
                                              fontSize: tablet
                                                  ? FontSizes.k14FontSize
                                                  : FontSizes.k12FontSize,
                                              color: kColorWhite,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    padding: tablet
                                        ? AppPaddings.combined(
                                            horizontal: 18,
                                            vertical: 14,
                                          )
                                        : AppPaddings.combined(
                                            horizontal: 14,
                                            vertical: 12,
                                          ),
                                    itemCount: siteStocks.length,
                                    separatorBuilder: (_, __) => Padding(
                                      padding: AppPaddings.pv8,
                                      child: Divider(
                                        height: 1,
                                        color: kColorLightGrey.withOpacity(0.5),
                                      ),
                                    ),
                                    itemBuilder: (context, stockIndex) {
                                      final stock = siteStocks[stockIndex];
                                      final isLowStock = stock.stockQty < 10;
                                      final isNegative = stock.stockQty < 0;

                                      return Container(
                                        padding: tablet
                                            ? AppPaddings.p12
                                            : AppPaddings.p10,
                                        decoration: BoxDecoration(
                                          color: isNegative
                                              ? kColorRed.withOpacity(0.05)
                                              : isLowStock
                                              ? kColorSecondary.withOpacity(
                                                  0.05,
                                                )
                                              : kColorGreen.withOpacity(0.05),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: isNegative
                                                ? kColorRed.withOpacity(0.2)
                                                : isLowStock
                                                ? kColorSecondary.withOpacity(
                                                    0.2,
                                                  )
                                                : kColorGreen.withOpacity(0.2),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    stock.iName.isNotEmpty
                                                        ? stock.iName
                                                        : 'Unknown Item',
                                                    style:
                                                        TextStyles.kSemiBoldOutfit(
                                                          fontSize: tablet
                                                              ? FontSizes
                                                                    .k15FontSize
                                                              : FontSizes
                                                                    .k14FontSize,
                                                          color:
                                                              kColorTextPrimary,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            AppSpaces.h12,
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  stock.stockQty
                                                      .toStringAsFixed(2),
                                                  style: TextStyles.kBoldOutfit(
                                                    fontSize: tablet
                                                        ? FontSizes.k18FontSize
                                                        : FontSizes.k16FontSize,
                                                    color: isNegative
                                                        ? kColorRed
                                                        : isLowStock
                                                        ? kColorSecondary
                                                        : kColorGreen,
                                                  ),
                                                ),
                                                AppSpaces.v2,
                                                Text(
                                                  stock.unit.isNotEmpty
                                                      ? stock.unit
                                                      : 'N/A',
                                                  style:
                                                      TextStyles.kMediumOutfit(
                                                        fontSize: tablet
                                                            ? FontSizes
                                                                  .k14FontSize
                                                            : FontSizes
                                                                  .k12FontSize,
                                                        color: kColorDarkGrey,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
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
