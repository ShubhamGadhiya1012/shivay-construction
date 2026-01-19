// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/grn_entry/controllers/grn_entry_controller.dart';
import 'package:shivay_construction/features/grn_entry/models/grn_dm.dart';
import 'package:shivay_construction/features/grn_entry/models/grn_detail_dm.dart';
import 'package:shivay_construction/features/grn_entry/widgets/direct_grn_item_card.dart';
import 'package:shivay_construction/features/grn_entry/widgets/grn_selected_item_card.dart';
import 'package:shivay_construction/features/grn_entry/widgets/po_item_selection_view.dart';
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

class GrnEntryScreen extends StatefulWidget {
  const GrnEntryScreen({
    super.key,
    required this.isEdit,
    this.grn,
    this.grnDetails,
    this.isDirect = false,
  });

  final bool isEdit;
  final GrnDm? grn;
  final List<GrnDetailDm>? grnDetails;
  final bool isDirect;

  @override
  State<GrnEntryScreen> createState() => _GrnEntryScreenState();
}

class _GrnEntryScreenState extends State<GrnEntryScreen> {
  final GrnEntryController _controller = Get.put(GrnEntryController());

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() async {
    _controller.dateController.text = DateFormat(
      'dd-MM-yyyy',
    ).format(DateTime.now());

    await _controller.getParties();
    await _controller.getGodowns();
    await _controller.getItems();

    if (widget.isDirect && !widget.isEdit) {
      _controller.isDirectGrn.value = true;
    }

    if (widget.isEdit && widget.grn != null) {
      final grn = widget.grn!;

      _controller.isEditMode.value = true;
      _controller.currentInvNo.value = grn.invNo;
      _controller.isDirectGrn.value = grn.type == 'Direct';
      _controller.dateController.text = convertyyyyMMddToddMMyyyy(grn.date);

      _controller.selectedPartyCode.value = grn.pCode;
      _controller.selectedPartyName.value = grn.pName;

      _controller.selectedGodownCode.value = grn.gdCode;
      _controller.selectedGodownName.value = grn.gdName;
      _controller.selectedSiteCode.value = grn.siteCode;
      _controller.siteNameController.text = grn.siteName;

      _controller.remarksController.text = grn.remarks;

      if (grn.attachments.isNotEmpty) {
        _controller.existingAttachmentUrls.clear();
        _controller.existingAttachmentUrls.addAll(grn.attachments.split(','));
      }

      if (widget.grnDetails != null && widget.grnDetails!.isNotEmpty) {
        if (grn.type == 'Direct') {
          _controller.populateDirectItemsFromGrnDetails(widget.grnDetails!);
        } else {
          _controller.populateSelectedItemsFromGrnDetails(widget.grnDetails!);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);

    return WillPopScope(
      onWillPop: () async {
        return _controller.handleBackPress();
      },
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Scaffold(
              appBar: AppAppbar(
                title: widget.isEdit ? 'Edit GRN' : 'Add GRN',
                leading: IconButton(
                  onPressed: () {
                    if (_controller.handleBackPress()) {
                      Get.back();
                    }
                  },
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size: tablet ? 25 : 20,
                    color: kColorPrimary,
                  ),
                ),
              ),
              body: Obx(() {
                if (_controller.isItemSelectionMode.value) {
                  return PoItemSelectionView(controller: _controller);
                }

                return Padding(
                  padding: tablet
                      ? AppPaddings.combined(horizontal: 24, vertical: 12)
                      : AppPaddings.p12,
                  child: Form(
                    key: _controller.grnFormKey,
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
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
                                Obx(
                                  () => AppDropdown(
                                    items: _controller.godownNames,
                                    hintText: 'Godown *',
                                    onChanged: _controller.onGodownSelected,
                                    selectedItem:
                                        _controller
                                            .selectedGodownName
                                            .value
                                            .isNotEmpty
                                        ? _controller.selectedGodownName.value
                                        : null,
                                    validatorText: 'Please select a godown',
                                  ),
                                ),
                                Obx(() {
                                  if (_controller
                                      .selectedGodownCode
                                      .value
                                      .isEmpty) {
                                    return const SizedBox.shrink();
                                  }

                                  return Column(
                                    children: [
                                      tablet ? AppSpaces.v16 : AppSpaces.v10,
                                      AppTextFormField(
                                        controller:
                                            _controller.siteNameController,
                                        hintText: 'Site Name',
                                        enabled: false,
                                        fillColor: kColorLightGrey,
                                      ),
                                    ],
                                  );
                                }),

                                tablet ? AppSpaces.v16 : AppSpaces.v10,
                                AppTextFormField(
                                  controller: _controller.remarksController,
                                  hintText: 'Remarks (Optional)',
                                  maxLines: 3,
                                ),

                                tablet ? AppSpaces.v20 : AppSpaces.v14,
                                Obx(
                                  () => Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Attachments (${_controller.attachmentFiles.length + _controller.existingAttachmentUrls.length})',
                                        style: TextStyles.kMediumOutfit(
                                          fontSize: tablet
                                              ? FontSizes.k16FontSize
                                              : FontSizes.k14FontSize,
                                          color: kColorTextPrimary,
                                        ),
                                      ),
                                      AppButton(
                                        buttonWidth: tablet
                                            ? 0.415.screenWidth
                                            : 0.45.screenWidth,
                                        buttonHeight: tablet ? 40 : 35,
                                        buttonColor: kColorPrimary,
                                        title: '+ Add',
                                        titleSize: tablet
                                            ? FontSizes.k14FontSize
                                            : FontSizes.k12FontSize,
                                        onPressed: () =>
                                            _showAttachmentSourceDialog(
                                              context,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                tablet ? AppSpaces.v10 : AppSpaces.v6,

                                Obx(() {
                                  if (_controller.attachmentFiles.isNotEmpty) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: kColorLightGrey,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: ListView.separated(
                                        padding: EdgeInsets.zero,
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount:
                                            _controller.attachmentFiles.length,
                                        separatorBuilder: (_, _) => Divider(
                                          height: 1,
                                          color: kColorLightGrey,
                                          indent: 16,
                                          endIndent: 16,
                                        ),
                                        itemBuilder: (context, index) {
                                          final file = _controller
                                              .attachmentFiles[index];
                                          return ListTile(
                                            dense: true,
                                            leading: Icon(
                                              Icons.insert_drive_file,
                                              color: kColorTextPrimary,
                                              size: tablet ? 24 : 20,
                                            ),
                                            title: Text(
                                              file.name,
                                              style: TextStyles.kMediumOutfit(
                                                fontSize: tablet
                                                    ? FontSizes.k14FontSize
                                                    : FontSizes.k12FontSize,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            subtitle: Text(
                                              '${(file.size / 1024).toStringAsFixed(2)} KB',
                                              style: TextStyles.kRegularOutfit(
                                                fontSize: tablet
                                                    ? FontSizes.k12FontSize
                                                    : FontSizes.k10FontSize,
                                                color: kColorDarkGrey,
                                              ),
                                            ),
                                            trailing: GestureDetector(
                                              onTap: () =>
                                                  _controller.removeFile(index),
                                              child: Icon(
                                                Icons.close,
                                                color: kColorRed,
                                                size: tablet ? 20 : 18,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                }),

                                tablet ? AppSpaces.v16 : AppSpaces.v10,

                                Obx(() {
                                  if (_controller
                                      .existingAttachmentUrls
                                      .isNotEmpty) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Existing Attachments (${_controller.existingAttachmentUrls.length})',
                                          style: TextStyles.kMediumOutfit(
                                            fontSize: tablet
                                                ? FontSizes.k16FontSize
                                                : FontSizes.k14FontSize,
                                            color: kColorTextPrimary,
                                          ),
                                        ),
                                        tablet ? AppSpaces.v10 : AppSpaces.v6,
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: kColorLightGrey,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: ListView.separated(
                                            padding: EdgeInsets.zero,
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: _controller
                                                .existingAttachmentUrls
                                                .length,
                                            separatorBuilder: (_, _) => Divider(
                                              height: 1,
                                              color: kColorLightGrey,
                                              indent: 16,
                                              endIndent: 16,
                                            ),
                                            itemBuilder: (context, index) {
                                              final fileUrl = _controller
                                                  .existingAttachmentUrls[index];
                                              final fileName = fileUrl
                                                  .split('/')
                                                  .last;
                                              return ListTile(
                                                dense: true,
                                                leading: Icon(
                                                  Icons.cloud_download,
                                                  color: kColorPrimary,
                                                  size: tablet ? 24 : 20,
                                                ),
                                                title: Text(
                                                  fileName,
                                                  style:
                                                      TextStyles.kMediumOutfit(
                                                        fontSize: tablet
                                                            ? FontSizes
                                                                  .k14FontSize
                                                            : FontSizes
                                                                  .k12FontSize,
                                                      ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                subtitle: Text(
                                                  'Tap to view',
                                                  style:
                                                      TextStyles.kRegularOutfit(
                                                        fontSize: tablet
                                                            ? FontSizes
                                                                  .k12FontSize
                                                            : FontSizes
                                                                  .k10FontSize,
                                                        color: kColorDarkGrey,
                                                      ),
                                                ),
                                                trailing: GestureDetector(
                                                  onTap: () => _controller
                                                      .removeExistingAttachment(
                                                        index,
                                                      ),
                                                  child: Icon(
                                                    Icons.close,
                                                    color: kColorRed,
                                                    size: tablet ? 20 : 18,
                                                  ),
                                                ),
                                                onTap: () => _controller
                                                    .openAttachment(fileUrl),
                                              );
                                            },
                                          ),
                                        ),
                                        tablet ? AppSpaces.v16 : AppSpaces.v10,
                                      ],
                                    );
                                  }
                                  return const SizedBox.shrink();
                                }),

                                tablet ? AppSpaces.v20 : AppSpaces.v14,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    AppButton(
                                      buttonWidth: tablet
                                          ? 0.415.screenWidth
                                          : 0.45.screenWidth,
                                      title: '+ Add Item',
                                      onPressed: () {
                                        if (_controller
                                            .selectedGodownCode
                                            .value
                                            .isEmpty) {
                                          showErrorSnackbar(
                                            'Error',
                                            'Please select godown first',
                                          );
                                          return;
                                        }

                                        if (_controller.isDirectGrn.value) {
                                          _controller.prepareAddDirectItem();
                                          _showDirectItemDialog();
                                        } else {
                                          _controller.getPoAuthItems();
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                tablet ? AppSpaces.v26 : AppSpaces.v20,

                                Obx(() {
                                  if (_controller.isDirectGrn.value) {
                                    if (_controller.directGrnItems.isNotEmpty) {
                                      return ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount:
                                            _controller.directGrnItems.length,
                                        itemBuilder: (context, index) {
                                          final item =
                                              _controller.directGrnItems[index];
                                          return Padding(
                                            padding: AppPaddings.custom(
                                              bottom: 8,
                                            ),
                                            child: DirectGrnItemCard(
                                              item: item,
                                              onEdit: () {
                                                _controller
                                                    .prepareEditDirectItem(
                                                      index,
                                                    );
                                                _showDirectItemDialog();
                                              },
                                              onDelete: () => _controller
                                                  .deleteDirectItem(index),
                                            ),
                                          );
                                        },
                                      );
                                    }
                                  } else {
                                    if (_controller
                                        .selectedPoOrders
                                        .isNotEmpty) {
                                      return ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount:
                                            _controller.selectedPoOrders.length,
                                        itemBuilder: (context, index) {
                                          final entry = _controller
                                              .selectedPoOrders
                                              .entries
                                              .elementAt(index);
                                          final key = entry.key;
                                          final poData = entry.value;

                                          return Padding(
                                            padding: AppPaddings.custom(
                                              bottom: 8,
                                            ),
                                            child: GrnSelectedItemCard(
                                              poData: poData,
                                              onRemove: () => _controller
                                                  .removeSelectedPo(key),
                                            ),
                                          );
                                        },
                                      );
                                    }
                                  }
                                  return const SizedBox.shrink();
                                }),
                              ],
                            ),
                          ),
                        ),

                        Obx(() {
                          final hasItems = _controller.isDirectGrn.value
                              ? _controller.directGrnItems.isNotEmpty
                              : _controller.selectedPoOrders.isNotEmpty;

                          if (hasItems) {
                            return Column(
                              children: [
                                AppButton(
                                  title: 'Save',
                                  buttonHeight: tablet ? 54 : 48,
                                  onPressed: () {
                                    if (_controller.grnFormKey.currentState!
                                        .validate()) {
                                      if (hasItems) {
                                        _controller.saveGrnEntry();
                                      } else {
                                        showErrorSnackbar(
                                          'Oops!',
                                          'Please add items to continue.',
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
                );
              }),
            ),
          ),
          Obx(() => AppLoadingOverlay(isLoading: _controller.isLoading.value)),
        ],
      ),
    );
  }

  void _showDirectItemDialog() {
    final bool tablet = AppScreenUtils.isTablet(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tablet ? 20 : 16),
        ),
        backgroundColor: Colors.transparent,
        child: Container(
          width: tablet ? 520 : double.infinity,
          decoration: BoxDecoration(
            color: kColorWhite,
            borderRadius: BorderRadius.circular(tablet ? 20 : 16),
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
                          _controller.isEditingDirectItem.value
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
                          _controller.isEditingDirectItem.value
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
                  key: _controller.directItemFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(
                        () => AppDropdown(
                          items: _controller.itemNames,
                          hintText: 'Select Item *',
                          onChanged: _controller.onDirectItemSelected,
                          selectedItem:
                              _controller
                                  .selectedDirectItemName
                                  .value
                                  .isNotEmpty
                              ? _controller.selectedDirectItemName.value
                              : null,
                          validatorText: 'Please select an item',
                        ),
                      ),
                      tablet ? AppSpaces.v16 : AppSpaces.v12,
                      Obx(
                        () => AppTextFormField(
                          controller: TextEditingController(
                            text: _controller.selectedDirectUnit.value,
                          ),
                          hintText: 'Unit',
                          enabled: false,
                          fillColor: kColorLightGrey,
                        ),
                      ),
                      tablet ? AppSpaces.v16 : AppSpaces.v12,
                      Row(
                        children: [
                          Expanded(
                            child: AppTextFormField(
                              controller: _controller.directRateController,
                              hintText: 'Rate *',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter rate';
                                }
                                final rate = double.tryParse(value);
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
                              controller: _controller.directQtyController,
                              hintText: 'Qty *',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter qty';
                                }
                                final qty = double.tryParse(value);
                                if (qty == null || qty <= 0) {
                                  return 'Please enter valid qty';
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
                                _controller.clearDirectItemForm();
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
                                title: _controller.isEditingDirectItem.value
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
                                      .directItemFormKey
                                      .currentState!
                                      .validate()) {
                                    _controller.addOrUpdateDirectItem();
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

  void _showAttachmentSourceDialog(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: kColorWhite,
            borderRadius: BorderRadius.circular(tablet ? 20 : 16),
          ),
          padding: tablet ? AppPaddings.p24 : AppPaddings.p20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: AppPaddings.p10,
                    decoration: BoxDecoration(
                      color: kColorPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.attachment,
                      color: kColorPrimary,
                      size: tablet ? 28 : 24,
                    ),
                  ),
                  tablet ? AppSpaces.h16 : AppSpaces.h12,
                  Expanded(
                    child: Text(
                      'Add Attachment',
                      style: TextStyles.kBoldOutfit(
                        fontSize: tablet
                            ? FontSizes.k20FontSize
                            : FontSizes.k18FontSize,
                        color: kColorTextPrimary,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Icon(
                      Icons.close,
                      color: kColorDarkGrey,
                      size: tablet ? 28 : 24,
                    ),
                  ),
                ],
              ),
              tablet ? AppSpaces.v20 : AppSpaces.v16,
              InkWell(
                onTap: () {
                  Get.back();
                  _controller.pickFromCamera();
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: tablet ? AppPaddings.p16 : AppPaddings.p12,
                  decoration: BoxDecoration(
                    color: kColorPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.camera_alt_rounded,
                        color: kColorPrimary,
                        size: tablet ? 28 : 24,
                      ),
                      tablet ? AppSpaces.h16 : AppSpaces.h12,
                      Text(
                        'Take Photo',
                        style: TextStyles.kSemiBoldOutfit(
                          fontSize: tablet
                              ? FontSizes.k16FontSize
                              : FontSizes.k14FontSize,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              tablet ? AppSpaces.v16 : AppSpaces.v12,
              InkWell(
                onTap: () {
                  Get.back();
                  _controller.pickFiles();
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: tablet ? AppPaddings.p16 : AppPaddings.p12,
                  decoration: BoxDecoration(
                    color: kColorPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.upload_file_rounded,
                        color: kColorPrimary,
                        size: tablet ? 28 : 24,
                      ),
                      tablet ? AppSpaces.h16 : AppSpaces.h12,
                      Text(
                        'Upload File',
                        style: TextStyles.kSemiBoldOutfit(
                          fontSize: tablet
                              ? FontSizes.k16FontSize
                              : FontSizes.k14FontSize,
                        ),
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
