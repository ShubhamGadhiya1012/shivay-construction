import 'package:flutter/material.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/indent_entry/models/site_wise_stock_dm.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';

class SiteStockCard extends StatelessWidget {
  const SiteStockCard({
    super.key,
    required this.siteGroup,
    required this.siteIndex,
    required this.isExpanded,
    required this.onTap,
    required this.isSingleItemMode,
    required this.tablet,
  });

  final SiteStockGroup siteGroup;
  final int siteIndex;
  final bool isExpanded;
  final VoidCallback onTap;
  final bool isSingleItemMode;
  final bool tablet;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: tablet
          ? AppPaddings.custom(bottom: 12)
          : AppPaddings.custom(bottom: 10),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(tablet ? 14 : 12),
          child: Padding(
            padding: tablet
                ? AppPaddings.combined(horizontal: 18, vertical: 16)
                : AppPaddings.combined(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Site Header
                Row(
                  children: [
                    Container(
                      padding: tablet ? AppPaddings.p10 : AppPaddings.p8,
                      decoration: BoxDecoration(
                        color: kColorPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.location_on_rounded,
                        color: kColorPrimary,
                        size: tablet ? 20 : 18,
                      ),
                    ),
                    tablet ? AppSpaces.h12 : AppSpaces.h10,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            siteGroup.siteName,
                            style: TextStyles.kBoldOutfit(
                              fontSize: tablet
                                  ? FontSizes.k18FontSize
                                  : FontSizes.k16FontSize,
                              color: kColorPrimary,
                            ),
                          ),
                          AppSpaces.v2,
                          Text(
                            '${siteGroup.godowns.length} Godown(s)',
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
                        AppSpaces.v2,
                        Text(
                          siteGroup.totalStock.toStringAsFixed(2),
                          style: TextStyles.kBoldOutfit(
                            fontSize: tablet
                                ? FontSizes.k16FontSize
                                : FontSizes.k14FontSize,
                            color: kColorGreen,
                          ),
                        ),
                      ],
                    ),
                    tablet ? AppSpaces.h12 : AppSpaces.h8,
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: tablet ? 28 : 24,
                        color: kColorPrimary,
                      ),
                    ),
                  ],
                ),

                // Expanded Content - Godowns
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Column(
                    children: [
                      tablet ? AppSpaces.v16 : AppSpaces.v12,
                      Divider(
                        height: 1,
                        color: kColorLightGrey.withOpacity(0.5),
                      ),
                      tablet ? AppSpaces.v12 : AppSpaces.v10,

                      // Godowns List
                      ...siteGroup.godowns.map((godown) {
                        return _buildGodownSection(godown);
                      }).toList(),
                    ],
                  ),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGodownSection(GodownStockGroup godown) {
    return Container(
      margin: AppPaddings.custom(bottom: tablet ? 10 : 8),
      decoration: BoxDecoration(
        color: kColorPrimary.withOpacity(0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kColorPrimary.withOpacity(0.2)),
      ),
      child: Padding(
        padding: tablet
            ? AppPaddings.combined(horizontal: 12, vertical: 12)
            : AppPaddings.combined(horizontal: 10, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Godown Header
            Row(
              children: [
                Icon(
                  Icons.warehouse_rounded,
                  color: kColorSecondary,
                  size: tablet ? 18 : 16,
                ),
                tablet ? AppSpaces.h8 : AppSpaces.h6,
                Expanded(
                  child: Text(
                    godown.gdName,
                    style: TextStyles.kSemiBoldOutfit(
                      fontSize: tablet
                          ? FontSizes.k14FontSize
                          : FontSizes.k12FontSize,
                      color: kColorTextPrimary,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Stock',
                      style: TextStyles.kRegularOutfit(
                        fontSize: FontSizes.k10FontSize,
                        color: kColorDarkGrey,
                      ),
                    ),
                    Text(
                      '${godown.totalStock.toStringAsFixed(2)} ${godown.items.isNotEmpty ? godown.items.first.unit : ''}',
                      style: TextStyles.kBoldOutfit(
                        fontSize: tablet
                            ? FontSizes.k14FontSize
                            : FontSizes.k12FontSize,
                        color: kColorSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Items List (only if not in single item mode)
            if (!isSingleItemMode) ...[
              tablet ? AppSpaces.v10 : AppSpaces.v8,
              ...godown.items.map((item) {
                return _buildItemCard(item);
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(SiteWiseStockDm item) {
    return Container(
      margin: AppPaddings.custom(bottom: tablet ? 8 : 6),
      padding: tablet
          ? AppPaddings.combined(horizontal: 12, vertical: 10)
          : AppPaddings.combined(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: kColorWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kColorLightGrey.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            color: kColorPrimary,
            size: tablet ? 16 : 14,
          ),
          tablet ? AppSpaces.h8 : AppSpaces.h6,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.iName,
                  style: TextStyles.kMediumOutfit(
                    fontSize: tablet
                        ? FontSizes.k12FontSize
                        : FontSizes.k10FontSize,
                    color: kColorTextPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpaces.v2,
                Text(
                  item.unit,
                  style: TextStyles.kRegularOutfit(
                    fontSize: FontSizes.k10FontSize,
                    color: kColorDarkGrey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            item.stockQty.toStringAsFixed(2),
            style: TextStyles.kBoldOutfit(
              fontSize: tablet ? FontSizes.k14FontSize : FontSizes.k12FontSize,
              color: kColorPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
