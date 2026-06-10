import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/purchase_order_entry/controllers/purchase_order_controller.dart';
import 'package:shivay_construction/features/purchase_order_entry/models/auth_indent_item_dm.dart';
import 'package:shivay_construction/features/purchase_order_entry/screens/last_purchase_rate_screen.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';
import 'package:shivay_construction/utils/helpers/date_format_helper.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_button.dart';
import 'package:shivay_construction/widgets/app_date_picker_text_form_field.dart';
import 'package:shivay_construction/widgets/app_dropdown.dart';
import 'package:shivay_construction/widgets/app_text_form_field.dart';

import '../../indent_entry/screens/site_wise_stock_screen.dart';

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
                      child: Text(
                        item.indentNo,
                        style: TextStyles.kBoldOutfit(
                          fontSize: tablet
                              ? FontSizes.k20FontSize
                              : FontSizes.k18FontSize,
                          color: kColorPrimary,
                        ),
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
                        'Items (${item.items.length})',
                        style: TextStyles.kSemiBoldOutfit(
                          fontSize: tablet
                              ? FontSizes.k18FontSize
                              : FontSizes.k16FontSize,
                          color: kColorTextPrimary,
                        ),
                      ),
                      tablet ? AppSpaces.v12 : AppSpaces.v8,
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: item.items.length,
                        itemBuilder: (context, index) {
                          final indent = item.items[index];
                          final key = '${item.indentNo}_${indent.indentSrNo}';
                          final qtyController = controller.qtyControllers[key];
                          final priceController =
                              controller.priceControllers[key];
                          final dateController =
                              controller.dateControllers[key];
                          final remarkController =
                              controller.remarkControllers[key];

                          Widget buildHsnInfoRow() {
                            if (indent.hsnNo.isEmpty)
                              return const SizedBox.shrink();

                            return Container(
                              margin: AppPaddings.custom(top: 6),
                              padding: tablet
                                  ? AppPaddings.combined(
                                      horizontal: 10,
                                      vertical: 6,
                                    )
                                  : AppPaddings.combined(
                                      horizontal: 8,
                                      vertical: 5,
                                    ),
                              decoration: BoxDecoration(
                                color: kColorGreen.withOpacity(0.07),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: kColorGreen.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'HSN: ${indent.hsnNo}',
                                    style: TextStyles.kMediumOutfit(
                                      fontSize: tablet
                                          ? FontSizes.k12FontSize
                                          : FontSizes.k10FontSize,
                                      color: kColorGreen,
                                    ),
                                  ),
                                  if (indent.igst > 0 ||
                                      indent.cgst > 0 ||
                                      indent.sgst > 0) ...[
                                    AppSpaces.v4,
                                    Text(
                                      'IGST: ${indent.igst}%   CGST: ${indent.cgst}%   SGST: ${indent.sgst}%',
                                      style: TextStyles.kRegularOutfit(
                                        fontSize: tablet
                                            ? FontSizes.k12FontSize
                                            : FontSizes.k10FontSize,
                                        color: kColorBlack,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }

                          Widget buildHsnDropdownRow() {
                            if (indent.hsnNo.isNotEmpty) {
                              return const SizedBox.shrink();
                            }

                            return Obx(() {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  tablet ? AppSpaces.v10 : AppSpaces.v8,
                                  Row(
                                    children: [
                                      Expanded(
                                        child: AppDropdown(
                                          hintText: 'Assign HSN No',
                                          items: controller.hsnNumbers,
                                          selectedItem:
                                              controller
                                                      .selectedHsnForIndent[key]
                                                      ?.isNotEmpty ==
                                                  true
                                              ? controller
                                                    .selectedHsnForIndent[key]
                                              : null,
                                          onChanged: (value) {
                                            if (value != null &&
                                                value.isNotEmpty) {
                                              WidgetsBinding.instance
                                                  .addPostFrameCallback((_) {
                                                    controller
                                                            .selectedHsnForIndent[key] =
                                                        value;
                                                    controller
                                                        .selectedHsnForIndent
                                                        .refresh();
                                                  });
                                            }
                                          },
                                        ),
                                      ),
                                      tablet ? AppSpaces.h10 : AppSpaces.h8,
                                      Material(
                                        color: kColorPrimary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(
                                          tablet ? 8 : 6,
                                        ),
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(
                                            tablet ? 8 : 6,
                                          ),
                                          onTap: () {
                                            final selectedHsn =
                                                controller
                                                    .selectedHsnForIndent[key] ??
                                                '';
                                            if (selectedHsn.isEmpty) {
                                              showErrorSnackbar(
                                                'Error',
                                                'Please select an HSN No',
                                              );
                                              return;
                                            }
                                            _showHsnConfirmDialog(
                                              context,
                                              tablet: tablet,
                                              iCode: indent.iCode,
                                              iName: indent.iName,
                                              hsnNo: selectedHsn,
                                              key: key,
                                            );
                                          },
                                          child: Container(
                                            padding: tablet
                                                ? AppPaddings.combined(
                                                    horizontal: 12,
                                                    vertical: 12,
                                                  )
                                                : AppPaddings.combined(
                                                    horizontal: 10,
                                                    vertical: 10,
                                                  ),
                                            child: Icon(
                                              Icons.check_rounded,
                                              size: tablet ? 20 : 18,
                                              color: kColorPrimary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            });
                          }

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
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    indent.iName,
                                                    style:
                                                        TextStyles.kSemiBoldOutfit(
                                                          fontSize: tablet
                                                              ? FontSizes
                                                                    .k16FontSize
                                                              : FontSizes
                                                                    .k14FontSize,
                                                          color:
                                                              kColorTextPrimary,
                                                        ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    Material(
                                                      color: kColorGreen
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            tablet ? 6 : 5,
                                                          ),
                                                      child: InkWell(
                                                        onTap: () => Get.to(
                                                          () =>
                                                              SiteWiseStockScreen(
                                                                iCode: indent
                                                                    .iCode,
                                                              ),
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              tablet ? 6 : 5,
                                                            ),
                                                        child: Container(
                                                          padding: tablet
                                                              ? AppPaddings.combined(
                                                                  horizontal: 8,
                                                                  vertical: 8,
                                                                )
                                                              : AppPaddings.combined(
                                                                  horizontal: 6,
                                                                  vertical: 6,
                                                                ),
                                                          child: Icon(
                                                            Icons
                                                                .visibility_rounded,
                                                            size: tablet
                                                                ? 16
                                                                : 14,
                                                            color: kColorGreen,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    tablet
                                                        ? AppSpaces.h8
                                                        : AppSpaces.h6,
                                                    Material(
                                                      color: kColorSecondary
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            tablet ? 6 : 5,
                                                          ),
                                                      child: InkWell(
                                                        onTap: () => Get.to(
                                                          () =>
                                                              LastPurchaseRateScreen(
                                                                iCode: indent
                                                                    .iCode,
                                                              ),
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              tablet ? 6 : 5,
                                                            ),
                                                        child: Container(
                                                          padding: tablet
                                                              ? AppPaddings.combined(
                                                                  horizontal: 8,
                                                                  vertical: 8,
                                                                )
                                                              : AppPaddings.combined(
                                                                  horizontal: 6,
                                                                  vertical: 6,
                                                                ),
                                                          child: Icon(
                                                            Icons
                                                                .currency_rupee_rounded,
                                                            size: tablet
                                                                ? 16
                                                                : 14,
                                                            color:
                                                                kColorSecondary,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            AppSpaces.v4,
                                            Text(
                                              'Required Date: ${convertyyyyMMddToddMMyyyy(indent.reqDate)}',
                                              style: TextStyles.kRegularOutfit(
                                                fontSize: tablet
                                                    ? FontSizes.k12FontSize
                                                    : FontSizes.k10FontSize,
                                                color: kColorDarkGrey,
                                              ),
                                            ),
                                            if (indent.gdName.isNotEmpty ||
                                                indent.siteName.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 4,
                                                ),
                                                child: Row(
                                                  children: [
                                                    if (indent
                                                        .gdName
                                                        .isNotEmpty)
                                                      Expanded(
                                                        child: Text(
                                                          'Head: ${indent.gdName}',
                                                          style: TextStyles.kRegularOutfit(
                                                            fontSize: tablet
                                                                ? FontSizes
                                                                      .k12FontSize
                                                                : FontSizes
                                                                      .k10FontSize,
                                                            color:
                                                                kColorDarkGrey,
                                                          ),
                                                        ),
                                                      ),
                                                    if (indent
                                                            .gdName
                                                            .isNotEmpty &&
                                                        indent
                                                            .siteName
                                                            .isNotEmpty)
                                                      const SizedBox(width: 8),
                                                    if (indent
                                                        .siteName
                                                        .isNotEmpty)
                                                      Expanded(
                                                        child: Text(
                                                          'Site: ${indent.siteName}',
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyles.kRegularOutfit(
                                                            fontSize: tablet
                                                                ? FontSizes
                                                                      .k12FontSize
                                                                : FontSizes
                                                                      .k10FontSize,
                                                            color:
                                                                kColorDarkGrey,
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            if (indent
                                                .indentRemark
                                                .isNotEmpty) ...[
                                              AppSpaces.v4,
                                              Text(
                                                'Remark: ${indent.indentRemark}',
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
                                            ],

                                            buildHsnInfoRow(),
                                          ],
                                        ),
                                      ),
                                      if (indent.isSelected &&
                                          qtyController != null &&
                                          priceController != null)
                                        Text(
                                          'Auth Qty: ${indent.authoriseQty.toStringAsFixed(2)}',
                                          style: TextStyles.kRegularOutfit(
                                            fontSize: tablet
                                                ? FontSizes.k12FontSize
                                                : FontSizes.k10FontSize,
                                            color: kColorDarkGrey,
                                          ),
                                        ),
                                    ],
                                  ),

                                  buildHsnDropdownRow(),

                                  if (indent.isSelected &&
                                      qtyController != null &&
                                      priceController != null &&
                                      dateController != null) ...[
                                    tablet ? AppSpaces.v12 : AppSpaces.v10,
                                    AppDatePickerTextFormField(
                                      dateController: dateController,
                                      hintText: 'Required Date',
                                      validator: (value) =>
                                          (value == null || value.isEmpty)
                                          ? 'Required'
                                          : null,
                                    ),
                                    tablet ? AppSpaces.v12 : AppSpaces.v10,
                                    Obx(() {
                                      final siteCode = indent.siteCode;
                                      final filteredGodownNames = controller
                                          .getGodownNamesBySite(siteCode);
                                      return AppDropdown(
                                        items: filteredGodownNames,
                                        hintText: 'Head',
                                        onChanged: (val) =>
                                            controller.onGodownSelected(
                                              key,
                                              val,
                                              siteCode: siteCode,
                                            ),
                                        selectedItem:
                                            (controller.selectedGodownName[key] ??
                                                    '')
                                                .isNotEmpty
                                            ? controller.selectedGodownName[key]
                                            : null,
                                      );
                                    }),
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
                                              AppTextFormField(
                                                controller: qtyController,
                                                hintText: 'Enter Quantity',
                                                keyboardType:
                                                    TextInputType.number,
                                                floatingLabelRequired: false,
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty)
                                                    return 'Required';
                                                  final qty = double.tryParse(
                                                    value,
                                                  );
                                                  if (qty == null || qty <= 0)
                                                    return 'Must be > 0';
                                                  return null;
                                                },
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
                                              AppTextFormField(
                                                controller: priceController,
                                                hintText: 'Enter Price',
                                                keyboardType:
                                                    TextInputType.number,
                                                floatingLabelRequired: false,
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty)
                                                    return 'Required';
                                                  final price = double.tryParse(
                                                    value,
                                                  );
                                                  if (price == null ||
                                                      price <= 0)
                                                    return 'Must be > 0';
                                                  return null;
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    tablet ? AppSpaces.v12 : AppSpaces.v10,
                                    Obx(() {
                                      final percCtrl = controller
                                          .discountPercControllers[key];
                                      final amtCtrl = controller
                                          .discountAmountControllers[key];
                                      if (percCtrl == null || amtCtrl == null)
                                        return const SizedBox.shrink();
                                      return Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Discount %',
                                                  style:
                                                      TextStyles.kMediumOutfit(
                                                        fontSize: tablet
                                                            ? FontSizes
                                                                  .k14FontSize
                                                            : FontSizes
                                                                  .k12FontSize,
                                                        color:
                                                            kColorTextPrimary,
                                                      ),
                                                ),
                                                tablet
                                                    ? AppSpaces.v6
                                                    : AppSpaces.v4,
                                                AppTextFormField(
                                                  controller: percCtrl,
                                                  hintText: 'Disc %',
                                                  keyboardType:
                                                      TextInputType.number,
                                                  floatingLabelRequired: false,
                                                  onChanged: (val) => controller
                                                      .onDiscountPercChanged(
                                                        key,
                                                        val,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          tablet
                                              ? AppSpaces.h12
                                              : AppSpaces.h10,
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Discount Amt',
                                                  style:
                                                      TextStyles.kMediumOutfit(
                                                        fontSize: tablet
                                                            ? FontSizes
                                                                  .k14FontSize
                                                            : FontSizes
                                                                  .k12FontSize,
                                                        color:
                                                            kColorTextPrimary,
                                                      ),
                                                ),
                                                tablet
                                                    ? AppSpaces.v6
                                                    : AppSpaces.v4,
                                                AppTextFormField(
                                                  controller: amtCtrl,
                                                  hintText: 'Disc Amt',
                                                  keyboardType:
                                                      TextInputType.number,
                                                  floatingLabelRequired: false,
                                                  onChanged: (val) => controller
                                                      .onDiscountAmountChanged(
                                                        key,
                                                        val,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                                    tablet ? AppSpaces.v12 : AppSpaces.v10,
                                    if (remarkController != null) ...[
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
                                      ),
                                    ],
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

  void _showHsnConfirmDialog(
    BuildContext context, {
    required bool tablet,
    required String iCode,
    required String iName,
    required String hsnNo,
    required String key,
  }) {
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
          width: tablet ? 420 : double.infinity,
          constraints: BoxConstraints(
            maxWidth: tablet ? 420 : MediaQuery.of(context).size.width * 0.9,
          ),
          decoration: BoxDecoration(
            color: kColorWhite,
            borderRadius: BorderRadius.circular(tablet ? 20 : 16),
            boxShadow: [
              BoxShadow(
                color: kColorPrimary.withOpacity(0.15),
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
                  color: kColorPrimary.withOpacity(0.08),
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
                        color: kColorPrimary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(tablet ? 12 : 10),
                      ),
                      child: Icon(
                        Icons.tag_rounded,
                        color: kColorPrimary,
                        size: tablet ? 26 : 22,
                      ),
                    ),
                    tablet ? AppSpaces.h12 : AppSpaces.h10,
                    Expanded(
                      child: Text(
                        'Update HSN No',
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
                      'Are you sure you want to assign HSN No to this item?',
                      style: TextStyles.kRegularOutfit(
                        fontSize: tablet
                            ? FontSizes.k16FontSize
                            : FontSizes.k14FontSize,
                        color: kColorDarkGrey,
                      ),
                    ),
                    tablet ? AppSpaces.v10 : AppSpaces.v8,
                    Text(
                      'Item: $iName',
                      style: TextStyles.kMediumOutfit(
                        fontSize: tablet
                            ? FontSizes.k14FontSize
                            : FontSizes.k12FontSize,
                        color: kColorTextPrimary,
                      ),
                    ),
                    AppSpaces.v4,
                    Text(
                      'HSN No: $hsnNo',
                      style: TextStyles.kMediumOutfit(
                        fontSize: tablet
                            ? FontSizes.k14FontSize
                            : FontSizes.k12FontSize,
                        color: kColorPrimary,
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
                            title: 'Confirm',
                            buttonColor: kColorPrimary,
                            titleColor: kColorWhite,
                            titleSize: tablet
                                ? FontSizes.k16FontSize
                                : FontSizes.k14FontSize,
                            buttonHeight: tablet ? 54 : 48,
                            onPressed: () {
                              Get.back();
                              controller.updateIndentHSN(
                                key: key,
                                iCode: iCode,
                                hsnNo: hsnNo,
                              );
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
