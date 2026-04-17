import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/item_master/models/item_master_dm.dart';
import 'package:shivay_construction/features/reports/controllers/grn_report_controller.dart';
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

class GrnReportScreen extends StatelessWidget {
  GrnReportScreen({super.key});

  final GrnReportController _controller = Get.put(GrnReportController());

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);

    return Stack(
      children: [
        GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            appBar: AppAppbar(
              title: 'GRN Report',
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
                            // Date Fields
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

                            // Party Dropdown
                            Obx(
                              () => AppDropdown(
                                items: _controller.partyNames,
                                hintText: 'Party',
                                onChanged: _controller.onPartySelected,
                                selectedItem:
                                    _controller
                                        .selectedPartyName
                                        .value
                                        .isNotEmpty
                                    ? _controller.selectedPartyName.value
                                    : null,
                              ),
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,

                            Obx(
                              () => AppDropdown(
                                items: _controller.siteNames,
                                hintText: 'Site',
                                onChanged: _controller.onSiteSelected,
                                selectedItem:
                                    _controller
                                        .selectedSiteName
                                        .value
                                        .isNotEmpty
                                    ? _controller.selectedSiteName.value
                                    : null,
                              ),
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,
                            // Godown Dropdown
                            Obx(
                              () => AppDropdown(
                                items: _controller.godownNames,
                                hintText: 'Godown',
                                onChanged: _controller.onGodownSelected,
                                selectedItem:
                                    _controller
                                        .selectedGodownName
                                        .value
                                        .isNotEmpty
                                    ? _controller.selectedGodownName.value
                                    : null,
                              ),
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,

                            // Items Selection
                            GestureDetector(
                              onTap: () {
                                _showItemSelectionBottomSheet(context);
                              },
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
            ),
          ),
        ),
        Obx(() => AppLoadingOverlay(isLoading: _controller.isLoading.value)),
      ],
    );
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
}
