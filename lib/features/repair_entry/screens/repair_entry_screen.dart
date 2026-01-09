// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/repair_entry/controllers/repair_entry_controller.dart';
import 'package:shivay_construction/features/repair_entry/models/repair_issue_dm.dart';
import 'package:shivay_construction/features/repair_entry/models/repair_issue_detail_dm.dart';
import 'package:shivay_construction/features/repair_entry/widgets/repair_item_card.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';
import 'package:shivay_construction/utils/extensions/app_size_extensions.dart';
import 'package:shivay_construction/utils/helpers/date_format_helper.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_appbar.dart';
import 'package:shivay_construction/widgets/app_button.dart';
import 'package:shivay_construction/widgets/app_date_picker_text_form_field.dart';
import 'package:shivay_construction/widgets/app_dropdown.dart';
import 'package:shivay_construction/widgets/app_loading_overlay.dart';
import 'package:shivay_construction/widgets/app_text_form_field.dart';

class RepairEntryScreen extends StatefulWidget {
  const RepairEntryScreen({super.key, this.issue, this.issueDetails});

  final RepairIssueDm? issue;
  final List<RepairIssueDetailDm>? issueDetails;

  @override
  State<RepairEntryScreen> createState() => _RepairEntryScreenState();
}

class _RepairEntryScreenState extends State<RepairEntryScreen> {
  final RepairEntryController _controller = Get.put(RepairEntryController());

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() async {
    _controller.dateController.text = DateFormat(
      'dd-MM-yyyy',
    ).format(DateTime.now());

    if (widget.issue != null && widget.issueDetails != null) {
      await _loadEditData();
    }
  }

  Future<void> _loadEditData() async {
    final issue = widget.issue!;
    final details = widget.issueDetails!;

    _controller.isEditMode.value = true;
    _controller.currentInvNo.value = issue.invNo;
    _controller.dateController.text = convertyyyyMMddToddMMyyyy(
      issue.issueDate,
    );
    _controller.descriptionController.text = issue.description;
    _controller.remarksController.text = issue.remarks;

    _controller.selectedPartyCode.value = issue.pCode;
    _controller.selectedPartyName.value = issue.pName;

    _controller.selectedFromGodownCode.value = issue.gdCode;
    _controller.selectedFromGodownName.value = issue.gdName;
    _controller.selectedFromSiteCode.value = issue.site;
    _controller.fromSiteNameController.text = issue.siteName;

    _controller.canAddItem.value = true;
    await _controller.getStockItems();

    _controller.itemsToSend.clear();
    int srNo = 1;
    for (var item in details) {
      _controller.itemsToSend.add({
        'SrNo': srNo++,
        'ICode': item.iCode,
        'iname': item.iName,
        'unit': 'Nos',
        'Qty': item.issuedQty,
        'availableQty': item.issuedQty,
      });
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
              title: widget.issue != null
                  ? 'Edit Repair Issue'
                  : 'New Repair Issue',
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
                key: _controller.repairFormKey,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppSpaces.v10,
                            AppDatePickerTextFormField(
                              dateController: _controller.dateController,
                              hintText: 'Date *',
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Please select date'
                                  : null,
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,
                            Obx(
                              () => AppDropdown(
                                items: _controller.partyNames,
                                hintText: 'Party *',
                                onChanged: _controller.onPartySelected,
                                selectedItem:
                                    _controller
                                        .selectedPartyName
                                        .value
                                        .isNotEmpty
                                    ? _controller.selectedPartyName.value
                                    : null,
                                validatorText: 'Please select a party',
                              ),
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,
                            AppTextFormField(
                              controller: _controller.descriptionController,
                              hintText: 'Description *',
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Please enter description'
                                  : null,
                            ),
                            tablet ? AppSpaces.v20 : AppSpaces.v14,
                            Text(
                              'From',
                              style: TextStyles.kSemiBoldOutfit(
                                fontSize: tablet
                                    ? FontSizes.k18FontSize
                                    : FontSizes.k16FontSize,
                                color: kColorTextPrimary,
                              ),
                            ),
                            tablet ? AppSpaces.v12 : AppSpaces.v8,
                            Obx(
                              () => AppDropdown(
                                items: _controller.godownNames,
                                hintText: 'From Godown *',
                                onChanged: _controller.onFromGodownSelected,
                                selectedItem:
                                    _controller
                                        .selectedFromGodownName
                                        .value
                                        .isNotEmpty
                                    ? _controller.selectedFromGodownName.value
                                    : null,
                                validatorText: 'Please select from godown',
                              ),
                            ),
                            tablet ? AppSpaces.v12 : AppSpaces.v8,
                            Obx(() {
                              if (_controller
                                  .selectedFromGodownCode
                                  .value
                                  .isEmpty) {
                                return const SizedBox.shrink();
                              }

                              return AppTextFormField(
                                controller: _controller.fromSiteNameController,
                                hintText: 'From Site',
                                enabled: false,
                                fillColor: kColorLightGrey,
                              );
                            }),
                            tablet ? AppSpaces.v16 : AppSpaces.v12,
                            AppTextFormField(
                              controller: _controller.remarksController,
                              hintText: 'Remarks',
                              maxLines: 3,
                            ),
                            tablet ? AppSpaces.v20 : AppSpaces.v14,
                            Obx(
                              () => Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Opacity(
                                    opacity: _controller.canAddItem.value
                                        ? 1.0
                                        : 0.5,
                                    child: AppButton(
                                      buttonWidth: tablet
                                          ? 0.415.screenWidth
                                          : 0.45.screenWidth,
                                      buttonHeight: tablet ? 40 : 35,
                                      buttonColor: _controller.canAddItem.value
                                          ? kColorPrimary
                                          : kColorLightGrey,
                                      title: '+ Add Item',
                                      titleSize: tablet
                                          ? FontSizes.k14FontSize
                                          : FontSizes.k12FontSize,
                                      onPressed: () {
                                        if (_controller.canAddItem.value) {
                                          _controller.prepareAddItem();
                                          _showItemDialog();
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            tablet ? AppSpaces.v26 : AppSpaces.v20,
                            Obx(() {
                              if (_controller.itemsToSend.isNotEmpty) {
                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _controller.itemsToSend.length,
                                  itemBuilder: (context, index) {
                                    final item = _controller.itemsToSend[index];

                                    return Padding(
                                      padding: AppPaddings.custom(bottom: 8),
                                      child: RepairItemCard(
                                        item: item,
                                        onEdit: () {
                                          _controller.prepareEditItem(index);
                                          _showItemDialog();
                                        },
                                        onDelete: () =>
                                            _showDeleteConfirmation(index),
                                      ),
                                    );
                                  },
                                );
                              }

                              return const SizedBox.shrink();
                            }),
                          ],
                        ),
                      ),
                    ),
                    Obx(() {
                      if (_controller.itemsToSend.isNotEmpty) {
                        return Column(
                          children: [
                            AppButton(
                              title: 'Save',
                              buttonHeight: tablet ? 54 : 48,
                              onPressed: () {
                                if (_controller.repairFormKey.currentState!
                                    .validate()) {
                                  if (_controller.itemsToSend.isNotEmpty) {
                                    _controller.saveRepairIssue();
                                  } else {
                                    showErrorSnackbar(
                                      'Oops!',
                                      'Please add at least one item to continue.',
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
                  key: _controller.itemFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(
                        () => AppDropdown(
                          items: _controller.itemNames,
                          hintText: 'Select Item *',
                          onChanged: _controller.onItemSelected,
                          selectedItem:
                              _controller.selectedItemName.value.isNotEmpty
                              ? _controller.selectedItemName.value
                              : null,
                          validatorText: 'Please select an item',
                        ),
                      ),
                      tablet ? AppSpaces.v16 : AppSpaces.v12,
                      Obx(() {
                        if (_controller.selectedItemCode.value.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Container(
                          padding: tablet ? AppPaddings.p12 : AppPaddings.p10,
                          decoration: BoxDecoration(
                            color: kColorGreen.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: kColorGreen.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Available Qty:',
                                style: TextStyles.kMediumOutfit(
                                  fontSize: tablet
                                      ? FontSizes.k14FontSize
                                      : FontSizes.k12FontSize,
                                  color: kColorDarkGrey,
                                ),
                              ),
                              Text(
                                '${_controller.availableQty.value.toStringAsFixed(2)} ${_controller.selectedUnit.value}',
                                style: TextStyles.kSemiBoldOutfit(
                                  fontSize: tablet
                                      ? FontSizes.k16FontSize
                                      : FontSizes.k14FontSize,
                                  color: kColorGreen,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      tablet ? AppSpaces.v16 : AppSpaces.v12,
                      Row(
                        children: [
                          Expanded(
                            child: AppTextFormField(
                              controller: _controller.qtyController,
                              hintText: 'Repair Qty *',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter qty';
                                }
                                final qty = double.tryParse(value);
                                if (qty == null || qty <= 0) {
                                  return 'Please enter valid qty';
                                }
                                if (qty > _controller.availableQty.value) {
                                  return 'Cannot exceed available qty';
                                }
                                return null;
                              },
                            ),
                          ),
                          tablet ? AppSpaces.h16 : AppSpaces.h12,
                          Expanded(
                            child: Obx(
                              () => AppTextFormField(
                                controller: TextEditingController(
                                  text: _controller.selectedUnit.value,
                                ),
                                hintText: 'Unit',
                                enabled: false,
                                fillColor: kColorLightGrey,
                              ),
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
                                  if (_controller.itemFormKey.currentState!
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
                              onPressed: () => Get.back(),
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
                                Get.back();
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
