import 'package:dropdown_search/dropdown_search.dart';
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
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
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
                                    hintText: 'Rate',
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d*\.?\d{0,2}'),
                                      ),
                                    ],
                                    validator: (value) {
                                      if (value != null &&
                                          value.trim().isNotEmpty) {
                                        final rate = double.tryParse(
                                          value.trim(),
                                        );
                                        if (rate == null) {
                                          return 'Please enter valid rate';
                                        }
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
                              () => _buildDropdownWithAddButton(
                                context,
                                tablet,
                                hintText: 'Category *',
                                items: _controller.categoryNames,
                                selectedItem:
                                    _controller
                                        .selectedCategory
                                        .value
                                        .isNotEmpty
                                    ? _controller.selectedCategory.value
                                    : null,
                                onChanged: _controller.onCategorySelected,
                                onAddNew: () => _showAddNewDialog(
                                  context,
                                  tablet,
                                  title: 'Add New Category',
                                  hintText: 'Enter category name',
                                  onAdd: _controller.addNewCategory,
                                ),
                                validatorText: 'Please select a category',
                              ),
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,

                            Obx(
                              () => _buildDropdownWithAddButton(
                                context,
                                tablet,
                                hintText: 'Item Group *',
                                items: _controller.itemGroupNames,
                                selectedItem:
                                    _controller
                                        .selectedItemGroup
                                        .value
                                        .isNotEmpty
                                    ? _controller.selectedItemGroup.value
                                    : null,
                                onChanged: _controller.onItemGroupSelected,
                                onAddNew: () => _showAddNewDialog(
                                  context,
                                  tablet,
                                  title: 'Add New Item Group',
                                  hintText: 'Enter item group name',
                                  onAdd: _controller.addNewItemGroup,
                                ),
                                validatorText: 'Please select an item group',
                              ),
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,

                            Obx(
                              () => _buildDropdownWithAddButton(
                                context,
                                tablet,
                                hintText: 'Item Sub Group *',
                                items: _controller.itemSubGroupNames,
                                selectedItem:
                                    _controller
                                        .selectedItemSubGroup
                                        .value
                                        .isNotEmpty
                                    ? _controller.selectedItemSubGroup.value
                                    : null,
                                onChanged: _controller.onItemSubGroupSelected,
                                onAddNew: () => _showAddNewDialog(
                                  context,
                                  tablet,
                                  title: 'Add New Item Sub Group',
                                  hintText: 'Enter item sub group name',
                                  onAdd: _controller.addNewItemSubGroup,
                                ),
                                validatorText:
                                    'Please select an item sub group',
                              ),
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,

                            Obx(
                              () => AppDropdown(
                                hintText: 'HSN No',
                                items: _controller.hsnNumbers,
                                selectedItem:
                                    _controller.selectedHsnNo.value.isNotEmpty
                                    ? _controller.selectedHsnNo.value
                                    : null,
                                onChanged: (value) {
                                  if (value == null || value.isEmpty) {
                                    _controller.clearHsn();
                                  } else {
                                    _controller.onHsnSelected(value);
                                  }
                                },
                                clearButtonProps: ClearButtonProps(
                                  isVisible: _controller
                                      .selectedHsnNo
                                      .value
                                      .isNotEmpty,
                                ),
                              ),
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,

                            Obx(
                              () => AppCheckboxRow(
                                title: 'Rent Item',
                                value: _controller.rentItem.value,
                                onChanged: _controller.toggleRentItem,
                              ),
                            ),

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
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Please enter rent rate';
                                      }
                                      final r = double.tryParse(value.trim());
                                      if (r == null || r <= 0) {
                                        return 'Please enter valid rent rate';
                                      }
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

  Widget _buildDropdownWithAddButton(
    BuildContext context,
    bool tablet, {
    required String hintText,
    required List<String> items,
    required String? selectedItem,
    required Function(String?) onChanged,
    required VoidCallback onAddNew,
    required String validatorText,
  }) {
    return Row(
      children: [
        Expanded(
          child: AppDropdown(
            hintText: hintText,
            items: items,
            selectedItem: selectedItem,
            onChanged: onChanged,
            validatorText: validatorText,
          ),
        ),
        tablet ? AppSpaces.h12 : AppSpaces.h8,
        Container(
          decoration: BoxDecoration(
            color: kColorPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(tablet ? 12 : 10),
            border: Border.all(
              color: kColorLightGrey.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onAddNew,
              borderRadius: BorderRadius.circular(tablet ? 12 : 10),
              child: Padding(
                padding: tablet
                    ? AppPaddings.combined(horizontal: 14, vertical: 14)
                    : AppPaddings.combined(horizontal: 12, vertical: 12),
                child: Icon(
                  Icons.add_rounded,
                  size: tablet ? 22 : 20,
                  color: kColorPrimary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showAddNewDialog(
    BuildContext context,
    bool tablet, {
    required String title,
    required String hintText,
    required Function(String) onAdd,
  }) {
    final newItemController = TextEditingController();
    final dialogFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tablet ? 20 : 16),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: tablet ? 520 : double.infinity,
          constraints: BoxConstraints(
            maxWidth: tablet ? 520 : MediaQuery.of(context).size.width * 0.9,
          ),
          decoration: BoxDecoration(
            color: kColorWhite,
            borderRadius: BorderRadius.circular(tablet ? 20 : 16),
            boxShadow: [
              BoxShadow(
                color: kColorPrimary.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: tablet
                    ? AppPaddings.combined(horizontal: 24, vertical: 20)
                    : AppPaddings.combined(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: kColorPrimary.withOpacity(0.08),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(tablet ? 20 : 16),
                    topRight: Radius.circular(tablet ? 20 : 16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: AppPaddings.p10,
                      decoration: BoxDecoration(
                        color: kColorPrimary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(tablet ? 12 : 10),
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        color: kColorPrimary,
                        size: tablet ? 26 : 22,
                      ),
                    ),
                    tablet ? AppSpaces.h12 : AppSpaces.h10,
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyles.kSemiBoldOutfit(
                          fontSize: tablet
                              ? FontSizes.k22FontSize
                              : FontSizes.k18FontSize,
                          color: kColorTextPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: tablet ? AppPaddings.p24 : AppPaddings.p20,
                child: Form(
                  key: dialogFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextFormField(
                        controller: newItemController,
                        hintText: hintText,
                        inputFormatters: [UpperCaseTextInputFormatter()],
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? 'This field is required'
                            : value.trim().length < 2
                            ? 'Must be at least 2 characters'
                            : null,
                      ),
                      tablet ? AppSpaces.v24 : AppSpaces.v20,
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                newItemController.clear();
                                Get.back();
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: kColorLightGrey,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    tablet ? 12 : 10,
                                  ),
                                ),
                                padding: AppPaddings.combined(
                                  vertical: tablet ? 16 : 14,
                                  horizontal: 0,
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyles.kMediumOutfit(
                                  color: kColorDarkGrey,
                                  fontSize: tablet
                                      ? FontSizes.k16FontSize
                                      : FontSizes.k14FontSize,
                                ),
                              ),
                            ),
                          ),
                          tablet ? AppSpaces.h16 : AppSpaces.h12,
                          Expanded(
                            child: AppButton(
                              title: 'Add',
                              buttonColor: kColorPrimary,
                              titleColor: kColorWhite,
                              titleSize: tablet
                                  ? FontSizes.k16FontSize
                                  : FontSizes.k14FontSize,
                              buttonHeight: tablet ? 54 : 48,
                              onPressed: () {
                                if (dialogFormKey.currentState!.validate()) {
                                  onAdd(newItemController.text.trim());
                                  newItemController.clear();
                                  Get.back();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
