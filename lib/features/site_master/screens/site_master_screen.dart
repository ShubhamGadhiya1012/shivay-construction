// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/site_master/controllers/site_master_controller.dart';
import 'package:shivay_construction/features/site_master/models/site_master_dm.dart';
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

class SiteMasterScreen extends StatelessWidget {
  final SiteMasterDm? site;

  SiteMasterScreen({super.key, this.site});

  final SiteMasterController _controller = Get.put(SiteMasterController());

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);

    if (site != null && !_controller.isEditMode.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.autoFillDataForEdit(site!);
      });
    }

    return Stack(
      children: [
        GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            appBar: AppAppbar(
              title: site != null ? 'Update Site' : 'Add Site',
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
                        key: _controller.siteFormKey,
                        child: Column(
                          children: [
                            tablet ? AppSpaces.v6 : AppSpaces.v4,
                            AppTextFormField(
                              controller: _controller.siteNameController,
                              hintText: 'Site Name *',
                              validator: (value) =>
                                  (value == null || value.trim().isEmpty)
                                  ? 'Please enter site name'
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
                                            onAdd: (value) {
                                              _controller.addNewCity(value);
                                            },
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
                                            onAdd: (value) {
                                              _controller.addNewState(value);
                                            },
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

                            AppTextFormField(
                              controller: _controller.pinCodeController,
                              hintText: 'Pin Code *',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(6),
                              ],
                              validator: (value) =>
                                  (value == null || value.trim().isEmpty)
                                  ? 'Please enter pin code'
                                  : value.trim().length != 6
                                  ? 'Pin code must be 6 digits'
                                  : null,
                            ),
                            tablet ? AppSpaces.v16 : AppSpaces.v10,

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
                        if (_controller.siteFormKey.currentState!.validate()) {
                          _controller.addUpdateSiteMaster();
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
