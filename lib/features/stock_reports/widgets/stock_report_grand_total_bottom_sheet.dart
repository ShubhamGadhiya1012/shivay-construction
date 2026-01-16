import 'package:flutter/material.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/stock_reports/models/stock_report_dm.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/helpers/amount_format_helper.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_radius.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';

class StockReportGrandTotalBottomSheet extends StatelessWidget {
  final StockReportDm grandTotal;
  final String reportName;

  const StockReportGrandTotalBottomSheet({
    super.key,
    required this.grandTotal,
    required this.reportName,
  });

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);

    return Container(
      decoration: BoxDecoration(
        color: kColorWhite,
        borderRadius: AppRadius.onlySm(topLeft: true, topRight: true),
      ),
      padding: tablet
          ? AppPaddings.combined(horizontal: 24, vertical: 20)
          : AppPaddings.combined(horizontal: 16, vertical: 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: tablet ? 60 : 40,
                height: tablet ? 6 : 4,
                decoration: BoxDecoration(
                  color: kColorLightGrey,
                  borderRadius: AppRadius.allSm(),
                ),
              ),
            ),
            tablet ? AppSpaces.v20 : AppSpaces.v14,
            Row(
              children: [
                Icon(
                  Icons.calculate_outlined,
                  color: kColorPrimary,
                  size: tablet ? 30 : 25,
                ),
                tablet ? AppSpaces.h12 : AppSpaces.h6,
                Text(
                  'Grand Total',
                  style: TextStyles.kSemiBoldOutfit(
                    fontSize: tablet
                        ? FontSizes.k26FontSize
                        : FontSizes.k20FontSize,
                    color: kColorPrimary,
                  ),
                ),
              ],
            ),
            tablet ? AppSpaces.v24 : AppSpaces.v28,
            ..._buildSummaryRows(tablet),
            tablet ? AppSpaces.v24 : AppSpaces.v18,
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSummaryRows(bool tablet) {
    final List<Widget> rows = [];

    if (reportName == 'STATEMENT') {
      rows.addAll([
        _summaryRow(
          'Open Qty',
          grandTotal.openQty?.toStringAsFixed(2) ?? '0.00',
          tablet,
        ),
        _divider(tablet),
        _summaryRow(
          'In Qty',
          grandTotal.inQty?.toStringAsFixed(2) ?? '0.00',
          tablet,
        ),
        _divider(tablet),
        _summaryRow(
          'Out Qty',
          grandTotal.outQty?.toStringAsFixed(2) ?? '0.00',
          tablet,
        ),
        _divider(tablet),
        _summaryRow(
          'Close Qty',
          grandTotal.closeQty?.toStringAsFixed(2) ?? '0.00',
          tablet,
          highlight: true,
        ),
      ]);
    } else {
      // FIFO, LIFO, LP
      rows.addAll([
        _summaryRow(
          'Close Qty',
          grandTotal.closeQty?.toStringAsFixed(2) ?? '0.00',
          tablet,
        ),
        _divider(tablet),
        _summaryRow(
          'Close Value',
          formatIndianCurrency(grandTotal.closeValue ?? 0),
          tablet,
          highlight: true,
        ),
      ]);
    }

    return rows;
  }

  Widget _divider(bool tablet) {
    return Divider(color: kColorLightGrey, height: tablet ? 24 : 20);
  }

  Widget _summaryRow(
    String label,
    String value,
    bool tablet, {
    bool highlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyles.kRegularOutfit(
            fontSize: tablet ? FontSizes.k22FontSize : FontSizes.k16FontSize,
            color: highlight ? kColorPrimary : kColorBlack,
          ),
        ),
        Text(
          value,
          style: TextStyles.kSemiBoldOutfit(
            fontSize: tablet ? FontSizes.k22FontSize : FontSizes.k16FontSize,
            color: highlight ? kColorPrimary : kColorBlue,
          ),
        ),
      ],
    );
  }
}
