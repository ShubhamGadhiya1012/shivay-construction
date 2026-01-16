// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/grn_entry/controllers/grn_entry_controller.dart';
import 'package:shivay_construction/features/grn_entry/models/po_auth_item_dm.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/helpers/date_format_helper.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_text_form_field.dart';

class PoOrderCard extends StatelessWidget {
  const PoOrderCard({
    super.key,
    required this.item,
    required this.order,
    required this.controller,
  });

  final PoAuthItemDm item;
  final PoOrderDm order;
  final GrnEntryController controller;

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);
    final key = '${order.poInvNo}_${order.poSrNo}';

    return Obx(() {
      final isSelected = controller.isPoOrderSelected(
        order.poInvNo,
        order.poSrNo,
      );
      final qtyController = controller.qtyControllers[key];
      if (qtyController == null) return const SizedBox.shrink();

      return GestureDetector(
        onTap: () {
          // Single tap only works if selection mode is active
          if (controller.isInSelectionMode.value) {
            controller.togglePoOrderSelection(item, order);
          }
        },
        onLongPress: () {
          // Long press to enter selection mode and select item
          controller.onPoOrderLongPress(item, order);
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? kColorPrimary.withOpacity(0.1) : kColorWhite,
            borderRadius: BorderRadius.circular(tablet ? 10 : 8),
            border: Border.all(
              color: isSelected
                  ? kColorPrimary
                  : kColorLightGrey.withOpacity(0.3),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.poInvNo,
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
                        Text(
                          'Date: ${convertyyyyMMddToddMMyyyy(order.poDate)}',
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
                  if (isSelected)
                    Container(
                      padding: tablet ? AppPaddings.p8 : AppPaddings.p6,
                      decoration: BoxDecoration(
                        color: kColorPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: kColorWhite,
                        size: tablet ? 18 : 16,
                      ),
                    ),
                ],
              ),
              tablet ? AppSpaces.v10 : AppSpaces.v8,
              Row(
                children: [
                  Expanded(
                    child: _buildInfoColumn(
                      label: 'PO Qty',
                      value: order.poQty.toStringAsFixed(2),
                      tablet: tablet,
                    ),
                  ),
                  AppSpaces.h8,
                  Expanded(
                    child: _buildInfoColumn(
                      label: 'Rate',
                      value: item.rate.toStringAsFixed(2), // Add this
                      tablet: tablet,
                    ),
                  ),
                  AppSpaces.h8,
                  Expanded(
                    child: _buildInfoColumn(
                      label: 'Received',
                      value: order.receivedQty.toStringAsFixed(2),
                      tablet: tablet,
                      valueColor: kColorGreen,
                    ),
                  ),
                  AppSpaces.h8,
                  Expanded(
                    child: _buildInfoColumn(
                      label: 'Pending',
                      value: order.pendingQty.toStringAsFixed(2),
                      tablet: tablet,
                      valueColor: kColorSecondary,
                    ),
                  ),
                ],
              ),
              if (isSelected) ...[
                tablet ? AppSpaces.v12 : AppSpaces.v10,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GRN Quantity *',
                      style: TextStyles.kMediumOutfit(
                        fontSize: tablet
                            ? FontSizes.k14FontSize
                            : FontSizes.k12FontSize,
                        color: kColorTextPrimary,
                      ),
                    ),
                    tablet ? AppSpaces.v6 : AppSpaces.v4,
                    // Wrap TextField in GestureDetector with behavior to absorb pointer events from parent
                    GestureDetector(
                      onTap: () {
                        // Do nothing - let the TextField handle the tap
                      },
                      child: AbsorbPointer(
                        absorbing: false, // Allow interaction with TextField
                        child: AppTextFormField(
                          controller: qtyController,
                          hintText: 'Enter GRN Qty',
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final qty = double.tryParse(value);
                            if (qty != null) {
                              controller.updateGrnQty(
                                order.poInvNo,
                                order.poSrNo,
                                qty,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    tablet ? AppSpaces.v4 : AppSpaces.v2,
                    Text(
                      'Max: ${order.pendingQty.toStringAsFixed(2)} ${item.unit}',
                      style: TextStyles.kRegularOutfit(
                        fontSize: tablet
                            ? FontSizes.k12FontSize
                            : FontSizes.k10FontSize,
                        color: kColorDarkGrey,
                      ),
                    ),
                  ],
                ),
              ],
              if (!isSelected) ...[
                tablet ? AppSpaces.v10 : AppSpaces.v8,
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
