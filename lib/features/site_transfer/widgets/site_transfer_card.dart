// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/site_transfer/controllers/site_transfer_list_controller.dart';
import 'package:shivay_construction/features/site_transfer/models/site_transfer_dm.dart';
import 'package:shivay_construction/features/site_transfer/screens/site_transfer_pdf_screen.dart';
import 'package:shivay_construction/features/site_transfer/screens/site_transfer_screen.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/helpers/date_format_helper.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_button.dart';
import 'package:shivay_construction/widgets/app_date_picker_text_form_field.dart';
import 'package:shivay_construction/widgets/app_text_form_field.dart';

class SiteTransferCard extends StatefulWidget {
  const SiteTransferCard({
    super.key,
    required this.transfer,
    required this.controller,
    required this.isExpanded,
    required this.onTap,
  });

  final SiteTransferDm transfer;
  final SiteTransferListController controller;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  State<SiteTransferCard> createState() => _SiteTransferCardState();
}

class _SiteTransferCardState extends State<SiteTransferCard> {
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
              await widget.controller.getTransferDetails(
                invNo: widget.transfer.invNo,
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
                            widget.transfer.invNo,
                            style: TextStyles.kBoldOutfit(
                              fontSize: tablet
                                  ? FontSizes.k20FontSize
                                  : FontSizes.k18FontSize,
                              color: kColorPrimary,
                            ),
                          ),
                          AppSpaces.v4,
                          Text(
                            'Date: ${convertyyyyMMddToddMMyyyy(widget.transfer.date)}',
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
                          await widget.controller.getTransferDetails(
                            invNo: widget.transfer.invNo,
                          );
                          SiteTransferPdfScreen.generateSiteTransferPdf(
                            transfer: widget.transfer,
                            transferDetails: widget.controller.transferDetails
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
                    AppSpaces.h8,
                    if (widget.transfer.status == 'PENDING')
                      Material(
                        color: kColorPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(tablet ? 10 : 8),
                        child: InkWell(
                          onTap: () async {
                            await widget.controller.getTransferDetails(
                              invNo: widget.transfer.invNo,
                            );
                            Get.to(
                              () => SiteTransferScreen(
                                transfer: widget.transfer,
                                transferDetails: widget
                                    .controller
                                    .transferDetails
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
                            child: Icon(
                              Icons.edit_rounded,
                              size: tablet ? 18 : 16,
                              color: kColorPrimary,
                            ),
                          ),
                        ),
                      ),
                    if (widget.transfer.status == 'PENDING') AppSpaces.h8,
                    if (widget.transfer.status == 'PENDING')
                      Material(
                        color: kColorRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(tablet ? 10 : 8),
                        child: InkWell(
                          onTap: () => _showDeleteConfirmation(context),
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
                    if (widget.transfer.status == 'Pending') AppSpaces.h8,
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
                tablet ? AppSpaces.v16 : AppSpaces.v12,
                Divider(height: 1, color: kColorLightGrey.withOpacity(0.5)),
                tablet ? AppSpaces.v16 : AppSpaces.v12,
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'From',
                            style: TextStyles.kMediumOutfit(
                              fontSize: tablet
                                  ? FontSizes.k12FontSize
                                  : FontSizes.k10FontSize,
                              color: kColorDarkGrey,
                            ),
                          ),
                          AppSpaces.v4,
                          _buildInfoRow(
                            label: 'Godown',
                            value: widget.transfer.fromGodown,
                            tablet: tablet,
                          ),
                          tablet ? AppSpaces.v8 : AppSpaces.v6,
                          _buildInfoRow(
                            label: 'Site',
                            value: widget.transfer.fromSiteName,
                            tablet: tablet,
                          ),
                        ],
                      ),
                    ),
                    AppSpaces.h12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'To',
                            style: TextStyles.kMediumOutfit(
                              fontSize: tablet
                                  ? FontSizes.k12FontSize
                                  : FontSizes.k10FontSize,
                              color: kColorDarkGrey,
                            ),
                          ),
                          AppSpaces.v4,
                          _buildInfoRow(
                            label: 'Godown',
                            value: widget.transfer.toGodown,
                            tablet: tablet,
                          ),
                          tablet ? AppSpaces.v8 : AppSpaces.v6,
                          _buildInfoRow(
                            label: 'Site',
                            value: widget.transfer.toSiteName,
                            tablet: tablet,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (widget.transfer.remarks.isNotEmpty) ...[
                  tablet ? AppSpaces.v12 : AppSpaces.v10,
                  _buildInfoRow(
                    label: 'Remarks',
                    value: widget.transfer.remarks,
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
                        color: widget.transfer.status == 'COMPLETED'
                            ? kColorGreen.withOpacity(0.1)
                            : kColorSecondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: widget.transfer.status == 'COMPLETED'
                              ? kColorGreen.withOpacity(0.3)
                              : kColorSecondary.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        widget.transfer.status,
                        style: TextStyles.kMediumOutfit(
                          fontSize: tablet
                              ? FontSizes.k14FontSize
                              : FontSizes.k12FontSize,
                          color: widget.transfer.status == 'COMPLETED'
                              ? kColorGreen
                              : kColorSecondary,
                        ),
                      ),
                    ),
                    if (widget.transfer.status == 'PENDING') ...[
                      const Spacer(),
                      SizedBox(
                        width: tablet ? 140 : 120,
                        child: AppButton(
                          title: 'Receive',
                          buttonHeight: tablet ? 40 : 36,
                          buttonColor: kColorGreen,
                          onPressed: () async {
                            await widget.controller.getTransferDetails(
                              invNo: widget.transfer.invNo,
                            );
                            widget.controller.prepareReceiveDialog(
                              widget.transfer,
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
                        'Transfer Items',
                        style: TextStyles.kSemiBoldOutfit(
                          fontSize: tablet
                              ? FontSizes.k18FontSize
                              : FontSizes.k16FontSize,
                          color: kColorTextPrimary,
                        ),
                      ),
                      tablet ? AppSpaces.v12 : AppSpaces.v8,
                      Obx(() {
                        if (widget.controller.transferDetails.isEmpty) {
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
                          itemCount: widget.controller.transferDetails.length,
                          itemBuilder: (context, index) {
                            final detail =
                                widget.controller.transferDetails[index];
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
                                  tablet ? AppSpaces.v8 : AppSpaces.v6,
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildQtyInfo('Qty', detail.qty, tablet),
                                      _buildQtyInfo(
                                        'Received',
                                        detail.receivedQty,
                                        tablet,
                                      ),
                                      _buildQtyInfo(
                                        'Dispute Godown Qty',
                                        detail.autoReturnQty,
                                        tablet,
                                      ),
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

  Widget _buildQtyInfo(String label, double value, bool tablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyles.kRegularOutfit(
            fontSize: tablet ? FontSizes.k10FontSize : FontSizes.k10FontSize,
            color: kColorDarkGrey,
          ),
        ),
        AppSpaces.v2,
        Text(
          value.toStringAsFixed(2),
          style: TextStyles.kMediumOutfit(
            fontSize: tablet ? FontSizes.k12FontSize : FontSizes.k12FontSize,
            color: kColorTextPrimary,
          ),
        ),
      ],
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
            fontSize: tablet ? FontSizes.k12FontSize : FontSizes.k10FontSize,
            color: kColorDarkGrey,
          ),
        ),
        tablet ? AppSpaces.v2 : AppSpaces.v2,
        Text(
          value,
          style: TextStyles.kSemiBoldOutfit(
            fontSize: tablet ? FontSizes.k14FontSize : FontSizes.k12FontSize,
            color: kColorTextPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
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
                          Icons.delete_rounded,
                          color: kColorRed,
                          size: tablet ? 26 : 22,
                        ),
                      ),
                      tablet ? AppSpaces.h12 : AppSpaces.h10,
                      Expanded(
                        child: Text(
                          'Confirm Delete',
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
                        'Are you sure you want to delete this transfer?',
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
                              buttonColor: kColorRed,
                              titleColor: kColorWhite,
                              titleSize: tablet
                                  ? FontSizes.k16FontSize
                                  : FontSizes.k14FontSize,
                              buttonHeight: tablet ? 54 : 48,
                              onPressed: () {
                                Get.back();
                                widget.controller.deleteSiteTransfer(
                                  widget.transfer.invNo,
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
                        'Receive Transfer',
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
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'From',
                                            style: TextStyles.kMediumOutfit(
                                              fontSize: tablet
                                                  ? FontSizes.k12FontSize
                                                  : FontSizes.k10FontSize,
                                              color: kColorDarkGrey,
                                            ),
                                          ),
                                          AppSpaces.v4,
                                          Text(
                                            widget.transfer.fromGodown,
                                            style: TextStyles.kSemiBoldOutfit(
                                              fontSize: tablet
                                                  ? FontSizes.k14FontSize
                                                  : FontSizes.k12FontSize,
                                              color: kColorTextPrimary,
                                            ),
                                          ),
                                          AppSpaces.v2,
                                          Text(
                                            widget.transfer.fromSiteName,
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
                                    AppSpaces.h12,
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'To',
                                            style: TextStyles.kMediumOutfit(
                                              fontSize: tablet
                                                  ? FontSizes.k12FontSize
                                                  : FontSizes.k10FontSize,
                                              color: kColorDarkGrey,
                                            ),
                                          ),
                                          AppSpaces.v4,
                                          Text(
                                            widget.transfer.toGodown,
                                            style: TextStyles.kSemiBoldOutfit(
                                              fontSize: tablet
                                                  ? FontSizes.k14FontSize
                                                  : FontSizes.k12FontSize,
                                              color: kColorTextPrimary,
                                            ),
                                          ),
                                          AppSpaces.v2,
                                          Text(
                                            widget.transfer.toSiteName,
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
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: widget.controller.transferDetails.length,
                            itemBuilder: (context, index) {
                              final detail =
                                  widget.controller.transferDetails[index];

                              return Container(
                                margin: AppPaddings.custom(bottom: 12),
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
                                            'Transfer Qty: ${detail.qty.toStringAsFixed(2)}',
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
                                        if (qty > detail.qty) {
                                          return 'Cannot exceed transfer qty';
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
                                widget.controller.saveReceiveTransfer(
                                  transfer: widget.transfer,
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
