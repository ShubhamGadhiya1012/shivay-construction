// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';

class SiteWiseStockCard extends StatelessWidget {
  const SiteWiseStockCard({
    super.key,
    required this.siteName,
    required this.gdName,
    required this.itemName,
    required this.stockQty,
    required this.unit,
  });

  final String siteName;
  final String gdName;
  final String itemName;
  final double stockQty;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);

    return Container(
      decoration: BoxDecoration(
        color: kColorWhite,
        borderRadius: BorderRadius.circular(tablet ? 12 : 10),
        border: Border.all(color: kColorLightGrey.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: kColorPrimary.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: tablet
          ? AppPaddings.combined(horizontal: 16, vertical: 14)
          : AppPaddings.combined(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                color: kColorPrimary,
                size: tablet ? 18 : 16,
              ),
              AppSpaces.h6,
              Expanded(
                child: Text(
                  siteName.isNotEmpty ? siteName : 'Unknown Site',
                  style: TextStyles.kSemiBoldOutfit(
                    fontSize: tablet
                        ? FontSizes.k16FontSize
                        : FontSizes.k14FontSize,
                    color: kColorPrimary,
                  ),
                ),
              ),
            ],
          ),

          if (gdName.isNotEmpty) ...[
            tablet ? AppSpaces.v6 : AppSpaces.v4,
            Row(
              children: [
                Icon(
                  Icons.warehouse_rounded,
                  color: kColorDarkGrey,
                  size: tablet ? 16 : 14,
                ),
                AppSpaces.h6,
                Expanded(
                  child: Text(
                    gdName,
                    style: TextStyles.kRegularOutfit(
                      fontSize: tablet
                          ? FontSizes.k14FontSize
                          : FontSizes.k12FontSize,
                      color: kColorDarkGrey,
                    ),
                  ),
                ),
              ],
            ),
          ],

          tablet ? AppSpaces.v10 : AppSpaces.v8,

          Container(
            padding: tablet
                ? AppPaddings.combined(horizontal: 12, vertical: 8)
                : AppPaddings.combined(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: kColorPrimary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kColorPrimary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Item',
                        style: TextStyles.kRegularOutfit(
                          fontSize: tablet
                              ? FontSizes.k12FontSize
                              : FontSizes.k10FontSize,
                          color: kColorDarkGrey,
                        ),
                      ),
                      AppSpaces.v2,
                      Text(
                        itemName.isNotEmpty ? itemName : 'Unknown Item',
                        style: TextStyles.kMediumOutfit(
                          fontSize: tablet
                              ? FontSizes.k14FontSize
                              : FontSizes.k12FontSize,
                          color: kColorTextPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                AppSpaces.h12,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Stock',
                      style: TextStyles.kRegularOutfit(
                        fontSize: tablet
                            ? FontSizes.k12FontSize
                            : FontSizes.k10FontSize,
                        color: kColorDarkGrey,
                      ),
                    ),
                    AppSpaces.v2,
                    Text(
                      '${stockQty.toStringAsFixed(2)} ${unit.isNotEmpty ? unit : 'N/A'}',
                      style: TextStyles.kBoldOutfit(
                        fontSize: tablet
                            ? FontSizes.k16FontSize
                            : FontSizes.k14FontSize,
                        color: kColorPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
