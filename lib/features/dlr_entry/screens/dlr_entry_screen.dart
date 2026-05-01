// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/dlr_entry/controllers/dlr_entry_controller.dart';
import 'package:shivay_construction/features/dlr_entry/models/dlr_dm.dart';
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

class DlrEntryScreen extends StatelessWidget {
  final DlrDm? dlr;

  DlrEntryScreen({super.key, this.dlr});

  final DlrEntryController _controller = Get.put(DlrEntryController());

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);

    if (dlr != null && !_controller.isEditMode.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.autoFillDataForEdit(dlr!);
      });
    }

    return Stack(
      children: [
        GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            appBar: AppAppbar(
              title: dlr != null ? 'Edit DLR Entry' : 'DLR Entry',
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
                        key: _controller.dlrFormKey,
                        child: Column(
                          children: [
                            tablet ? AppSpaces.v10 : AppSpaces.v4,

                            // Date
                            AppDatePickerTextFormField(
                              dateController: _controller.dateController,
                              hintText: 'Date *',
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Please select date'
                                  : null,
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,

                            // Shift
                            Obx(
                              () => AppDropdown(
                                items: _controller.shifts,
                                selectedItem:
                                    _controller.selectedShift.value.isNotEmpty
                                    ? _controller.selectedShift.value
                                    : null,
                                hintText: 'Shift *',
                                onChanged: _controller.onShiftSelected,
                                validatorText: 'Please select shift',
                              ),
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,

                            // Site
                            Obx(
                              () => AppDropdown(
                                items: _controller.siteNames,
                                selectedItem:
                                    _controller
                                        .selectedSiteName
                                        .value
                                        .isNotEmpty
                                    ? _controller.selectedSiteName.value
                                    : null,
                                hintText: 'Site',
                                onChanged: _controller.onSiteSelected,
                              ),
                            ),
                            tablet ? AppSpaces.v20 : AppSpaces.v14,

                            // Add New button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                AppButton(
                                  buttonWidth: tablet
                                      ? 0.415.screenWidth
                                      : 0.45.screenWidth,
                                  title: '+ Add New',
                                  onPressed: () {
                                    _controller.prepareAddItem();
                                    _showItemDialog(context);
                                  },
                                ),
                              ],
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v12,

                            // DLR Items list
                            Obx(() {
                              if (_controller.dlrItems.isNotEmpty) {
                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _controller.dlrItems.length,
                                  itemBuilder: (context, index) {
                                    final item = _controller.dlrItems[index];
                                    return _buildDlrItemCard(
                                      context: context,
                                      item: item,
                                      index: index,
                                      tablet: tablet,
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
                  ),

                  // Submit / Update button
                  Obx(() {
                    if (_controller.dlrItems.isNotEmpty) {
                      return Column(
                        children: [
                          AppButton(
                            title: _controller.isEditMode.value
                                ? 'Update'
                                : 'Submit',
                            buttonHeight: tablet ? 54 : 48,
                            onPressed: () {
                              if (_controller.dlrFormKey.currentState!
                                  .validate()) {
                                if (_controller.dlrItems.isNotEmpty) {
                                  _controller.saveDlrEntry();
                                } else {
                                  showErrorSnackbar(
                                    'Oops!',
                                    'Please add at least one party entry.',
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
        Obx(() => AppLoadingOverlay(isLoading: _controller.isLoading.value)),
      ],
    );
  }

  Widget _buildDlrItemCard({
    required BuildContext context,
    required Map<String, dynamic> item,
    required int index,
    required bool tablet,
  }) {
    return Container(
      margin: AppPaddings.custom(bottom: 10),
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
            children: [
              Expanded(
                child: Text(
                  item['partyName'] ?? '',
                  style: TextStyles.kSemiBoldOutfit(
                    fontSize: tablet
                        ? FontSizes.k16FontSize
                        : FontSizes.k14FontSize,
                    color: kColorPrimary,
                  ),
                ),
              ),
              Material(
                color: kColorPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(tablet ? 8 : 6),
                child: InkWell(
                  onTap: () {
                    _controller.prepareEditItem(index);
                    _showItemDialog(context);
                  },
                  borderRadius: BorderRadius.circular(tablet ? 8 : 6),
                  child: Container(
                    padding: tablet
                        ? AppPaddings.combined(horizontal: 10, vertical: 8)
                        : AppPaddings.combined(horizontal: 8, vertical: 6),
                    child: Icon(
                      Icons.edit_rounded,
                      size: tablet ? 18 : 16,
                      color: kColorPrimary,
                    ),
                  ),
                ),
              ),
              tablet ? AppSpaces.h8 : AppSpaces.h6,
              Material(
                color: kColorRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(tablet ? 8 : 6),
                child: InkWell(
                  onTap: () => _showDeleteConfirmation(context, index),
                  borderRadius: BorderRadius.circular(tablet ? 8 : 6),
                  child: Container(
                    padding: tablet
                        ? AppPaddings.combined(horizontal: 10, vertical: 8)
                        : AppPaddings.combined(horizontal: 8, vertical: 6),
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
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailColumn(
                        label: 'Skill',
                        value: (item['Skill'] ?? 0.0).toStringAsFixed(2),
                        tablet: tablet,
                      ),
                    ),
                    AppSpaces.h12,
                    Expanded(
                      child: _buildDetailColumn(
                        label: 'Skill Rate',
                        value: (item['SkillRate'] ?? 0.0).toStringAsFixed(2),
                        tablet: tablet,
                      ),
                    ),
                    AppSpaces.h12,
                    Expanded(
                      child: _buildDetailColumn(
                        label: 'Unskill',
                        value: (item['UnSkill'] ?? 0.0).toStringAsFixed(2),
                        tablet: tablet,
                      ),
                    ),
                    AppSpaces.h12,
                    Expanded(
                      child: _buildDetailColumn(
                        label: 'Unskill Rate',
                        value: (item['UnSkillRate'] ?? 0.0).toStringAsFixed(2),
                        tablet: tablet,
                      ),
                    ),
                  ],
                ),
                if ((item['Activity'] ?? '').toString().isNotEmpty ||
                    (item['supervisorName'] ?? '').toString().isNotEmpty ||
                    (item['Remark'] ?? '').toString().isNotEmpty) ...[
                  tablet ? AppSpaces.v8 : AppSpaces.v6,
                  Row(
                    children: [
                      if ((item['Activity'] ?? '').toString().isNotEmpty)
                        Expanded(
                          child: _buildDetailColumn(
                            label: 'Activity',
                            value: item['Activity'],
                            tablet: tablet,
                          ),
                        ),
                      if ((item['Activity'] ?? '').toString().isNotEmpty &&
                          (item['supervisorName'] ?? '').toString().isNotEmpty)
                        AppSpaces.h12,
                      if ((item['supervisorName'] ?? '').toString().isNotEmpty)
                        Expanded(
                          child: _buildDetailColumn(
                            label: 'Supervisor',
                            value: item['supervisorName'],
                            tablet: tablet,
                          ),
                        ),
                    ],
                  ),
                  if ((item['Remark'] ?? '').toString().isNotEmpty) ...[
                    tablet ? AppSpaces.v8 : AppSpaces.v6,
                    _buildDetailColumn(
                      label: 'Remark',
                      value: item['Remark'],
                      tablet: tablet,
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailColumn({
    required String label,
    required String value,
    required bool tablet,
  }) {
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
            color: kColorTextPrimary,
          ),
        ),
      ],
    );
  }

  void _showItemDialog(BuildContext context) {
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
            maxHeight: MediaQuery.of(context).size.height * 0.85,
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
              // Dialog header
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
                              ? 'Update Entry'
                              : 'Add New Entry',
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

              // Dialog body
              Flexible(
                child: Form(
                  key: _controller.dlrItemFormKey,
                  child: SingleChildScrollView(
                    padding: tablet ? AppPaddings.p24 : AppPaddings.p20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        tablet ? AppSpaces.v16 : AppSpaces.v12,

                        // Skill & Skill Rate
                        Row(
                          children: [
                            Expanded(
                              child: AppTextFormField(
                                controller: _controller.skillController,
                                hintText: 'Skill',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,3}'),
                                  ),
                                ],
                                validator: (value) =>
                                    value == null || value.isEmpty
                                    ? 'Please enter skill'
                                    : null,
                              ),
                            ),
                            tablet ? AppSpaces.h16 : AppSpaces.h12,
                            Expanded(
                              child: AppTextFormField(
                                controller: _controller.skillRateController,
                                hintText: 'Skill Rate',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,3}'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        tablet ? AppSpaces.v16 : AppSpaces.v12,

                        // Unskill & Unskill Rate
                        Row(
                          children: [
                            Expanded(
                              child: AppTextFormField(
                                controller: _controller.unskillController,
                                hintText: 'Unskill',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,3}'),
                                  ),
                                ],
                                validator: (value) =>
                                    value == null || value.isEmpty
                                    ? 'Please enter Unskill'
                                    : null,
                              ),
                            ),
                            tablet ? AppSpaces.h16 : AppSpaces.h12,
                            Expanded(
                              child: AppTextFormField(
                                controller: _controller.unskillRateController,
                                hintText: 'Unskill Rate',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,3}'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        tablet ? AppSpaces.v16 : AppSpaces.v12,

                        // Supervisor dropdown
                        Obx(
                          () => AppDropdown(
                            items: _controller.supervisorNames,
                            hintText: 'Supervisor',
                            onChanged: _controller.onSupervisorSelected,
                            selectedItem:
                                _controller
                                    .selectedSupervisorName
                                    .value
                                    .isNotEmpty
                                ? _controller.selectedSupervisorName.value
                                : null,
                            validatorText: 'Please select a Supervisor',
                          ),
                        ),
                        tablet ? AppSpaces.v16 : AppSpaces.v12,

                        // Activity dropdown — dynamic with "+ Add New Activity"
                        Obx(
                          () => AppDropdown(
                            items: [
                              '+ Add New Activity',
                              ..._controller.activityNames,
                            ],
                            hintText: 'Activity',
                            onChanged: (value) {
                              if (value == '+ Add New Activity') {
                                _showAddNewDialog(
                                  context,
                                  title: 'Add New Activity',
                                  hintText: 'Enter activity name',
                                  onAdd: (val) {
                                    _controller.addNewActivity(val);
                                  },
                                );
                              } else {
                                _controller.onActivitySelected(value);
                              }
                            },
                            selectedItem:
                                _controller
                                    .selectedActivityName
                                    .value
                                    .isNotEmpty
                                ? _controller.selectedActivityName.value
                                : null,
                          ),
                        ),
                        tablet ? AppSpaces.v16 : AppSpaces.v12,

                        // Remark field
                        AppTextFormField(
                          controller: _controller.remarkController,
                          hintText: 'Remark',
                          maxLines: 2,
                        ),
                        tablet ? AppSpaces.v24 : AppSpaces.v20,

                        // Cancel & Add/Update buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  _controller.clearItemForm();
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
                                    if (_controller.dlrItemFormKey.currentState!
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Generic "Add New" dialog — same pattern as SiteMasterScreen
  void _showAddNewDialog(
    BuildContext context, {
    required String title,
    required String hintText,
    required Function(String) onAdd,
  }) {
    final bool tablet = AppScreenUtils.isTablet(context);
    final newItemController = TextEditingController();
    final dialogFormKey = GlobalKey<FormState>();

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
                      child: Icon(
                        Icons.add_rounded,
                        color: kColorPrimary,
                        size: tablet ? 26 : 22,
                      ),
                    ),
                    tablet ? AppSpaces.h12 : AppSpaces.h10,
                    Expanded(
                      child: Text(
                        title,
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
                child: Form(
                  key: dialogFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextFormField(
                        controller: newItemController,
                        hintText: hintText,
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? 'This field is required'
                            : value.trim().length < 2
                            ? 'Must be at least 2 characters'
                            : null,
                      ),
                      tablet ? AppSpaces.v24 : AppSpaces.v20,
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                newItemController.clear();
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
                            child: AppButton(
                              title: 'Add',
                              buttonColor: kColorPrimary,
                              titleColor: kColorWhite,
                              titleSize: tablet
                                  ? FontSizes.k16FontSize
                                  : FontSizes.k14FontSize,
                              buttonHeight: tablet ? 54 : 48,
                              onPressed: () {
                                if (dialogFormKey.currentState!.validate()) {
                                  onAdd(newItemController.text.trim());
                                  newItemController.clear();
                                  Get.back();
                                }
                              },
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

  void _showDeleteConfirmation(BuildContext context, int index) {
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
                        'Are you sure you want to delete this entry?',
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
