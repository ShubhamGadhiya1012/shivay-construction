import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/dlr_entry/controllers/dlr_entry_controller.dart';
import 'package:shivay_construction/features/dlr_entry/models/dlr_dm.dart';
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
                                selectedItem:
                                    _controller
                                        .selectedPartyName
                                        .value
                                        .isNotEmpty
                                    ? _controller.selectedPartyName.value
                                    : null,
                                hintText: 'Party *',
                                onChanged: _controller.onPartySelected,
                                validatorText: 'Please select a party',
                              ),
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,

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

                            Row(
                              children: [
                                Expanded(
                                  child: AppTextFormField(
                                    controller: _controller.skillController,
                                    hintText: 'Skill *',
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d+\.?\d{0,3}'),
                                      ),
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter skill';
                                      }
                                      final skill = double.tryParse(value);
                                      if (skill == null || skill < 0) {
                                        return 'Please enter valid skill';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                tablet ? AppSpaces.h16 : AppSpaces.h12,
                                Expanded(
                                  child: AppTextFormField(
                                    controller: _controller.skillRateController,
                                    hintText: 'Skill Rate *',
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d+\.?\d{0,3}'),
                                      ),
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter skill rate';
                                      }
                                      final rate = double.tryParse(value);
                                      if (rate == null || rate < 0) {
                                        return 'Please enter valid rate';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,

                            Row(
                              children: [
                                Expanded(
                                  child: AppTextFormField(
                                    controller: _controller.unskillController,
                                    hintText: 'Unskill *',
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d+\.?\d{0,3}'),
                                      ),
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter unskill';
                                      }
                                      final unskill = double.tryParse(value);
                                      if (unskill == null || unskill < 0) {
                                        return 'Please enter valid unskill';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                tablet ? AppSpaces.h16 : AppSpaces.h12,
                                Expanded(
                                  child: AppTextFormField(
                                    controller:
                                        _controller.unskillRateController,
                                    hintText: 'Unskill Rate *',
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d+\.?\d{0,3}'),
                                      ),
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter unskill rate';
                                      }
                                      final rate = double.tryParse(value);
                                      if (rate == null || rate < 0) {
                                        return 'Please enter valid rate';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,

                            Obx(
                              () => AppDropdown(
                                items: _controller.supervisorNames,
                                selectedItem:
                                    _controller
                                        .selectedSupervisorName
                                        .value
                                        .isNotEmpty
                                    ? _controller.selectedSupervisorName.value
                                    : null,
                                hintText: 'Supervisor *',
                                onChanged: _controller.onSupervisorSelected,
                                validatorText: 'Please select supervisor',
                              ),
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,

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
                            tablet ? AppSpaces.v16 : AppSpaces.v10,

                            Obx(
                              () => AppDropdown(
                                items: _controller.godownNames,
                                selectedItem:
                                    _controller
                                        .selectedGodownName
                                        .value
                                        .isNotEmpty
                                    ? _controller.selectedGodownName.value
                                    : null,
                                hintText: 'Godown',
                                onChanged: _controller.onGodownSelected,
                              ),
                            ),
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
                        if (_controller.dlrFormKey.currentState!.validate()) {
                          _controller.saveDlrEntry();
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
}
