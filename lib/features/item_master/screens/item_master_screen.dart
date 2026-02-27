// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/item_master/controllers/item_master_controller.dart';
import 'package:shivay_construction/features/item_master/models/item_master_dm.dart';
import 'package:shivay_construction/utils/formatters/text_input_formatters.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_appbar.dart';
import 'package:shivay_construction/widgets/app_button.dart';
import 'package:shivay_construction/widgets/app_checkbox_row.dart';
import 'package:shivay_construction/widgets/app_dropdown.dart';
import 'package:shivay_construction/widgets/app_loading_overlay.dart';
import 'package:shivay_construction/widgets/app_text_form_field.dart';

class ItemMasterScreen extends StatelessWidget {
  final ItemMasterDm? item;

  ItemMasterScreen({super.key, this.item});

  final ItemMasterController _controller = Get.put(ItemMasterController());

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);

    if (item != null && !_controller.isEditMode.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.autoFillDataForEdit(item!);
      });
    }

    return Stack(
      children: [
        GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            appBar: AppAppbar(
              title: item != null ? 'Update Item' : 'Add Item',
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: tablet ? 25 : 20,
                  color: kColorPrimary,
                ),
                onPressed: () {
                  _controller.clearAll();
                  Get.back();
                },
              ),
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
                        key: _controller.itemFormKey,
                        child: Column(
                          children: [
                            tablet ? AppSpaces.v6 : AppSpaces.v4,
                            AppTextFormField(
                              controller: _controller.iNameController,
                              hintText: 'Item Name *',
                              inputFormatters: [UpperCaseTextInputFormatter()],
                              validator: (value) =>
                                  (value == null || value.trim().isEmpty)
                                  ? 'Please enter item name'
                                  : value.trim().length < 2
                                  ? 'Name must be at least 2 characters'
                                  : null,
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,

                            AppTextFormField(
                              controller: _controller.descriptionController,
                              hintText: 'Description',
                              maxLines: 3,
                              inputFormatters: [
                                CapitalizeFirstLetterFormatter(),
                              ],
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,

                            Row(
                              children: [
                                Expanded(
                                  child: AppTextFormField(
                                    controller: _controller.rateController,
                                    hintText: 'Rate *',
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d+\.?\d{0,2}'),
                                      ),
                                    ],
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Please enter rate';
                                      }
                                      final rate = double.tryParse(
                                        value.trim(),
                                      );
                                      if (rate == null || rate <= 0) {
                                        return 'Please enter valid rate';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                tablet ? AppSpaces.h16 : AppSpaces.h12,
                                Expanded(
                                  child: AppTextFormField(
                                    controller: _controller.unitController,
                                    hintText: 'Unit *',
                                    validator: (value) =>
                                        (value == null || value.trim().isEmpty)
                                        ? 'Please enter unit'
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,

                            Obx(
                              () => AppDropdown(
                                hintText: 'Category *',
                                items: _controller.categoryNames,
                                selectedItem:
                                    _controller
                                        .selectedCategory
                                        .value
                                        .isNotEmpty
                                    ? _controller.selectedCategory.value
                                    : null,
                                onChanged: (selectedValue) {
                                  _controller.onCategorySelected(selectedValue);
                                },
                                validatorText: 'Please select a category',
                              ),
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,

                            Obx(
                              () => AppDropdown(
                                hintText: 'Item Group *',
                                items: _controller.itemGroupNames,
                                selectedItem:
                                    _controller
                                        .selectedItemGroup
                                        .value
                                        .isNotEmpty
                                    ? _controller.selectedItemGroup.value
                                    : null,
                                onChanged: (selectedValue) {
                                  _controller.onItemGroupSelected(
                                    selectedValue,
                                  );
                                },
                                validatorText: 'Please select an item group',
                              ),
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,

                            Obx(
                              () => AppDropdown(
                                hintText: 'Item Sub Group *',
                                items: _controller.itemSubGroupNames,
                                selectedItem:
                                    _controller
                                        .selectedItemSubGroup
                                        .value
                                        .isNotEmpty
                                    ? _controller.selectedItemSubGroup.value
                                    : null,
                                onChanged: (selectedValue) {
                                  _controller.onItemSubGroupSelected(
                                    selectedValue,
                                  );
                                },
                                validatorText:
                                    'Please select an item sub group',
                              ),
                            ), // After unit row, add HSN dropdown:
                            tablet ? AppSpaces.v16 : AppSpaces.v10,
                            Obx(
                              () => AppDropdown(
                                hintText: 'HSN No',
                                items: _controller.hsnNumbers,
                                selectedItem:
                                    _controller.selectedHsnNo.value.isNotEmpty
                                    ? _controller.selectedHsnNo.value
                                    : null,
                                onChanged: _controller.onHsnSelected,
                              ),
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,

                            // Rent Item checkbox:
                            Obx(
                              () => AppCheckboxRow(
                                title: 'Rent Item',
                                value: _controller.rentItem.value,
                                onChanged: _controller.toggleRentItem,
                              ),
                            ),

                            // Frequency + Rent Rate (visible only when rentItem is true):
                            Obx(() {
                              if (!_controller.rentItem.value) {
                                return const SizedBox.shrink();
                              }
                              return Column(
                                children: [
                                  tablet ? AppSpaces.v16 : AppSpaces.v10,
                                  AppDropdown(
                                    hintText: 'Frequency *',
                                    items:
                                        ItemMasterController.frequencyOptions,
                                    selectedItem:
                                        _controller
                                            .frequencyController
                                            .text
                                            .isNotEmpty
                                        ? _controller.frequencyController.text
                                        : null,
                                    onChanged: _controller.onFrequencySelected,
                                    validatorText: 'Please select frequency',
                                  ),
                                  tablet ? AppSpaces.v16 : AppSpaces.v10,
                                  AppTextFormField(
                                    controller: _controller.rentRateController,
                                    hintText: 'Rent Rate *',
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d+\.?\d{0,2}'),
                                      ),
                                    ],
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty)
                                        return 'Please enter rent rate';
                                      final r = double.tryParse(value.trim());
                                      if (r == null || r <= 0)
                                        return 'Please enter valid rent rate';
                                      return null;
                                    },
                                  ),
                                ],
                              );
                            }),
                            tablet ? AppSpaces.v20 : AppSpaces.v16,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Obx(
                    () => AppButton(
                      title: _controller.isEditMode.value ? 'Update' : 'Submit',
                      buttonHeight: tablet ? 54 : 48,
                      onPressed: () {
                        if (_controller.itemFormKey.currentState!.validate()) {
                          _controller.addUpdateItemMaster();
                        }
                      },
                    ),
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
}
