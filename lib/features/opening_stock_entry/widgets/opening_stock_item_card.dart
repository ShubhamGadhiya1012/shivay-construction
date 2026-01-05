// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_card.dart';
import 'package:shivay_construction/widgets/app_title_value_container.dart';

class OpeningStockItemCard extends StatelessWidget {
  const OpeningStockItemCard({
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

    return AppCard(
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
                      item['iname'] ?? '',
                      style: TextStyles.kSemiBoldOutfit(
                        fontSize: tablet
                            ? FontSizes.k26FontSize
                            : FontSizes.k20FontSize,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Material(
                    color: kColorPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(tablet ? 8 : 6),
                    child: InkWell(
                      onTap: onEdit,
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
                  tablet ? AppSpaces.h12 : AppSpaces.h8,
                  Material(
                    color: kColorRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(tablet ? 8 : 6),
                    child: InkWell(
                      onTap: onDelete,
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
            ],
          ),
          tablet ? AppSpaces.v16 : AppSpaces.v10,
          Row(
            children: [
              Expanded(
                child: AppTitleValueContainer(
                  title: 'QTY',
                  value: (item['qty'] ?? 0.0).toStringAsFixed(2),
                ),
              ),
              AppSpaces.h10,
              Expanded(
                child: AppTitleValueContainer(
                  title: 'RATE',
                  value: '₹${(item['rate'] ?? 0.0).toStringAsFixed(2)}',
                ),
              ),
              AppSpaces.h10,
              Expanded(
                child: AppTitleValueContainer(
                  title: 'AMOUNT',
                  value:
                      '₹${((item['qty'] ?? 0.0) * (item['rate'] ?? 0.0)).toStringAsFixed(2)}',
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
