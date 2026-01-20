// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/item_help/models/item_help_item_dm.dart';
import 'package:shivay_construction/features/item_help/screens/item_help_detail_screen.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';

class ItemHelpItemCard extends StatelessWidget {
  const ItemHelpItemCard({super.key, required this.item});

  final ItemHelpItemDm item;

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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(tablet ? 14 : 12),
          child: Padding(
            padding: tablet
                ? AppPaddings.combined(horizontal: 18, vertical: 16)
                : AppPaddings.combined(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.iName,
                        style: TextStyles.kBoldOutfit(
                          fontSize: tablet
                              ? FontSizes.k20FontSize
                              : FontSizes.k18FontSize,
                          color: kColorPrimary,
                        ),
                      ),
                    ),
                    tablet ? AppSpaces.h12 : AppSpaces.h8,
                    Material(
                      color: kColorPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(tablet ? 10 : 8),
                      child: InkWell(
                        onTap: () {
                          Get.to(() => ItemHelpDetailScreen(iCode: item.iCode));
                        },
                        borderRadius: BorderRadius.circular(tablet ? 10 : 8),
                        child: Container(
                          padding: tablet
                              ? AppPaddings.combined(
                                  horizontal: 12,
                                  vertical: 8,
                                )
                              : AppPaddings.combined(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.visibility_rounded,
                                size: tablet ? 18 : 16,
                                color: kColorPrimary,
                              ),
                              AppSpaces.h6,
                              Text(
                                'View Details',
                                style: TextStyles.kSemiBoldOutfit(
                                  fontSize: tablet
                                      ? FontSizes.k15FontSize
                                      : FontSizes.k14FontSize,
                                  color: kColorPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                tablet ? AppSpaces.v16 : AppSpaces.v12,
                Divider(height: 1, color: kColorLightGrey.withOpacity(0.5)),
                tablet ? AppSpaces.v16 : AppSpaces.v12,
                _buildInfoRow(
                  label: 'Description',
                  value: item.description,
                  tablet: tablet,
                ),
                tablet ? AppSpaces.v12 : AppSpaces.v10,
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        label: 'Unit',
                        value: item.unit,
                        tablet: tablet,
                      ),
                    ),
                    tablet ? AppSpaces.h16 : AppSpaces.h12,
                    Expanded(
                      child: _buildInfoRow(
                        label: 'Category',
                        value: item.categoryName,
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
                        label: 'Group',
                        value: item.groupName,
                        tablet: tablet,
                      ),
                    ),
                    tablet ? AppSpaces.h16 : AppSpaces.h12,
                    Expanded(
                      child: _buildInfoRow(
                        label: 'Sub Group',
                        value: item.subGroupName,
                        tablet: tablet,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
}
