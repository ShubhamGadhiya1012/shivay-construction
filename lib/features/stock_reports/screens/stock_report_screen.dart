// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/item_master/models/item_master_dm.dart';
import 'package:shivay_construction/features/stock_reports/controllers/stock_report_controller.dart';
import 'package:shivay_construction/features/stock_reports/widgets/stock_report_card.dart';
import 'package:shivay_construction/features/stock_reports/widgets/stock_report_grand_total_bottom_sheet.dart';
import 'package:shivay_construction/features/stock_reports/widgets/stock_report_opening_closing_card.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_appbar.dart';
import 'package:shivay_construction/widgets/app_button.dart';
import 'package:shivay_construction/widgets/app_date_picker_text_form_field.dart';
import 'package:shivay_construction/widgets/app_dropdown.dart';
import 'package:shivay_construction/widgets/app_loading_overlay.dart';
import 'package:shivay_construction/widgets/app_multiple_selection_bottom_sheet.dart';
import 'package:shivay_construction/widgets/app_multiple_selection_field.dart';
import 'package:shivay_construction/widgets/app_summary_bottom_sheet_button.dart';
import 'package:shivay_construction/widgets/app_text_form_field.dart';

class StockReportScreen extends StatefulWidget {
  final String reportName;
  final String reportTitle;
  final String rType;
  final String method;

  const StockReportScreen({
    super.key,
    required this.reportName,
    required this.reportTitle,
    required this.rType,
    required this.method,
  });

  @override
  State<StockReportScreen> createState() => _StockReportScreenState();
}

class _StockReportScreenState extends State<StockReportScreen> {
  late final StockReportController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(StockReportController(), tag: widget.reportName);
    _controller.setReportConfig(
      name: widget.reportName,
      title: widget.reportTitle,
      type: widget.rType,
      mtd: widget.method,
    );
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
              title: widget.reportTitle,
              leading: IconButton(
                onPressed: () {
                  if (_controller.isReportScreen.value) {
                    _controller.togglePage();
                  } else {
                    Get.back();
                  }
                },
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: tablet ? 25 : 20,
                  color: kColorPrimary,
                ),
              ),
              actions: [
                Obx(() {
                  if (!_controller.isReportScreen.value) {
                    return Padding(
                      padding: AppPaddings.custom(right: 10),
                      child: TextButton(
                        onPressed: _controller.clearAll,
                        child: Text(
                          'Clear All',
                          style: TextStyles.kMediumOutfit(
                            fontSize: tablet
                                ? FontSizes.k14FontSize
                                : FontSizes.k12FontSize,
                            color: kColorPrimary,
                          ),
                        ),
                      ),
                    );
                  }

                  if (_controller.stockReports.isNotEmpty) {
                    return IconButton(
                      onPressed: _controller.downloadPdf,
                      icon: Icon(
                        Icons.file_download_outlined,
                        size: tablet ? 25 : 20,
                        color: kColorPrimary,
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                }),
              ],
            ),
            body: Obx(() {
              return _controller.isReportScreen.value
                  ? _buildReportView(tablet)
                  : _buildFormView(tablet);
            }),
          ),
        ),
        Obx(() => AppLoadingOverlay(isLoading: _controller.isLoading.value)),
      ],
    );
  }

  Widget _buildFormView(bool tablet) {
    return Padding(
      padding: tablet
          ? AppPaddings.combined(horizontal: 24, vertical: 12)
          : AppPaddings.p12,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: _controller.reportFormKey,
                child: Column(
                  children: [
                    tablet ? AppSpaces.v10 : AppSpaces.v4,
                    // Date Fields
                    Row(
                      children: [
                        Expanded(
                          child: AppDatePickerTextFormField(
                            dateController: _controller.fromDateController,
                            hintText: 'From Date *',
                            validator: (value) => value == null || value.isEmpty
                                ? 'Please select from date'
                                : null,
                          ),
                        ),
                        tablet ? AppSpaces.h16 : AppSpaces.h12,
                        Expanded(
                          child: AppDatePickerTextFormField(
                            dateController: _controller.toDateController,
                            hintText: 'To Date *',
                            validator: (value) => value == null || value.isEmpty
                                ? 'Please select to date'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    tablet ? AppSpaces.v16 : AppSpaces.v10,

                    // Godown Dropdown
                    Obx(
                      () => AppDropdown(
                        items: _controller.godownNames,
                        hintText: 'Godown',
                        onChanged: _controller.onGodownSelected,
                        selectedItem:
                            _controller.selectedGodownName.value.isNotEmpty
                            ? _controller.selectedGodownName.value
                            : null,
                      ),
                    ),
                    tablet ? AppSpaces.v16 : AppSpaces.v10,

                    // Site Name (Auto-filled, disabled)
                    Obx(() {
                      if (_controller.selectedSiteCode.value.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Column(
                        children: [
                          AppTextFormField(
                            controller: _controller.siteNameController,
                            hintText: 'Site Name',
                            enabled: false,
                            fillColor: kColorLightGrey,
                          ),
                          tablet ? AppSpaces.v16 : AppSpaces.v10,
                        ],
                      );
                    }),

                    // Items Selection
                    GestureDetector(
                      onTap: () => _showItemSelectionBottomSheet(context),
                      child: AppMultipleSelectionField(
                        placeholder: 'Select Items',
                        selectedItems: _controller.selectedItemNames,
                        onTap: () => _showItemSelectionBottomSheet(context),
                        showFullList: true,
                      ),
                    ),
                    tablet ? AppSpaces.v16 : AppSpaces.v10,
                  ],
                ),
              ),
            ),
          ),
          // Generate Report Button
          AppButton(
            title: 'Generate Report',
            buttonHeight: tablet ? 54 : 48,
            onPressed: () {
              if (_controller.reportFormKey.currentState!.validate()) {
                _controller.generateReport();
              }
            },
          ),
          tablet ? AppSpaces.v10 : AppSpaces.v8,
        ],
      ),
    );
  }

  Widget _buildReportView(bool tablet) {
    return Obx(() {
      if (_controller.stockReports.isEmpty && !_controller.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: tablet ? 80 : 64,
                color: kColorLightGrey,
              ),
              tablet ? AppSpaces.v20 : AppSpaces.v16,
              Text(
                'No Records Found',
                style: TextStyles.kMediumOutfit(
                  fontSize: tablet
                      ? FontSizes.k24FontSize
                      : FontSizes.k18FontSize,
                  color: kColorTextPrimary,
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: tablet
                  ? AppPaddings.combined(horizontal: 24, vertical: 12)
                  : AppPaddings.p12,
              itemCount: _getItemCountWithoutClosing(),
              itemBuilder: (context, index) {
                return _buildListItemWithoutClosing(index, tablet);
              },
            ),
          ),
          // Fixed Closing Stock at bottom
          if (_controller.closingStock.value != null) ...[
            Padding(
              padding: tablet
                  ? AppPaddings.combined(horizontal: 24, vertical: 12)
                  : AppPaddings.p12,
              child: StockReportOpeningClosingCard(
                title: 'Closing Stock',
                data: _controller.closingStock.value!,
              ),
            ),
          ],
          if (_controller.grandTotal.value != null) ...[
            Padding(
              padding: tablet
                  ? AppPaddings.combined(horizontal: 24, vertical: 12)
                  : AppPaddings.p12,
              child: InkWell(
                onTap: () => _showGrandTotalBottomSheet(context),
                child: AppSummaryBottomSheetButton(title: 'View Grand Total'),
              ),
            ),
          ],
        ],
      );
    });
  }

  int _getItemCountWithoutClosing() {
    int count = 0;
    if (_controller.openingStock.value != null) count++;
    count += _controller.stockReports.length;
    return count;
  }

  Widget _buildListItemWithoutClosing(int index, bool tablet) {
    if (_controller.openingStock.value != null) {
      if (index == 0) {
        return Padding(
          padding: AppPaddings.custom(bottom: tablet ? 12 : 8),
          child: StockReportOpeningClosingCard(
            title: 'Opening Stock',
            data: _controller.openingStock.value!,
          ),
        );
      }
      index--;
    }

    if (index < _controller.stockReports.length) {
      final report = _controller.stockReports[index];
      return Padding(
        padding: AppPaddings.custom(bottom: tablet ? 12 : 8),
        child: StockReportCard(
          stockReport: report,
          reportName: widget.reportName,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _showItemSelectionBottomSheet(BuildContext context) {
    Get.bottomSheet(
      SelectionBottomSheet<ItemMasterDm>(
        title: 'Select Items',
        items: _controller.filteredItems,
        selectedCodes: _controller.selectedItems,
        selectedNames: _controller.selectedItemNames,
        itemNameGetter: (item) => item.iName,
        itemCodeGetter: (item) => item.iCode,
        searchController: _controller.searchItemController,
        onSelectionChanged: (selected, item) {
          if (selected == true) {
            _controller.selectedItems.add(item.iCode);
            _controller.selectedItemNames.add(item.iName);
          } else {
            _controller.selectedItems.remove(item.iCode);
            _controller.selectedItemNames.remove(item.iName);
          }
        },
        onSelectAll: _controller.selectAllItems,
        onClearAll: () {
          _controller.selectedItems.clear();
          _controller.selectedItemNames.clear();
        },
        onSearchChanged: (value) {
          _controller.filteredItems.value = _controller.items
              .where(
                (item) =>
                    item.iName.toLowerCase().contains(value.toLowerCase()),
              )
              .toList();
        },
      ),
      isScrollControlled: true,
    );
  }

  void _showGrandTotalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StockReportGrandTotalBottomSheet(
        grandTotal: _controller.grandTotal.value!,
        reportName: widget.reportName,
      ),
    );
  }
}
