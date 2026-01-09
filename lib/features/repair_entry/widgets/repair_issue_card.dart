// widgets/repair_issue_card.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/repair_entry/controllers/repair_issue_list_controller.dart';
import 'package:shivay_construction/features/repair_entry/models/repair_issue_dm.dart';
import 'package:shivay_construction/features/repair_entry/screens/repair_entry_screen.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/helpers/date_format_helper.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_button.dart';
import 'package:shivay_construction/widgets/app_date_picker_text_form_field.dart';
import 'package:shivay_construction/widgets/app_text_form_field.dart';

class RepairIssueCard extends StatefulWidget {
  const RepairIssueCard({
    super.key,
    required this.issue,
    required this.controller,
  });

  final RepairIssueDm issue;
  final RepairIssueListController controller;

  @override
  State<RepairIssueCard> createState() => _RepairIssueCardState();
}

class _RepairIssueCardState extends State<RepairIssueCard> {
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
              await widget.controller.getIssueDetails(
                invNo: widget.issue.invNo,
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
                            widget.issue.invNo,
                            style: TextStyles.kBoldOutfit(
                              fontSize: tablet
                                  ? FontSizes.k20FontSize
                                  : FontSizes.k18FontSize,
                              color: kColorPrimary,
                            ),
                          ),
                          AppSpaces.v4,
                          Text(
                            'Date: ${convertyyyyMMddToddMMyyyy(widget.issue.issueDate)}',
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
                    if (widget.issue.status == 'Pending')
                      Material(
                        color: kColorPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(tablet ? 10 : 8),
                        child: InkWell(
                          onTap: () async {
                            await widget.controller.getIssueDetails(
                              invNo: widget.issue.invNo,
                            );
                            Get.to(
                              () => RepairEntryScreen(
                                issue: widget.issue,
                                issueDetails: widget.controller.issueDetails
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
                                AppSpaces.h6,
                                Text(
                                  'Edit',
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
                    if (widget.issue.status == 'Pending') AppSpaces.h8,
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
                  label: 'Party',
                  value: widget.issue.pName,
                  tablet: tablet,
                ),
                tablet ? AppSpaces.v12 : AppSpaces.v10,
                _buildInfoRow(
                  label: 'Description',
                  value: widget.issue.description,
                  tablet: tablet,
                ),
                tablet ? AppSpaces.v12 : AppSpaces.v10,
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        label: 'Godown',
                        value: widget.issue.gdName,
                        tablet: tablet,
                      ),
                    ),
                    tablet ? AppSpaces.h12 : AppSpaces.h10,
                    Expanded(
                      child: _buildInfoRow(
                        label: 'Site',
                        value: widget.issue.siteName,
                        tablet: tablet,
                      ),
                    ),
                  ],
                ),
                if (widget.issue.remarks.isNotEmpty) ...[
                  tablet ? AppSpaces.v12 : AppSpaces.v10,
                  _buildInfoRow(
                    label: 'Remarks',
                    value: widget.issue.remarks,
                    tablet: tablet,
                  ),
                ],
                tablet ? AppSpaces.v12 : AppSpaces.v10,
                Row(
                  children: [
                    Container(
                      padding: tablet
                          ? AppPaddings.combined(horizontal: 12, vertical: 6)
                          : AppPaddings.combined(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: widget.issue.status == 'Completed'
                            ? kColorGreen.withOpacity(0.1)
                            : kColorSecondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: widget.issue.status == 'Completed'
                              ? kColorGreen.withOpacity(0.3)
                              : kColorSecondary.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        widget.issue.status,
                        style: TextStyles.kMediumOutfit(
                          fontSize: tablet
                              ? FontSizes.k14FontSize
                              : FontSizes.k12FontSize,
                          color: widget.issue.status == 'Completed'
                              ? kColorGreen
                              : kColorSecondary,
                        ),
                      ),
                    ),
                    if (widget.issue.status == 'Pending' ||
                        widget.issue.status == 'Partial') ...[
                      const Spacer(),
                      SizedBox(
                        width: tablet ? 140 : 120,
                        child: AppButton(
                          title: 'Receive',
                          buttonHeight: tablet ? 40 : 36,
                          buttonColor: kColorGreen,
                          onPressed: () async {
                            await widget.controller.getIssueDetails(
                              invNo: widget.issue.invNo,
                            );
                            widget.controller.prepareReceiveDialog(
                              widget.issue,
                            );
                            // ignore: use_build_context_synchronously
                            _showReceiveDialog(context);
                          },
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
                        'Repair Items',
                        style: TextStyles.kSemiBoldOutfit(
                          fontSize: tablet
                              ? FontSizes.k18FontSize
                              : FontSizes.k16FontSize,
                          color: kColorTextPrimary,
                        ),
                      ),
                      tablet ? AppSpaces.v12 : AppSpaces.v8,
                      Obx(() {
                        if (widget.controller.issueDetails.isEmpty) {
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
                          itemCount: widget.controller.issueDetails.length,
                          itemBuilder: (context, index) {
                            final detail =
                                widget.controller.issueDetails[index];
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
                                        child: _buildDetailRow(
                                          label: 'Issued Qty',
                                          value: detail.issuedQty
                                              .toStringAsFixed(2),
                                          tablet: tablet,
                                        ),
                                      ),
                                      AppSpaces.h12,
                                      Expanded(
                                        child: _buildDetailRow(
                                          label: 'Received Qty',
                                          value: detail.receivedQty
                                              .toStringAsFixed(2),
                                          tablet: tablet,
                                          valueColor: kColorGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                  AppSpaces.v8,
                                  _buildDetailRow(
                                    label: 'Balance Qty',
                                    value: detail.balanceQty.toStringAsFixed(2),
                                    tablet: tablet,
                                    valueColor: kColorSecondary,
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

  void _showReceiveDialog(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);
    final formKey = GlobalKey<FormState>();

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
                        'Receive Repair',
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
                    child: Obx(
                      () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: tablet ? AppPaddings.p12 : AppPaddings.p10,
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
                                  children: [
                                    Expanded(
                                      child: _buildDetailRow(
                                        label: 'Site',
                                        value: widget.issue.siteName,
                                        tablet: tablet,
                                      ),
                                    ),
                                    AppSpaces.h12,
                                    Expanded(
                                      child: _buildDetailRow(
                                        label: 'Godown',
                                        value: widget.issue.gdName,
                                        tablet: tablet,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          tablet ? AppSpaces.v16 : AppSpaces.v12,
                          AppDatePickerTextFormField(
                            dateController: widget.controller.dateController,
                            hintText: 'Date *',
                            validator: (value) => value == null || value.isEmpty
                                ? 'Please select date'
                                : null,
                          ),
                          tablet ? AppSpaces.v16 : AppSpaces.v12,
                          AppTextFormField(
                            controller: widget.controller.remarksController,
                            hintText: 'Remarks',
                            maxLines: 2,
                          ),
                          tablet ? AppSpaces.v16 : AppSpaces.v12,
                          Text(
                            'Items to Receive',
                            style: TextStyles.kSemiBoldOutfit(
                              fontSize: tablet
                                  ? FontSizes.k16FontSize
                                  : FontSizes.k14FontSize,
                              color: kColorTextPrimary,
                            ),
                          ),
                          tablet ? AppSpaces.v12 : AppSpaces.v8,
                          // Find this ListView.builder in the dialog (around line 380)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: widget.controller.issueDetails
                                .where((detail) => detail.balanceQty > 0)
                                .length, // CHANGE THIS LINE
                            itemBuilder: (context, index) {
                              // ADD THESE 2 LINES
                              final filteredDetails = widget
                                  .controller
                                  .issueDetails
                                  .where((detail) => detail.balanceQty > 0)
                                  .toList();
                              final detail =
                                  filteredDetails[index]; // CHANGE THIS LINE

                              return Container(
                                margin: AppPaddings.custom(bottom: 12),
                                // ... rest of the code remains same
                                padding: tablet
                                    ? AppPaddings.p16
                                    : AppPaddings.p12,
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
                                            'Balance: ${detail.balanceQty.toStringAsFixed(2)}',
                                            style: TextStyles.kMediumOutfit(
                                              fontSize: tablet
                                                  ? FontSizes.k14FontSize
                                                  : FontSizes.k12FontSize,
                                              color: kColorSecondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    AppSpaces.v12,
                                    AppTextFormField(
                                      controller: widget
                                          .controller
                                          .receiveControllers[detail.srNo]!,
                                      hintText: 'Received Qty *',
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter received qty';
                                        }
                                        final qty = double.tryParse(value);
                                        if (qty == null || qty < 0) {
                                          return 'Please enter valid qty';
                                        }
                                        if (qty > detail.balanceQty) {
                                          return 'Cannot exceed balance qty';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
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
                        onPressed: () {
                          widget.controller.clearReceiveForm();
                          Get.back();
                        },
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
                      child: Obx(() {
                        final isLoading = widget.controller.isLoading.value;
                        return Opacity(
                          opacity: isLoading ? 0.6 : 1.0,
                          child: AppButton(
                            title: 'Receive',
                            buttonColor: kColorGreen,
                            titleColor: kColorWhite,
                            titleSize: tablet
                                ? FontSizes.k16FontSize
                                : FontSizes.k14FontSize,
                            buttonHeight: tablet ? 54 : 48,
                            onPressed: () {
                              if (!isLoading) {
                                widget.controller.saveReceiveRepair(
                                  issue: widget.issue,
                                  formKey: formKey,
                                );
                              }
                            },
                          ),
                        );
                      }),
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
