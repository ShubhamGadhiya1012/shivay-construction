// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/company_master/controllers/company_master_controller.dart';
import 'package:shivay_construction/features/company_master/models/company_master_dm.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_appbar.dart';
import 'package:shivay_construction/widgets/app_button.dart';
import 'package:shivay_construction/widgets/app_dropdown.dart';
import 'package:shivay_construction/widgets/app_loading_overlay.dart';
import 'package:shivay_construction/widgets/app_text_form_field.dart';

class CompanyMasterScreen extends StatelessWidget {
  final CompanyMasterDm? company;

  CompanyMasterScreen({super.key, this.company});

  final CompanyMasterController _controller = Get.put(
    CompanyMasterController(),
  );

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);

    if (company != null && !_controller.isEditMode.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.autoFillDataForEdit(company!);
      });
    }

    return Stack(
      children: [
        GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            appBar: AppAppbar(
              title: company != null ? 'Update Company' : 'Add Company',
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
                        key: _controller.companyFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            tablet ? AppSpaces.v6 : AppSpaces.v4,

                            // ── Section: Basic Information ──────────────────
                            _buildSectionHeader('Basic Information', tablet),
                            tablet ? AppSpaces.v10 : AppSpaces.v8,

                            AppTextFormField(
                              controller: _controller.nameController,
                              hintText: 'Company Name *',
                              validator: (value) =>
                                  (value == null || value.trim().isEmpty)
                                  ? 'Please enter company name'
                                  : value.trim().length < 2
                                  ? 'Name must be at least 2 characters'
                                  : null,
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,

                            AppTextFormField(
                              controller: _controller.address1Controller,
                              hintText: 'Address Line 1 *',
                              validator: (value) =>
                                  (value == null || value.trim().isEmpty)
                                  ? 'Please enter address'
                                  : null,
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,

                            AppTextFormField(
                              controller: _controller.address2Controller,
                              hintText: 'Address Line 2',
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,

                            // City & State dropdowns
                            Row(
                              children: [
                                Expanded(
                                  child: Obx(
                                    () => AppDropdown(
                                      hintText: 'City *',
                                      items: [
                                        '+ Add New City',
                                        ..._controller.cityNames,
                                      ],
                                      selectedItem:
                                          _controller
                                              .selectedCity
                                              .value
                                              .isNotEmpty
                                          ? _controller.selectedCity.value
                                          : null,
                                      onChanged: (selectedValue) {
                                        if (selectedValue == '+ Add New City') {
                                          _showAddNewDialog(
                                            context,
                                            title: 'Add New City',
                                            hintText: 'Enter city name',
                                            onAdd: (value) =>
                                                _controller.addNewCity(value),
                                          );
                                        } else {
                                          _controller.onCitySelected(
                                            selectedValue,
                                          );
                                        }
                                      },
                                      validatorText: 'Please select a city',
                                    ),
                                  ),
                                ),
                                tablet ? AppSpaces.h16 : AppSpaces.h12,
                                Expanded(
                                  child: Obx(
                                    () => AppDropdown(
                                      hintText: 'State *',
                                      items: [
                                        '+ Add New State',
                                        ..._controller.stateNames,
                                      ],
                                      selectedItem:
                                          _controller
                                              .selectedState
                                              .value
                                              .isNotEmpty
                                          ? _controller.selectedState.value
                                          : null,
                                      onChanged: (selectedValue) {
                                        if (selectedValue ==
                                            '+ Add New State') {
                                          _showAddNewDialog(
                                            context,
                                            title: 'Add New State',
                                            hintText: 'Enter state name',
                                            onAdd: (value) =>
                                                _controller.addNewState(value),
                                          );
                                        } else {
                                          _controller.onStateSelected(
                                            selectedValue,
                                          );
                                        }
                                      },
                                      validatorText: 'Please select a state',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,

                            // ZIP & Country
                            Row(
                              children: [
                                Expanded(
                                  child: AppTextFormField(
                                    controller: _controller.zipController,
                                    hintText: 'ZIP Code *',
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(6),
                                    ],
                                    validator: (value) =>
                                        (value == null || value.trim().isEmpty)
                                        ? 'Please enter ZIP code'
                                        : value.trim().length != 6
                                        ? 'ZIP code must be 6 digits'
                                        : null,
                                  ),
                                ),
                                tablet ? AppSpaces.h16 : AppSpaces.h12,
                                Expanded(
                                  child: AppTextFormField(
                                    controller: _controller.countryController,
                                    hintText: 'Country',
                                  ),
                                ),
                              ],
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,

                            // Phone & Fax
                            Row(
                              children: [
                                Expanded(
                                  child: AppTextFormField(
                                    controller: _controller.phoneController,
                                    hintText: 'Phone',
                                    keyboardType: TextInputType.phone,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                  ),
                                ),
                                tablet ? AppSpaces.h16 : AppSpaces.h12,
                                Expanded(
                                  child: AppTextFormField(
                                    controller: _controller.faxController,
                                    hintText: 'Fax',
                                    keyboardType: TextInputType.phone,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,

                            AppTextFormField(
                              controller: _controller.emailController,
                              hintText: 'Email',
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value != null && value.trim().isNotEmpty) {
                                  final emailRegex = RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  );
                                  if (!emailRegex.hasMatch(value.trim())) {
                                    return 'Please enter a valid email';
                                  }
                                }
                                return null;
                              },
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,

                            AppTextFormField(
                              controller: _controller.mgmtEmailController,
                              hintText: 'Management Email',
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value != null && value.trim().isNotEmpty) {
                                  final emailRegex = RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  );
                                  if (!emailRegex.hasMatch(value.trim())) {
                                    return 'Please enter a valid email';
                                  }
                                }
                                return null;
                              },
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,

                            AppTextFormField(
                              controller: _controller.urlController,
                              hintText: 'Website URL',
                              keyboardType: TextInputType.url,
                            ),
                            tablet ? AppSpaces.v24 : AppSpaces.v20,

                            // ── Section: Tax & Registration ─────────────────
                            _buildSectionHeader('Tax & Registration', tablet),
                            tablet ? AppSpaces.v10 : AppSpaces.v8,

                            Row(
                              children: [
                                Expanded(
                                  child: AppTextFormField(
                                    controller: _controller.panController,
                                    hintText: 'PAN Number',
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(10),
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[A-Z0-9]'),
                                      ),
                                    ],
                                  ),
                                ),
                                tablet ? AppSpaces.h16 : AppSpaces.h12,
                                Expanded(
                                  child: AppTextFormField(
                                    controller: _controller.gstNumberController,
                                    hintText: 'GST Number',
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(15),
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[A-Z0-9]'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,

                            Row(
                              children: [
                                Expanded(
                                  child: AppTextFormField(
                                    controller: _controller.cinNoController,
                                    hintText: 'CIN No',
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(21),
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[A-Z0-9/]'),
                                      ),
                                    ],
                                  ),
                                ),
                                tablet ? AppSpaces.h16 : AppSpaces.h12,
                                Expanded(
                                  child: AppTextFormField(
                                    controller: _controller.msmeNoController,
                                    hintText: 'MSME No',
                                  ),
                                ),
                              ],
                            ),
                            tablet ? AppSpaces.v24 : AppSpaces.v20,

                            // ── Section: Statutory Codes ────────────────────
                            _buildSectionHeader('Statutory Codes', tablet),
                            tablet ? AppSpaces.v10 : AppSpaces.v8,

                            Row(
                              children: [
                                Expanded(
                                  child: AppTextFormField(
                                    controller: _controller.uanController,
                                    hintText: 'UAN',
                                  ),
                                ),
                                tablet ? AppSpaces.h16 : AppSpaces.h12,
                                Expanded(
                                  child: AppTextFormField(
                                    controller: _controller.ptCodeController,
                                    hintText: 'PT Code',
                                  ),
                                ),
                              ],
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,

                            Row(
                              children: [
                                Expanded(
                                  child: AppTextFormField(
                                    controller: _controller.estCodeController,
                                    hintText: 'EST Code',
                                  ),
                                ),
                                tablet ? AppSpaces.h16 : AppSpaces.h12,
                                Expanded(
                                  child: AppTextFormField(
                                    controller: _controller.pfCodeController,
                                    hintText: 'PF Code',
                                  ),
                                ),
                              ],
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,

                            AppTextFormField(
                              controller: _controller.esiCodeController,
                              hintText: 'ESI Code',
                            ),
                            tablet ? AppSpaces.v24 : AppSpaces.v20,

                            // ── Section: Bank Details 1 ─────────────────────
                            _buildSectionHeader('Bank Details 1', tablet),
                            tablet ? AppSpaces.v10 : AppSpaces.v8,

                            AppTextFormField(
                              controller: _controller.coBankName1Controller,
                              hintText: 'Bank Name',
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,

                            Row(
                              children: [
                                Expanded(
                                  child: AppTextFormField(
                                    controller:
                                        _controller.coBankBranch1Controller,
                                    hintText: 'Branch',
                                  ),
                                ),
                                tablet ? AppSpaces.h16 : AppSpaces.h12,
                                Expanded(
                                  child: AppTextFormField(
                                    controller:
                                        _controller.coBankAcNo1Controller,
                                    hintText: 'Account No',
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,

                            AppTextFormField(
                              controller: _controller.coBankIfsc1Controller,
                              hintText: 'IFSC Code',
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(11),
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[A-Z0-9]'),
                                ),
                              ],
                            ),
                            tablet ? AppSpaces.v24 : AppSpaces.v20,

                            // ── Section: Bank Details 2 ─────────────────────
                            _buildSectionHeader('Bank Details 2', tablet),
                            tablet ? AppSpaces.v10 : AppSpaces.v8,

                            AppTextFormField(
                              controller: _controller.coBankName2Controller,
                              hintText: 'Bank Name',
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,

                            Row(
                              children: [
                                Expanded(
                                  child: AppTextFormField(
                                    controller:
                                        _controller.coBankBranch2Controller,
                                    hintText: 'Branch',
                                  ),
                                ),
                                tablet ? AppSpaces.h16 : AppSpaces.h12,
                                Expanded(
                                  child: AppTextFormField(
                                    controller:
                                        _controller.coBankAcNo2Controller,
                                    hintText: 'Account No',
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,

                            AppTextFormField(
                              controller: _controller.coBankIfsc2Controller,
                              hintText: 'IFSC Code',
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(11),
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[A-Z0-9]'),
                                ),
                              ],
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
                        if (_controller.companyFormKey.currentState!
                            .validate()) {
                          _controller.addUpdateCompanyMaster();
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

  Widget _buildSectionHeader(String title, bool tablet) {
    return Row(
      children: [
        Container(
          width: 4,
          height: tablet ? 22 : 18,
          decoration: BoxDecoration(
            color: kColorPrimary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        AppSpaces.h8,
        Text(
          title,
          style: TextStyles.kSemiBoldOutfit(
            fontSize: tablet ? FontSizes.k18FontSize : FontSizes.k16FontSize,
            color: kColorTextPrimary,
          ),
        ),
      ],
    );
  }

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
}
