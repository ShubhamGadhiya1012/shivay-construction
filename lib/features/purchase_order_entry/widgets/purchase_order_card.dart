// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/indent_entry/screens/site_wise_stock_screen.dart';
import 'package:shivay_construction/features/purchase_order_entry/controllers/purchase_order_list_controller.dart';
import 'package:shivay_construction/features/purchase_order_entry/models/purchase_order_list_dm.dart';
import 'package:shivay_construction/features/purchase_order_entry/screens/purchase_order_pdf_screen.dart';
import 'package:shivay_construction/features/purchase_order_entry/screens/purchase_order_screen.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/helpers/date_format_helper.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_button.dart';

class PurchaseOrderCard extends StatefulWidget {
  const PurchaseOrderCard({
    super.key,
    required this.order,
    required this.controller,
    required this.isExpanded,
    required this.onTap,
    required this.onDelete,
  });

  final PurchaseOrderListDm order;
  final PurchaseOrderListController controller;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  State<PurchaseOrderCard> createState() => _PurchaseOrderCardState();
}

class _PurchaseOrderCardState extends State<PurchaseOrderCard> {
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
          onTap: () async {
            if (!widget.isExpanded) {
              await widget.controller.getOrderDetailsForCard(
                widget.order.invNo,
              );
            }
            widget.onTap();
          },
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
                            widget.order.invNo,
                            style: TextStyles.kBoldOutfit(
                              fontSize: tablet
                                  ? FontSizes.k20FontSize
                                  : FontSizes.k18FontSize,
                              color: kColorPrimary,
                            ),
                          ),
                          AppSpaces.v4,
                          Text(
                            'Date: ${convertyyyyMMddToddMMyyyy(widget.order.date)}',
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
                    tablet ? AppSpaces.h12 : AppSpaces.h8,
                    Material(
                      color: kColorSecondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(tablet ? 10 : 8),
                      child: InkWell(
                        onTap: () async {
                          await widget.controller.getOrderDetailsForCard(
                            widget.order.invNo,
                          );
                          PurchaseOrderPdfScreen.generatePurchaseOrderPdf(
                            order: widget.order,
                            orderDetails: widget.controller.orderDetails
                                .toList(),
                          );
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
                          child: Icon(
                            Icons.picture_as_pdf_rounded,
                            size: tablet ? 18 : 16,
                            color: kColorSecondary,
                          ),
                        ),
                      ),
                    ),

                    if (!widget.order.authorize) ...[
                      tablet ? AppSpaces.h8 : AppSpaces.h6,
                      Material(
                        color: kColorPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(tablet ? 10 : 8),
                        child: InkWell(
                          onTap: () async {
                            await widget.controller.getOrderDetailsForCard(
                              widget.order.invNo,
                            );
                            Get.to(
                              () => PurchaseOrderScreen(
                                order: widget.order,
                                orderDetails: widget.controller.orderDetails
                                    .toList(),
                              ),
                            );
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
                                  Icons.edit_rounded,
                                  size: tablet ? 18 : 16,
                                  color: kColorPrimary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                    AppSpaces.h8,
                    if (widget.controller.isAdmin.value) ...[
                      Material(
                        color: kColorRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(tablet ? 10 : 8),
                        child: InkWell(
                          onTap: () => _showDeleteDialog(context, tablet),
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
                            child: Icon(
                              Icons.delete_rounded,
                              size: tablet ? 18 : 16,
                              color: kColorRed,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                tablet ? AppSpaces.v16 : AppSpaces.v12,
                Divider(height: 1, color: kColorLightGrey.withOpacity(0.5)),
                tablet ? AppSpaces.v16 : AppSpaces.v12,
                _buildInfoRow(
                  label: 'Party',
                  value: widget.order.pName,
                  tablet: tablet,
                ),
                tablet ? AppSpaces.v12 : AppSpaces.v10,
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        label: 'Godown',
                        value: widget.order.gdName,
                        tablet: tablet,
                      ),
                    ),
                    tablet ? AppSpaces.h12 : AppSpaces.h10,
                    Expanded(
                      child: _buildInfoRow(
                        label: 'Site',
                        value: widget.order.siteName,
                        tablet: tablet,
                      ),
                    ),
                  ],
                ),
                if (widget.order.remarks.isNotEmpty) ...[
                  tablet ? AppSpaces.v12 : AppSpaces.v10,
                  _buildInfoRow(
                    label: 'Remarks',
                    value: widget.order.remarks,
                    tablet: tablet,
                  ),
                ],
                tablet ? AppSpaces.v12 : AppSpaces.v10,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoRow(
                      label: 'Total Amount',
                      value: '₹ ${widget.order.amount.toStringAsFixed(2)}',
                      tablet: tablet,
                    ),
                    tablet ? AppSpaces.h12 : AppSpaces.h8,
                    AnimatedRotation(
                      turns: widget.isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: tablet ? 28 : 24,
                        color: kColorPrimary,
                      ),
                    ),
                  ],
                ),
                tablet ? AppSpaces.v12 : AppSpaces.v10,
                Row(
                  children: [
                    Container(
                      padding: tablet
                          ? AppPaddings.combined(horizontal: 12, vertical: 6)
                          : AppPaddings.combined(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          widget.order.poStatus,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _getStatusColor(
                            widget.order.poStatus,
                          ).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        widget.order.poStatus,
                        style: TextStyles.kMediumOutfit(
                          fontSize: tablet
                              ? FontSizes.k14FontSize
                              : FontSizes.k12FontSize,
                          color: _getStatusColor(widget.order.poStatus),
                        ),
                      ),
                    ),
                    if (!widget.order.authorize &&
                        widget.controller.canAuthorizePO.value) ...[
                      const Spacer(),
                      SizedBox(
                        width: tablet ? 140 : 120,
                        child: AppButton(
                          title: 'Authorize',
                          buttonHeight: tablet ? 40 : 36,
                          onPressed: () => _showAuthorizeDialog(context),
                        ),
                      ),
                    ],
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
                        'Order Items',
                        style: TextStyles.kSemiBoldOutfit(
                          fontSize: tablet
                              ? FontSizes.k18FontSize
                              : FontSizes.k16FontSize,
                          color: kColorTextPrimary,
                        ),
                      ),
                      tablet ? AppSpaces.v12 : AppSpaces.v8,
                      Obx(() {
                        if (widget.controller.orderDetails.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: AppPaddings.pv12,
                              child: Text(
                                'No items found',
                                style: TextStyles.kRegularOutfit(
                                  fontSize: tablet
                                      ? FontSizes.k14FontSize
                                      : FontSizes.k12FontSize,
                                  color: kColorDarkGrey,
                                ),
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: widget.controller.orderDetails.length,
                          itemBuilder: (context, itemIndex) {
                            final item =
                                widget.controller.orderDetails[itemIndex];

                            return Container(
                              margin: AppPaddings.custom(
                                bottom: tablet ? 10 : 8,
                              ),
                              decoration: BoxDecoration(
                                color: kColorWhite,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: kColorPrimary.withOpacity(0.2),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: tablet
                                        ? AppPaddings.combined(
                                            horizontal: 12,
                                            vertical: 10,
                                          )
                                        : AppPaddings.combined(
                                            horizontal: 10,
                                            vertical: 8,
                                          ),
                                    decoration: BoxDecoration(
                                      color: kColorPrimary.withOpacity(0.08),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: tablet
                                              ? AppPaddings.p6
                                              : AppPaddings.p4,
                                          decoration: BoxDecoration(
                                            color: kColorPrimary,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.inventory_2_outlined,
                                            color: kColorWhite,
                                            size: tablet ? 16 : 14,
                                          ),
                                        ),
                                        tablet ? AppSpaces.h10 : AppSpaces.h8,
                                        Expanded(
                                          child: Text(
                                            item.iName,
                                            style: TextStyles.kSemiBoldOutfit(
                                              fontSize: tablet
                                                  ? FontSizes.k14FontSize
                                                  : FontSizes.k12FontSize,
                                              color: kColorTextPrimary,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Padding(
                                    padding: tablet
                                        ? AppPaddings.combined(
                                            horizontal: 12,
                                            vertical: 10,
                                          )
                                        : AppPaddings.combined(
                                            horizontal: 10,
                                            vertical: 8,
                                          ),
                                    child: Column(
                                      children: item.indents.asMap().entries.map((
                                        entry,
                                      ) {
                                        final indentIndex = entry.key;
                                        final indent = entry.value;
                                        final isLast =
                                            indentIndex ==
                                            item.indents.length - 1;

                                        return Container(
                                          margin: AppPaddings.custom(
                                            bottom: isLast
                                                ? 0
                                                : (tablet ? 8 : 6),
                                          ),
                                          padding: tablet
                                              ? AppPaddings.combined(
                                                  horizontal: 10,
                                                  vertical: 8,
                                                )
                                              : AppPaddings.combined(
                                                  horizontal: 8,
                                                  vertical: 7,
                                                ),
                                          decoration: BoxDecoration(
                                            color: kColorPrimary.withOpacity(
                                              0.04,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: kColorPrimary.withOpacity(
                                                0.15,
                                              ),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    width: tablet ? 4 : 3,
                                                    height: tablet ? 24 : 20,
                                                    decoration: BoxDecoration(
                                                      color: kColorPrimary,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            2,
                                                          ),
                                                    ),
                                                  ),
                                                  tablet
                                                      ? AppSpaces.h10
                                                      : AppSpaces.h8,
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          indent.indentInvNo,
                                                          style: TextStyles.kMediumOutfit(
                                                            fontSize: tablet
                                                                ? FontSizes
                                                                      .k12FontSize
                                                                : FontSizes
                                                                      .k12FontSize,
                                                            color:
                                                                kColorTextPrimary,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        AppSpaces.v2,
                                                        Row(
                                                          children: [
                                                            Text(
                                                              indent.unit,
                                                              style: TextStyles.kRegularOutfit(
                                                                fontSize: tablet
                                                                    ? FontSizes
                                                                          .k10FontSize
                                                                    : FontSizes
                                                                          .k10FontSize,
                                                                color:
                                                                    kColorDarkGrey,
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  AppPaddings.combined(
                                                                    horizontal:
                                                                        6,
                                                                    vertical: 0,
                                                                  ),
                                                              child: Container(
                                                                width: 3,
                                                                height: 3,
                                                                decoration: BoxDecoration(
                                                                  color:
                                                                      kColorDarkGrey,
                                                                  shape: BoxShape
                                                                      .circle,
                                                                ),
                                                              ),
                                                            ),
                                                            Text(
                                                              'Qty: ${indent.orderQty.toStringAsFixed(2)}',
                                                              style: TextStyles.kMediumOutfit(
                                                                fontSize: tablet
                                                                    ? FontSizes
                                                                          .k10FontSize
                                                                    : FontSizes
                                                                          .k10FontSize,
                                                                color:
                                                                    kColorPrimary,
                                                              ),
                                                            ),

                                                            if (indent.price !=
                                                                null) ...[
                                                              Padding(
                                                                padding:
                                                                    AppPaddings.combined(
                                                                      horizontal:
                                                                          6,
                                                                      vertical:
                                                                          0,
                                                                    ),
                                                                child: Container(
                                                                  width: 3,
                                                                  height: 3,
                                                                  decoration: BoxDecoration(
                                                                    color:
                                                                        kColorDarkGrey,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                ),
                                                              ),
                                                              Text(
                                                                'Rate: ₹${indent.price!.toStringAsFixed(2)}',
                                                                style: TextStyles.kRegularOutfit(
                                                                  fontSize:
                                                                      tablet
                                                                      ? FontSizes
                                                                            .k10FontSize
                                                                      : FontSizes
                                                                            .k10FontSize,
                                                                  color:
                                                                      kColorDarkGrey,
                                                                ),
                                                              ),
                                                            ],
                                                          ],
                                                        ),
                                                        Text(
                                                          'Amt: ₹${indent.amount!.toStringAsFixed(2)}',
                                                          style: TextStyles.kMediumOutfit(
                                                            fontSize: tablet
                                                                ? FontSizes
                                                                      .k10FontSize
                                                                : FontSizes
                                                                      .k10FontSize,
                                                            color: kColorGreen,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  Material(
                                                    color: kColorGreen
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          tablet ? 6 : 5,
                                                        ),
                                                    child: InkWell(
                                                      onTap: () {
                                                        Get.to(
                                                          () =>
                                                              SiteWiseStockScreen(
                                                                iCode:
                                                                    item.iCode,
                                                              ),
                                                        );
                                                      },
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
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }),
                    ],
                  ),
                  crossFadeState: widget.isExpanded
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

  void _showAuthorizeDialog(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tablet ? 20 : 16),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: tablet ? 400 : double.infinity,
          constraints: BoxConstraints(
            maxWidth: tablet ? 400 : MediaQuery.of(context).size.width * 0.9,
          ),
          decoration: BoxDecoration(
            color: kColorWhite,
            borderRadius: BorderRadius.circular(tablet ? 20 : 16),
            boxShadow: [
              BoxShadow(
                color: kColorGreen.withOpacity(0.15),
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
                  color: kColorGreen.withOpacity(0.08),
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
                        color: kColorGreen.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(tablet ? 12 : 10),
                      ),
                      child: Icon(
                        Icons.check_circle_outline,
                        color: kColorGreen,
                        size: tablet ? 26 : 22,
                      ),
                    ),
                    tablet ? AppSpaces.h12 : AppSpaces.h10,
                    Expanded(
                      child: Text(
                        'Confirm Authorization',
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
                      'Are you sure you want to authorize this Purchase Order?',
                      style: TextStyles.kRegularOutfit(
                        fontSize: tablet
                            ? FontSizes.k16FontSize
                            : FontSizes.k14FontSize,
                        color: kColorDarkGrey,
                      ),
                    ),
                    tablet ? AppSpaces.v8 : AppSpaces.v6,
                    Text(
                      'PO No: ${widget.order.invNo}',
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
                            onPressed: () => Navigator.of(dialogContext).pop(),
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
                            title: 'Authorize',
                            buttonColor: kColorGreen,
                            titleColor: kColorWhite,
                            titleSize: tablet
                                ? FontSizes.k16FontSize
                                : FontSizes.k14FontSize,
                            buttonHeight: tablet ? 54 : 48,
                            onPressed: () {
                              widget.controller.authorizePurchaseOrder(
                                invNo: widget.order.invNo,
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
                        'Delete Purchase Order',
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
                      'Are you sure you want to delete "${widget.order.invNo}"?',
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
                            onPressed: widget.onDelete,
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'complete':
        return kColorGreen;
      case 'partial':
        return kColorSecondary;
      case 'pending':
        return kColorSecondary;
      default:
        return kColorDarkGrey;
    }
  }
}
