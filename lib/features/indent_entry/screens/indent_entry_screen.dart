// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/indent_entry/controllers/indent_entry_controller.dart';
import 'package:shivay_construction/features/indent_entry/models/indent_dm.dart';
import 'package:shivay_construction/features/indent_entry/models/indent_detail_dm.dart';
import 'package:shivay_construction/features/indent_entry/screens/site_wise_stock_screen.dart';
import 'package:shivay_construction/features/indent_entry/widgets/indent_item_card.dart';
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

class IndentEntryScreen extends StatefulWidget {
  const IndentEntryScreen({
    super.key,
    required this.isEdit,
    this.indent,
    this.indentDetails,
  });

  final bool isEdit;
  final IndentDm? indent;
  final List<IndentDetailDm>? indentDetails;

  @override
  State<IndentEntryScreen> createState() => _IndentEntryScreenState();
}

class _IndentEntryScreenState extends State<IndentEntryScreen> {
  final IndentEntryController _controller = Get.put(IndentEntryController());

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() async {
    _controller.dateController.text = DateFormat(
      'dd-MM-yyyy',
    ).format(DateTime.now());

    await _controller.getGodowns();
    await _controller.getItems();

    if (widget.isEdit && widget.indent != null) {
      final indent = widget.indent!;

      _controller.isEditMode.value = true;
      _controller.currentInvNo.value = indent.invNo;
      _controller.dateController.text = _convertyyyyMMddToddMMyyyy(indent.date);

      _controller.selectedGodownCode.value = indent.gdCode;
      _controller.selectedGodownName.value = indent.gdName;
      _controller.selectedSiteCode.value = indent.siteCode;
      _controller.siteNameController.text = indent.siteName;

      if (indent.attachments.isNotEmpty) {
        _controller.existingAttachmentUrls.clear();
        _controller.existingAttachmentUrls.addAll(
          indent.attachments.split(','),
        );
      }

      if (widget.indentDetails != null && widget.indentDetails!.isNotEmpty) {
        _controller.itemsToSend.assignAll(
          widget.indentDetails!.map((indentDtl) {
            return {
              "SrNo": indentDtl.srNo,
              "ICode": indentDtl.iCode,
              "iname": indentDtl.iCode.isNotEmpty
                  ? _controller.items
                        .firstWhere((item) => item.iCode == indentDtl.iCode)
                        .iName
                  : '',
              "Unit": indentDtl.unit,
              "Qty": indentDtl.indentQty,
              "ReqDate": indentDtl.reqDate.isNotEmpty ? indentDtl.reqDate : '',
              "reqDate": indentDtl.reqDate.isNotEmpty
                  ? _convertyyyyMMddToddMMyyyy(indentDtl.reqDate)
                  : '',
            };
          }).toList(),
        );
      }
    }
  }

  String _convertyyyyMMddToddMMyyyy(String dateStr) {
    if (dateStr.isEmpty) return '';
    final parts = dateStr.split('-');
    return '${parts[2]}-${parts[1]}-${parts[0]}';
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
              title: widget.isEdit ? 'Edit Indent' : 'Add Indent',
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
                key: _controller.indentFormKey,
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
                            tablet ? AppSpaces.v16 : AppSpaces.v10,
                            Obx(() {
                              if (_controller
                                  .selectedGodownCode
                                  .value
                                  .isEmpty) {
                                return const SizedBox.shrink();
                              }

                              return AppTextFormField(
                                controller: _controller.siteNameController,
                                hintText: 'Site Name',
                                enabled: false,
                                fillColor: kColorLightGrey,
                              );
                            }),

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
                                        _showAttachmentSourceDialog(context),
                                  ),
                                ],
                              ),
                            ),
                            tablet ? AppSpaces.v10 : AppSpaces.v6,
                            Obx(() {
                              if (_controller.attachmentFiles.isNotEmpty) {
                                return Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: kColorLightGrey),
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
                                      final file =
                                          _controller.attachmentFiles[index];
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                        borderRadius: BorderRadius.circular(10),
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
                                              style: TextStyles.kMediumOutfit(
                                                fontSize: tablet
                                                    ? FontSizes.k14FontSize
                                                    : FontSizes.k12FontSize,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            subtitle: Text(
                                              'Tap to view',
                                              style: TextStyles.kRegularOutfit(
                                                fontSize: tablet
                                                    ? FontSizes.k12FontSize
                                                    : FontSizes.k10FontSize,
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
                                    _controller.prepareAddItem();
                                    _showItemDialog();
                                  },
                                ),
                              ],
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
                                      child: IndentItemCard(
                                        item: item,
                                        onEdit: () {
                                          _controller.prepareEditItem(index);
                                          _showItemDialog();
                                        },
                                        onDelete: () =>
                                            _showDeleteConfirmation(index),
                                        onViewStock: () {
                                          Get.to(
                                            () => SiteWiseStockScreen(
                                              iCode:
                                                  item['ICode'] ??
                                                  item['icode'] ??
                                                  '',
                                            ),
                                          );
                                        },
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
                                if (_controller.indentFormKey.currentState!
                                    .validate()) {
                                  if (_controller.itemsToSend.isNotEmpty) {
                                    _controller.saveIndentEntry();
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
              Text(
                'Choose how you want to add your attachment',
                style: TextStyles.kRegularOutfit(
                  fontSize: tablet
                      ? FontSizes.k14FontSize
                      : FontSizes.k12FontSize,
                  color: kColorDarkGrey,
                ),
                textAlign: TextAlign.center,
              ),
              tablet ? AppSpaces.v24 : AppSpaces.v20,
              InkWell(
                onTap: () {
                  Get.back();
                  _controller.pickFromCamera();
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: tablet ? AppPaddings.p16 : AppPaddings.p12,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        kColorPrimary.withOpacity(0.1),
                        kColorPrimary.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: kColorPrimary.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: tablet ? AppPaddings.p12 : AppPaddings.p10,
                        decoration: BoxDecoration(
                          color: kColorPrimary,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: kColorPrimary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.camera_alt_rounded,
                          color: kColorWhite,
                          size: tablet ? 28 : 24,
                        ),
                      ),
                      tablet ? AppSpaces.h16 : AppSpaces.h12,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Take Photo',
                              style: TextStyles.kSemiBoldOutfit(
                                fontSize: tablet
                                    ? FontSizes.k16FontSize
                                    : FontSizes.k14FontSize,
                                color: kColorTextPrimary,
                              ),
                            ),
                            AppSpaces.v4,
                            Text(
                              'Capture using camera',
                              style: TextStyles.kRegularOutfit(
                                fontSize: tablet
                                    ? FontSizes.k12FontSize
                                    : FontSizes.k10FontSize,
                                color: kColorDarkGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: kColorPrimary,
                        size: tablet ? 20 : 18,
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
                    gradient: LinearGradient(
                      colors: [
                        kColorPrimary.withOpacity(0.1),
                        kColorPrimary.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: kColorPrimary.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: tablet ? AppPaddings.p12 : AppPaddings.p10,
                        decoration: BoxDecoration(
                          color: kColorPrimary,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: kColorPrimary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.upload_file_rounded,
                          color: kColorWhite,
                          size: tablet ? 28 : 24,
                        ),
                      ),
                      tablet ? AppSpaces.h16 : AppSpaces.h12,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Upload File',
                              style: TextStyles.kSemiBoldOutfit(
                                fontSize: tablet
                                    ? FontSizes.k16FontSize
                                    : FontSizes.k14FontSize,
                                color: kColorTextPrimary,
                              ),
                            ),
                            AppSpaces.v4,
                            Text(
                              'Choose from device storage',
                              style: TextStyles.kRegularOutfit(
                                fontSize: tablet
                                    ? FontSizes.k12FontSize
                                    : FontSizes.k10FontSize,
                                color: kColorDarkGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: kColorPrimary,
                        size: tablet ? 20 : 18,
                      ),
                    ],
                  ),
                ),
              ),
              tablet ? AppSpaces.v12 : AppSpaces.v8,
            ],
          ),
        ),
      ),
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
                  key: _controller.indentItemFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppDatePickerTextFormField(
                        dateController: _controller.reqDateController,
                        hintText: 'Request Date *',
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please select request date'
                            : null,
                      ),
                      tablet ? AppSpaces.v16 : AppSpaces.v12,
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

                      Row(
                        children: [
                          Expanded(
                            child: AppTextFormField(
                              controller: _controller.qtyController,
                              hintText: 'Qty *',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter qty';
                                }
                                final qty = double.tryParse(value);
                                if (qty == null) {
                                  return 'Please enter a valid number';
                                }
                                if (qty <= 0) {
                                  return 'Qty must be greater than 0';
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
                                  if (_controller
                                      .indentItemFormKey
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
