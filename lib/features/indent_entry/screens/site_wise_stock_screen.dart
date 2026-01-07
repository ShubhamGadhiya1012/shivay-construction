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
                    Expanded(
                      child: Obx(() {
                        if (_controller.filteredStockList.isEmpty &&
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
                          itemCount: _controller.filteredStockList.length,
                          itemBuilder: (context, index) {
                            final stock = _controller.filteredStockList[index];

                            return Padding(
                              padding: tablet
                                  ? AppPaddings.custom(bottom: 12)
                                  : AppPaddings.custom(bottom: 8),
                              child: SiteWiseStockCard(
                                siteName: stock.siteName,
                                gdName: stock.gdName,
                                itemName: stock.iName,
                                stockQty: stock.stockQty,
                                unit: stock.unit,
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
