// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/indent_entry/screens/site_wise_stock_screen.dart';
import 'package:shivay_construction/features/item_help/controllers/item_help_detail_controller.dart';
import 'package:shivay_construction/features/item_help/screens/item_help_last_grn_screen.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_appbar.dart';
import 'package:shivay_construction/widgets/app_loading_overlay.dart';

class ItemHelpDetailScreen extends StatefulWidget {
  const ItemHelpDetailScreen({super.key, required this.iCode});

  final String iCode;

  @override
  State<ItemHelpDetailScreen> createState() => _ItemHelpDetailScreenState();
}

class _ItemHelpDetailScreenState extends State<ItemHelpDetailScreen> {
  final ItemHelpDetailController _controller = Get.put(
    ItemHelpDetailController(),
  );

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() async {
    await _controller.getItemDetails(iCode: widget.iCode);
  }

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);

    return Stack(
      children: [
        Scaffold(
          appBar: AppAppbar(
            title: 'Item Details',
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                size: tablet ? 25 : 20,
                color: kColorPrimary,
              ),
              onPressed: () => Get.back(),
            ),
          ),
          body: Padding(
            padding: tablet
                ? AppPaddings.combined(horizontal: 24, vertical: 12)
                : AppPaddings.p12,
            child: Obx(() {
              if (_controller.itemDetails.isEmpty &&
                  !_controller.isLoading.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: tablet ? 80 : 64,
                        color: kColorLightGrey,
                      ),
                      tablet ? AppSpaces.v20 : AppSpaces.v16,
                      Text(
                        'No Details Found',
                        style: TextStyles.kMediumOutfit(
                          fontSize: tablet
                              ? FontSizes.k24FontSize
                              : FontSizes.k18FontSize,
                          color: kColorTextPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (_controller.itemDetails.isEmpty) {
                return const SizedBox.shrink();
              }

              final detail = _controller.itemDetails.first;

              return SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    color: kColorWhite,
                    borderRadius: BorderRadius.circular(tablet ? 14 : 12),
                    border: Border.all(color: kColorLightGrey.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: kColorPrimary.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: tablet
                      ? AppPaddings.combined(horizontal: 18, vertical: 16)
                      : AppPaddings.combined(horizontal: 14, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detail.iName,
                        style: TextStyles.kBoldOutfit(
                          fontSize: tablet
                              ? FontSizes.k20FontSize
                              : FontSizes.k18FontSize,
                          color: kColorPrimary,
                        ),
                      ),
                      tablet ? AppSpaces.v16 : AppSpaces.v12,
                      _buildInfoRow(
                        label: 'Description',
                        value: detail.description,
                        tablet: tablet,
                      ),
                      tablet ? AppSpaces.v12 : AppSpaces.v10,
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoRow(
                              label: 'Unit',
                              value: detail.unit,
                              tablet: tablet,
                            ),
                          ),
                          tablet ? AppSpaces.h12 : AppSpaces.h10,
                          Expanded(
                            child: _buildInfoRow(
                              label: 'Average Rate',
                              value: '₹${detail.avgRate.toStringAsFixed(2)}',
                              tablet: tablet,
                            ),
                          ),
                        ],
                      ),
                      tablet ? AppSpaces.v12 : AppSpaces.v10,
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoRow(
                              label: 'PO Pending Qty',
                              value: detail.poPendingQty.toStringAsFixed(2),
                              tablet: tablet,
                            ),
                          ),
                          tablet ? AppSpaces.h16 : AppSpaces.h12,
                          Expanded(
                            child: _buildInfoRow(
                              label: 'Stock Qty',
                              value: detail.stockQty.toStringAsFixed(2),
                              tablet: tablet,
                            ),
                          ),
                        ],
                      ),
                      tablet ? AppSpaces.v20 : AppSpaces.v16,
                      Row(
                        children: [
                          Expanded(
                            child: Material(
                              color: kColorGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                tablet ? 10 : 8,
                              ),
                              child: InkWell(
                                onTap: () {
                                  Get.to(
                                    () => SiteWiseStockScreen(
                                      iCode: widget.iCode,
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(
                                  tablet ? 10 : 8,
                                ),
                                child: Container(
                                  padding: tablet
                                      ? AppPaddings.combined(
                                          horizontal: 12,
                                          vertical: 12,
                                        )
                                      : AppPaddings.combined(
                                          horizontal: 10,
                                          vertical: 10,
                                        ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.inventory_2_outlined,
                                        size: tablet ? 20 : 18,
                                        color: kColorGreen,
                                      ),
                                      tablet ? AppSpaces.h8 : AppSpaces.h6,
                                      Text(
                                        'View Stock',
                                        style: TextStyles.kSemiBoldOutfit(
                                          fontSize: tablet
                                              ? FontSizes.k15FontSize
                                              : FontSizes.k14FontSize,
                                          color: kColorGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          tablet ? AppSpaces.h16 : AppSpaces.h12,
                          Expanded(
                            child: Material(
                              color: kColorSecondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                tablet ? 10 : 8,
                              ),
                              child: InkWell(
                                onTap: () {
                                  Get.to(
                                    () => ItemHelpLastGrnScreen(
                                      iCode: widget.iCode,
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(
                                  tablet ? 10 : 8,
                                ),
                                child: Container(
                                  padding: tablet
                                      ? AppPaddings.combined(
                                          horizontal: 12,
                                          vertical: 12,
                                        )
                                      : AppPaddings.combined(
                                          horizontal: 10,
                                          vertical: 10,
                                        ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.receipt_long_outlined,
                                        size: tablet ? 20 : 18,
                                        color: kColorSecondary,
                                      ),
                                      tablet ? AppSpaces.h8 : AppSpaces.h6,
                                      Text(
                                        'Last GRN',
                                        style: TextStyles.kSemiBoldOutfit(
                                          fontSize: tablet
                                              ? FontSizes.k15FontSize
                                              : FontSizes.k14FontSize,
                                          color: kColorSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        Obx(() => AppLoadingOverlay(isLoading: _controller.isLoading.value)),
      ],
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required bool tablet,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyles.kMediumOutfit(
            fontSize: tablet ? FontSizes.k14FontSize : FontSizes.k12FontSize,
            color: kColorDarkGrey,
          ),
        ),
        tablet ? AppSpaces.v4 : AppSpaces.v2,
        Text(
          value,
          style: TextStyles.kSemiBoldOutfit(
            fontSize: tablet ? FontSizes.k15FontSize : FontSizes.k14FontSize,
            color: kColorTextPrimary,
          ),
        ),
      ],
    );
  }
}
