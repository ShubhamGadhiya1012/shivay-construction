// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/opening_stock_entry/controllers/opening_stocks_controller.dart';
import 'package:shivay_construction/features/opening_stock_entry/models/opening_stock_dm.dart';
import 'package:shivay_construction/features/opening_stock_entry/screens/opening_stock_entry_screen.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_card.dart';
import 'package:shivay_construction/widgets/app_title_value_container.dart';

class OpeningStocksCard extends StatelessWidget {
  const OpeningStocksCard({
    super.key,
    required this.openingStock,
    required OpeningStocksController controller,
  });

  final OpeningStockDm openingStock;

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);

    String displayDate = openingStock.date;
    if (openingStock.date.contains('-')) {
      final parts = openingStock.date.split('-');
      if (parts.length == 3) {
        displayDate = '${parts[2]}-${parts[1]}-${parts[0]}';
      }
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  openingStock.invNo,
                  style: TextStyles.kSemiBoldOutfit(
                    fontSize: tablet
                        ? FontSizes.k26FontSize
                        : FontSizes.k18FontSize,
                  ),
                ),
              ),
              Material(
                color: kColorPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(tablet ? 8 : 6),
                child: InkWell(
                  onTap: () {
                    Get.to(
                      () => OpeningStockEntryScreen(
                        isEdit: true,
                        openingStock: openingStock,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(tablet ? 8 : 6),
                  child: Container(
                    padding: tablet
                        ? AppPaddings.combined(horizontal: 10, vertical: 10)
                        : AppPaddings.combined(horizontal: 8, vertical: 8),
                    child: Icon(
                      Icons.edit_rounded,
                      size: tablet ? 20 : 18,
                      color: kColorPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Text(
            'Date: $displayDate',
            style: TextStyles.kMediumOutfit(
              fontSize: tablet ? FontSizes.k22FontSize : FontSizes.k16FontSize,
            ),
          ),
          tablet ? AppSpaces.v16 : AppSpaces.v10,
          Row(
            children: [
              Expanded(
                child: AppTitleValueContainer(
                  title: 'Godown',
                  value: openingStock.gdName,
                ),
              ),
              AppSpaces.h10,
              Expanded(
                child: AppTitleValueContainer(
                  title: 'Site',
                  value: openingStock.siteName,
                ),
              ),
            ],
          ),
        ],
      ),
      onTap: () {},
    );
  }
}
