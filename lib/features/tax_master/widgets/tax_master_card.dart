// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/tax_master/models/tax_master_dm.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_button.dart';

class TaxMasterCard extends StatelessWidget {
  const TaxMasterCard({
    super.key,
    required this.tax,
    required this.onEdit,
    required this.onDelete,
  });

  final TaxMasterDm tax;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  Widget _buildTaxBadge({
    required String label,
    required bool active,
    required bool tablet,
  }) {
    return Container(
      padding: tablet
          ? AppPaddings.combined(horizontal: 12, vertical: 6)
          : AppPaddings.combined(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: active
            ? kColorPrimary.withOpacity(0.1)
            : kColorLightGrey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: active
              ? kColorPrimary.withOpacity(0.4)
              : kColorLightGrey.withOpacity(0.4),
        ),
      ),
      child: Text(
        label,
        style: TextStyles.kMediumOutfit(
          fontSize: tablet ? FontSizes.k14FontSize : FontSizes.k12FontSize,
          color: active ? kColorPrimary : kColorDarkGrey,
        ),
      ),
    );
  }

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
      child: Padding(
        padding: tablet
            ? AppPaddings.combined(horizontal: 18, vertical: 16)
            : AppPaddings.combined(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header Row ──
            Row(
              children: [
                Expanded(
                  child: Text(
                    tax.taxName,
                    style: TextStyles.kBoldOutfit(
                      fontSize: tablet
                          ? FontSizes.k20FontSize
                          : FontSizes.k18FontSize,
                      color: kColorPrimary,
                    ),
                  ),
                ),
                tablet ? AppSpaces.h12 : AppSpaces.h8,
                // Edit Button
                Material(
                  color: kColorPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(tablet ? 10 : 8),
                  child: InkWell(
                    onTap: onEdit,
                    borderRadius: BorderRadius.circular(tablet ? 10 : 8),
                    child: Container(
                      padding: tablet
                          ? AppPaddings.combined(horizontal: 12, vertical: 8)
                          : AppPaddings.combined(horizontal: 10, vertical: 6),
                      child: Icon(
                        Icons.edit_rounded,
                        size: tablet ? 18 : 16,
                        color: kColorPrimary,
                      ),
                    ),
                  ),
                ),
                tablet ? AppSpaces.h12 : AppSpaces.h8,
                // Delete Button
                Material(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(tablet ? 10 : 8),
                  child: InkWell(
                    onTap: () => _showDeleteDialog(context, tablet),
                    borderRadius: BorderRadius.circular(tablet ? 10 : 8),
                    child: Container(
                      padding: tablet
                          ? AppPaddings.combined(horizontal: 10, vertical: 8)
                          : AppPaddings.combined(horizontal: 8, vertical: 6),
                      child: Icon(
                        Icons.delete_rounded,
                        size: tablet ? 20 : 18,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            tablet ? AppSpaces.v12 : AppSpaces.v10,
            Divider(height: 1, color: kColorLightGrey.withOpacity(0.5)),
            tablet ? AppSpaces.v12 : AppSpaces.v10,

            // ── Tax Badges ──
            Row(
              children: [
                _buildTaxBadge(label: 'IGST', active: tax.igst, tablet: tablet),
                tablet ? AppSpaces.h12 : AppSpaces.h8,
                _buildTaxBadge(label: 'CGST', active: tax.cgst, tablet: tablet),
                tablet ? AppSpaces.h12 : AppSpaces.h8,
                _buildTaxBadge(label: 'SGST', active: tax.sgst, tablet: tablet),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, bool tablet) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tablet ? 20 : 16),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: tablet ? 520 : double.infinity,
          constraints: BoxConstraints(
            maxWidth: tablet ? 520 : MediaQuery.of(context).size.width * 0.9,
          ),
          decoration: BoxDecoration(
            color: kColorWhite,
            borderRadius: BorderRadius.circular(tablet ? 20 : 16),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: tablet
                    ? AppPaddings.combined(horizontal: 24, vertical: 20)
                    : AppPaddings.combined(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(tablet ? 20 : 16),
                    topRight: Radius.circular(tablet ? 20 : 16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: AppPaddings.p10,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(tablet ? 12 : 10),
                      ),
                      child: Icon(
                        Icons.delete_rounded,
                        color: Colors.red,
                        size: tablet ? 26 : 22,
                      ),
                    ),
                    tablet ? AppSpaces.h12 : AppSpaces.h10,
                    Expanded(
                      child: Text(
                        'Delete Tax',
                        style: TextStyles.kSemiBoldOutfit(
                          fontSize: tablet
                              ? FontSizes.k22FontSize
                              : FontSizes.k18FontSize,
                          color: kColorTextPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: tablet ? AppPaddings.p24 : AppPaddings.p20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Are you sure you want to delete "${tax.taxName}"?',
                      style: TextStyles.kRegularOutfit(
                        fontSize: tablet
                            ? FontSizes.k16FontSize
                            : FontSizes.k14FontSize,
                        color: kColorTextPrimary,
                      ),
                    ),
                    tablet ? AppSpaces.v8 : AppSpaces.v6,
                    Text(
                      'This action cannot be undone.',
                      style: TextStyles.kRegularOutfit(
                        fontSize: tablet
                            ? FontSizes.k14FontSize
                            : FontSizes.k12FontSize,
                        color: kColorDarkGrey,
                      ),
                    ),
                    tablet ? AppSpaces.v24 : AppSpaces.v20,
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Get.back(),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: kColorLightGrey,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  tablet ? 12 : 10,
                                ),
                              ),
                              padding: AppPaddings.combined(
                                vertical: tablet ? 16 : 14,
                                horizontal: 0,
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyles.kMediumOutfit(
                                color: kColorDarkGrey,
                                fontSize: tablet
                                    ? FontSizes.k16FontSize
                                    : FontSizes.k14FontSize,
                              ),
                            ),
                          ),
                        ),
                        tablet ? AppSpaces.h16 : AppSpaces.h12,
                        Expanded(
                          child: AppButton(
                            title: 'Delete',
                            buttonColor: Colors.red,
                            titleColor: kColorWhite,
                            titleSize: tablet
                                ? FontSizes.k16FontSize
                                : FontSizes.k14FontSize,
                            buttonHeight: tablet ? 54 : 48,
                            onPressed: () {
                              Get.back();
                              onDelete();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
