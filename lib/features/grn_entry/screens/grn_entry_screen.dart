// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/grn_entry/controllers/grn_entry_controller.dart';
import 'package:shivay_construction/features/grn_entry/models/grn_dm.dart';
import 'package:shivay_construction/features/grn_entry/models/grn_detail_dm.dart';
import 'package:shivay_construction/features/grn_entry/models/po_auth_item_dm.dart';
import 'package:shivay_construction/features/grn_entry/widgets/direct_grn_item_card.dart';
import 'package:shivay_construction/features/grn_entry/widgets/grn_selected_item_card.dart';
import 'package:shivay_construction/features/grn_entry/widgets/po_order_card.dart';
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

    await _controller.getGodowns();
    await _controller.getItems();

    if (widget.isDirect && !widget.isEdit) {
      _controller.isDirectGrn.value = true;
      _controller.currentStep.value = 1;
      // Load parties and sites for Direct GRN (reuse existing methods)
      await _controller.getParties();
      await _controller.getSites();
    } else if (!widget.isEdit) {
      _controller.isDirectGrn.value = false;
      _controller.currentStep.value = 0;
      await _controller.getPoAuthItems();
    }

    if (widget.isEdit && widget.grn != null) {
      await _loadEditData();
    }
  }

  Future<void> _loadEditData() async {
    final grn = widget.grn!;

    _controller.isEditMode.value = true;
    _controller.currentInvNo.value = grn.invNo;
    _controller.isDirectGrn.value = grn.type == 'Direct';
    _controller.dateController.text = convertyyyyMMddToddMMyyyy(grn.date);

    _controller.selectedPartyCode.value = grn.pCode;
    _controller.selectedPartyName.value = grn.pName;
    _controller.selectedSiteCode.value = grn.siteCode;
    _controller.selectedSiteName.value = grn.siteName;
    _controller.lockedSiteCode.value = grn.siteCode;
    _controller.lockedSiteName.value = grn.siteName;
    _controller.lockedPartyCode.value = grn.pCode;
    _controller.lockedPartyName.value = grn.pName;

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
        await _controller.getPoAuthItems();
      }
    }

    _controller.currentStep.value = 1;
  }

  void _handleBackPress() {
    if (_controller.currentStep.value == 1 && !widget.isEdit) {
      if (!_controller.isDirectGrn.value) {
        _controller.goBackToSelection();
      } else {
        // Direct GRN: go back to list
        Get.back();
      }
    } else {
      Get.back();
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
                title: widget.isEdit
                    ? 'Edit GRN'
                    : widget.isDirect
                    ? 'Direct GRN'
                    : 'Add GRN',
                leading: IconButton(
                  onPressed: () {
                    if (_controller.currentStep.value == 1 &&
                        !widget.isEdit &&
                        !_controller.isDirectGrn.value) {
                      _controller.goBackToSelection();
                    } else {
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
                if (_controller.currentStep.value == 0) {
                  return _buildStepZero(tablet);
                }
                return _buildStepOne(tablet);
              }),
            ),
          ),
          Obx(() => AppLoadingOverlay(isLoading: _controller.isLoading.value)),
        ],
      ),
    );
  }

  Widget _buildStepZero(bool tablet) {
    return Padding(
      padding: tablet
          ? AppPaddings.combined(horizontal: 24, vertical: 12)
          : AppPaddings.p12,
      child: Column(
        children: [
          Obx(() {
            if (_controller.isInSelectionMode.value) {
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
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Site: ${_controller.lockedSiteName.value}',
                                  style: TextStyles.kRegularOutfit(
                                    fontSize: tablet
                                        ? FontSizes.k12FontSize
                                        : FontSizes.k10FontSize,
                                    color: kColorDarkGrey,
                                  ),
                                ),
                                Text(
                                  'Party: ${_controller.lockedPartyName.value}',
                                  style: TextStyles.kRegularOutfit(
                                    fontSize: tablet
                                        ? FontSizes.k12FontSize
                                        : FontSizes.k10FontSize,
                                    color: kColorDarkGrey,
                                  ),
                                ),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        }),
                      ],
                    ),
                    TextButton(
                      onPressed: () => _controller.deselectAllOrders(),
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
              );
            }
            return const SizedBox.shrink();
          }),

          Obx(() {
            if (!_controller.isInSelectionMode.value &&
                _controller.poAuthItems.isNotEmpty) {
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
                        'Long press on a PO to start selection. Only orders from the same site and party can be selected.',
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
              if (_controller.poAuthItems.isEmpty &&
                  !_controller.isLoading.value) {
                return Center(
                  child: Text(
                    'No authorized PO items found',
                    style: TextStyles.kMediumOutfit(
                      fontSize: tablet
                          ? FontSizes.k18FontSize
                          : FontSizes.k16FontSize,
                    ),
                  ),
                );
              }
              return ListView.builder(
                itemCount: _controller.poAuthItems.length,
                itemBuilder: (context, index) {
                  final item = _controller.poAuthItems[index];
                  return Obx(() {
                    return _PoAuthItemCard(
                      item: item,
                      itemIndex: index,
                      isExpanded: _controller.expandedItemIndices.contains(
                        index,
                      ),
                      isSelectionMode: _controller.isInSelectionMode.value,
                      controller: _controller,
                    );
                  });
                },
              );
            }),
          ),

          Obx(() {
            if (_controller.selectedPoOrders.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              children: [
                AppButton(
                  title:
                      'Proceed (${_controller.selectedPoOrders.length} selected)',
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
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please select date'
                          : null,
                    ),
                    tablet ? AppSpaces.v16 : AppSpaces.v10,

                    if (!_controller.isDirectGrn.value) ...[
                      Obx(() {
                        return Container(
                          padding: tablet
                              ? AppPaddings.combined(
                                  horizontal: 12,
                                  vertical: 12,
                                )
                              : AppPaddings.combined(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
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

                      Obx(() {
                        return Container(
                          padding: tablet
                              ? AppPaddings.combined(
                                  horizontal: 12,
                                  vertical: 12,
                                )
                              : AppPaddings.combined(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
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
                                Icons.person_outline,
                                color: kColorPrimary,
                                size: tablet ? 20 : 18,
                              ),
                              AppSpaces.h8,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Party',
                                      style: TextStyles.kRegularOutfit(
                                        fontSize: tablet
                                            ? FontSizes.k12FontSize
                                            : FontSizes.k10FontSize,
                                        color: kColorDarkGrey,
                                      ),
                                    ),
                                    Text(
                                      _controller
                                              .selectedPartyName
                                              .value
                                              .isNotEmpty
                                          ? _controller.selectedPartyName.value
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
                    ] else ...[
                      // Dropdowns for Direct GRN
                      Obx(
                        () => AppDropdown(
                          items: _controller.partyNames,
                          hintText: 'Party *',
                          onChanged: _controller.onDirectPartySelected,
                          selectedItem:
                              _controller
                                  .selectedDirectPartyName
                                  .value
                                  .isNotEmpty
                              ? _controller.selectedDirectPartyName.value
                              : null,
                          validatorText: 'Please select party',
                        ),
                      ),
                      tablet ? AppSpaces.v16 : AppSpaces.v10,
                      Obx(
                        () => AppDropdown(
                          items: _controller.sites
                              .map((s) => s.siteName)
                              .toList(),
                          hintText: 'Site *',
                          onChanged: _controller.onDirectSiteSelected,
                          selectedItem:
                              _controller
                                  .selectedDirectSiteName
                                  .value
                                  .isNotEmpty
                              ? _controller.selectedDirectSiteName.value
                              : null,
                          validatorText: 'Please select site',
                        ),
                      ),
                      tablet ? AppSpaces.v16 : AppSpaces.v10,
                    ],

                    AppTextFormField(
                      controller: _controller.remarksController,
                      hintText: 'Remarks (Optional)',
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
                                ? 0.35.screenWidth
                                : 0.38.screenWidth,
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

                    tablet ? AppSpaces.v20 : AppSpaces.v14,

                    Obx(
                      () => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _controller.isDirectGrn.value
                                ? 'Items (${_controller.directGrnItems.length})'
                                : 'Selected PO Items (${_controller.selectedPoOrders.length})',
                            style: TextStyles.kMediumOutfit(
                              fontSize: tablet
                                  ? FontSizes.k16FontSize
                                  : FontSizes.k14FontSize,
                              color: kColorTextPrimary,
                            ),
                          ),
                          AppButton(
                            buttonWidth: tablet
                                ? 0.35.screenWidth
                                : 0.42.screenWidth,
                            buttonHeight: tablet ? 40 : 35,
                            buttonColor: kColorPrimary,
                            title: _controller.isDirectGrn.value
                                ? '+ Add Item'
                                : '+ Add / Edit',
                            titleSize: tablet
                                ? FontSizes.k14FontSize
                                : FontSizes.k12FontSize,
                            onPressed: () {
                              if (_controller.isDirectGrn.value) {
                                _controller.prepareAddDirectItem();
                                _showDirectItemDialog();
                              } else {
                                _controller.goBackToSelection();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    tablet ? AppSpaces.v10 : AppSpaces.v6,

                    Obx(() {
                      if (_controller.isDirectGrn.value) {
                        if (_controller.directGrnItems.isNotEmpty) {
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _controller.directGrnItems.length,
                            itemBuilder: (context, index) {
                              final item = _controller.directGrnItems[index];
                              return Padding(
                                padding: AppPaddings.custom(bottom: 8),
                                child: DirectGrnItemCard(
                                  item: item,
                                  onEdit: () {
                                    _controller.prepareEditDirectItem(index);
                                    _showDirectItemDialog();
                                  },
                                  onDelete: () =>
                                      _controller.deleteDirectItem(index),
                                ),
                              );
                            },
                          );
                        }
                      } else {
                        if (_controller.selectedPoOrders.isNotEmpty) {
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _controller.selectedPoOrders.length,
                            itemBuilder: (context, index) {
                              final entry = _controller.selectedPoOrders.entries
                                  .elementAt(index);
                              final key = entry.key;
                              final poData = entry.value;
                              return Padding(
                                padding: AppPaddings.custom(bottom: 8),
                                child: GrnSelectedItemCard(
                                  poData: poData,
                                  onRemove: () =>
                                      _controller.removeSelectedPo(key),
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
                      onPressed: () => _controller.saveGrnEntry(),
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
                        () => _buildDropdownFromController(
                          items: _controller.itemNames.toList(),
                          hintText: 'Select Item *',
                          selectedItem:
                              _controller
                                  .selectedDirectItemName
                                  .value
                                  .isNotEmpty
                              ? _controller.selectedDirectItemName.value
                              : null,
                          onChanged: _controller.onDirectItemSelected,
                          validatorText: 'Please select an item',
                          tablet: tablet,
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
                      Obx(
                        () => AppDropdown(
                          items: _controller.godownNames,
                          hintText: 'Head *',
                          onChanged: _controller.onDirectGodownSelected,
                          selectedItem:
                              _controller
                                  .selectedDirectGodownName
                                  .value
                                  .isNotEmpty
                              ? _controller.selectedDirectGodownName.value
                              : null,
                          validatorText: 'Please select Head',
                        ),
                      ),
                      tablet ? AppSpaces.v16 : AppSpaces.v12,
                      Row(
                        children: [
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
                          tablet ? AppSpaces.h16 : AppSpaces.h12,
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

  Widget _buildDropdownFromController({
    required List<String> items,
    required String hintText,
    required String? selectedItem,
    required Function(String?) onChanged,
    required String validatorText,
    required bool tablet,
  }) {
    return AppDropdown(
      items: items,
      hintText: hintText,
      onChanged: onChanged,
      selectedItem: selectedItem,
      validatorText: validatorText,
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

class _PoAuthItemCard extends StatelessWidget {
  const _PoAuthItemCard({
    required this.item,
    required this.itemIndex,
    required this.isExpanded,
    required this.isSelectionMode,
    required this.controller,
  });

  final PoAuthItemDm item;
  final int itemIndex;
  final bool isExpanded;
  final bool isSelectionMode;
  final GrnEntryController controller;

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);

    return Container(
      margin: tablet
          ? AppPaddings.custom(bottom: 12)
          : AppPaddings.custom(bottom: 10),
      decoration: BoxDecoration(
        color: kColorWhite,
        borderRadius: BorderRadius.circular(tablet ? 14 : 12),
        border: Border.all(color: kColorLightGrey.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: kColorPrimary.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.toggleItemExpansion(itemIndex),
          borderRadius: BorderRadius.circular(tablet ? 14 : 12),
          child: Padding(
            padding: tablet
                ? AppPaddings.combined(horizontal: 18, vertical: 16)
                : AppPaddings.combined(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.iName,
                        style: TextStyles.kBoldOutfit(
                          fontSize: tablet
                              ? FontSizes.k20FontSize
                              : FontSizes.k18FontSize,
                          color: kColorPrimary,
                        ),
                      ),
                    ),
                    Text(
                      'Unit: ${item.unit}',
                      style: TextStyles.kRegularOutfit(
                        fontSize: tablet
                            ? FontSizes.k12FontSize
                            : FontSizes.k10FontSize,
                        color: kColorDarkGrey,
                      ),
                    ),
                    tablet ? AppSpaces.h12 : AppSpaces.h8,
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: tablet ? 28 : 24,
                        color: kColorPrimary,
                      ),
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      tablet ? AppSpaces.v16 : AppSpaces.v12,
                      Divider(
                        height: 1,
                        color: kColorLightGrey.withOpacity(0.5),
                      ),
                      tablet ? AppSpaces.v12 : AppSpaces.v8,
                      Text(
                        'Purchase Orders (${item.orders.length})',
                        style: TextStyles.kSemiBoldOutfit(
                          fontSize: tablet
                              ? FontSizes.k16FontSize
                              : FontSizes.k14FontSize,
                          color: kColorTextPrimary,
                        ),
                      ),
                      tablet ? AppSpaces.v10 : AppSpaces.v8,
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: item.orders.length,
                        itemBuilder: (context, orderIndex) {
                          final order = item.orders[orderIndex];
                          return Padding(
                            padding: AppPaddings.custom(bottom: 8),
                            child: PoOrderCard(
                              item: item,
                              order: order,
                              controller: controller,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
