// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/department%20master/controllers/department_master_controller.dart';
import 'package:shivay_construction/features/department%20master/widgets/department_master_card.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_appbar.dart';
import 'package:shivay_construction/widgets/app_button.dart';
import 'package:shivay_construction/widgets/app_loading_overlay.dart';
import 'package:shivay_construction/widgets/app_text_form_field.dart';

class DepartmentMasterScreen extends StatelessWidget {
  DepartmentMasterScreen({super.key});

  final DepartmentMasterController _controller = Get.put(
    DepartmentMasterController(),
  );

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);

    return Stack(
      children: [
        GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            appBar: AppAppbar(
              title: 'Department Master',
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: tablet ? 25 : 20,
                  color: kColorPrimary,
                ),
                onPressed: () => Get.back(),
              ),
            ),
            body: Padding(
              padding: tablet
                  ? AppPaddings.combined(horizontal: 24, vertical: 12)
                  : AppPaddings.p12,
              child: Column(
                children: [
                  AppTextFormField(
                    controller: _controller.searchController,
                    hintText: 'Search Department',
                    onChanged: (value) => _controller.filterDepartments(value),
                  ),
                  tablet ? AppSpaces.v16 : AppSpaces.v12,
                  Obx(() {
                    if (_controller.filteredDepartments.isEmpty &&
                        !_controller.isLoading.value) {
                      return Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.business_center_outlined,
                                size: tablet ? 80 : 64,
                                color: kColorLightGrey,
                              ),
                              tablet ? AppSpaces.v20 : AppSpaces.v16,
                              Text(
                                'No Departments Found',
                                style: TextStyles.kMediumOutfit(
                                  fontSize: tablet
                                      ? FontSizes.k24FontSize
                                      : FontSizes.k18FontSize,
                                  color: kColorTextPrimary,
                                ),
                              ),
                              AppSpaces.v8,
                              Text(
                                'Add a new department to get started',
                                style: TextStyles.kRegularOutfit(
                                  fontSize: tablet
                                      ? FontSizes.k16FontSize
                                      : FontSizes.k14FontSize,
                                  color: kColorDarkGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Expanded(
                      child: RefreshIndicator(
                        backgroundColor: kColorWhite,
                        color: kColorPrimary,
                        strokeWidth: 2.5,
                        onRefresh: () => _controller.getDepartments(),
                        child: ListView.builder(
                          itemCount: _controller.filteredDepartments.length,
                          itemBuilder: (context, index) {
                            final department =
                                _controller.filteredDepartments[index];
                            return DepartmentMasterCard(
                              department: department,
                              onEdit: () => _showDepartmentDialog(
                                dCode: department.dCode,
                                initialName: department.dName,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(tablet ? 16 : 12),
                boxShadow: [
                  BoxShadow(
                    color: kColorPrimary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: () => _showDepartmentDialog(),
                backgroundColor: kColorPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(tablet ? 16 : 12),
                ),
                icon: Icon(
                  Icons.add,
                  color: kColorWhite,
                  size: tablet ? 24 : 20,
                ),
                label: Text(
                  'Add New',
                  style: TextStyles.kSemiBoldOutfit(
                    fontSize: tablet
                        ? FontSizes.k16FontSize
                        : FontSizes.k14FontSize,
                    color: kColorWhite,
                  ),
                ),
              ),
            ),
          ),
        ),
        Obx(() => AppLoadingOverlay(isLoading: _controller.isLoading.value)),
      ],
    );
  }

  void _showDepartmentDialog({String? dCode, String? initialName}) {
    final bool tablet = AppScreenUtils.isTablet(Get.context!);
    _controller.dNameController.text = initialName ?? '';

    showDialog(
      context: Get.context!,
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
            maxWidth: tablet
                ? 520
                : MediaQuery.of(Get.context!).size.width * 0.9,
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
                        dCode != null
                            ? Icons.edit_rounded
                            : Icons.add_business_rounded,
                        color: kColorPrimary,
                        size: tablet ? 26 : 22,
                      ),
                    ),
                    tablet ? AppSpaces.h12 : AppSpaces.h10,
                    Expanded(
                      child: Text(
                        dCode != null
                            ? 'Update Department'
                            : 'Add New Department',
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
                  key: _controller.departmentFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Department Name',
                        style: TextStyles.kMediumOutfit(
                          fontSize: tablet
                              ? FontSizes.k16FontSize
                              : FontSizes.k14FontSize,
                          color: kColorTextPrimary,
                        ),
                      ),
                      tablet ? AppSpaces.v10 : AppSpaces.v8,
                      AppTextFormField(
                        controller: _controller.dNameController,
                        hintText: 'Enter department name',
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? 'Please enter department name'
                            : value.trim().length < 2
                            ? 'Name must be at least 2 characters'
                            : null,
                      ),
                      tablet ? AppSpaces.v24 : AppSpaces.v20,
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                _controller.dNameController.clear();
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
                              title: dCode != null ? 'Update' : 'Add',
                              buttonColor: kColorPrimary,
                              titleColor: kColorWhite,
                              titleSize: tablet
                                  ? FontSizes.k16FontSize
                                  : FontSizes.k14FontSize,
                              buttonHeight: tablet ? 54 : 48,
                              onPressed: () async {
                                if (_controller.departmentFormKey.currentState!
                                    .validate()) {
                                  Get.back();
                                  await _controller.addUpdateDepartment(
                                    dCode: dCode ?? '',
                                    dName: _controller.dNameController.text
                                        .trim(),
                                  );
                                  _controller.dNameController.clear();
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
