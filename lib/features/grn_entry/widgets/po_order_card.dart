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
import 'package:shivay_construction/widgets/app_dropdown.dart';
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
          if (controller.isInSelectionMode.value) {
            controller.togglePoOrderSelection(item, order);
          }
        },
        onLongPress: () {
          if (!controller.isInSelectionMode.value) {
            controller.isInSelectionMode.value = true;
          }
          controller.togglePoOrderSelection(item, order);
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
                        if (!isSelected && order.gdName.isNotEmpty) ...[
                          AppSpaces.v2,
                          Text(
                            'Head: ${order.gdName}',
                            style: TextStyles.kRegularOutfit(
                              fontSize: tablet
                                  ? FontSizes.k12FontSize
                                  : FontSizes.k10FontSize,
                              color: kColorDarkGrey,
                            ),
                          ),
                        ],
                        if (!isSelected && order.poRemark.isNotEmpty) ...[
                          AppSpaces.v2,
                          Text(
                            'Remark: ${order.poRemark}',
                            style: TextStyles.kRegularOutfit(
                              fontSize: tablet
                                  ? FontSizes.k12FontSize
                                  : FontSizes.k10FontSize,
                              color: kColorDarkGrey,
                            ),
                          ),
                        ],

                        AppSpaces.v2,
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'SiteName : ${order.siteName} ',
                                style: TextStyles.kRegularOutfit(
                                  fontSize: tablet
                                      ? FontSizes.k12FontSize
                                      : FontSizes.k10FontSize,
                                  color: kColorDarkGrey,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'PartyName: ${order.pName}',
                                style: TextStyles.kRegularOutfit(
                                  fontSize: tablet
                                      ? FontSizes.k12FontSize
                                      : FontSizes.k10FontSize,
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
                      value: item.rate.toStringAsFixed(2),
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
                    AppTextFormField(
                      controller: qtyController,
                      hintText: 'Enter GRN Qty',
                      keyboardType: TextInputType.number,
                      floatingLabelRequired: false,
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
                tablet ? AppSpaces.v12 : AppSpaces.v10,

                Obx(() {
                  return AppDropdown(
                    items: controller.godownNames,
                    hintText: 'Head',
                    onChanged: (val) => controller.onPoGodownSelected(key, val),
                    selectedItem:
                        (controller.selectedPoGodownName[key] ?? '').isNotEmpty
                        ? controller.selectedPoGodownName[key]
                        : null,
                    fillColor: kColorLightGrey,
                    enabled: false,
                  );
                }),
                tablet ? AppSpaces.v12 : AppSpaces.v10,

                Builder(
                  builder: (context) {
                    final remarkController =
                        controller.poRemarkControllers[key];
                    if (remarkController == null) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Remark',
                          style: TextStyles.kMediumOutfit(
                            fontSize: tablet
                                ? FontSizes.k14FontSize
                                : FontSizes.k12FontSize,
                            color: kColorTextPrimary,
                          ),
                        ),
                        tablet ? AppSpaces.v6 : AppSpaces.v4,
                        AppTextFormField(
                          controller: remarkController,
                          hintText: 'Enter Remark',
                          maxLines: 2,
                          floatingLabelRequired: false,
                          onChanged: (value) {
                            if (controller.selectedPoOrders.containsKey(key)) {
                              controller.selectedPoOrders[key]!['PORemark'] =
                                  value;
                              controller.selectedPoOrders.refresh();
                            }
                          },
                        ),
                      ],
                    );
                  },
                ),
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
