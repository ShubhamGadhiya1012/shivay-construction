// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';

class DirectGrnItemCard extends StatelessWidget {
  const DirectGrnItemCard({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  final Map<String, dynamic> item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);
    final double qty = ((item['qty'] ?? 0.0) as num).toDouble();
    final double rate = ((item['rate'] ?? 0.0) as num).toDouble();
    final double amount = qty * rate;

    return Container(
      decoration: BoxDecoration(
        color: kColorWhite,
        borderRadius: BorderRadius.circular(tablet ? 14 : 12),
        border: Border.all(color: kColorLightGrey.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: kColorPrimary.withOpacity(0.06),
            blurRadius: 8,
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
              Container(
                padding: AppPaddings.p8,
                decoration: BoxDecoration(
                  color: kColorPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.inventory_2_rounded,
                  color: kColorPrimary,
                  size: tablet ? 18 : 16,
                ),
              ),
              AppSpaces.h10,
              Expanded(
                child: Text(
                  item['iname'] ?? '',
                  style: TextStyles.kSemiBoldOutfit(
                    fontSize: tablet
                        ? FontSizes.k18FontSize
                        : FontSizes.k16FontSize,
                    color: kColorTextPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Material(
                color: kColorPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(tablet ? 8 : 6),
                child: InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(tablet ? 8 : 6),
                  child: Padding(
                    padding: AppPaddings.combined(horizontal: 8, vertical: 8),
                    child: Icon(
                      Icons.edit_rounded,
                      size: tablet ? 20 : 18,
                      color: kColorPrimary,
                    ),
                  ),
                ),
              ),
              AppSpaces.h8,
              Material(
                color: kColorRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(tablet ? 8 : 6),
                child: InkWell(
                  onTap: onDelete,
                  borderRadius: BorderRadius.circular(tablet ? 8 : 6),
                  child: Padding(
                    padding: AppPaddings.combined(horizontal: 8, vertical: 8),
                    child: Icon(
                      Icons.delete_rounded,
                      size: tablet ? 20 : 18,
                      color: kColorRed,
                    ),
                  ),
                ),
              ),
            ],
          ),
          tablet ? AppSpaces.v12 : AppSpaces.v10,
          Container(
            padding: tablet
                ? AppPaddings.combined(horizontal: 12, vertical: 8)
                : AppPaddings.combined(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: kColorPrimary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kColorPrimary.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailColumn(
                        label: 'Qty',
                        value: qty.toStringAsFixed(2),
                        tablet: tablet,
                      ),
                    ),
                    AppSpaces.h12,
                    Expanded(
                      child: _buildDetailColumn(
                        label: 'Rate',
                        value: rate.toStringAsFixed(2),
                        tablet: tablet,
                      ),
                    ),
                    AppSpaces.h12,
                    Expanded(
                      child: _buildDetailColumn(
                        label: 'Unit',
                        value: item['unit'] ?? '',
                        tablet: tablet,
                      ),
                    ),
                  ],
                ),
                Divider(
                  height: tablet ? 16 : 12,
                  color: kColorPrimary.withOpacity(0.15),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Amount',
                      style: TextStyles.kRegularOutfit(
                        fontSize: tablet
                            ? FontSizes.k12FontSize
                            : FontSizes.k10FontSize,
                        color: kColorDarkGrey,
                      ),
                    ),
                    Text(
                      amount.toStringAsFixed(2),
                      style: TextStyles.kSemiBoldOutfit(
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

  Widget _buildDetailColumn({
    required String label,
    required String value,
    required bool tablet,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyles.kRegularOutfit(
            fontSize: tablet ? FontSizes.k12FontSize : FontSizes.k10FontSize,
            color: kColorDarkGrey,
          ),
        ),
        AppSpaces.v2,
        Text(
          value,
          style: TextStyles.kMediumOutfit(
            fontSize: tablet ? FontSizes.k14FontSize : FontSizes.k12FontSize,
            color: kColorTextPrimary,
          ),
        ),
      ],
    );
  }
}
