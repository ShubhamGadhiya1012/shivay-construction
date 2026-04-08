// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/indent_entry/screens/site_wise_stock_screen.dart';
import 'package:shivay_construction/features/purchase_order_entry/controllers/purchase_order_controller.dart';
import 'package:shivay_construction/features/purchase_order_entry/models/purchase_order_detail_dm.dart';
import 'package:shivay_construction/features/purchase_order_entry/models/purchase_order_list_dm.dart';
import 'package:shivay_construction/features/purchase_order_entry/screens/last_purchase_rate_screen.dart';
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
    await _controller.getParties();

    if (widget.order != null && widget.orderDetails != null) {
      _loadEditData();
    }

    // Load auth indent items (no site code needed)
    await _controller.getAuthIndentItems();
  }

  void _loadEditData() {
    final order = widget.order!;
    final details = widget.orderDetails!;

    _controller.isEditMode.value = true;
    _controller.currentInvNo.value = order.invNo;
    _controller.dateController.text = convertyyyyMMddToddMMyyyy(order.date);
    _controller.remarksController.text = order.remarks;

    _controller.selectedSiteCode.value = order.siteCode;
    _controller.selectedSiteName.value = order.siteName;
    _controller.lockedSiteCode.value = order.siteCode;
    _controller.lockedSiteName.value = order.siteName;

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
          'Price': indent.price ?? 0.0,
          'IndentNo': indent.indentInvNo,
          'IndentSrNo': indent.indentSrNo,
          'ReqDate': indent.reqDate.isNotEmpty
              ? convertyyyyMMddToddMMyyyy(indent.reqDate)
              : convertyyyyMMddToddMMyyyy(
                  DateTime.now().toString().split(' ')[0],
                ),
          'GDCode': indent.gdCode,
          'GDName': indent.gdName,
          'IndentRemark': indent.indentRemark,
          'SiteCode': order.siteCode,
          'SiteName': order.siteName,
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
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
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
                    ? _buildStepZero(tablet) // Selection card screen
                    : _buildStepOne(tablet); // Form screen
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
      _controller.goBackToSelection();
    } else {
      Get.back();
    }
  }

  // ─── STEP 0: Selection Card Screen ─────────────────────────────────────────

  Widget _buildStepZero(bool tablet) {
    return Padding(
      padding: tablet
          ? AppPaddings.combined(horizontal: 24, vertical: 12)
          : AppPaddings.p12,
      child: Column(
        children: [
          // Selection mode header
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                        Obx(() {
                          if (_controller.lockedSiteName.value.isNotEmpty) {
                            return Text(
                              'Site: ${_controller.lockedSiteName.value}',
                              style: TextStyles.kRegularOutfit(
                                fontSize: tablet
                                    ? FontSizes.k12FontSize
                                    : FontSizes.k10FontSize,
                                color: kColorDarkGrey,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }),
                      ],
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

          // Hint banner
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
                  border: Border.all(color: kColorPrimary.withOpacity(0.2)),
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
                        'Long press on an indent to start selection. Only indents from the same site can be selected.',
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

          tablet ? AppSpaces.v12 : AppSpaces.v10,

          // List of auth indent items
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
                      controller: _controller,
                    );
                  });
                },
              );
            }),
          ),

          // Proceed button
          Obx(() {
            if (_controller.selectedPurchaseItems.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              children: [
                AppButton(
                  title:
                      'Proceed (${_controller.selectedPurchaseItems.length} items)',
                  buttonHeight: tablet ? 54 : 48,
                  onPressed: () => _controller.proceedToForm(),
                ),
                tablet ? AppSpaces.v10 : AppSpaces.v8,
              ],
            );
          }),
        ],
      ),
    );
  }

  // ─── STEP 1: Form Screen ────────────────────────────────────────────────────

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

                    // Date
                    AppDatePickerTextFormField(
                      dateController: _controller.dateController,
                      hintText: 'Date *',
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please select date'
                          : null,
                    ),
                    tablet ? AppSpaces.v16 : AppSpaces.v10,

                    Obx(() {
                      return Container(
                        padding: tablet
                            ? AppPaddings.combined(horizontal: 12, vertical: 12)
                            : AppPaddings.combined(horizontal: 8, vertical: 8),
                        decoration: BoxDecoration(
                          color: kColorPrimary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: kColorPrimary.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: kColorPrimary,
                              size: tablet ? 20 : 18,
                            ),
                            AppSpaces.h8,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Site',
                                    style: TextStyles.kRegularOutfit(
                                      fontSize: tablet
                                          ? FontSizes.k12FontSize
                                          : FontSizes.k10FontSize,
                                      color: kColorDarkGrey,
                                    ),
                                  ),
                                  Text(
                                    _controller
                                            .selectedSiteName
                                            .value
                                            .isNotEmpty
                                        ? _controller.selectedSiteName.value
                                        : '—',
                                    style: TextStyles.kMediumOutfit(
                                      fontSize: tablet
                                          ? FontSizes.k14FontSize
                                          : FontSizes.k12FontSize,
                                      color: kColorTextPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.lock_outline,
                              color: kColorDarkGrey,
                              size: tablet ? 16 : 14,
                            ),
                          ],
                        ),
                      );
                    }),
                    tablet ? AppSpaces.v16 : AppSpaces.v10,

                    // Party dropdown
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

                    // Remarks
                    AppTextFormField(
                      controller: _controller.remarksController,
                      hintText: 'Remarks',
                      maxLines: 3,
                    ),
                    tablet ? AppSpaces.v20 : AppSpaces.v14,

                    // Attachments
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
                            title: '+ Attachment',
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

                    // New attachments list
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

                    // Existing attachments
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

                    tablet ? AppSpaces.v20 : AppSpaces.v14,

                    // Items header with "Edit Selection" button
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
                            title: '+ Add / Edit Items',
                            titleSize: tablet
                                ? FontSizes.k14FontSize
                                : FontSizes.k12FontSize,
                            onPressed: () => _controller.goBackToSelection(),
                          ),
                        ],
                      ),
                    ),
                    tablet ? AppSpaces.v10 : AppSpaces.v6,

                    // Selected items list
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
                              final key =
                                  '${item['IndentNo']}_${item['IndentSrNo']}';
                              final qtyController =
                                  _controller.qtyControllers[key];
                              final priceController =
                                  _controller.priceControllers[key];
                              final dateCtrl = _controller.dateControllers[key];
                              final remarkController =
                                  _controller.remarkControllers[key];

                              return Padding(
                                padding: tablet
                                    ? AppPaddings.combined(
                                        horizontal: 16,
                                        vertical: 12,
                                      )
                                    : AppPaddings.combined(
                                        horizontal: 14,
                                        vertical: 10,
                                      ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.inventory_2_outlined,
                                          color: kColorPrimary,
                                          size: tablet ? 24 : 20,
                                        ),
                                        tablet ? AppSpaces.h10 : AppSpaces.h8,
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item['iName'] ??
                                                    item['ICode'] ??
                                                    '',
                                                style: TextStyles.kMediumOutfit(
                                                  fontSize: tablet
                                                      ? FontSizes.k14FontSize
                                                      : FontSizes.k12FontSize,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              AppSpaces.v2,
                                              Text(
                                                'Indent: ${item['IndentNo']} | Site: ${item['SiteName'] ?? ''}',
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
                                            ],
                                          ),
                                        ),
                                        Material(
                                          color: kColorGreen.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            tablet ? 8 : 6,
                                          ),
                                          child: InkWell(
                                            onTap: () => Get.to(
                                              () => SiteWiseStockScreen(
                                                iCode: item['ICode'],
                                              ),
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              tablet ? 8 : 6,
                                            ),
                                            child: Container(
                                              padding: tablet
                                                  ? AppPaddings.combined(
                                                      horizontal: 10,
                                                      vertical: 10,
                                                    )
                                                  : AppPaddings.combined(
                                                      horizontal: 8,
                                                      vertical: 8,
                                                    ),
                                              child: Icon(
                                                Icons.visibility_rounded,
                                                size: tablet ? 18 : 16,
                                                color: kColorGreen,
                                              ),
                                            ),
                                          ),
                                        ),
                                        tablet ? AppSpaces.h8 : AppSpaces.h6,
                                        Material(
                                          color: kColorSecondary.withOpacity(
                                            0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            tablet ? 8 : 6,
                                          ),
                                          child: InkWell(
                                            onTap: () => Get.to(
                                              () => LastPurchaseRateScreen(
                                                iCode: item['ICode'],
                                              ),
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              tablet ? 8 : 6,
                                            ),
                                            child: Container(
                                              padding: tablet
                                                  ? AppPaddings.combined(
                                                      horizontal: 10,
                                                      vertical: 10,
                                                    )
                                                  : AppPaddings.combined(
                                                      horizontal: 8,
                                                      vertical: 8,
                                                    ),
                                              child: Icon(
                                                Icons.currency_rupee_rounded,
                                                size: tablet ? 18 : 16,
                                                color: kColorSecondary,
                                              ),
                                            ),
                                          ),
                                        ),
                                        tablet ? AppSpaces.h8 : AppSpaces.h6,
                                        Material(
                                          color: kColorRed.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            tablet ? 8 : 6,
                                          ),
                                          child: InkWell(
                                            onTap: () => _controller
                                                .removeSelectedItem(index),
                                            borderRadius: BorderRadius.circular(
                                              tablet ? 8 : 6,
                                            ),
                                            child: Container(
                                              padding: tablet
                                                  ? AppPaddings.combined(
                                                      horizontal: 10,
                                                      vertical: 10,
                                                    )
                                                  : AppPaddings.combined(
                                                      horizontal: 8,
                                                      vertical: 8,
                                                    ),
                                              child: Icon(
                                                Icons.delete_rounded,
                                                size: tablet ? 18 : 16,
                                                color: kColorRed,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    tablet ? AppSpaces.v12 : AppSpaces.v10,

                                    if (dateCtrl != null) ...[
                                      AppDatePickerTextFormField(
                                        dateController: dateCtrl,
                                        hintText: 'Required Date',
                                        validator: (value) =>
                                            (value == null || value.isEmpty)
                                            ? 'Required'
                                            : null,
                                        onChanged: (value) {
                                          if (value.isNotEmpty) {
                                            _controller
                                                    .selectedPurchaseItems[index]['ReqDate'] =
                                                value;
                                            _controller.selectedPurchaseItems
                                                .refresh();
                                          }
                                        },
                                      ),
                                      tablet ? AppSpaces.v12 : AppSpaces.v10,
                                    ],

                                    Obx(
                                      () => AppDropdown(
                                        items: _controller.godownNames,
                                        hintText: 'Head',
                                        onChanged: (val) => _controller
                                            .onGodownSelected(key, val),
                                        selectedItem:
                                            (_controller.selectedGodownName[key] ??
                                                    '')
                                                .isNotEmpty
                                            ? _controller
                                                  .selectedGodownName[key]
                                            : null,
                                      ),
                                    ),
                                    tablet ? AppSpaces.v12 : AppSpaces.v10,

                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Quantity',
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
                                              AppSpaces.v4,
                                              if (qtyController != null)
                                                AppTextFormField(
                                                  controller: qtyController,
                                                  hintText: 'Quantity',
                                                  keyboardType:
                                                      TextInputType.number,
                                                  floatingLabelRequired: false,
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Required';
                                                    }
                                                    final qty = double.tryParse(
                                                      value,
                                                    );
                                                    if (qty == null ||
                                                        qty <= 0) {
                                                      return 'Must be > 0';
                                                    }
                                                    return null;
                                                  },
                                                  onChanged: (value) {
                                                    final qty =
                                                        double.tryParse(
                                                          value,
                                                        ) ??
                                                        item['Qty'];
                                                    _controller
                                                        .updateSelectedItemQty(
                                                          index,
                                                          qty,
                                                        );
                                                  },
                                                ),
                                            ],
                                          ),
                                        ),
                                        tablet ? AppSpaces.h12 : AppSpaces.h10,
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Price',
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
                                              AppSpaces.v4,
                                              if (priceController != null)
                                                AppTextFormField(
                                                  controller: priceController,
                                                  hintText: 'Price',
                                                  keyboardType:
                                                      TextInputType.number,
                                                  floatingLabelRequired: false,
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Required';
                                                    }
                                                    final price =
                                                        double.tryParse(value);
                                                    if (price == null ||
                                                        price <= 0) {
                                                      return 'Must be > 0';
                                                    }
                                                    return null;
                                                  },
                                                  onChanged: (value) {
                                                    final price =
                                                        double.tryParse(
                                                          value,
                                                        ) ??
                                                        0.0;
                                                    _controller
                                                        .updateSelectedItemPrice(
                                                          index,
                                                          price,
                                                        );
                                                  },
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    tablet ? AppSpaces.v12 : AppSpaces.v10,

                                    if (remarkController != null) ...[
                                      Text(
                                        'Remark',
                                        style: TextStyles.kRegularOutfit(
                                          fontSize: tablet
                                              ? FontSizes.k12FontSize
                                              : FontSizes.k10FontSize,
                                          color: kColorDarkGrey,
                                        ),
                                      ),
                                      AppSpaces.v4,
                                      AppTextFormField(
                                        controller: remarkController,
                                        hintText: 'Enter Remark',
                                        maxLines: 2,
                                        floatingLabelRequired: false,
                                        onChanged: (value) {
                                          _controller
                                                  .selectedPurchaseItems[index]['IndentRemark'] =
                                              value;
                                          _controller.selectedPurchaseItems
                                              .refresh();
                                        },
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),
              ),
            ),

            // Submit button
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
              _buildAttachmentOption(
                context: context,
                tablet: tablet,
                icon: Icons.camera_alt_rounded,
                title: 'Take Photo',
                subtitle: 'Capture using camera',
                onTap: () {
                  Get.back();
                  _controller.pickFromCamera();
                },
              ),
              tablet ? AppSpaces.v16 : AppSpaces.v12,
              _buildAttachmentOption(
                context: context,
                tablet: tablet,
                icon: Icons.upload_file_rounded,
                title: 'Upload File',
                subtitle: 'Choose from device storage',
                onTap: () {
                  Get.back();
                  _controller.pickFiles();
                },
              ),
              tablet ? AppSpaces.v12 : AppSpaces.v8,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required BuildContext context,
    required bool tablet,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
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
          border: Border.all(color: kColorPrimary.withOpacity(0.3), width: 1.5),
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
              child: Icon(icon, color: kColorWhite, size: tablet ? 28 : 24),
            ),
            tablet ? AppSpaces.h16 : AppSpaces.h12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyles.kSemiBoldOutfit(
                      fontSize: tablet
                          ? FontSizes.k16FontSize
                          : FontSizes.k14FontSize,
                      color: kColorTextPrimary,
                    ),
                  ),
                  AppSpaces.v4,
                  Text(
                    subtitle,
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
    );
  }
}
