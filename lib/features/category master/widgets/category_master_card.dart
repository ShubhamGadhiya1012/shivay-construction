// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/category%20master/models/category_master_dm.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';

class CategoryMasterCard extends StatelessWidget {
  const CategoryMasterCard({
    super.key,
    required this.category,
    required this.onEdit,
  });

  final CategoryMasterDm category;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);

    return Container(
      margin: tablet
          ? AppPaddings.custom(bottom: 10)
          : AppPaddings.custom(bottom: 8),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(tablet ? 12 : 10),
          child: Padding(
            padding: tablet
                ? AppPaddings.combined(horizontal: 16, vertical: 14)
                : AppPaddings.combined(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    category.cName,
                    style: TextStyles.kSemiBoldOutfit(
                      fontSize: tablet
                          ? FontSizes.k18FontSize
                          : FontSizes.k16FontSize,
                      color: kColorTextPrimary,
                    ),
                  ),
                ),
                tablet ? AppSpaces.h12 : AppSpaces.h8,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
