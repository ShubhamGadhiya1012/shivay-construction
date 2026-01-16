import 'package:flutter/material.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/stock_reports/models/stock_report_dm.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/helpers/amount_format_helper.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_card.dart';
import 'package:shivay_construction/widgets/app_title_value_container.dart';

class StockReportCard extends StatelessWidget {
  const StockReportCard({
    super.key,
    required this.stockReport,
    required this.reportName,
  });

  final StockReportDm stockReport;
  final String reportName;

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);

    switch (reportName) {
      case 'STATEMENT':
        return _buildStatementCard(tablet);
      case 'FIFO':
      case 'LIFO':
      case 'LP':
        return _buildValuationCard(tablet);
      case 'LEDGER':
        return _buildLedgerCard(tablet);
      case 'GROUPSTOCK':
        return _buildGroupStockCard(tablet);
      case 'SITESTOCK':
        return _buildSiteStockCard(tablet);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStatementCard(bool tablet) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stockReport.iName ?? '',
            style: TextStyles.kSemiBoldOutfit(
              fontSize: tablet ? FontSizes.k24FontSize : FontSizes.k18FontSize,
              color: kColorPrimary,
            ),
          ),
          if (stockReport.unit?.isNotEmpty == true)
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Unit: ${stockReport.unit}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyles.kRegularOutfit(
                      fontSize: tablet
                          ? FontSizes.k20FontSize
                          : FontSizes.k14FontSize,
                      color: kColorDarkGrey,
                    ),
                  ),
                ),
                if (stockReport.igName?.isNotEmpty == true) ...[
                  AppSpaces.h8,
                  Expanded(
                    child: Text(
                      'Group: ${stockReport.igName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyles.kRegularOutfit(
                        fontSize: tablet
                            ? FontSizes.k20FontSize
                            : FontSizes.k14FontSize,
                        color: kColorDarkGrey,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          tablet ? AppSpaces.v16 : AppSpaces.v10,
          Row(
            children: [
              Expanded(
                child: AppTitleValueContainer(
                  title: 'Open Qty',
                  value: stockReport.openQty?.toStringAsFixed(2) ?? '0.00',
                  color: kColorGrey,
                ),
              ),
              tablet ? AppSpaces.h12 : AppSpaces.h8,
              Expanded(
                child: AppTitleValueContainer(
                  title: 'In Qty',
                  value: stockReport.inQty?.toStringAsFixed(2) ?? '0.00',
                  color: kColorGrey,
                ),
              ),
            ],
          ),
          tablet ? AppSpaces.v12 : AppSpaces.v8,
          Row(
            children: [
              Expanded(
                child: AppTitleValueContainer(
                  title: 'Out Qty',
                  value: stockReport.outQty?.toStringAsFixed(2) ?? '0.00',
                  color: kColorGrey,
                ),
              ),
              tablet ? AppSpaces.h12 : AppSpaces.h8,
              Expanded(
                child: AppTitleValueContainer(
                  title: 'Close Qty',
                  value: stockReport.closeQty?.toStringAsFixed(2) ?? '0.00',
                  color: kColorGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildValuationCard(bool tablet) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stockReport.iName ?? '',
            style: TextStyles.kSemiBoldOutfit(
              fontSize: tablet ? FontSizes.k24FontSize : FontSizes.k18FontSize,
              color: kColorPrimary,
            ),
          ),
          if (stockReport.unit?.isNotEmpty == true)
            Text(
              'Unit: ${stockReport.unit}',
              style: TextStyles.kRegularOutfit(
                fontSize: tablet
                    ? FontSizes.k20FontSize
                    : FontSizes.k14FontSize,
                color: kColorDarkGrey,
              ),
            ),
          tablet ? AppSpaces.v16 : AppSpaces.v10,
          Row(
            children: [
              Expanded(
                child: AppTitleValueContainer(
                  title: 'Close Qty',
                  value: stockReport.closeQty?.toStringAsFixed(2) ?? '0.00',
                  color: kColorGrey,
                ),
              ),
              tablet ? AppSpaces.h12 : AppSpaces.h8,
              Expanded(
                child: AppTitleValueContainer(
                  title: 'Rate',
                  value: formatIndianCurrency(stockReport.rate ?? 0),
                  color: kColorGrey,
                ),
              ),
            ],
          ),
          tablet ? AppSpaces.v12 : AppSpaces.v8,
          AppTitleValueContainer(
            title: 'Close Value',
            value: formatIndianCurrency(stockReport.closeValue ?? 0),
            color: kColorGrey,
          ),
        ],
      ),
    );
  }

  Widget _buildLedgerCard(bool tablet) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                stockReport.date ?? '',
                style: TextStyles.kMediumOutfit(
                  fontSize: tablet
                      ? FontSizes.k22FontSize
                      : FontSizes.k16FontSize,
                  color: kColorPrimary,
                ),
              ),
              if (stockReport.dbc?.isNotEmpty == true)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: kColorPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    stockReport.dbc!,
                    style: TextStyles.kMediumOutfit(
                      fontSize: tablet
                          ? FontSizes.k16FontSize
                          : FontSizes.k12FontSize,
                      color: kColorPrimary,
                    ),
                  ),
                ),
            ],
          ),
          if (stockReport.siteName?.isNotEmpty == true) ...[
            tablet ? AppSpaces.v8 : AppSpaces.v4,
            Text(
              'Site: ${stockReport.siteName}',
              style: TextStyles.kRegularOutfit(
                fontSize: tablet
                    ? FontSizes.k20FontSize
                    : FontSizes.k14FontSize,
                color: kColorDarkGrey,
              ),
            ),
          ],
          if (stockReport.gdName?.isNotEmpty == true)
            Text(
              'Godown: ${stockReport.gdName}',
              style: TextStyles.kRegularOutfit(
                fontSize: tablet
                    ? FontSizes.k20FontSize
                    : FontSizes.k14FontSize,
                color: kColorDarkGrey,
              ),
            ),
          if (stockReport.pName?.isNotEmpty == true)
            Text(
              'Party: ${stockReport.pName}',
              style: TextStyles.kRegularOutfit(
                fontSize: tablet
                    ? FontSizes.k20FontSize
                    : FontSizes.k14FontSize,
                color: kColorDarkGrey,
              ),
            ),
          tablet ? AppSpaces.v12 : AppSpaces.v8,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (stockReport.invNo?.isNotEmpty == true)
                Text(
                  'Inv: ${stockReport.invNo}',
                  style: TextStyles.kRegularOutfit(
                    fontSize: tablet
                        ? FontSizes.k18FontSize
                        : FontSizes.k14FontSize,
                    color: kColorTextPrimary,
                  ),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (stockReport.receiptQty != null &&
                      stockReport.receiptQty! > 0)
                    Text(
                      'Receipt: ${stockReport.receiptQty!.toStringAsFixed(2)}',
                      style: TextStyles.kSemiBoldOutfit(
                        fontSize: tablet
                            ? FontSizes.k20FontSize
                            : FontSizes.k16FontSize,
                        color: kColorGreen,
                      ),
                    ),
                  if (stockReport.issueQty != null && stockReport.issueQty! > 0)
                    Text(
                      'Issue: ${stockReport.issueQty!.toStringAsFixed(2)}',
                      style: TextStyles.kSemiBoldOutfit(
                        fontSize: tablet
                            ? FontSizes.k20FontSize
                            : FontSizes.k16FontSize,
                        color: kColorRed,
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

  Widget _buildGroupStockCard(bool tablet) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (stockReport.igName?.isNotEmpty == true)
            Text(
              stockReport.igName!,
              style: TextStyles.kSemiBoldOutfit(
                fontSize: tablet
                    ? FontSizes.k20FontSize
                    : FontSizes.k16FontSize,
                color: kColorPrimary,
              ),
            ),
          tablet ? AppSpaces.v8 : AppSpaces.v4,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  stockReport.iName ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.kSemiBoldOutfit(
                    fontSize: tablet
                        ? FontSizes.k24FontSize
                        : FontSizes.k18FontSize,
                    color: kColorPrimary,
                  ),
                ),
              ),
              if (stockReport.unit?.isNotEmpty == true) ...[
                AppSpaces.h8,
                Text(
                  'Unit: ${stockReport.unit}',
                  style: TextStyles.kRegularOutfit(
                    fontSize: tablet
                        ? FontSizes.k20FontSize
                        : FontSizes.k14FontSize,
                    color: kColorDarkGrey,
                  ),
                ),
              ],
            ],
          ),
          tablet ? AppSpaces.v12 : AppSpaces.v8,
          AppTitleValueContainer(
            title: 'Stock Qty',
            value: stockReport.stockQty?.toStringAsFixed(2) ?? '0.00',
            color: kColorGrey,
          ),
        ],
      ),
    );
  }

  Widget _buildSiteStockCard(bool tablet) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stockReport.siteName ?? '',
            style: TextStyles.kSemiBoldOutfit(
              fontSize: tablet ? FontSizes.k20FontSize : FontSizes.k16FontSize,
              color: kColorPrimary,
            ),
          ),
          if (stockReport.gdName?.isNotEmpty == true)
            Text(
              'Godown: ${stockReport.gdName}',
              style: TextStyles.kRegularOutfit(
                fontSize: tablet
                    ? FontSizes.k18FontSize
                    : FontSizes.k14FontSize,
                color: kColorDarkGrey,
              ),
            ),
          tablet ? AppSpaces.v12 : AppSpaces.v8,
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  stockReport.iName ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.kSemiBoldOutfit(
                    fontSize: tablet
                        ? FontSizes.k24FontSize
                        : FontSizes.k18FontSize,
                    color: kColorPrimary,
                  ),
                ),
              ),
              if (stockReport.unit?.isNotEmpty == true) ...[
                AppSpaces.h8,
                Text(
                  'Unit: ${stockReport.unit}',
                  style: TextStyles.kRegularOutfit(
                    fontSize: tablet
                        ? FontSizes.k20FontSize
                        : FontSizes.k14FontSize,
                    color: kColorDarkGrey,
                  ),
                ),
              ],
            ],
          ),
          tablet ? AppSpaces.v12 : AppSpaces.v8,
          AppTitleValueContainer(
            title: 'Stock Qty',
            value: stockReport.stockQty?.toStringAsFixed(2) ?? '0.00',
            color: kColorGrey,
          ),
        ],
      ),
    );
  }
}
