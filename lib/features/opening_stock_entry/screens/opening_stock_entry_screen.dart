// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/opening_stock_entry/controllers/opening_stock_entry_controller.dart';
import 'package:shivay_construction/features/opening_stock_entry/models/opening_stock_dm.dart';
import 'package:shivay_construction/features/opening_stock_entry/widgets/opening_stock_item_card.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';
import 'package:shivay_construction/utils/extensions/app_size_extensions.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_appbar.dart';
import 'package:shivay_construction/widgets/app_button.dart';
import 'package:shivay_construction/widgets/app_date_picker_text_form_field.dart';
import 'package:shivay_construction/widgets/app_dropdown.dart';
import 'package:shivay_construction/widgets/app_loading_overlay.dart';
import 'package:shivay_construction/widgets/app_text_form_field.dart';

class OpeningStockEntryScreen extends StatefulWidget {
  const OpeningStockEntryScreen({
    super.key,
    required this.isEdit,
    this.openingStock,
  });

  final bool isEdit;
  final OpeningStockDm? openingStock;

  @override
  State<OpeningStockEntryScreen> createState() =>
      _OpeningStockEntryScreenState();
}

class _OpeningStockEntryScreenState extends State<OpeningStockEntryScreen> {
  final OpeningStockEntryController _controller = Get.put(
    OpeningStockEntryController(),
  );

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() async {
    await _controller.getGodowns();
    await _controller.getItems();

    if (widget.isEdit && widget.openingStock != null) {
      final stock = widget.openingStock!;

      final parts = stock.date.split('-');
      _controller.dateController.text = '${parts[2]}-${parts[1]}-${parts[0]}';

      _controller.selectedGodownCode.value = stock.gdCode;
      _controller.selectedGodownName.value = stock.gdName;
      _controller.selectedSiteCode.value = stock.siteCode;
      _controller.siteNameController.text = stock.siteName;

      if (stock.items.isNotEmpty) {
        _controller.itemsToSend.assignAll(
          stock.items.map((item) {
            return {
              "srNo": item.srNo,
              "icode": item.iCode,
              "iname": item.iName,
              "qty": item.qty,
              "rate": item.rate,
            };
          }).toList(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            appBar: AppAppbar(
              title: widget.isEdit ? 'Edit Opening Stock' : 'Add Opening Stock',
              leading: IconButton(
                onPressed: () => Get.back(),
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: tablet ? 25 : 20,
                  color: kColorPrimary,
                ),
              ),
            ),
            body: Padding(
              padding: tablet
                  ? AppPaddings.combined(horizontal: 24, vertical: 12)
                  : AppPaddings.p12,
              child: Form(
                key: _controller.openingStockFormKey,
                child: Column(
                  children: [
                    AppSpaces.v10,
                    AppDatePickerTextFormField(
                      dateController: _controller.dateController,
                      hintText: 'Date',
                    ),
                    tablet ? AppSpaces.v16 : AppSpaces.v10,
                    Obx(
                      () => AppDropdown(
                        items: _controller.godownNames,
                        hintText: 'Godown',
                        onChanged: _controller.onGodownSelected,
                        selectedItem:
                            _controller.selectedGodownName.value.isNotEmpty
                            ? _controller.selectedGodownName.value
                            : null,
                        validatorText: 'Please select a godown.',
                      ),
                    ),
                    tablet ? AppSpaces.v16 : AppSpaces.v10,
                    AppTextFormField(
                      controller: _controller.siteNameController,
                      hintText: 'Site Name',
                      enabled: false,
                      fillColor: kColorLightGrey,
                    ),
                    tablet ? AppSpaces.v20 : AppSpaces.v14,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AppButton(
                          buttonWidth: tablet
                              ? 0.415.screenWidth
                              : 0.45.screenWidth,
                          title: '+ Add Item',
                          onPressed: () => () {
                            _controller.prepareAddItem();
                            _showItemDialog();
                          }(),
                        ),
                      ],
                    ),
                    tablet ? AppSpaces.v26 : AppSpaces.v20,
                    Obx(() {
                      if (_controller.itemsToSend.isNotEmpty) {
                        return Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _controller.itemsToSend.length,
                            itemBuilder: (context, index) {
                              final item = _controller.itemsToSend[index];

                              return Padding(
                                padding: AppPaddings.custom(bottom: 8),
                                child: OpeningStockItemCard(
                                  item: item,
                                  onEdit: () => (int index) {
                                    _controller.prepareEditItem(index);
                                    _showItemDialog();
                                  }(index),
                                  onDelete: () =>
                                      _showDeleteConfirmation(index),
                                ),
                              );
                            },
                          ),
                        );
                      }

                      return const SizedBox.shrink();
                    }),
                    Obx(() {
                      if (_controller.itemsToSend.isNotEmpty) {
                        return Column(
                          children: [
                            AppButton(
                              title: 'Save',
                              onPressed: () {
                                if (_controller
                                    .openingStockFormKey
                                    .currentState!
                                    .validate()) {
                                  if (_controller.itemsToSend.isNotEmpty) {
                                    _controller.saveOpeningStockEntry(
                                      invNo: widget.isEdit
                                          ? widget.openingStock!.invNo
                                          : '',
                                    );
                                  } else {
                                    showErrorSnackbar(
                                      'Oops!',
                                      'Please add an item to continue.',
                                    );
                                  }
                                }
                              },
                            ),
                            tablet ? AppSpaces.v20 : AppSpaces.v10,
                          ],
                        );
                      }
                      return AppSpaces.shrink;
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
        Obx(() => AppLoadingOverlay(isLoading: _controller.isLoading.value)),
      ],
    );
  }

  void _showItemDialog() {
    final bool tablet = AppScreenUtils.isTablet(context);

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
                      child: Obx(
                        () => Icon(
                          _controller.isEditingItem.value
                              ? Icons.edit_rounded
                              : Icons.add_box_rounded,
                          color: kColorPrimary,
                          size: tablet ? 26 : 22,
                        ),
                      ),
                    ),
                    tablet ? AppSpaces.h12 : AppSpaces.h10,
                    Expanded(
                      child: Obx(
                        () => Text(
                          _controller.isEditingItem.value
                              ? 'Update Item'
                              : 'Add New Item',
                          style: TextStyles.kSemiBoldOutfit(
                            fontSize: tablet
                                ? FontSizes.k22FontSize
                                : FontSizes.k18FontSize,
                            color: kColorTextPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: tablet ? AppPaddings.p24 : AppPaddings.p20,
                child: Form(
                  key: _controller.openingStockItemFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(
                        () => AppDropdown(
                          items: _controller.itemNames,
                          hintText: 'Select Item',
                          onChanged: _controller.onItemSelected,
                          selectedItem:
                              _controller.selectedItemName.value.isNotEmpty
                              ? _controller.selectedItemName.value
                              : null,
                          validatorText: 'Please select an item',
                        ),
                      ),
                      tablet ? AppSpaces.v16 : AppSpaces.v12,
                      Row(
                        children: [
                          Expanded(
                            child: AppTextFormField(
                              controller: _controller.qtyController,
                              hintText: 'Qty',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter qty';
                                }
                                return null;
                              },
                            ),
                          ),
                          tablet ? AppSpaces.h16 : AppSpaces.h12,
                          Expanded(
                            child: AppTextFormField(
                              controller: _controller.rateController,
                              hintText: 'Rate',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter rate';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      tablet ? AppSpaces.v24 : AppSpaces.v20,
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                _controller.clearItemForm();
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
                            child: Obx(
                              () => AppButton(
                                title: _controller.isEditingItem.value
                                    ? 'Update'
                                    : 'Add',
                                buttonColor: kColorPrimary,
                                titleColor: kColorWhite,
                                titleSize: tablet
                                    ? FontSizes.k16FontSize
                                    : FontSizes.k14FontSize,
                                buttonHeight: tablet ? 54 : 48,
                                onPressed: () {
                                  if (_controller
                                      .openingStockItemFormKey
                                      .currentState!
                                      .validate()) {
                                    _controller.addOrUpdateItem();
                                  }
                                },
                              ),
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

  void _showDeleteConfirmation(int index) {
    final bool tablet = AppScreenUtils.isTablet(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tablet ? 20 : 16),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: tablet ? 400 : double.infinity,
            constraints: BoxConstraints(
              maxWidth: tablet ? 400 : MediaQuery.of(context).size.width * 0.9,
            ),
            decoration: BoxDecoration(
              color: kColorWhite,
              borderRadius: BorderRadius.circular(tablet ? 20 : 16),
              boxShadow: [
                BoxShadow(
                  color: kColorRed.withOpacity(0.15),
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
                    color: kColorRed.withOpacity(0.08),
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
                          color: kColorRed.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(tablet ? 12 : 10),
                        ),
                        child: Icon(
                          Icons.delete_rounded,
                          color: kColorRed,
                          size: tablet ? 26 : 22,
                        ),
                      ),
                      tablet ? AppSpaces.h12 : AppSpaces.h10,
                      Expanded(
                        child: Text(
                          'Confirm Delete',
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Are you sure you want to delete this item?',
                        style: TextStyles.kRegularOutfit(
                          fontSize: tablet
                              ? FontSizes.k16FontSize
                              : FontSizes.k14FontSize,
                          color: kColorDarkGrey,
                        ),
                      ),
                      tablet ? AppSpaces.v24 : AppSpaces.v20,
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(),
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
                              title: 'Delete',
                              buttonColor: kColorRed,
                              titleColor: kColorWhite,
                              titleSize: tablet
                                  ? FontSizes.k16FontSize
                                  : FontSizes.k14FontSize,
                              buttonHeight: tablet ? 54 : 48,
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                                _controller.deleteItem(index);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
