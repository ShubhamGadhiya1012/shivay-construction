// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/issue_entry/controllers/issue_entry_controller.dart';
import 'package:shivay_construction/features/issue_entry/models/grn_item_dm.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_dropdown.dart';
import 'package:shivay_construction/widgets/app_text_form_field.dart';

class GrnItemCardForIssue extends StatelessWidget {
  const GrnItemCardForIssue({
    super.key,
    required this.grn,
    required this.item,
    required this.controller,
  });

  final GrnItemForIssueDm grn;
  final GrnItemDetailDm item;
  final IssueEntryController controller;

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);
    final key = '${grn.grnInvNo}_${item.grnSrNo}';

    return Obx(() {
      final isSelected = controller.isItemSelected(grn.grnInvNo, item.grnSrNo);
      final qtyController = controller.qtyControllers[key];
      if (qtyController == null) return const SizedBox.shrink();

      return GestureDetector(
        onTap: () {
          if (controller.isInSelectionMode.value) {
            controller.toggleItemSelection(grn, item);
          }
        },
        onLongPress: () {
          if (!controller.isInSelectionMode.value) {
            controller.isInSelectionMode.value = true;
          }
          controller.toggleItemSelection(grn, item);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? kColorPrimary.withOpacity(0.12) : kColorWhite,
            borderRadius: BorderRadius.circular(tablet ? 10 : 8),
            border: Border.all(
              color: isSelected
                  ? kColorPrimary
                  : kColorLightGrey.withOpacity(0.4),
              width: isSelected ? 2 : 1,
            ),
          ),
          padding: tablet
              ? AppPaddings.combined(horizontal: 12, vertical: 10)
              : AppPaddings.combined(horizontal: 10, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (controller.isInSelectionMode.value) ...[
                    Icon(
                      isSelected ? Icons.check_circle : Icons.circle_outlined,
                      color: isSelected ? kColorPrimary : kColorDarkGrey,
                      size: tablet ? 22 : 20,
                    ),
                    tablet ? AppSpaces.h10 : AppSpaces.h8,
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.iName,
                          style: TextStyles.kSemiBoldOutfit(
                            fontSize: tablet
                                ? FontSizes.k16FontSize
                                : FontSizes.k14FontSize,
                            color: isSelected
                                ? kColorPrimary
                                : kColorTextPrimary,
                          ),
                        ),
                        AppSpaces.v4,
                        if (!isSelected && item.gdName.isNotEmpty) ...[
                          Text(
                            'Head: ${item.gdName}',
                            style: TextStyles.kRegularOutfit(
                              fontSize: tablet
                                  ? FontSizes.k12FontSize
                                  : FontSizes.k10FontSize,
                              color: kColorDarkGrey,
                            ),
                          ),
                          AppSpaces.v2,
                        ],
                        if (!isSelected && item.cpName.isNotEmpty) ...[
                          Text(
                            'Contractor: ${item.cpName}',
                            style: TextStyles.kRegularOutfit(
                              fontSize: tablet
                                  ? FontSizes.k12FontSize
                                  : FontSizes.k10FontSize,
                              color: kColorDarkGrey,
                            ),
                          ),
                          AppSpaces.v2,
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              tablet ? AppSpaces.v10 : AppSpaces.v8,
              Row(
                children: [
                  Expanded(
                    child: _buildInfoColumn(
                      label: 'GRN Qty',
                      value: item.grnQty.toStringAsFixed(2),
                      tablet: tablet,
                    ),
                  ),
                  AppSpaces.h8,
                  Expanded(
                    child: _buildInfoColumn(
                      label: 'Rate',
                      value: item.rate.toStringAsFixed(2),
                      tablet: tablet,
                    ),
                  ),
                  AppSpaces.h8,
                  Expanded(
                    child: _buildInfoColumn(
                      label: 'Issued',
                      value: item.issuedQty.toStringAsFixed(2),
                      tablet: tablet,
                      valueColor: kColorGreen,
                    ),
                  ),
                  AppSpaces.h8,
                  Expanded(
                    child: _buildInfoColumn(
                      label: 'Pending',
                      value: item.pendingQty.toStringAsFixed(2),
                      tablet: tablet,
                      valueColor: kColorSecondary,
                    ),
                  ),
                ],
              ),
              if (isSelected) ...[
                tablet ? AppSpaces.v12 : AppSpaces.v10,

                // Issue Quantity field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Issue Quantity *',
                      style: TextStyles.kMediumOutfit(
                        fontSize: tablet
                            ? FontSizes.k14FontSize
                            : FontSizes.k12FontSize,
                        color: kColorTextPrimary,
                      ),
                    ),
                    tablet ? AppSpaces.v6 : AppSpaces.v4,
                    AppTextFormField(
                      controller: qtyController,
                      hintText: 'Enter Issue Qty',
                      keyboardType: TextInputType.number,
                      floatingLabelRequired: false,
                      onChanged: (value) {
                        final qty = double.tryParse(value);
                        if (qty != null) {
                          controller.updateIssueQty(
                            grn.grnInvNo,
                            item.grnSrNo,
                            qty,
                          );
                        }
                      },
                    ),
                    tablet ? AppSpaces.v4 : AppSpaces.v2,
                    Text(
                      'Max: ${item.pendingQty.toStringAsFixed(2)} ${item.unit}',
                      style: TextStyles.kRegularOutfit(
                        fontSize: tablet
                            ? FontSizes.k12FontSize
                            : FontSizes.k10FontSize,
                        color: kColorDarkGrey,
                      ),
                    ),
                  ],
                ),

                tablet ? AppSpaces.v12 : AppSpaces.v10,

                // Head (Godown) dropdown
                Obx(() {
                  final selectedName =
                      controller.selectedItemGodownName[key] ?? '';
                  return AppDropdown(
                    items: controller.godownNames,
                    hintText: 'Head',
                    onChanged: (val) =>
                        controller.onItemGodownSelected(key, val),
                    selectedItem: selectedName.isNotEmpty ? selectedName : null,
                  );
                }),

                tablet ? AppSpaces.v12 : AppSpaces.v10,

                // Contractor/Sub-Contractor dropdown
                Obx(() {
                  final selectedName = controller.selectedItemCpName[key] ?? '';
                  return AppDropdown(
                    items: controller.contractorNames,
                    hintText: 'Contractor / Sub-Contractor',
                    onChanged: (val) =>
                        controller.onItemContractorSelected(key, val),
                    selectedItem: selectedName.isNotEmpty ? selectedName : null,
                  );
                }),
              ],
              if (!isSelected) ...[
                tablet ? AppSpaces.v8 : AppSpaces.v6,
                Obx(
                  () => Text(
                    controller.isInSelectionMode.value
                        ? 'Tap to select'
                        : 'Long press to select',
                    style: TextStyles.kRegularOutfit(
                      fontSize: tablet
                          ? FontSizes.k12FontSize
                          : FontSizes.k10FontSize,
                      color: kColorDarkGrey,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildInfoColumn({
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
