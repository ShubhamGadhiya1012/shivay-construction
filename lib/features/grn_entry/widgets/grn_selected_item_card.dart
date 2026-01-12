// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/helpers/date_format_helper.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';

class GrnSelectedItemCard extends StatelessWidget {
  const GrnSelectedItemCard({
    super.key,
    required this.poData,
    required this.onRemove,
  });

  final Map<String, dynamic> poData;
  final VoidCallback onRemove;

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      poData['iName'] ?? '',
                      style: TextStyles.kSemiBoldOutfit(
                        fontSize: tablet
                            ? FontSizes.k18FontSize
                            : FontSizes.k16FontSize,
                        color: kColorTextPrimary,
                      ),
                    ),
                    AppSpaces.v4,
                    Text(
                      'PO: ${poData['poInvNo']}',
                      style: TextStyles.kRegularOutfit(
                        fontSize: tablet
                            ? FontSizes.k14FontSize
                            : FontSizes.k12FontSize,
                        color: kColorDarkGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Material(
                color: kColorRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(tablet ? 8 : 6),
                child: InkWell(
                  onTap: onRemove,
                  borderRadius: BorderRadius.circular(tablet ? 8 : 6),
                  child: Container(
                    padding: tablet
                        ? AppPaddings.combined(horizontal: 10, vertical: 10)
                        : AppPaddings.combined(horizontal: 8, vertical: 8),
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
                        label: 'PO Date',
                        value: convertyyyyMMddToddMMyyyy(
                          poData['poDate'] ?? '',
                        ),
                        tablet: tablet,
                      ),
                    ),

                    Expanded(
                      child: _buildDetailColumn(
                        label: 'PO Qty',
                        value: (poData['poQty'] ?? 0.0).toStringAsFixed(2),
                        tablet: tablet,
                      ),
                    ),
                    Expanded(
                      child: _buildDetailColumn(
                        label: 'GRN Qty',
                        value:
                            '${(poData['grnQty'] ?? 0.0).toStringAsFixed(2)} ${poData['unit']}',
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
