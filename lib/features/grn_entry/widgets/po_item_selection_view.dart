// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/grn_entry/controllers/grn_entry_controller.dart';
import 'package:shivay_construction/features/grn_entry/models/po_auth_item_dm.dart';
import 'package:shivay_construction/features/grn_entry/widgets/po_order_card.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_button.dart';

class PoItemSelectionView extends StatelessWidget {
  const PoItemSelectionView({super.key, required this.controller});

  final GrnEntryController controller;

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);

    return WillPopScope(
      onWillPop: () async {
        controller.cancelItemSelection();
        return false;
      },
      child: Column(
        children: [
          Container(
            padding: tablet
                ? AppPaddings.combined(horizontal: 24, vertical: 16)
                : AppPaddings.combined(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: kColorPrimary.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(color: kColorLightGrey.withOpacity(0.3)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(
                  () => controller.isInSelectionMode.value
                      ? Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: kColorPrimary,
                              size: tablet ? 20 : 18,
                            ),
                            tablet ? AppSpaces.h8 : AppSpaces.h6,
                            Text(
                              'Selection Mode',
                              style: TextStyles.kMediumOutfit(
                                fontSize: tablet
                                    ? FontSizes.k14FontSize
                                    : FontSizes.k12FontSize,
                                color: kColorPrimary,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Icon(
                              Icons.touch_app,
                              color: kColorDarkGrey,
                              size: tablet ? 20 : 18,
                            ),
                            tablet ? AppSpaces.h8 : AppSpaces.h6,
                            Text(
                              'Long press on Purchase Order to select',
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
                Obx(
                  () => Text(
                    '${controller.selectedPoOrders.length} items',
                    style: TextStyles.kSemiBoldOutfit(
                      fontSize: tablet
                          ? FontSizes.k16FontSize
                          : FontSizes.k14FontSize,
                      color: kColorPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.poAuthItems.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: tablet ? 80 : 64,
                        color: kColorLightGrey,
                      ),
                      tablet ? AppSpaces.v16 : AppSpaces.v12,
                      Text(
                        'No PO items available',
                        style: TextStyles.kMediumOutfit(
                          fontSize: tablet
                              ? FontSizes.k18FontSize
                              : FontSizes.k16FontSize,
                          color: kColorDarkGrey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: tablet
                    ? AppPaddings.combined(horizontal: 24, vertical: 16)
                    : AppPaddings.combined(horizontal: 16, vertical: 12),
                itemCount: controller.poAuthItems.length,
                itemBuilder: (context, index) {
                  final item = controller.poAuthItems[index];
                  return _buildItemCard(item, tablet);
                },
              );
            }),
          ),
          Container(
            padding: tablet
                ? AppPaddings.combined(horizontal: 24, vertical: 16)
                : AppPaddings.combined(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: kColorWhite,
              border: Border(
                top: BorderSide(color: kColorLightGrey.withOpacity(0.3)),
              ),
              boxShadow: [
                BoxShadow(
                  color: kColorPrimary.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: AppButton(
              title: 'Confirm Selection',
              buttonColor: kColorPrimary,
              titleColor: kColorWhite,
              titleSize: tablet ? FontSizes.k16FontSize : FontSizes.k14FontSize,
              buttonHeight: tablet ? 54 : 48,
              onPressed: controller.confirmItemSelection,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(PoAuthItemDm item, bool tablet) {
    return Container(
      margin: AppPaddings.custom(bottom: 12),
      decoration: BoxDecoration(
        color: kColorWhite,
        borderRadius: BorderRadius.circular(tablet ? 12 : 10),
        border: Border.all(color: kColorLightGrey.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: kColorPrimary.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: tablet
                ? AppPaddings.combined(horizontal: 16, vertical: 12)
                : AppPaddings.combined(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: kColorPrimary.withOpacity(0.08),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(tablet ? 12 : 10),
                topRight: Radius.circular(tablet ? 12 : 10),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.iName,
                        style: TextStyles.kSemiBoldOutfit(
                          fontSize: tablet
                              ? FontSizes.k18FontSize
                              : FontSizes.k16FontSize,
                          color: kColorPrimary,
                        ),
                      ),
                      AppSpaces.v4,
                      Text(
                        'Unit: ${item.unit}',
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
              ],
            ),
          ),
          Padding(
            padding: tablet
                ? AppPaddings.combined(horizontal: 16, vertical: 12)
                : AppPaddings.combined(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Purchase Orders (${item.orders.length})',
                  style: TextStyles.kMediumOutfit(
                    fontSize: tablet
                        ? FontSizes.k14FontSize
                        : FontSizes.k12FontSize,
                    color: kColorDarkGrey,
                  ),
                ),
                tablet ? AppSpaces.v10 : AppSpaces.v8,
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: item.orders.length,
                  itemBuilder: (context, index) {
                    final order = item.orders[index];
                    return Padding(
                      padding: AppPaddings.custom(bottom: 8),
                      child: PoOrderCard(
                        item: item,
                        order: order,
                        controller: controller,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
