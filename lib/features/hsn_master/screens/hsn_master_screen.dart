// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/hsn_master/controllers/hsn_master_controller.dart';
import 'package:shivay_construction/features/hsn_master/models/hsn_master_dm.dart';
import 'package:shivay_construction/features/hsn_master/models/hsn_master_detail_dm.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_appbar.dart';
import 'package:shivay_construction/widgets/app_button.dart';
import 'package:shivay_construction/widgets/app_checkbox_row.dart';
import 'package:shivay_construction/widgets/app_date_picker_text_form_field.dart';
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
          final detail = hsnDetails!.first;
          _controller.fillDetailData(
            igst: detail.igst,
            sgst: detail.sgst,
            cgst: detail.cgst,
            effectDate: detail.effectDate,
          );
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

                            // HSN No
                            AppTextFormField(
                              controller: _controller.hsnNoController,
                              hintText: 'HSN No *',

                              validator: (value) =>
                                  (value == null || value.trim().isEmpty)
                                  ? 'Please enter HSN No'
                                  : null,
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,

                            // Org HSN No
                            AppTextFormField(
                              controller: _controller.orgHsnNoController,
                              hintText: 'Org HSN No *',
                              validator: (value) =>
                                  (value == null || value.trim().isEmpty)
                                  ? 'Please enter Org HSN No'
                                  : null,
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,

                            // Chapter No
                            AppTextFormField(
                              controller: _controller.chapterNoController,
                              hintText: 'Chapter No *',
                              validator: (value) =>
                                  (value == null || value.trim().isEmpty)
                                  ? 'Please enter Chapter No'
                                  : null,
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,

                            // Unit & EWB Unit
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

                            // Description
                            AppTextFormField(
                              controller: _controller.descriptionController,
                              hintText: 'Description',
                              maxLines: 3,
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,

                            // Effect Date
                            AppDatePickerTextFormField(
                              dateController: _controller.effectDateController,
                              hintText: 'Effect Date *',
                              validator: (value) =>
                                  (value == null || value.trim().isEmpty)
                                  ? 'Please select effect date'
                                  : null,
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,

                            // IGST, SGST, CGST
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
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Please enter IGST';
                                      }
                                      final v = double.tryParse(value.trim());
                                      if (v == null || v < 0) {
                                        return 'Invalid IGST';
                                      }
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
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Please enter SGST';
                                      }
                                      final v = double.tryParse(value.trim());
                                      if (v == null || v < 0) {
                                        return 'Invalid SGST';
                                      }
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
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Please enter CGST';
                                      }
                                      final v = double.tryParse(value.trim());
                                      if (v == null || v < 0) {
                                        return 'Invalid CGST';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,

                            // SAC Checkbox
                            Obx(
                              () => AppCheckboxRow(
                                title: 'SAC (Service Accounting Code)',
                                value: _controller.sac.value,
                                onChanged: _controller.toggleSac,
                              ),
                            ),
                            tablet ? AppSpaces.v20 : AppSpaces.v16,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Submit Button
                  Obx(
                    () => AppButton(
                      title: _controller.isEditMode.value ? 'Update' : 'Submit',
                      buttonHeight: tablet ? 54 : 48,
                      onPressed: () {
                        if (_controller.hsnFormKey.currentState!.validate()) {
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
}
