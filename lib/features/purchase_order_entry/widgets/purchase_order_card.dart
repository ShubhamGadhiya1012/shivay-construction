import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/purchase_order_entry/controllers/purchase_order_list_controller.dart';
import 'package:shivay_construction/features/purchase_order_entry/models/purchase_order_list_dm.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/helpers/date_format_helper.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';

class PurchaseOrderCard extends StatefulWidget {
  const PurchaseOrderCard({
    super.key,
    required this.order,
    required this.controller,
  });

  final PurchaseOrderListDm order;
  final PurchaseOrderListController controller;

  @override
  State<PurchaseOrderCard> createState() => _PurchaseOrderCardState();
}

class _PurchaseOrderCardState extends State<PurchaseOrderCard> {
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
              await widget.controller.getOrderDetailsForCard(
                widget.order.invNo,
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
                              ? FontSizes.k16FontSize
                              : FontSizes.k14FontSize,
                          color: kColorTextPrimary,
                        ),
                      ),
                      tablet ? AppSpaces.v8 : AppSpaces.v6,
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

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: widget.controller.orderDetails.length,
                          separatorBuilder: (_, __) =>
                              tablet ? AppSpaces.v8 : AppSpaces.v6,
                          itemBuilder: (context, index) {
                            final item = widget.controller.orderDetails[index];
                            return Container(
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
                                    item.iName,
                                    style: TextStyles.kSemiBoldOutfit(
                                      fontSize: tablet
                                          ? FontSizes.k14FontSize
                                          : FontSizes.k12FontSize,
                                      color: kColorTextPrimary,
                                    ),
                                  ),
                                  AppSpaces.v6,
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Unit: ${item.unit}',
                                        style: TextStyles.kRegularOutfit(
                                          fontSize: tablet
                                              ? FontSizes.k12FontSize
                                              : FontSizes.k12FontSize,
                                          color: kColorDarkGrey,
                                        ),
                                      ),
                                      Text(
                                        'Qty: ${item.orderQty.toStringAsFixed(2)}',
                                        style: TextStyles.kMediumOutfit(
                                          fontSize: tablet
                                              ? FontSizes.k12FontSize
                                              : FontSizes.k12FontSize,
                                          color: kColorPrimary,
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
}
