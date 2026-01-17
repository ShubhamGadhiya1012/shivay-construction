// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/indent_entry/controllers/indents_controller.dart';
import 'package:shivay_construction/features/indent_entry/models/indent_detail_dm.dart';
import 'package:shivay_construction/features/indent_entry/models/indent_dm.dart';
import 'package:shivay_construction/features/indent_entry/screens/indent_entry_screen.dart';
import 'package:shivay_construction/features/indent_entry/screens/indent_pdf_screen.dart';
import 'package:shivay_construction/features/indent_entry/screens/site_wise_stock_screen.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/helpers/date_format_helper.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_button.dart';
import 'package:shivay_construction/widgets/app_text_form_field.dart';

class IndentCard extends StatefulWidget {
  const IndentCard({super.key, required this.indent, required this.controller});

  final IndentDm indent;
  final IndentsController controller;

  @override
  State<IndentCard> createState() => _IndentCardState();
}

class _IndentCardState extends State<IndentCard> {
  bool isExpanded = false;

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
            if (!isExpanded) {
              await widget.controller.getIndentDetails(
                invNo: widget.indent.invNo,
              );
            }
            setState(() {
              isExpanded = !isExpanded;
            });
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
                            widget.indent.invNo,
                            style: TextStyles.kBoldOutfit(
                              fontSize: tablet
                                  ? FontSizes.k20FontSize
                                  : FontSizes.k18FontSize,
                              color: kColorPrimary,
                            ),
                          ),
                          AppSpaces.v4,
                          Text(
                            'Date: ${convertyyyyMMddToddMMyyyy(widget.indent.date)}',
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
                          await widget.controller.getIndentDetails(
                            invNo: widget.indent.invNo,
                          );
                          IndentPdfScreen.generateIndentPdf(
                            indent: widget.indent,
                            indentDetails: widget.controller.indentDetails
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
                          child: Row(
                            children: [
                              Icon(
                                Icons.picture_as_pdf_rounded,
                                size: tablet ? 18 : 16,
                                color: kColorSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    AppSpaces.h8,
                    if (!widget.indent.authorize && !widget.indent.closeIndent)
                      Material(
                        color: kColorPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(tablet ? 10 : 8),
                        child: InkWell(
                          onTap: () async {
                            await widget.controller.getIndentDetails(
                              invNo: widget.indent.invNo,
                            );
                            Get.to(
                              () => IndentEntryScreen(
                                isEdit: true,
                                indent: widget.indent,
                                indentDetails: widget.controller.indentDetails
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
                    if (!widget.indent.authorize && !widget.indent.closeIndent)
                      AppSpaces.h8,
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
                tablet ? AppSpaces.v16 : AppSpaces.v12,
                Divider(height: 1, color: kColorLightGrey.withOpacity(0.5)),
                tablet ? AppSpaces.v16 : AppSpaces.v12,
                _buildInfoRow(
                  label: 'Godown',
                  value: widget.indent.gdName,
                  tablet: tablet,
                ),
                tablet ? AppSpaces.v12 : AppSpaces.v10,
                _buildInfoRow(
                  label: 'Site',
                  value: widget.indent.siteName,
                  tablet: tablet,
                ),
                tablet ? AppSpaces.v12 : AppSpaces.v10,
                Row(
                  children: [
                    Container(
                      padding: tablet
                          ? AppPaddings.combined(horizontal: 12, vertical: 6)
                          : AppPaddings.combined(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: widget.indent.authorize
                            ? kColorGreen.withOpacity(0.1)
                            : widget.indent.closeIndent
                            ? kColorRed.withOpacity(0.1)
                            : kColorSecondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: widget.indent.authorize
                              ? kColorGreen.withOpacity(0.3)
                              : widget.indent.closeIndent
                              ? kColorRed.withOpacity(0.3)
                              : kColorSecondary.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        widget.indent.authorize
                            ? 'Authorized'
                            : widget.indent.closeIndent
                            ? 'Closed'
                            : 'Pending',
                        style: TextStyles.kMediumOutfit(
                          fontSize: tablet
                              ? FontSizes.k14FontSize
                              : FontSizes.k12FontSize,
                          color: widget.indent.authorize
                              ? kColorGreen
                              : widget.indent.closeIndent
                              ? kColorRed
                              : kColorSecondary,
                        ),
                      ),
                    ),
                    if (!widget.indent.authorize &&
                        !widget.indent.closeIndent &&
                        widget.controller.canAuthorizeIndent.value) ...[
                      const Spacer(),
                      SizedBox(
                        width: tablet ? 140 : 120,
                        child: AppButton(
                          title: 'Authorize',
                          buttonHeight: tablet ? 40 : 36,
                          onPressed: () {
                            _showAuthorizeDialog(context);
                          },
                        ),
                      ),
                    ],
                  ],
                ),
                // Add Close Indent info text for pending indents only
                if (!widget.indent.authorize && !widget.indent.closeIndent) ...[
                  tablet ? AppSpaces.v12 : AppSpaces.v10,
                  GestureDetector(
                    onTap: () => _showCloseIndentDialog(context),
                    child: Container(
                      padding: tablet
                          ? AppPaddings.combined(horizontal: 12, vertical: 8)
                          : AppPaddings.combined(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: kColorRed.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: kColorRed.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: tablet ? 18 : 16,
                            color: kColorRed,
                          ),
                          tablet ? AppSpaces.h8 : AppSpaces.h6,
                          Expanded(
                            child: Text(
                              'Tap here to close this indent without authorization',
                              style: TextStyles.kMediumOutfit(
                                fontSize: tablet
                                    ? FontSizes.k12FontSize
                                    : FontSizes.k10FontSize,
                                color: kColorRed,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: tablet ? 14 : 12,
                            color: kColorRed,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
                        'Items',
                        style: TextStyles.kSemiBoldOutfit(
                          fontSize: tablet
                              ? FontSizes.k18FontSize
                              : FontSizes.k16FontSize,
                          color: kColorTextPrimary,
                        ),
                      ),
                      tablet ? AppSpaces.v12 : AppSpaces.v8,
                      Obx(() {
                        if (widget.controller.indentDetails.isEmpty) {
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

                        // Replace the existing item ListView.builder section (around line 280-350) with this:

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: widget.controller.indentDetails.length,
                          itemBuilder: (context, index) {
                            final detail =
                                widget.controller.indentDetails[index];
                            return Container(
                              margin: AppPaddings.custom(bottom: 8),
                              padding: tablet
                                  ? AppPaddings.p12
                                  : AppPaddings.p10,
                              decoration: BoxDecoration(
                                color: kColorPrimary.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: kColorPrimary.withOpacity(0.2),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          detail.iName,
                                          style: TextStyles.kSemiBoldOutfit(
                                            fontSize: tablet
                                                ? FontSizes.k16FontSize
                                                : FontSizes.k14FontSize,
                                            color: kColorPrimary,
                                          ),
                                        ),
                                      ),
                                      AppSpaces.h8,
                                      Material(
                                        color: kColorGreen.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(
                                          tablet ? 8 : 6,
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            Get.to(
                                              () => SiteWiseStockScreen(
                                                iCode: detail.iCode,
                                              ),
                                            );
                                          },
                                          borderRadius: BorderRadius.circular(
                                            tablet ? 8 : 6,
                                          ),
                                          child: Container(
                                            padding: tablet
                                                ? AppPaddings.combined(
                                                    horizontal: 10,
                                                    vertical: 8,
                                                  )
                                                : AppPaddings.combined(
                                                    horizontal: 8,
                                                    vertical: 6,
                                                  ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.visibility_rounded,
                                                  size: tablet ? 18 : 16,
                                                  color: kColorGreen,
                                                ),
                                                AppSpaces.h4,
                                                Text(
                                                  'Stock',
                                                  style:
                                                      TextStyles.kSemiBoldOutfit(
                                                        fontSize: tablet
                                                            ? FontSizes
                                                                  .k14FontSize
                                                            : FontSizes
                                                                  .k12FontSize,
                                                        color: kColorGreen,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  AppSpaces.v8,
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildDetailRow(
                                          label: 'Unit',
                                          value: detail.unit,
                                          tablet: tablet,
                                        ),
                                      ),
                                      AppSpaces.h12,
                                      Expanded(
                                        child: _buildDetailRow(
                                          label: 'Indent Qty',
                                          value: detail.indentQty
                                              .toStringAsFixed(2),
                                          tablet: tablet,
                                        ),
                                      ),
                                    ],
                                  ),
                                  AppSpaces.v8,
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildDetailRow(
                                          label: 'Req. Date',
                                          value: convertyyyyMMddToddMMyyyy(
                                            detail.reqDate,
                                          ),
                                          tablet: tablet,
                                        ),
                                      ),
                                      if (widget.indent.authorize) ...[
                                        AppSpaces.h12,
                                        Expanded(
                                          child: _buildDetailRow(
                                            label: 'Authorized Qty',
                                            value: detail.authorizedQty
                                                .toStringAsFixed(2),
                                            tablet: tablet,
                                            valueColor: kColorGreen,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }),
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

  Widget _buildDetailRow({
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
            fontSize: tablet ? FontSizes.k12FontSize : FontSizes.k12FontSize,
            color: kColorDarkGrey,
          ),
        ),
        AppSpaces.v2,
        Text(
          value,
          style: TextStyles.kMediumOutfit(
            fontSize: tablet ? FontSizes.k14FontSize : FontSizes.k14FontSize,
            color: valueColor ?? kColorTextPrimary,
          ),
        ),
      ],
    );
  }

  void _showAuthorizeDialog(BuildContext context) async {
    final bool tablet = AppScreenUtils.isTablet(context);

    await widget.controller.getIndentDetails(invNo: widget.indent.invNo);

    final authorizeControllers = <int, TextEditingController>{};
    final formKey = GlobalKey<FormState>();

    final currentIndentDetails = List<IndentDetailDm>.from(
      widget.controller.indentDetails,
    );

    for (var detail in currentIndentDetails) {
      authorizeControllers[detail.srNo] = TextEditingController(
        text: detail.indentQty.toStringAsFixed(2),
      );
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tablet ? 20 : 16),
        ),
        backgroundColor: kColorWhite,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: tablet ? 600 : MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: tablet
                    ? AppPaddings.combined(horizontal: 24, vertical: 20)
                    : AppPaddings.combined(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: kColorGreen.withOpacity(0.1),
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
                        color: kColorGreen.withOpacity(0.2),
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
                        'Authorize Indent',
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
              Flexible(
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    padding: tablet ? AppPaddings.p24 : AppPaddings.p20,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: currentIndentDetails.length,
                      itemBuilder: (context, index) {
                        final detail = currentIndentDetails[index];
                        return Container(
                          margin: AppPaddings.custom(bottom: 12),
                          padding: tablet ? AppPaddings.p16 : AppPaddings.p12,
                          decoration: BoxDecoration(
                            color: kColorPrimary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: kColorPrimary.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                detail.iName,
                                style: TextStyles.kSemiBoldOutfit(
                                  fontSize: tablet
                                      ? FontSizes.k16FontSize
                                      : FontSizes.k14FontSize,
                                  color: kColorPrimary,
                                ),
                              ),
                              AppSpaces.v8,
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Indent Qty: ${detail.indentQty.toStringAsFixed(2)} ${detail.unit}',
                                      style: TextStyles.kRegularOutfit(
                                        fontSize: tablet
                                            ? FontSizes.k14FontSize
                                            : FontSizes.k12FontSize,
                                        color: kColorDarkGrey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              AppSpaces.v12,
                              AppTextFormField(
                                controller: authorizeControllers[detail.srNo]!,
                                hintText: 'Authorized Qty *',
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter authorized qty';
                                  }
                                  final qty = double.tryParse(value);
                                  if (qty == null || qty <= 0) {
                                    return 'Please enter valid qty';
                                  }
                                  if (qty > detail.indentQty) {
                                    return 'Cannot exceed indent qty';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding: tablet ? AppPaddings.p24 : AppPaddings.p20,
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: kColorLightGrey, width: 1.5),
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
                          if (formKey.currentState!.validate()) {
                            final itemAuthData = <Map<String, dynamic>>[];

                            for (var detail in currentIndentDetails) {
                              final controller =
                                  authorizeControllers[detail.srNo];
                              if (controller != null) {
                                itemAuthData.add({
                                  "SrNo": detail.srNo,
                                  "ICode": detail.iCode,
                                  "Qty": double.parse(controller.text),
                                });
                              }
                            }

                            widget.controller.authorizeIndent(
                              invNo: widget.indent.invNo,
                              itemAuthData: itemAuthData,
                            );
                          }
                        },
                      ),
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

  void _showCloseIndentDialog(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
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
                  color: kColorRed.withOpacity(0.15),
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
                    color: kColorRed.withOpacity(0.08),
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
                          color: kColorRed.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(tablet ? 12 : 10),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: kColorRed,
                          size: tablet ? 26 : 22,
                        ),
                      ),
                      tablet ? AppSpaces.h12 : AppSpaces.h10,
                      Expanded(
                        child: Text(
                          'Close Indent',
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
                        'Are you sure you want to close this indent without authorization?',
                        style: TextStyles.kRegularOutfit(
                          fontSize: tablet
                              ? FontSizes.k16FontSize
                              : FontSizes.k14FontSize,
                          color: kColorDarkGrey,
                        ),
                      ),
                      tablet ? AppSpaces.v24 : AppSpaces.v20,
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(),
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
                              title: 'Close',
                              buttonColor: kColorRed,
                              titleColor: kColorWhite,
                              titleSize: tablet
                                  ? FontSizes.k16FontSize
                                  : FontSizes.k14FontSize,
                              buttonHeight: tablet ? 54 : 48,
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                                widget.controller.closeIndent(
                                  invNo: widget.indent.invNo,
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
        );
      },
    );
  }
}
