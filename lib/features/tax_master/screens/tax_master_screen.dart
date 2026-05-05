// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/tax_master/controllers/tax_master_controller.dart';
import 'package:shivay_construction/features/tax_master/models/tax_master_dm.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/formatters/text_input_formatters.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_appbar.dart';
import 'package:shivay_construction/widgets/app_button.dart';
import 'package:shivay_construction/widgets/app_loading_overlay.dart';
import 'package:shivay_construction/widgets/app_text_form_field.dart';

class TaxMasterScreen extends StatelessWidget {
  final TaxMasterDm? tax;

  TaxMasterScreen({super.key, this.tax});

  final TaxMasterController _controller = Get.put(TaxMasterController());

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);

    if (tax != null && !_controller.isEditMode.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.autoFillDataForEdit(tax!);
      });
    }

    return Stack(
      children: [
        GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            appBar: AppAppbar(
              title: tax != null ? 'Update Tax' : 'Add Tax',
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
                        key: _controller.taxFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            tablet ? AppSpaces.v6 : AppSpaces.v4,

                            // Tax Name
                            AppTextFormField(
                              controller: _controller.taxNameController,
                              hintText: 'Tax Name *',
                              inputFormatters: [UpperCaseTextInputFormatter()],
                              validator: (value) =>
                                  (value == null || value.trim().isEmpty)
                                  ? 'Please enter tax name'
                                  : value.trim().length < 2
                                  ? 'Name must be at least 2 characters'
                                  : null,
                            ),
                            tablet ? AppSpaces.v20 : AppSpaces.v16,

                            // Tax Type Label
                            Text(
                              'Tax Type',
                              style: TextStyles.kSemiBoldOutfit(
                                fontSize: tablet
                                    ? FontSizes.k16FontSize
                                    : FontSizes.k14FontSize,
                                color: kColorTextPrimary,
                              ),
                            ),
                            tablet ? AppSpaces.v12 : AppSpaces.v8,

                            // IGST Checkbox
                            Container(
                              decoration: BoxDecoration(
                                color: kColorWhite,
                                borderRadius: BorderRadius.circular(
                                  tablet ? 12 : 10,
                                ),
                                border: Border.all(
                                  color: kColorLightGrey.withOpacity(0.4),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: kColorPrimary.withOpacity(0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Obx(
                                () => CheckboxListTile(
                                  title: Text(
                                    'IGST',
                                    style: TextStyles.kMediumOutfit(
                                      fontSize: tablet
                                          ? FontSizes.k16FontSize
                                          : FontSizes.k14FontSize,
                                      color: kColorTextPrimary,
                                    ),
                                  ),
                                  value: _controller.igst.value,
                                  onChanged: _controller.toggleIgst,
                                  activeColor: kColorPrimary,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  contentPadding: tablet
                                      ? AppPaddings.combined(
                                          horizontal: 12,
                                          vertical: 4,
                                        )
                                      : AppPaddings.combined(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      tablet ? 12 : 10,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            tablet ? AppSpaces.v12 : AppSpaces.v10,

                            // SGST Checkbox
                            Container(
                              decoration: BoxDecoration(
                                color: kColorWhite,
                                borderRadius: BorderRadius.circular(
                                  tablet ? 12 : 10,
                                ),
                                border: Border.all(
                                  color: kColorLightGrey.withOpacity(0.4),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: kColorPrimary.withOpacity(0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Obx(
                                () => CheckboxListTile(
                                  title: Text(
                                    'SGST',
                                    style: TextStyles.kMediumOutfit(
                                      fontSize: tablet
                                          ? FontSizes.k16FontSize
                                          : FontSizes.k14FontSize,
                                      color: kColorTextPrimary,
                                    ),
                                  ),
                                  value: _controller.sgst.value,
                                  onChanged: _controller.toggleSgst,
                                  activeColor: kColorPrimary,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  contentPadding: tablet
                                      ? AppPaddings.combined(
                                          horizontal: 12,
                                          vertical: 4,
                                        )
                                      : AppPaddings.combined(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      tablet ? 12 : 10,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            tablet ? AppSpaces.v12 : AppSpaces.v10,

                            // CGST Checkbox
                            Container(
                              decoration: BoxDecoration(
                                color: kColorWhite,
                                borderRadius: BorderRadius.circular(
                                  tablet ? 12 : 10,
                                ),
                                border: Border.all(
                                  color: kColorLightGrey.withOpacity(0.4),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: kColorPrimary.withOpacity(0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Obx(
                                () => CheckboxListTile(
                                  title: Text(
                                    'CGST',
                                    style: TextStyles.kMediumOutfit(
                                      fontSize: tablet
                                          ? FontSizes.k16FontSize
                                          : FontSizes.k14FontSize,
                                      color: kColorTextPrimary,
                                    ),
                                  ),
                                  value: _controller.cgst.value,
                                  onChanged: _controller.toggleCgst,
                                  activeColor: kColorPrimary,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  contentPadding: tablet
                                      ? AppPaddings.combined(
                                          horizontal: 12,
                                          vertical: 4,
                                        )
                                      : AppPaddings.combined(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      tablet ? 12 : 10,
                                    ),
                                  ),
                                ),
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
                        if (_controller.taxFormKey.currentState!.validate()) {
                          _controller.addUpdateTaxMaster();
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
