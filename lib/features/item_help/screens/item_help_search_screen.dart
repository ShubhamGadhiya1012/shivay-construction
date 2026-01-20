// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/item_help/controllers/item_help_search_controller.dart';
import 'package:shivay_construction/features/item_help/screens/item_help_items_screen.dart';
import 'package:shivay_construction/features/item_master/models/item_master_dm.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_appbar.dart';
import 'package:shivay_construction/widgets/app_button.dart';
import 'package:shivay_construction/widgets/app_dropdown.dart';
import 'package:shivay_construction/widgets/app_loading_overlay.dart';
import 'package:shivay_construction/widgets/app_multiple_selection_bottom_sheet.dart';
import 'package:shivay_construction/widgets/app_multiple_selection_field.dart';

class ItemHelpSearchScreen extends StatelessWidget {
  ItemHelpSearchScreen({super.key});

  final ItemHelpSearchController _controller = Get.put(
    ItemHelpSearchController(),
  );

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);

    return Stack(
      children: [
        GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            appBar: AppAppbar(
              title: 'Item Help',
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: tablet ? 25 : 20,
                  color: kColorPrimary,
                ),
                onPressed: () => Get.back(),
              ),
              actions: [
                Padding(
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
                        key: _controller.searchFormKey,
                        child: Column(
                          children: [
                            tablet ? AppSpaces.v10 : AppSpaces.v4,
                            Obx(
                              () => AppDropdown(
                                items: _controller.categoryNames,
                                hintText: 'Category',
                                onChanged: _controller.onCategorySelected,
                                selectedItem:
                                    _controller
                                        .selectedCategory
                                        .value
                                        .isNotEmpty
                                    ? _controller.selectedCategory.value
                                    : null,
                              ),
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,
                            Obx(
                              () => AppDropdown(
                                items: _controller.itemGroupNames,
                                hintText: 'Item Group',
                                onChanged: _controller.onItemGroupSelected,
                                selectedItem:
                                    _controller
                                        .selectedItemGroup
                                        .value
                                        .isNotEmpty
                                    ? _controller.selectedItemGroup.value
                                    : null,
                              ),
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,
                            Obx(
                              () => AppDropdown(
                                items: _controller.itemSubGroupNames,
                                hintText: 'Item Sub Group',
                                onChanged: _controller.onItemSubGroupSelected,
                                selectedItem:
                                    _controller
                                        .selectedItemSubGroup
                                        .value
                                        .isNotEmpty
                                    ? _controller.selectedItemSubGroup.value
                                    : null,
                              ),
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,
                            GestureDetector(
                              onTap: () =>
                                  _showItemSelectionBottomSheet(context),
                              child: AppMultipleSelectionField(
                                placeholder: 'Select Items',
                                selectedItems: _controller.selectedItems,
                                onTap: () =>
                                    _showItemSelectionBottomSheet(context),
                                showFullList: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  AppButton(
                    title: 'Search Items',
                    buttonHeight: tablet ? 54 : 48,
                    onPressed: () {
                      Get.to(
                        () => ItemHelpItemsScreen(
                          cCode: _controller.selectedCategoryCode.value,
                          igCode: _controller.selectedItemGroupCode.value,
                          icCode: _controller.selectedItemSubGroupCode.value,
                          iCode: _controller.selectedItemCodes.join(','),
                        ),
                      );
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
        items: _controller.items,
        selectedCodes: _controller.selectedItemCodes,
        selectedNames: _controller.selectedItems,
        itemNameGetter: (item) => item.iName,
        itemCodeGetter: (item) => item.iCode,
        searchController: TextEditingController(),
        onSelectionChanged: (selected, item) {
          if (selected == true) {
            _controller.selectedItemCodes.add(item.iCode);
            _controller.selectedItems.add(item.iName);
          } else {
            _controller.selectedItemCodes.remove(item.iCode);
            _controller.selectedItems.remove(item.iName);
          }
        },
        onSelectAll: _controller.selectAllItems,
        onClearAll: () {
          _controller.selectedItemCodes.clear();
          _controller.selectedItems.clear();
        },
        onSearchChanged: (value) {},
      ),
      isScrollControlled: true,
    );
  }
}
