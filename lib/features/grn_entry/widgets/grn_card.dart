// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/grn_entry/controllers/grns_controller.dart';
import 'package:shivay_construction/features/grn_entry/models/grn_dm.dart';
import 'package:shivay_construction/features/grn_entry/screens/grn_entry_screen.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/helpers/date_format_helper.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';

class GrnCard extends StatefulWidget {
  const GrnCard({super.key, required this.grn, required this.controller});

  final GrnDm grn;
  final GrnsController controller;

  @override
  State<GrnCard> createState() => _GrnCardState();
}

class _GrnCardState extends State<GrnCard> {
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
              await widget.controller.getGrnDetails(invNo: widget.grn.invNo);
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
                            widget.grn.invNo,
                            style: TextStyles.kBoldOutfit(
                              fontSize: tablet
                                  ? FontSizes.k20FontSize
                                  : FontSizes.k18FontSize,
                              color: kColorPrimary,
                            ),
                          ),
                          AppSpaces.v4,
                          Text(
                            'Date: ${convertyyyyMMddToddMMyyyy(widget.grn.date)}',
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
                      color: kColorPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(tablet ? 10 : 8),
                      child: InkWell(
                        onTap: () async {
                          await widget.controller.getGrnDetails(
                            invNo: widget.grn.invNo,
                          );
                          Get.to(
                            () => GrnEntryScreen(
                              isEdit: true,
                              grn: widget.grn,
                              grnDetails: widget.controller.grnDetails.toList(),
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
                  label: 'Party',
                  value: widget.grn.pName,
                  tablet: tablet,
                ),
                tablet ? AppSpaces.v12 : AppSpaces.v10,
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        label: 'Godown',
                        value: widget.grn.gdName,
                        tablet: tablet,
                      ),
                    ),
                    tablet ? AppSpaces.h12 : AppSpaces.h10,
                    Expanded(
                      child: _buildInfoRow(
                        label: 'Site',
                        value: widget.grn.siteName,
                        tablet: tablet,
                      ),
                    ),
                  ],
                ),
                if (widget.grn.remarks.isNotEmpty) ...[
                  tablet ? AppSpaces.v12 : AppSpaces.v10,
                  _buildInfoRow(
                    label: 'Remarks',
                    value: widget.grn.remarks,
                    tablet: tablet,
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
                        if (widget.controller.grnDetails.isEmpty) {
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
                          itemCount: widget.controller.grnDetails.length,
                          itemBuilder: (context, index) {
                            final detail = widget.controller.grnDetails[index];
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
                                  AppSpaces.v4,
                                  Text(
                                    'PO: ${detail.poInvNo}',
                                    style: TextStyles.kRegularOutfit(
                                      fontSize: tablet
                                          ? FontSizes.k12FontSize
                                          : FontSizes.k10FontSize,
                                      color: kColorDarkGrey,
                                    ),
                                  ),
                                  AppSpaces.v8,
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildDetailRow(
                                          label: 'Qty',
                                          value:
                                              '${detail.qty.toStringAsFixed(2)} ${detail.unit}',
                                          tablet: tablet,
                                        ),
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
