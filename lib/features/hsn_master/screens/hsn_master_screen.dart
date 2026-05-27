// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/hsn_master/controllers/hsn_master_controller.dart';
import 'package:shivay_construction/features/hsn_master/models/hsn_master_dm.dart';
import 'package:shivay_construction/features/hsn_master/models/hsn_master_detail_dm.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';
import 'package:shivay_construction/utils/extensions/app_size_extensions.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_appbar.dart';
import 'package:shivay_construction/widgets/app_button.dart';
import 'package:shivay_construction/widgets/app_checkbox_row.dart';
import 'package:shivay_construction/widgets/app_date_picker_text_form_field.dart';
import 'package:shivay_construction/widgets/app_dropdown.dart';
import 'package:shivay_construction/widgets/app_loading_overlay.dart';
import 'package:shivay_construction/widgets/app_text_form_field.dart';

class HsnMasterScreen extends StatelessWidget {
  final HsnMasterDm? hsn;
  final List<HsnMasterDetailDm>? hsnDetails;

  HsnMasterScreen({super.key, this.hsn, this.hsnDetails});

  final HsnMasterController _controller = Get.put(HsnMasterController());

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);

    if (hsn != null && !_controller.isEditMode.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.autoFillDataForEdit(hsn!);
        if (hsnDetails != null && hsnDetails!.isNotEmpty) {
          _controller.loadHsnDetailsFromApi(hsnDetails!);
        }
      });
    }

    return Stack(
      children: [
        GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            appBar: AppAppbar(
              title: hsn != null ? 'Update HSN' : 'Add HSN',
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
                        key: _controller.hsnFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            tablet ? AppSpaces.v6 : AppSpaces.v4,

                            AppTextFormField(
                              controller: _controller.hsnNoController,
                              hintText: 'HSN No *',
                              validator: (value) =>
                                  (value == null || value.trim().isEmpty)
                                  ? 'Please enter HSN No'
                                  : null,
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,

                            AppTextFormField(
                              controller: _controller.orgHsnNoController,
                              hintText: 'Org HSN No *',
                              validator: (value) =>
                                  (value == null || value.trim().isEmpty)
                                  ? 'Please enter Org HSN No'
                                  : null,
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,

                            AppTextFormField(
                              controller: _controller.chapterNoController,
                              hintText: 'Chapter No *',
                              validator: (value) =>
                                  (value == null || value.trim().isEmpty)
                                  ? 'Please enter Chapter No'
                                  : null,
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,

                            Row(
                              children: [
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
                                tablet ? AppSpaces.h16 : AppSpaces.h12,
                                Expanded(
                                  child: AppTextFormField(
                                    controller: _controller.ewbUnitController,
                                    hintText: 'EWB Unit *',
                                    validator: (value) =>
                                        (value == null || value.trim().isEmpty)
                                        ? 'Please enter EWB unit'
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,

                            AppTextFormField(
                              controller: _controller.descriptionController,
                              hintText: 'Description',
                              maxLines: 3,
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,

                            Obx(
                              () => AppCheckboxRow(
                                title: 'SAC (Service Accounting Code)',
                                value: _controller.sac.value,
                                onChanged: _controller.toggleSac,
                              ),
                            ),

                            tablet ? AppSpaces.v20 : AppSpaces.v16,

                            // ── Tax Details Section ──
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Obx(
                                  () => Text(
                                    'Tax Details (${_controller.hsnDetails.length})',
                                    style: TextStyles.kMediumOutfit(
                                      fontSize: tablet
                                          ? FontSizes.k16FontSize
                                          : FontSizes.k14FontSize,
                                      color: kColorTextPrimary,
                                    ),
                                  ),
                                ),
                                AppButton(
                                  buttonWidth: tablet
                                      ? 0.25.screenWidth
                                      : 0.35.screenWidth,
                                  buttonHeight: tablet ? 40 : 35,
                                  buttonColor: kColorPrimary,
                                  title: '+ Add Tax',
                                  titleSize: tablet
                                      ? FontSizes.k14FontSize
                                      : FontSizes.k12FontSize,
                                  onPressed: () {
                                    _controller.prepareAddDetail();
                                    _showTaxDetailDialog(context);
                                  },
                                ),
                              ],
                            ),
                            tablet ? AppSpaces.v12 : AppSpaces.v8,

                            Obx(() {
                              if (_controller.hsnDetails.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _controller.hsnDetails.length,
                                itemBuilder: (context, index) {
                                  final detail = _controller.hsnDetails[index];
                                  return _HsnDetailCard(
                                    detail: detail,
                                    tablet: tablet,
                                    onEdit: () {
                                      _controller.prepareEditDetail(index);
                                      _showTaxDetailDialog(context);
                                    },
                                    onDelete: () =>
                                        _showDeleteDetailConfirmation(
                                          context,
                                          index,
                                        ),
                                  );
                                },
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
                        if (_controller.hsnFormKey.currentState!.validate()) {
                          if (_controller.hsnDetails.isEmpty) {
                            showErrorSnackbar(
                              'Tax Required',
                              'Please add at least one tax detail.',
                            );
                            return;
                          }
                          _controller.addUpdateHsnMaster();
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

  void _showTaxDetailDialog(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tablet ? 20 : 16),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: tablet ? 520 : double.infinity,
          constraints: BoxConstraints(
            maxWidth: tablet ? 520 : MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
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
              // Dialog Header
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
                          _controller.isEditingDetail.value
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
                          _controller.isEditingDetail.value
                              ? 'Update Tax Detail'
                              : 'Add Tax Detail',
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

              // Dialog Body
              Flexible(
                child: Form(
                  key: _controller.hsnDetailItemFormKey,
                  child: SingleChildScrollView(
                    padding: tablet ? AppPaddings.p24 : AppPaddings.p20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppDatePickerTextFormField(
                          dateController: _controller.effectDateController,
                          hintText: 'Effect Date *',
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                              ? 'Please select effect date'
                              : null,
                        ),
                        tablet ? AppSpaces.v16 : AppSpaces.v12,

                        Obx(
                          () => AppDropdown(
                            hintText: 'Tax Type',
                            items: _controller.taxNames,
                            selectedItem:
                                _controller.selectedTaxName.value.isNotEmpty
                                ? _controller.selectedTaxName.value
                                : null,
                            onChanged: _controller.onTaxSelected,
                          ),
                        ),
                        tablet ? AppSpaces.v16 : AppSpaces.v12,

                        Row(
                          children: [
                            Expanded(
                              child: AppTextFormField(
                                controller: _controller.igstController,
                                hintText: 'IGST (%) *',
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
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Enter IGST';
                                  }
                                  final v = double.tryParse(value.trim());
                                  if (v == null || v < 0) return 'Invalid';
                                  return null;
                                },
                              ),
                            ),
                            tablet ? AppSpaces.h16 : AppSpaces.h12,
                            Expanded(
                              child: AppTextFormField(
                                controller: _controller.sgstController,
                                hintText: 'SGST (%) *',
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
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Enter SGST';
                                  }
                                  final v = double.tryParse(value.trim());
                                  if (v == null || v < 0) return 'Invalid';
                                  return null;
                                },
                              ),
                            ),
                            tablet ? AppSpaces.h16 : AppSpaces.h12,
                            Expanded(
                              child: AppTextFormField(
                                controller: _controller.cgstController,
                                hintText: 'CGST (%) *',
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
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Enter CGST';
                                  }
                                  final v = double.tryParse(value.trim());
                                  if (v == null || v < 0) return 'Invalid';
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
                                  _controller.clearDetailForm();
                                  Navigator.of(dialogContext).pop();
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
                                  title: _controller.isEditingDetail.value
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
                                        .hsnDetailItemFormKey
                                        .currentState!
                                        .validate()) {
                                      _controller.addOrUpdateDetail();
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDetailConfirmation(BuildContext context, int index) {
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
                        'Are you sure you want to delete this tax detail?',
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
                                _controller.deleteDetail(index);
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

// ── Inline card widget for each tax detail row ──
class _HsnDetailCard extends StatelessWidget {
  const _HsnDetailCard({
    required this.detail,
    required this.tablet,
    required this.onEdit,
    required this.onDelete,
  });

  final Map<String, dynamic> detail;
  final bool tablet;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    final parts = dateStr.split('-');
    if (parts.length < 3) return dateStr;
    if (parts[0].length == 4) {
      return '${parts[2]}-${parts[1]}-${parts[0]}';
    }
    return dateStr;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppPaddings.custom(bottom: 8),
      decoration: BoxDecoration(
        color: kColorWhite,
        borderRadius: BorderRadius.circular(tablet ? 12 : 10),
        border: Border.all(color: kColorLightGrey.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: kColorPrimary.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: tablet
          ? AppPaddings.combined(horizontal: 16, vertical: 14)
          : AppPaddings.combined(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  detail['TName']?.toString().isNotEmpty == true
                      ? detail['TName']
                      : 'Tax Detail',
                  style: TextStyles.kSemiBoldOutfit(
                    fontSize: tablet
                        ? FontSizes.k16FontSize
                        : FontSizes.k14FontSize,
                    color: kColorTextPrimary,
                  ),
                ),
              ),
              Row(
                children: [
                  Material(
                    color: kColorPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(tablet ? 8 : 6),
                    child: InkWell(
                      onTap: onEdit,
                      borderRadius: BorderRadius.circular(tablet ? 8 : 6),
                      child: Container(
                        padding: tablet
                            ? AppPaddings.combined(horizontal: 10, vertical: 10)
                            : AppPaddings.combined(horizontal: 8, vertical: 8),
                        child: Icon(
                          Icons.edit_rounded,
                          size: tablet ? 20 : 18,
                          color: kColorPrimary,
                        ),
                      ),
                    ),
                  ),
                  tablet ? AppSpaces.h12 : AppSpaces.h8,
                  Material(
                    color: kColorRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(tablet ? 8 : 6),
                    child: InkWell(
                      onTap: onDelete,
                      borderRadius: BorderRadius.circular(tablet ? 8 : 6),
                      child: Container(
                        padding: tablet
                            ? AppPaddings.combined(horizontal: 10, vertical: 10)
                            : AppPaddings.combined(horizontal: 8, vertical: 8),
                        child: Icon(
                          Icons.delete_rounded,
                          size: tablet ? 20 : 18,
                          color: kColorRed,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          tablet ? AppSpaces.v10 : AppSpaces.v8,
          Container(
            padding: tablet
                ? AppPaddings.combined(horizontal: 12, vertical: 8)
                : AppPaddings.combined(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: kColorPrimary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kColorPrimary.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DetailRow(
                  label: 'Effect Date',
                  value: _formatDate(detail['EffectDate']?.toString() ?? ''),
                  tablet: tablet,
                ),
                tablet ? AppSpaces.v8 : AppSpaces.v6,
                Row(
                  children: [
                    Expanded(
                      child: _DetailCol(
                        label: 'IGST',
                        value: '${(detail['IGST'] ?? 0.0).toStringAsFixed(2)}%',
                        tablet: tablet,
                      ),
                    ),
                    AppSpaces.h12,
                    Expanded(
                      child: _DetailCol(
                        label: 'SGST',
                        value: '${(detail['SGST'] ?? 0.0).toStringAsFixed(2)}%',
                        tablet: tablet,
                      ),
                    ),
                    AppSpaces.h12,
                    Expanded(
                      child: _DetailCol(
                        label: 'CGST',
                        value: '${(detail['CGST'] ?? 0.0).toStringAsFixed(2)}%',
                        tablet: tablet,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.tablet,
  });
  final String label;
  final String value;
  final bool tablet;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyles.kRegularOutfit(
            fontSize: tablet ? FontSizes.k12FontSize : FontSizes.k12FontSize,
            color: kColorDarkGrey,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyles.kMediumOutfit(
              fontSize: tablet ? FontSizes.k12FontSize : FontSizes.k12FontSize,
              color: kColorTextPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailCol extends StatelessWidget {
  const _DetailCol({
    required this.label,
    required this.value,
    required this.tablet,
  });
  final String label;
  final String value;
  final bool tablet;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyles.kRegularOutfit(
            fontSize: tablet ? FontSizes.k12FontSize : FontSizes.k10FontSize,
            color: kColorDarkGrey,
          ),
        ),
        AppSpaces.v2,
        Text(
          value,
          style: TextStyles.kMediumOutfit(
            fontSize: tablet ? FontSizes.k14FontSize : FontSizes.k12FontSize,
            color: kColorPrimary,
          ),
        ),
      ],
    );
  }
}
