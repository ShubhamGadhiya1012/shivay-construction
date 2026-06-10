// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/godown_master/models/godown_master_dm.dart';
import 'package:shivay_construction/features/item_master/models/item_master_dm.dart';
import 'package:shivay_construction/features/party_masters/models/party_master_dm.dart';
import 'package:shivay_construction/features/reports/controllers/issue_report_controller.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_appbar.dart';
import 'package:shivay_construction/widgets/app_button.dart';
import 'package:shivay_construction/widgets/app_date_picker_text_form_field.dart';
import 'package:shivay_construction/widgets/app_loading_overlay.dart';
import 'package:shivay_construction/widgets/app_multiple_selection_bottom_sheet.dart';
import 'package:shivay_construction/widgets/app_multiple_selection_field.dart';

class IssueReportScreen extends StatelessWidget {
  IssueReportScreen({super.key});

  final IssueReportController _controller = Get.put(IssueReportController());

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);

    return Stack(
      children: [
        GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            appBar: AppAppbar(
              title: 'Issue Report',
              leading: IconButton(
                onPressed: () => Get.back(),
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: tablet ? 25 : 20,
                  color: kColorPrimary,
                ),
              ),
              actions: [
                Padding(
                  padding: AppPaddings.custom(right: 10),
                  child: TextButton(
                    onPressed: () {
                      _controller.clearAll();
                    },
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
                ),
              ],
            ),
            body: Padding(
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
                            Row(
                              children: [
                                Expanded(
                                  child: AppDatePickerTextFormField(
                                    dateController:
                                        _controller.fromDateController,
                                    hintText: 'From Date *',
                                    validator: (value) =>
                                        value == null || value.isEmpty
                                        ? 'Please select from date'
                                        : null,
                                  ),
                                ),
                                tablet ? AppSpaces.h16 : AppSpaces.h12,
                                Expanded(
                                  child: AppDatePickerTextFormField(
                                    dateController:
                                        _controller.toDateController,
                                    hintText: 'To Date *',
                                    validator: (value) =>
                                        value == null || value.isEmpty
                                        ? 'Please select to date'
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,
                            GestureDetector(
                              onTap: () =>
                                  _showPartySelectionBottomSheet(context),
                              child: AppMultipleSelectionField(
                                placeholder: 'Select Contractor',
                                selectedItems: _controller.selectedPartyNames,
                                onTap: () =>
                                    _showPartySelectionBottomSheet(context),
                                showFullList: true,
                              ),
                            ),

                            tablet ? AppSpaces.v16 : AppSpaces.v10,
                            GestureDetector(
                              onTap: () =>
                                  _showGodownSelectionBottomSheet(context),
                              child: AppMultipleSelectionField(
                                placeholder: 'Select Head',
                                selectedItems: _controller.selectedGodownNames,
                                onTap: () =>
                                    _showGodownSelectionBottomSheet(context),
                                showFullList: true,
                              ),
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,
                            GestureDetector(
                              onTap: () =>
                                  _showItemSelectionBottomSheet(context),
                              child: AppMultipleSelectionField(
                                placeholder: 'Select Items',
                                selectedItems: _controller.selectedItemNames,
                                onTap: () =>
                                    _showItemSelectionBottomSheet(context),
                                showFullList: true,
                              ),
                            ),

                            tablet ? AppSpaces.v16 : AppSpaces.v10,
                          ],
                        ),
                      ),
                    ),
                  ),
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
            ),
          ),
        ),
        Obx(() => AppLoadingOverlay(isLoading: _controller.isLoading.value)),
      ],
    );
  }

  void _showPartySelectionBottomSheet(BuildContext context) {
    Get.bottomSheet(
      SelectionBottomSheet<PartyMasterDm>(
        title: 'Select Parties',
        items: _controller.parties,
        selectedCodes: _controller.selectedPartyCodes,
        selectedNames: _controller.selectedPartyNames,
        itemNameGetter: (item) => item.accountName,
        itemCodeGetter: (item) => item.pCode,
        searchController: _controller.searchPartyController,
        onSelectionChanged: (selected, item) {
          _controller.togglePartySelection(selected ?? false, item.accountName);
        },
        onSelectAll: _controller.selectAllParties,
        onClearAll: _controller.clearAllParties,
        onSearchChanged: (value) {
          // Search functionality if needed
        },
      ),
      isScrollControlled: true,
    );
  }

  void _showGodownSelectionBottomSheet(BuildContext context) {
    Get.bottomSheet(
      SelectionBottomSheet<GodownMasterDm>(
        title: 'Select Head (Godowns)',
        items: _controller.godowns,
        selectedCodes: _controller.selectedGodownCodes,
        selectedNames: _controller.selectedGodownNames,
        itemNameGetter: (item) => item.gdName,
        itemCodeGetter: (item) => item.gdCode,
        searchController: _controller.searchGodownController,
        onSelectionChanged: (selected, item) {
          _controller.toggleGodownSelection(selected ?? false, item.gdName);
        },
        onSelectAll: _controller.selectAllGodowns,
        onClearAll: _controller.clearAllGodowns,
        onSearchChanged: (value) {
          // Search functionality if needed
        },
      ),
      isScrollControlled: true,
    );
  }

  void _showItemSelectionBottomSheet(BuildContext context) {
    Get.bottomSheet(
      SelectionBottomSheet<ItemMasterDm>(
        title: 'Select Items',
        items: _controller.filteredItems,
        selectedCodes: _controller.selectedItemCodes,
        selectedNames: _controller.selectedItemNames,
        itemNameGetter: (item) => item.iName,
        itemCodeGetter: (item) => item.iCode,
        searchController: _controller.searchItemController,
        onSelectionChanged: (selected, item) {
          _controller.toggleItemSelection(
            selected ?? false,
            item.iCode,
            item.iName,
          );
        },
        onSelectAll: _controller.selectAllItems,
        onClearAll: _controller.clearAllItems,
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
}
