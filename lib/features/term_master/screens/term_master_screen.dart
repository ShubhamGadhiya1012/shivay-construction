// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/term_master/controllers/term_master_controller.dart';
import 'package:shivay_construction/features/term_master/models/term_master_dm.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_appbar.dart';
import 'package:shivay_construction/widgets/app_button.dart';
import 'package:shivay_construction/widgets/app_checkbox_row.dart';
import 'package:shivay_construction/widgets/app_dropdown.dart';
import 'package:shivay_construction/widgets/app_loading_overlay.dart';
import 'package:shivay_construction/widgets/app_text_form_field.dart';

class TermMasterScreen extends StatelessWidget {
  final TermMasterDm? term;

  TermMasterScreen({super.key, this.term});

  final TermMasterController _controller = Get.put(TermMasterController());

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);

    if (term != null && !_controller.isEditMode.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.autoFillDataForEdit(term!);
      });
    }

    return Stack(
      children: [
        GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            appBar: AppAppbar(
              title: term != null ? 'Update Term' : 'Add Term',
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
                        key: _controller.termFormKey,
                        child: Column(
                          children: [
                            tablet ? AppSpaces.v16 : AppSpaces.v12,
                            AppTextFormField(
                              controller: _controller.termNameController,
                              hintText: 'Term Name *',
                              validator: (value) =>
                                  (value == null || value.trim().isEmpty)
                                  ? 'Please enter term name'
                                  : null,
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,
                            Obx(
                              () => AppDropdown(
                                hintText: 'Term Type *',
                                items: const ['PO'],
                                selectedItem: _controller.termType.value,
                                onChanged: (val) {
                                  if (val != null) _controller.termType.value = val;
                                },
                              ),
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,
                            Obx(
                              () => AppCheckboxRow(
                                title: 'Is Fixed',
                                value: _controller.isFix.value,
                                onChanged: () =>
                                    _controller.isFix.value = !_controller.isFix.value,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  AppButton(
                    title: _controller.isEditMode.value ? 'Update' : 'Submit',
                    buttonHeight: tablet ? 54 : 48,
                    onPressed: () {
                      if (_controller.termFormKey.currentState!.validate()) {
                        _controller.addUpdateTerm();
                      }
                    },
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
