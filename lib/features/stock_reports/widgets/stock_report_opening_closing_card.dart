import 'package:flutter/material.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/stock_reports/models/stock_report_dm.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_radius.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';

class StockReportOpeningClosingCard extends StatelessWidget {
  final String title;
  final StockReportDm data;

  const StockReportOpeningClosingCard({
    super.key,
    required this.title,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);

    return Container(
      padding: tablet ? AppPaddings.p16 : AppPaddings.p12,
      decoration: BoxDecoration(
        color: kColorLightGrey,
        borderRadius: AppRadius.allSm(),
        border: Border.all(color: kColorDarkGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.desc ?? '',
            style: TextStyles.kMediumOutfit(
              fontSize: tablet ? FontSizes.k22FontSize : FontSizes.k16FontSize,
              color: kColorPrimary,
            ),
          ),

          tablet ? AppSpaces.v12 : AppSpaces.v8,
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (data.receiptQty ?? 0).toStringAsFixed(2),
                      style: TextStyles.kMediumOutfit(
                        fontSize: tablet
                            ? FontSizes.k24FontSize
                            : FontSizes.k18FontSize,
                        color: kColorGreen,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (data.issueQty ?? 0).toStringAsFixed(2),
                      style: TextStyles.kMediumOutfit(
                        fontSize: tablet
                            ? FontSizes.k24FontSize
                            : FontSizes.k18FontSize,
                        color: kColorRed,
                      ),
                    ),
                  ],
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.balanceQty != null &&
                            data.balanceQty!.toString().isNotEmpty
                        ? data.balanceQty!.toStringAsFixed(2)
                        : '0',
                    style: TextStyles.kMediumOutfit(
                      fontSize: tablet
                          ? FontSizes.k24FontSize
                          : FontSizes.k18FontSize,
                      color: kColorBlue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
