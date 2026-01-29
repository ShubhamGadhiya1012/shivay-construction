import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/purchase_order_entry/controllers/last_purchase_rate_controller.dart';
import 'package:shivay_construction/features/purchase_order_entry/widgets/last_purchase_rate_card.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_appbar.dart';
import 'package:shivay_construction/widgets/app_loading_overlay.dart';

class LastPurchaseRateScreen extends StatefulWidget {
  final String iCode;

  const LastPurchaseRateScreen({super.key, required this.iCode});

  @override
  State<LastPurchaseRateScreen> createState() => _LastPurchaseRateScreenState();
}

class _LastPurchaseRateScreenState extends State<LastPurchaseRateScreen> {
  final LastPurchaseRateController _controller = Get.put(
    LastPurchaseRateController(),
  );

  @override
  void initState() {
    super.initState();
    _controller.getLastPurchaseRate(iCode: widget.iCode);
  }

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);

    return Stack(
      children: [
        GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            appBar: AppAppbar(
              title: 'Last Purchase Rates',
              leading: IconButton(
                onPressed: () => Get.back(),
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: tablet ? 25 : 20,
                  color: kColorPrimary,
                ),
              ),
            ),
            body: RefreshIndicator(
              elevation: 0,
              backgroundColor: kColorWhite,
              color: kColorPrimary,
              onRefresh: () =>
                  _controller.getLastPurchaseRate(iCode: widget.iCode),
              child: Padding(
                padding: tablet
                    ? AppPaddings.combined(horizontal: 24, vertical: 12)
                    : AppPaddings.p12,
                child: Column(
                  children: [
                    Expanded(
                      child: Obx(() {
                        if (_controller.purchaseRateList.isEmpty &&
                            !_controller.isLoading.value) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_long_outlined,
                                  size: tablet ? 80 : 64,
                                  color: kColorLightGrey,
                                ),
                                tablet ? AppSpaces.v16 : AppSpaces.v12,
                                Text(
                                  'No purchase history found',
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
                          itemCount: _controller.purchaseRateList.length,
                          itemBuilder: (context, index) {
                            final purchase =
                                _controller.purchaseRateList[index];

                            return Padding(
                              padding: tablet
                                  ? AppPaddings.custom(bottom: 12)
                                  : AppPaddings.custom(bottom: 8),
                              child: LastPurchaseRateCard(
                                poInvno: purchase.poInvno,
                                date: purchase.date,
                                pName: purchase.pName,
                                qty: purchase.qty,
                                rate: purchase.rate,
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Obx(() => AppLoadingOverlay(isLoading: _controller.isLoading.value)),
      ],
    );
  }
}
