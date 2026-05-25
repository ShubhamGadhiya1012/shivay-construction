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
    await _controller.getTaxTypes();

    if (widget.order != null && widget.orderDetails != null) {
      _loadEditData();
    }

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
          'IGSTPerc': 0.0,
          'CGSTPerc': 0.0,
          'SGSTPerc': 0.0,
          'HSNNo': '',
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
                switch (_controller.currentStep.value) {
                  case 0:
                    return _buildStepZero(tablet);
                  case 1:
                    return _buildStepOne(tablet);
                  case 2:
                    return _buildStepTwo(tablet);
                  case 3:
                    return _buildStepThree(tablet);
                  default:
                    return _buildStepZero(tablet);
                }
              }),
            ),
          ),
          Obx(() => AppLoadingOverlay(isLoading: _controller.isLoading.value)),
        ],
      ),
    );
  }

  void _handleBackPress() {
    switch (_controller.currentStep.value) {
      case 0:
        Get.back();
        break;
      case 1:
        _controller.goBackToSelection();
        break;
      case 2:
        _controller.goBackToForm();
        break;
      case 3:
        _controller.goBackToLedger();
        break;
    }
  }

  Widget _buildStepZero(bool tablet) {
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

          Obx(() {
            if (_controller.selectedPurchaseItems.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              children: [
                AppButton(
                  title:
                      'Next (${_controller.selectedPurchaseItems.length} items)',
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

                    Obx(() => _buildLockedSiteWidget(tablet)),
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

                    Obx(
                      () => AppDropdown(
                        items: _controller.taxTypeNames,
                        hintText: 'Tax Type *',
                        onChanged: _controller.onTaxTypeSelected,
                        selectedItem:
                            _controller.selectedTaxTypeName.value.isNotEmpty
                            ? _controller.selectedTaxTypeName.value
                            : null,
                        validatorText: 'Please select a tax type',
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

                    Obx(() {
                      if (_controller.attachmentFiles.isNotEmpty) {
                        return _buildAttachmentList(tablet);
                      }
                      return const SizedBox.shrink();
                    }),
                    tablet ? AppSpaces.v16 : AppSpaces.v10,

                    Obx(() {
                      if (_controller.existingAttachmentUrls.isNotEmpty) {
                        return _buildExistingAttachmentList(tablet);
                      }
                      return const SizedBox.shrink();
                    }),

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

                    Obx(() {
                      if (_controller.selectedPurchaseItems.isNotEmpty) {
                        return _buildSelectedItemsList(tablet);
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
                    title: 'Next',
                    buttonHeight: tablet ? 54 : 48,
                    onPressed: () => _controller.proceedToLedger(),
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
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Obx(() {
                    if (_controller.ledgerDataToSend.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: AppPaddings.pv12,
                          child: Text(
                            'No ledger data available',
                            style: TextStyles.kRegularOutfit(
                              fontSize: tablet
                                  ? FontSizes.k14FontSize
                                  : FontSizes.k12FontSize,
                              color: kColorDarkGrey,
                            ),
                          ),
                        ),
                      );
                    }
                    return Container(
                      decoration: BoxDecoration(
                        color: kColorWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kColorLightGrey),
                      ),
                      padding: tablet ? AppPaddings.p12 : AppPaddings.p10,
                      child: Column(
                        children: _controller.ledgerDataToSend.map((voucher) {
                          return _buildLedgerRow(voucher, tablet);
                        }).toList(),
                      ),
                    );
                  }),
                  tablet ? AppSpaces.v16 : AppSpaces.v12,
                ],
              ),
            ),
          ),
          AppButton(
            title: 'Next',
            buttonHeight: tablet ? 54 : 48,
            onPressed: () => _controller.proceedToTerms(),
          ),
          tablet ? AppSpaces.v10 : AppSpaces.v8,
        ],
      ),
    );
  }

  Widget _buildLedgerRow(Map<String, dynamic> voucher, bool tablet) {
    final desc = voucher['DESC'] as String;
    final amtCtrl = _controller.customiseVoucherAmountControllers[desc];
    final percCtrl = _controller.customiseVoucherPercentageControllers[desc];

    final isDisabled =
        desc == 'Gross Total' ||
        desc == 'Net Total' ||
        desc == 'Round [-]' ||
        desc == 'Round [+]';
    final isNetTotal = desc == 'Net Total';
    final isGrossTotal = desc == 'Gross Total';

    if (voucher['PR'] == 'P') {
      return Padding(
        padding: AppPaddings.custom(bottom: 8),
        child: Row(
          children: [
            SizedBox(
              width: tablet ? 110 : 90,
              child: Text(
                desc,
                style: TextStyles.kRegularOutfit(
                  fontSize: tablet
                      ? FontSizes.k14FontSize
                      : FontSizes.k12FontSize,
                  color: kColorPrimary,
                ),
              ),
            ),

            Expanded(
              child: AppTextFormField(
                controller: percCtrl!,
                hintText: '%',
                keyboardType: TextInputType.number,
                floatingLabelRequired: true,
              ),
            ),
            AppSpaces.h6,
            Expanded(
              child: AppTextFormField(
                controller: amtCtrl!,
                hintText: 'Amount',
                keyboardType: TextInputType.number,
                floatingLabelRequired: true,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: AppPaddings.custom(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: tablet ? 110 : 90,
            child: Text(
              desc,
              style: TextStyles.kMediumOutfit(
                fontSize: tablet
                    ? FontSizes.k14FontSize
                    : FontSizes.k12FontSize,
                color: isNetTotal || isGrossTotal
                    ? kColorPrimary
                    : kColorTextPrimary,
                fontWeight: isNetTotal || isGrossTotal
                    ? FontWeight.w700
                    : FontWeight.w400,
              ),
            ),
          ),
          AppSpaces.h6,
          Expanded(
            child: AppTextFormField(
              controller: amtCtrl!,
              hintText: desc,
              enabled: !isDisabled,
              fillColor: isDisabled ? kColorLightGrey : kColorWhite,
              keyboardType: TextInputType.number,
              floatingLabelRequired: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepThree(bool tablet) {
    return Padding(
      padding: tablet
          ? AppPaddings.combined(horizontal: 24, vertical: 12)
          : AppPaddings.p12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSpaces.v8,

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Terms & Conditions',
                style: TextStyles.kSemiBoldOutfit(
                  fontSize: tablet
                      ? FontSizes.k20FontSize
                      : FontSizes.k18FontSize,
                  color: kColorTextPrimary,
                ),
              ),
              AppButton(
                buttonWidth: tablet ? 140 : 120,
                buttonHeight: tablet ? 38 : 34,
                title: '+ Add Term',
                titleSize: tablet
                    ? FontSizes.k14FontSize
                    : FontSizes.k12FontSize,
                onPressed: () => _controller.addManualTerm(),
              ),
            ],
          ),
          tablet ? AppSpaces.v8 : AppSpaces.v6,

          Text(
            'Select terms, edit descriptions if needed, or add custom terms.',
            style: TextStyles.kRegularOutfit(
              fontSize: tablet ? FontSizes.k14FontSize : FontSizes.k12FontSize,
              color: kColorDarkGrey,
            ),
          ),
          tablet ? AppSpaces.v16 : AppSpaces.v12,

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() {
                    if (_controller.termsList.isEmpty &&
                        !_controller.isLoading.value) {
                      return Center(
                        child: Text(
                          'No terms found',
                          style: TextStyles.kMediumOutfit(
                            fontSize: tablet
                                ? FontSizes.k16FontSize
                                : FontSizes.k14FontSize,
                            color: kColorDarkGrey,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _controller.termsList.length,
                      itemBuilder: (context, index) {
                        final term = _controller.termsList[index];
                        final editCtrl =
                            _controller.editableTermDescriptions[term.termCode];

                        return Obx(() {
                          final isSelected = _controller.selectedTermCodes
                              .contains(term.termCode);

                          return Container(
                            margin: AppPaddings.custom(bottom: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? kColorPrimary.withOpacity(0.08)
                                  : kColorWhite,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? kColorPrimary
                                    : kColorLightGrey.withOpacity(0.5),
                                width: isSelected ? 1.5 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: kColorPrimary.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                CheckboxListTile(
                                  value: isSelected,
                                  onChanged: (_) => _controller
                                      .toggleTermSelection(term.termCode),
                                  activeColor: kColorPrimary,
                                  title: Text(
                                    term.termName,
                                    style: TextStyles.kMediumOutfit(
                                      fontSize: tablet
                                          ? FontSizes.k15FontSize
                                          : FontSizes.k12FontSize,
                                      color: kColorTextPrimary,
                                    ),
                                  ),

                                  controlAffinity:
                                      ListTileControlAffinity.leading,

                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),

                                if (isSelected && editCtrl != null)
                                  Padding(
                                    padding: tablet
                                        ? AppPaddings.combined(
                                            horizontal: 12,
                                            vertical: 8,
                                          )
                                        : AppPaddings.combined(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                    child: AppTextFormField(
                                      controller: editCtrl,
                                      hintText: 'Edit term description',
                                      maxLines: 2,
                                      floatingLabelRequired: true,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        });
                      },
                    );
                  }),

                  Obx(() {
                    if (_controller.manualTermControllers.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        tablet ? AppSpaces.v16 : AppSpaces.v12,
                        Text(
                          'Custom Terms',
                          style: TextStyles.kSemiBoldOutfit(
                            fontSize: tablet
                                ? FontSizes.k16FontSize
                                : FontSizes.k14FontSize,
                            color: kColorTextPrimary,
                          ),
                        ),
                        tablet ? AppSpaces.v8 : AppSpaces.v6,
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _controller.manualTermControllers.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: AppPaddings.custom(bottom: 8),
                              padding: tablet
                                  ? AppPaddings.combined(
                                      horizontal: 12,
                                      vertical: 10,
                                    )
                                  : AppPaddings.combined(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                              decoration: BoxDecoration(
                                color: kColorWhite,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: kColorPrimary.withOpacity(0.4),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: kColorPrimary.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: AppPaddings.custom(top: 4),
                                    width: tablet ? 28 : 24,
                                    height: tablet ? 28 : 24,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: kColorPrimary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyles.kMediumOutfit(
                                        fontSize: tablet
                                            ? FontSizes.k12FontSize
                                            : FontSizes.k10FontSize,
                                        color: kColorWhite,
                                      ),
                                    ),
                                  ),
                                  tablet ? AppSpaces.h10 : AppSpaces.h8,
                                  Expanded(
                                    child: AppTextFormField(
                                      controller: _controller
                                          .manualTermControllers[index],
                                      hintText: 'Enter custom term description',
                                      maxLines: 5,
                                      floatingLabelRequired: true,
                                    ),
                                  ),
                                  tablet ? AppSpaces.h10 : AppSpaces.h8,
                                  GestureDetector(
                                    onTap: () =>
                                        _controller.removeManualTerm(index),
                                    child: Container(
                                      margin: AppPaddings.custom(top: 4),
                                      padding: AppPaddings.p6,
                                      decoration: BoxDecoration(
                                        color: kColorRed.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Icon(
                                        Icons.delete_rounded,
                                        color: kColorRed,
                                        size: tablet ? 20 : 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  }),

                  tablet ? AppSpaces.v12 : AppSpaces.v8,
                ],
              ),
            ),
          ),

          AppButton(
            title: 'Submit',
            buttonHeight: tablet ? 54 : 48,
            onPressed: () => _controller.savePurchaseOrder(),
          ),
          tablet ? AppSpaces.v10 : AppSpaces.v8,
        ],
      ),
    );
  }

  Widget _buildLockedSiteWidget(bool tablet) {
    return Container(
      padding: tablet
          ? AppPaddings.combined(horizontal: 12, vertical: 12)
          : AppPaddings.combined(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: kColorPrimary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kColorPrimary.withOpacity(0.3)),
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
                  _controller.selectedSiteName.value.isNotEmpty
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
  }

  Widget _buildAttachmentList(bool tablet) {
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
        separatorBuilder: (_, __) => Divider(
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

  Widget _buildExistingAttachmentList(bool tablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Existing Attachments (${_controller.existingAttachmentUrls.length})',
          style: TextStyles.kMediumOutfit(
            fontSize: tablet ? FontSizes.k16FontSize : FontSizes.k14FontSize,
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
            itemCount: _controller.existingAttachmentUrls.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: kColorLightGrey,
              indent: 16,
              endIndent: 16,
            ),
            itemBuilder: (context, index) {
              final fileUrl = _controller.existingAttachmentUrls[index];
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
                trailing: GestureDetector(
                  onTap: () => _controller.removeExistingAttachment(index),
                  child: Icon(
                    Icons.close,
                    color: kColorRed,
                    size: tablet ? 20 : 18,
                  ),
                ),
                onTap: () => _controller.openAttachment(fileUrl),
              );
            },
          ),
        ),
        tablet ? AppSpaces.v16 : AppSpaces.v10,
      ],
    );
  }

  Widget _buildSelectedItemsList(bool tablet) {
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
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: kColorLightGrey,
          indent: 16,
          endIndent: 16,
        ),
        itemBuilder: (context, index) {
          final item = _controller.selectedPurchaseItems[index];
          final key = '${item['IndentNo']}_${item['IndentSrNo']}';
          final qtyController = _controller.qtyControllers[key];
          final priceController = _controller.priceControllers[key];
          final dateCtrl = _controller.dateControllers[key];
          final remarkController = _controller.remarkControllers[key];

          return Padding(
            padding: tablet
                ? AppPaddings.combined(horizontal: 16, vertical: 12)
                : AppPaddings.combined(horizontal: 14, vertical: 10),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['iName'] ?? item['ICode'] ?? '',
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
                    _buildIconButton(
                      color: kColorGreen,
                      icon: Icons.visibility_rounded,
                      tablet: tablet,
                      onTap: () => Get.to(
                        () => SiteWiseStockScreen(iCode: item['ICode']),
                      ),
                    ),
                    tablet ? AppSpaces.h8 : AppSpaces.h6,
                    _buildIconButton(
                      color: kColorSecondary,
                      icon: Icons.currency_rupee_rounded,
                      tablet: tablet,
                      onTap: () => Get.to(
                        () => LastPurchaseRateScreen(iCode: item['ICode']),
                      ),
                    ),
                    tablet ? AppSpaces.h8 : AppSpaces.h6,
                    _buildIconButton(
                      color: kColorRed,
                      icon: Icons.delete_rounded,
                      tablet: tablet,
                      onTap: () => _controller.removeSelectedItem(index),
                    ),
                  ],
                ),
                tablet ? AppSpaces.v12 : AppSpaces.v10,

                if (dateCtrl != null) ...[
                  AppDatePickerTextFormField(
                    dateController: dateCtrl,
                    hintText: 'Required Date',
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Required' : null,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        _controller.selectedPurchaseItems[index]['ReqDate'] =
                            value;
                        _controller.selectedPurchaseItems.refresh();
                      }
                    },
                  ),
                  tablet ? AppSpaces.v12 : AppSpaces.v10,
                ],

                Obx(() {
                  final siteCode = item['SiteCode']; // Get from selected item
                  final filteredGodownNames = _controller.getGodownNamesBySite(
                    siteCode,
                  );

                  return AppDropdown(
                    items: filteredGodownNames,
                    hintText: 'Head',
                    onChanged: (val) => _controller.onGodownSelected(
                      key,
                      val,
                      siteCode: siteCode,
                    ),
                    selectedItem:
                        (_controller.selectedGodownName[key] ?? '').isNotEmpty
                        ? _controller.selectedGodownName[key]
                        : null,
                  );
                }),
                tablet ? AppSpaces.v12 : AppSpaces.v10,

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quantity',
                            style: TextStyles.kRegularOutfit(
                              fontSize: tablet
                                  ? FontSizes.k12FontSize
                                  : FontSizes.k10FontSize,
                              color: kColorDarkGrey,
                            ),
                          ),
                          AppSpaces.v4,
                          if (qtyController != null)
                            AppTextFormField(
                              controller: qtyController,
                              hintText: 'Quantity',
                              keyboardType: TextInputType.number,
                              floatingLabelRequired: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                final qty = double.tryParse(value);
                                if (qty == null || qty <= 0) {
                                  return 'Must be > 0';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                final qty =
                                    double.tryParse(value) ?? item['Qty'];
                                _controller.updateSelectedItemQty(index, qty);
                              },
                            ),
                        ],
                      ),
                    ),
                    tablet ? AppSpaces.h12 : AppSpaces.h10,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Price',
                            style: TextStyles.kRegularOutfit(
                              fontSize: tablet
                                  ? FontSizes.k12FontSize
                                  : FontSizes.k10FontSize,
                              color: kColorDarkGrey,
                            ),
                          ),
                          AppSpaces.v4,
                          if (priceController != null)
                            AppTextFormField(
                              controller: priceController,
                              hintText: 'Price',
                              keyboardType: TextInputType.number,
                              floatingLabelRequired: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                final price = double.tryParse(value);
                                if (price == null || price <= 0) {
                                  return 'Must be > 0';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                final price = double.tryParse(value) ?? 0.0;
                                _controller.updateSelectedItemPrice(
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

                Obx(() {
                  final percCtrl = _controller.discountPercControllers[key];
                  final amtCtrl = _controller.discountAmountControllers[key];
                  if (percCtrl == null || amtCtrl == null)
                    return const SizedBox.shrink();
                  return Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Discount %',
                              style: TextStyles.kRegularOutfit(
                                fontSize: tablet
                                    ? FontSizes.k12FontSize
                                    : FontSizes.k10FontSize,
                                color: kColorDarkGrey,
                              ),
                            ),
                            AppSpaces.v4,
                            AppTextFormField(
                              controller: percCtrl,
                              hintText: 'Disc %',
                              keyboardType: TextInputType.number,
                              floatingLabelRequired: true,
                              onChanged: (val) =>
                                  _controller.onDiscountPercChanged(key, val),
                            ),
                          ],
                        ),
                      ),
                      tablet ? AppSpaces.h12 : AppSpaces.h10,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Discount Amt',
                              style: TextStyles.kRegularOutfit(
                                fontSize: tablet
                                    ? FontSizes.k12FontSize
                                    : FontSizes.k10FontSize,
                                color: kColorDarkGrey,
                              ),
                            ),
                            AppSpaces.v4,
                            AppTextFormField(
                              controller: amtCtrl,
                              hintText: 'Disc Amt',
                              keyboardType: TextInputType.number,
                              floatingLabelRequired: true,
                              onChanged: (val) =>
                                  _controller.onDiscountAmountChanged(key, val),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
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
                    floatingLabelRequired: true,
                    onChanged: (value) {
                      _controller.selectedPurchaseItems[index]['IndentRemark'] =
                          value;
                      _controller.selectedPurchaseItems.refresh();
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

  Widget _buildIconButton({
    required Color color,
    required IconData icon,
    required bool tablet,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(tablet ? 8 : 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tablet ? 8 : 6),
        child: Container(
          padding: tablet
              ? AppPaddings.combined(horizontal: 10, vertical: 10)
              : AppPaddings.combined(horizontal: 8, vertical: 8),
          child: Icon(icon, size: tablet ? 18 : 16, color: color),
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
              _buildAttachmentOption(
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
