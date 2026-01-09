// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/purchase_order_entry/controllers/purchase_order_controller.dart';
import 'package:shivay_construction/features/purchase_order_entry/models/purchase_order_detail_dm.dart';
import 'package:shivay_construction/features/purchase_order_entry/models/purchase_order_list_dm.dart';
import 'package:shivay_construction/features/purchase_order_entry/widgets/auth_indent_item_card.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
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

class PurchaseOrderScreen extends StatefulWidget {
  const PurchaseOrderScreen({super.key, this.order, this.orderDetails});
  final PurchaseOrderListDm? order;
  final List<PurchaseOrderDetailDm>? orderDetails;
  @override
  State<PurchaseOrderScreen> createState() => _PurchaseOrderScreenState();
}

class _PurchaseOrderScreenState extends State<PurchaseOrderScreen> {
  final PurchaseOrderController _controller = Get.put(
    PurchaseOrderController(),
  );

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
    await _controller.getParties();

    if (widget.order != null && widget.orderDetails != null) {
      _loadEditData();
    }
  }

  void _loadEditData() {
    final order = widget.order!;
    final details = widget.orderDetails!;

    _controller.isEditMode.value = true;
    _controller.currentInvNo.value = order.invNo;
    _controller.dateController.text = convertyyyyMMddToddMMyyyy(order.date);
    _controller.remarksController.text = order.remarks;

    _controller.selectedGodownCode.value = order.gdCode;
    _controller.selectedGodownName.value = order.gdName;
    _controller.selectedSiteCode.value = order.siteCode;
    _controller.siteNameController.text = order.siteName;

    _controller.selectedPartyCode.value = order.pCode;
    _controller.selectedPartyName.value = order.pName;

    if (order.attachments.isNotEmpty) {
      _controller.existingAttachmentUrls.clear();
      _controller.existingAttachmentUrls.addAll(order.attachments.split(','));
    }

    _controller.selectedPurchaseItems.clear();
    int srNo = 1;
    for (var item in details) {
      for (var indent in item.indents) {
        _controller.selectedPurchaseItems.add({
          'SrNo': srNo++,
          'ICode': item.iCode,
          'iName': item.iName,
          'Unit': indent.unit,
          'Qty': indent.orderQty,
          'IndentNo': indent.indentInvNo,
          'IndentSrNo': indent.indentSrNo,
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _handleBackPress();
      },
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Scaffold(
              appBar: AppAppbar(
                title: widget.order != null
                    ? 'Edit Purchase Order'
                    : 'New Purchase Order',
                leading: IconButton(
                  onPressed: () => _handleBackPress(),
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size: tablet ? 25 : 20,
                    color: kColorPrimary,
                  ),
                ),
              ),
              body: Obx(() {
                return _controller.currentStep.value == 0
                    ? _buildStepOne(tablet)
                    : _buildStepTwo(tablet);
              }),
            ),
          ),
          Obx(() => AppLoadingOverlay(isLoading: _controller.isLoading.value)),
        ],
      ),
    );
  }

  void _handleBackPress() {
    if (_controller.currentStep.value == 1) {
      _controller.previousStep();
    } else {
      Get.back();
    }
  }

  Widget _buildStepOne(bool tablet) {
    return Padding(
      padding: tablet
          ? AppPaddings.combined(horizontal: 24, vertical: 12)
          : AppPaddings.p12,
      child: Form(
        key: _controller.purchaseOrderFormKey,
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
                      validator: (value) => value == null || value.isEmpty
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
                            _controller.selectedGodownName.value.isNotEmpty
                            ? _controller.selectedGodownName.value
                            : null,
                        validatorText: 'Please select a godown',
                      ),
                    ),
                    Obx(() {
                      if (_controller.selectedGodownCode.value.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Column(
                        children: [
                          tablet ? AppSpaces.v16 : AppSpaces.v10,
                          AppTextFormField(
                            controller: _controller.siteNameController,
                            hintText: 'Site Name',
                            enabled: false,
                            fillColor: kColorLightGrey,
                          ),
                        ],
                      );
                    }),
                    tablet ? AppSpaces.v16 : AppSpaces.v10,
                    Obx(
                      () => AppDropdown(
                        items: _controller.partyNames,
                        hintText: 'Party *',
                        onChanged: _controller.onPartySelected,
                        selectedItem:
                            _controller.selectedPartyName.value.isNotEmpty
                            ? _controller.selectedPartyName.value
                            : null,
                        validatorText: 'Please select a party',
                      ),
                    ),
                    tablet ? AppSpaces.v16 : AppSpaces.v10,
                    AppTextFormField(
                      controller: _controller.remarksController,
                      hintText: 'Remarks',
                      maxLines: 3,
                    ),

                    tablet ? AppSpaces.v20 : AppSpaces.v14,
                    Obx(
                      () => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Items (${_controller.selectedPurchaseItems.length})',
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
                                _controller.openItemSelectionScreen(),
                          ),
                        ],
                      ),
                    ),
                    tablet ? AppSpaces.v10 : AppSpaces.v6,

                    Obx(() {
                      if (_controller.selectedPurchaseItems.isNotEmpty) {
                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: kColorLightGrey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _controller.selectedPurchaseItems.length,
                            separatorBuilder: (_, _) => Divider(
                              height: 1,
                              color: kColorLightGrey,
                              indent: 16,
                              endIndent: 16,
                            ),
                            itemBuilder: (context, index) {
                              final item =
                                  _controller.selectedPurchaseItems[index];

                              if (_controller.authIndentItems.isNotEmpty) {
                                for (var authItem
                                    in _controller.authIndentItems) {
                                  if (authItem.iCode == item['ICode']) {
                                    break;
                                  }
                                }
                              }

                              return ListTile(
                                dense: true,
                                leading: Icon(
                                  Icons.inventory_2_outlined,
                                  color: kColorPrimary,
                                  size: tablet ? 24 : 20,
                                ),
                                title: Text(
                                  item['iName'] ?? item['ICode'] ?? '',
                                  style: TextStyles.kMediumOutfit(
                                    fontSize: tablet
                                        ? FontSizes.k14FontSize
                                        : FontSizes.k12FontSize,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  'Indent: ${item['IndentNo']} | Qty: ${item['Qty']}',
                                  style: TextStyles.kRegularOutfit(
                                    fontSize: tablet
                                        ? FontSizes.k12FontSize
                                        : FontSizes.k10FontSize,
                                    color: kColorDarkGrey,
                                  ),
                                ),
                                trailing: GestureDetector(
                                  onTap: () =>
                                      _controller.removeSelectedItem(index),
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

                    tablet ? AppSpaces.v20 : AppSpaces.v14,
                    Obx(
                      () => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _controller.attachmentFiles.length,
                            separatorBuilder: (_, _) => Divider(
                              height: 1,
                              color: kColorLightGrey,
                              indent: 16,
                              endIndent: 16,
                            ),
                            itemBuilder: (context, index) {
                              final file = _controller.attachmentFiles[index];
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
                                  onTap: () => _controller.removeFile(index),
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
                      if (_controller.existingAttachmentUrls.isNotEmpty) {
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
                                border: Border.all(color: kColorLightGrey),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListView.separated(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount:
                                    _controller.existingAttachmentUrls.length,
                                separatorBuilder: (_, _) => Divider(
                                  height: 1,
                                  color: kColorLightGrey,
                                  indent: 16,
                                  endIndent: 16,
                                ),
                                itemBuilder: (context, index) {
                                  final fileUrl =
                                      _controller.existingAttachmentUrls[index];
                                  final fileName = fileUrl.split('/').last;
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
                                          .removeExistingAttachment(index),
                                      child: Icon(
                                        Icons.close,
                                        color: kColorRed,
                                        size: tablet ? 20 : 18,
                                      ),
                                    ),
                                    onTap: () =>
                                        _controller.openAttachment(fileUrl),
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
                  ],
                ),
              ),
            ),

            Obx(() {
              if (_controller.selectedPurchaseItems.isEmpty) {
                return const SizedBox.shrink();
              }

              return Column(
                children: [
                  AppButton(
                    title: 'Submit',
                    buttonHeight: tablet ? 54 : 48,
                    onPressed: () => _controller.savePurchaseOrder(),
                  ),
                  tablet ? AppSpaces.v10 : AppSpaces.v8,
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStepTwo(bool tablet) {
    return Padding(
      padding: tablet
          ? AppPaddings.combined(horizontal: 24, vertical: 12)
          : AppPaddings.p12,
      child: Column(
        children: [
          Obx(() {
            if (_controller.isSelectionMode.value) {
              return Container(
                padding: tablet ? AppPaddings.p12 : AppPaddings.p10,
                decoration: BoxDecoration(
                  color: kColorPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Selection Mode',
                      style: TextStyles.kSemiBoldOutfit(
                        fontSize: tablet
                            ? FontSizes.k16FontSize
                            : FontSizes.k14FontSize,
                        color: kColorPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => _controller.selectAllIndents(),
                          child: Text(
                            'Select All',
                            style: TextStyles.kMediumOutfit(
                              fontSize: tablet
                                  ? FontSizes.k14FontSize
                                  : FontSizes.k12FontSize,
                              color: kColorPrimary,
                            ),
                          ),
                        ),
                        tablet ? AppSpaces.h8 : AppSpaces.h4,
                        TextButton(
                          onPressed: () => _controller.deselectAllIndents(),
                          child: Text(
                            'Deselect All',
                            style: TextStyles.kMediumOutfit(
                              fontSize: tablet
                                  ? FontSizes.k14FontSize
                                  : FontSizes.k12FontSize,
                              color: kColorRed,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          Obx(() {
            if (!_controller.isSelectionMode.value &&
                _controller.authIndentItems.isNotEmpty) {
              return Container(
                margin: tablet
                    ? AppPaddings.custom(top: 12, bottom: 4)
                    : AppPaddings.custom(top: 10, bottom: 4),
                padding: tablet
                    ? AppPaddings.combined(horizontal: 14, vertical: 10)
                    : AppPaddings.combined(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      kColorPrimary.withOpacity(0.08),
                      kColorPrimary.withOpacity(0.03),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: kColorPrimary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: tablet ? AppPaddings.p8 : AppPaddings.p6,
                      decoration: BoxDecoration(
                        color: kColorPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.info_outline,
                        color: kColorWhite,
                        size: tablet ? 18 : 16,
                      ),
                    ),
                    tablet ? AppSpaces.h12 : AppSpaces.h10,
                    Expanded(
                      child: Text(
                        'Long press on Authorized indent to select multiple Indents for the Purchase Order.',
                        style: TextStyles.kMediumOutfit(
                          fontSize: tablet
                              ? FontSizes.k14FontSize
                              : FontSizes.k12FontSize,
                          color: kColorTextPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          tablet ? AppSpaces.v16 : AppSpaces.v12,
          tablet ? AppSpaces.v16 : AppSpaces.v12,

          Expanded(
            child: Obx(() {
              if (_controller.authIndentItems.isEmpty &&
                  !_controller.isLoading.value) {
                return Center(
                  child: Text(
                    'No authorized indent items found',
                    style: TextStyles.kMediumOutfit(
                      fontSize: tablet
                          ? FontSizes.k18FontSize
                          : FontSizes.k16FontSize,
                    ),
                  ),
                );
              }

              return ListView.builder(
                itemCount: _controller.authIndentItems.length,
                itemBuilder: (context, index) {
                  final item = _controller.authIndentItems[index];
                  return Obx(() {
                    return AuthIndentItemCard(
                      item: item,
                      isExpanded: _controller.expandedItemIndices.contains(
                        index,
                      ),
                      isSelectionMode: _controller.isSelectionMode.value,
                      onTap: () => _controller.toggleItemExpansion(index),
                      onIndentTap: (indentIndex) {
                        if (_controller.isSelectionMode.value) {
                          _controller.toggleIndentSelection(index, indentIndex);
                        }
                      },
                      onIndentLongPress: (indentIndex) {
                        _controller.enableSelectionMode(index, indentIndex);
                      },
                    );
                  });
                },
              );
            }),
          ),

          Obx(() {
            bool hasSelection = _controller.authIndentItems.any(
              (item) => item.indents.any((indent) => indent.isSelected),
            );

            if (_controller.authIndentItems.isEmpty || !hasSelection) {
              return const SizedBox.shrink();
            }

            return Column(
              children: [
                Obx(() {
                  bool hasSelection = _controller.authIndentItems.any(
                    (item) => item.indents.any((indent) => indent.isSelected),
                  );

                  if (_controller.authIndentItems.isEmpty || !hasSelection) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    children: [
                      AppButton(
                        title: 'Save',
                        buttonHeight: tablet ? 54 : 48,
                        onPressed: () => _controller.saveSelectedItems(),
                      ),
                      tablet ? AppSpaces.v10 : AppSpaces.v8,
                    ],
                  );
                }),
              ],
            );
          }),
        ],
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
}
