// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/item_help/models/item_help_last_grn_dm.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';

class ItemHelpLastGrnCard extends StatelessWidget {
  const ItemHelpLastGrnCard({super.key, required this.grn});

  final ItemHelpLastGrnDm grn;

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);

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
      padding: tablet
          ? AppPaddings.combined(horizontal: 18, vertical: 16)
          : AppPaddings.combined(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  grn.invno,
                  style: TextStyles.kBoldOutfit(
                    fontSize: tablet
                        ? FontSizes.k20FontSize
                        : FontSizes.k18FontSize,
                    color: kColorPrimary,
                  ),
                ),
              ),
              if (grn.type.isNotEmpty) ...[
                Container(
                  padding: tablet
                      ? AppPaddings.combined(horizontal: 10, vertical: 6)
                      : AppPaddings.combined(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: kColorSecondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: kColorSecondary.withOpacity(0.3)),
                  ),
                  child: Text(
                    grn.type,
                    style: TextStyles.kMediumOutfit(
                      fontSize: tablet
                          ? FontSizes.k12FontSize
                          : FontSizes.k10FontSize,
                      color: kColorSecondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          tablet ? AppSpaces.v12 : AppSpaces.v8,
          Text(
            'Date: ${grn.date}',
            style: TextStyles.kRegularOutfit(
              fontSize: tablet ? FontSizes.k14FontSize : FontSizes.k12FontSize,
              color: kColorDarkGrey,
            ),
          ),
          tablet ? AppSpaces.v16 : AppSpaces.v12,
          Divider(height: 1, color: kColorLightGrey.withOpacity(0.5)),
          tablet ? AppSpaces.v16 : AppSpaces.v12,
          _buildInfoRow(label: 'Party', value: grn.pName, tablet: tablet),
          tablet ? AppSpaces.v12 : AppSpaces.v10,
          _buildInfoRow(label: 'Item', value: grn.iName, tablet: tablet),
          if (grn.remarks.isNotEmpty) ...[
            tablet ? AppSpaces.v12 : AppSpaces.v10,
            _buildInfoRow(label: 'Remarks', value: grn.remarks, tablet: tablet),
          ],
          if (grn.poInvNo.isNotEmpty) ...[
            tablet ? AppSpaces.v12 : AppSpaces.v10,
            _buildInfoRow(
              label: 'PO Invoice No',
              value: grn.poInvNo,
              tablet: tablet,
            ),
          ],
          tablet ? AppSpaces.v16 : AppSpaces.v12,
          Container(
            padding: tablet
                ? AppPaddings.combined(horizontal: 12, vertical: 10)
                : AppPaddings.combined(horizontal: 10, vertical: 8),
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
                        value: grn.qty.toStringAsFixed(2),
                        tablet: tablet,
                      ),
                    ),
                    AppSpaces.h12,
                    Expanded(
                      child: _buildDetailColumn(
                        label: 'Unit',
                        value: grn.unit,
                        tablet: tablet,
                      ),
                    ),
                  ],
                ),
                tablet ? AppSpaces.v10 : AppSpaces.v8,
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailColumn(
                        label: 'Rate',
                        value: '₹${grn.rate.toStringAsFixed(2)}',
                        tablet: tablet,
                      ),
                    ),
                    AppSpaces.h12,
                    Expanded(
                      child: _buildDetailColumn(
                        label: 'Amount',
                        value: '₹${grn.amount.toStringAsFixed(2)}',
                        tablet: tablet,
                        valueColor: kColorGreen,
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

  Widget _buildDetailColumn({
    required String label,
    required String value,
    required bool tablet,
    Color? valueColor,
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
            color: valueColor ?? kColorTextPrimary,
          ),
        ),
      ],
    );
  }
}
