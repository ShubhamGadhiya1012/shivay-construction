import 'package:flutter/material.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/helpers/date_format_helper.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';

class LastPurchaseRateCard extends StatelessWidget {
  const LastPurchaseRateCard({
    super.key,
    required this.poInvno,
    required this.date,
    required this.pName,
    required this.qty,
    required this.rate,
  });

  final String poInvno;
  final String date;
  final String pName;
  final double qty;
  final double rate;

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);

    return Container(
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
      padding: tablet
          ? AppPaddings.combined(horizontal: 16, vertical: 14)
          : AppPaddings.combined(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  poInvno,
                  style: TextStyles.kSemiBoldOutfit(
                    fontSize: tablet
                        ? FontSizes.k16FontSize
                        : FontSizes.k14FontSize,
                    color: kColorPrimary,
                  ),
                ),
              ),
              Text(
                'Purchase Date: ${convertyyyyMMddToddMMyyyy(date)}',
                style: TextStyles.kRegularOutfit(
                  fontSize: tablet
                      ? FontSizes.k12FontSize
                      : FontSizes.k10FontSize,
                  color: kColorDarkGrey,
                ),
              ),
            ],
          ),
          tablet ? AppSpaces.v8 : AppSpaces.v6,
          Row(
            children: [
              Icon(
                Icons.person_outline,
                color: kColorDarkGrey,
                size: tablet ? 16 : 14,
              ),
              AppSpaces.h6,
              Expanded(
                child: Text(
                  pName,
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
          tablet ? AppSpaces.v10 : AppSpaces.v8,
          Container(
            padding: tablet
                ? AppPaddings.combined(horizontal: 12, vertical: 8)
                : AppPaddings.combined(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: kColorPrimary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kColorPrimary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quantity',
                        style: TextStyles.kRegularOutfit(
                          fontSize: tablet
                              ? FontSizes.k12FontSize
                              : FontSizes.k10FontSize,
                          color: kColorDarkGrey,
                        ),
                      ),
                      AppSpaces.v2,
                      Text(
                        qty.toStringAsFixed(2),
                        style: TextStyles.kMediumOutfit(
                          fontSize: tablet
                              ? FontSizes.k14FontSize
                              : FontSizes.k12FontSize,
                          color: kColorTextPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpaces.h12,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Rate',
                      style: TextStyles.kRegularOutfit(
                        fontSize: tablet
                            ? FontSizes.k12FontSize
                            : FontSizes.k10FontSize,
                        color: kColorDarkGrey,
                      ),
                    ),
                    AppSpaces.v2,
                    Text(
                      '₹${rate.toStringAsFixed(2)}',
                      style: TextStyles.kBoldOutfit(
                        fontSize: tablet
                            ? FontSizes.k16FontSize
                            : FontSizes.k14FontSize,
                        color: kColorPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
