// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/purchase_order_entry/controllers/purchase_order_controller.dart';
import 'package:shivay_construction/features/purchase_order_entry/models/auth_indent_item_dm.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/helpers/date_format_helper.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_text_form_field.dart';

class AuthIndentItemCard extends StatelessWidget {
  const AuthIndentItemCard({
    super.key,
    required this.item,
    required this.isExpanded,
    required this.isSelectionMode,
    required this.onTap,
    required this.onIndentTap,
    required this.onIndentLongPress,
    required this.controller,
  });

  final AuthIndentItemDm item;
  final bool isExpanded;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final Function(int) onIndentTap;
  final Function(int) onIndentLongPress;
  final PurchaseOrderController controller;

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
          onTap: onTap,
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.iName,
                            style: TextStyles.kBoldOutfit(
                              fontSize: tablet
                                  ? FontSizes.k20FontSize
                                  : FontSizes.k18FontSize,
                              color: kColorPrimary,
                            ),
                          ),
                        ],
                      ),
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
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      tablet ? AppSpaces.v16 : AppSpaces.v12,
                      Divider(
                        height: 1,
                        color: kColorLightGrey.withOpacity(0.5),
                      ),
                      tablet ? AppSpaces.v16 : AppSpaces.v12,
                      Text(
                        'Authorized Indents',
                        style: TextStyles.kSemiBoldOutfit(
                          fontSize: tablet
                              ? FontSizes.k18FontSize
                              : FontSizes.k16FontSize,
                          color: kColorTextPrimary,
                        ),
                      ),
                      tablet ? AppSpaces.v12 : AppSpaces.v8,
                      // REPLACE the ListView.builder (that builds indent items) with:
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: item.indents.length,
                        itemBuilder: (context, index) {
                          final indent = item.indents[index];
                          final key = '${indent.indentNo}_${indent.indentSrNo}';
                          final qtyController = controller.qtyControllers[key];
                          final priceController =
                              controller.priceControllers[key];

                          return GestureDetector(
                            onTap: () => onIndentTap(index),
                            onLongPress: () => onIndentLongPress(index),
                            child: Container(
                              margin: AppPaddings.custom(bottom: 8),
                              padding: tablet
                                  ? AppPaddings.p12
                                  : AppPaddings.p10,
                              decoration: BoxDecoration(
                                color: indent.isSelected
                                    ? kColorPrimary.withOpacity(0.15)
                                    : kColorPrimary.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: indent.isSelected
                                      ? kColorPrimary
                                      : kColorPrimary.withOpacity(0.2),
                                  width: indent.isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      if (isSelectionMode) ...[
                                        Icon(
                                          indent.isSelected
                                              ? Icons.check_circle
                                              : Icons.circle_outlined,
                                          color: indent.isSelected
                                              ? kColorPrimary
                                              : kColorDarkGrey,
                                          size: tablet ? 24 : 20,
                                        ),
                                        tablet ? AppSpaces.h12 : AppSpaces.h8,
                                      ],
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              indent.indentNo,
                                              style: TextStyles.kSemiBoldOutfit(
                                                fontSize: tablet
                                                    ? FontSizes.k16FontSize
                                                    : FontSizes.k14FontSize,
                                                color: kColorPrimary,
                                              ),
                                            ),
                                            AppSpaces.v4,
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    'Required Date: ${convertyyyyMMddToddMMyyyy(indent.date)}',
                                                    style:
                                                        TextStyles.kRegularOutfit(
                                                          fontSize: tablet
                                                              ? FontSizes
                                                                    .k12FontSize
                                                              : FontSizes
                                                                    .k10FontSize,
                                                          color: kColorDarkGrey,
                                                        ),
                                                  ),
                                                ),
                                                if (indent.isSelected &&
                                                    qtyController != null &&
                                                    priceController != null)
                                                  Expanded(
                                                    child: Text(
                                                      'Authorized Qty: ${indent.indentQty.toStringAsFixed(2)}',
                                                      style: TextStyles.kRegularOutfit(
                                                        fontSize: tablet
                                                            ? FontSizes
                                                                  .k12FontSize
                                                            : FontSizes
                                                                  .k10FontSize,
                                                        color: kColorDarkGrey,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  if (indent.isSelected &&
                                      qtyController != null &&
                                      priceController != null) ...[
                                    tablet ? AppSpaces.v12 : AppSpaces.v10,
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Quantity *',
                                                style: TextStyles.kMediumOutfit(
                                                  fontSize: tablet
                                                      ? FontSizes.k14FontSize
                                                      : FontSizes.k12FontSize,
                                                  color: kColorTextPrimary,
                                                ),
                                              ),
                                              tablet
                                                  ? AppSpaces.v6
                                                  : AppSpaces.v4,
                                              GestureDetector(
                                                onTap: () {},
                                                child: AbsorbPointer(
                                                  absorbing: false,
                                                  child: AppTextFormField(
                                                    controller: qtyController,
                                                    hintText: 'Enter Quantity',
                                                    keyboardType:
                                                        TextInputType.number,
                                                    floatingLabelRequired:
                                                        false,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        tablet ? AppSpaces.h12 : AppSpaces.h10,
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Price *',
                                                style: TextStyles.kMediumOutfit(
                                                  fontSize: tablet
                                                      ? FontSizes.k14FontSize
                                                      : FontSizes.k12FontSize,
                                                  color: kColorTextPrimary,
                                                ),
                                              ),
                                              tablet
                                                  ? AppSpaces.v6
                                                  : AppSpaces.v4,
                                              GestureDetector(
                                                onTap: () {},
                                                child: AbsorbPointer(
                                                  absorbing: false,
                                                  child: AppTextFormField(
                                                    controller: priceController,
                                                    hintText: 'Enter Price',
                                                    keyboardType:
                                                        TextInputType.number,
                                                    floatingLabelRequired:
                                                        false,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ] else ...[
                                    tablet ? AppSpaces.v8 : AppSpaces.v6,
                                    _buildDetailRow(
                                      label: 'Authorized Qty',
                                      value: indent.authoriseQty
                                          .toStringAsFixed(2),
                                      tablet: tablet,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
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

  Widget _buildDetailRow({
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
            fontSize: tablet ? FontSizes.k12FontSize : FontSizes.k12FontSize,
            color: kColorDarkGrey,
          ),
        ),
        AppSpaces.v2,
        Text(
          value,
          style: TextStyles.kMediumOutfit(
            fontSize: tablet ? FontSizes.k14FontSize : FontSizes.k14FontSize,
            color: kColorTextPrimary,
          ),
        ),
      ],
    );
  }
}
