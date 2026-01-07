// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/opening_stock_entry/controllers/opening_stocks_controller.dart';
import 'package:shivay_construction/features/opening_stock_entry/screens/opening_stock_entry_screen.dart';
import 'package:shivay_construction/features/opening_stock_entry/widgets/opening_stocks_card.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_appbar.dart';
import 'package:shivay_construction/widgets/app_loading_overlay.dart';
import 'package:shivay_construction/widgets/app_text_form_field.dart';

class OpeningStocksScreen extends StatelessWidget {
  OpeningStocksScreen({super.key});

  final OpeningStocksController _controller = Get.put(
    OpeningStocksController(),
  );

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            appBar: AppAppbar(
              title: 'Opening Stocks',
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
              onRefresh: () async {
                await _controller.getOpeningStocks();
              },
              child: Padding(
                padding: tablet
                    ? AppPaddings.combined(horizontal: 24, vertical: 12)
                    : AppPaddings.p12,
                child: Column(
                  children: [
                    AppTextFormField(
                      controller: _controller.searchController,
                      hintText: 'Search',
                      onChanged: (query) {
                        _controller.searchQuery.value = query;
                      },
                    ),
                    tablet ? AppSpaces.v20 : AppSpaces.v12,
                    Obx(() {
                      if (_controller.openingStocks.isEmpty &&
                          !_controller.isLoading.value) {
                        return Expanded(
                          child: Center(
                            child: Text(
                              'No opening stocks found.',
                              style: TextStyles.kMediumOutfit(
                                fontSize: tablet
                                    ? FontSizes.k26FontSize
                                    : FontSizes.k20FontSize,
                              ),
                            ),
                          ),
                        );
                      }
                      return Expanded(
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (scrollNotification) {
                            if (scrollNotification is ScrollEndNotification &&
                                scrollNotification.metrics.extentAfter == 0) {
                              _controller.getOpeningStocks(loadMore: true);
                            }
                            return false;
                          },
                          child: Obx(() {
                            return ListView.builder(
                              itemCount:
                                  _controller.openingStocks.length +
                                  (_controller.isLoadingMore.value ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index < _controller.openingStocks.length) {
                                  final stock =
                                      _controller.openingStocks[index];
                                  return OpeningStocksCard(
                                    openingStock: stock,
                                    controller: _controller,
                                  );
                                } else {
                                  return Padding(
                                    padding: tablet
                                        ? AppPaddings.pv12
                                        : AppPaddings.pv8,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: kColorPrimary,
                                      ),
                                    ),
                                  );
                                }
                              },
                            );
                          }),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(tablet ? 16 : 12),
                boxShadow: [
                  BoxShadow(
                    color: kColorPrimary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: () {
                  Get.to(() => const OpeningStockEntryScreen(isEdit: false));
                },
                backgroundColor: kColorPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(tablet ? 16 : 12),
                ),
                icon: Icon(
                  Icons.add,
                  color: kColorWhite,
                  size: tablet ? 24 : 20,
                ),
                label: Text(
                  'Add New',
                  style: TextStyles.kSemiBoldOutfit(
                    fontSize: tablet
                        ? FontSizes.k16FontSize
                        : FontSizes.k14FontSize,
                    color: kColorWhite,
                  ),
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
