import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/user_settings/controllers/user_management_controller.dart';
import 'package:shivay_construction/utils/formatters/text_input_formatters.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_appbar.dart';
import 'package:shivay_construction/widgets/app_button.dart';
import 'package:shivay_construction/widgets/app_dropdown.dart';
import 'package:shivay_construction/widgets/app_loading_overlay.dart';
import 'package:shivay_construction/widgets/app_text_form_field.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({
    super.key,
    required this.isEdit,
    this.fullName,
    this.mobileNo,
    this.userId,
    this.isAppAccess,
    this.userType,
    this.seCodes,
    this.pCodes,
    this.eCodes,
    this.gdCodes,
  });

  final bool isEdit;
  final String? fullName;
  final String? mobileNo;
  final int? userId;
  final bool? isAppAccess;
  final int? userType;
  final String? seCodes;
  final String? pCodes;
  final String? eCodes;
  final String? gdCodes;

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final UserManagementController _controller = Get.put(
    UserManagementController(),
  );

  @override
  void initState() {
    super.initState();
    _controller.setupValidationListeners();
    initialize();
  }

  void initialize() async {
    if (widget.isEdit) {
      _controller.fullNameController.text = widget.fullName!;
      _controller.mobileNoController.text = widget.mobileNo!;
      _controller.selectedUserType.value = widget.userType!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            appBar: AppAppbar(
              title: 'User Management',
              leading: IconButton(
                onPressed: () => Get.back(),
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: tablet ? 25 : 20,
                  color: kColorPrimary,
                ),
              ),
            ),
            body: Padding(
              padding: tablet
                  ? AppPaddings.combined(horizontal: 24, vertical: 12)
                  : AppPaddings.p12,
              child: SingleChildScrollView(
                child: Form(
                  key: _controller.manageUserFormKey,
                  child: Column(
                    children: [
                      AppTextFormField(
                        controller: _controller.fullNameController,
                        hintText: 'Full Name',
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                        inputFormatters: [TitleCaseTextInputFormatter()],
                      ),
                      tablet ? AppSpaces.v16 : AppSpaces.v10,
                      AppTextFormField(
                        controller: _controller.mobileNoController,
                        hintText: 'Mobile Number',
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your mobile number';
                          }
                          if (value.length != 10) {
                            return 'Please enter a 10-digit mobile number';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          MobileNumberInputFormatter(),
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                      ),
                      tablet ? AppSpaces.v16 : AppSpaces.v10,
                      Obx(
                        () => AppTextFormField(
                          controller: _controller.passwordController,
                          hintText: 'Password',
                          isObscure: _controller.obscuredText.value,
                          suffixIcon: IconButton(
                            onPressed: () {
                              _controller.togglePasswordVisibility();
                            },
                            icon: Icon(
                              _controller.obscuredText.value
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      tablet ? AppSpaces.v16 : AppSpaces.v10,
                      Obx(
                        () => AppDropdown(
                          items: _controller.userTypes.values.toList(),
                          hintText: 'User Type',
                          showSearchBox: false,
                          onChanged: (selectedValue) {
                            _controller.onUserTypeChanged(selectedValue!);
                          },
                          selectedItem:
                              _controller.selectedUserType.value != null
                              ? _controller.userTypes.entries
                                    .firstWhere(
                                      (ut) =>
                                          ut.key ==
                                          _controller.selectedUserType.value,
                                    )
                                    .value
                              : null,
                          validatorText: 'Please select a user type.',
                        ),
                      ),
                      tablet ? AppSpaces.v30 : AppSpaces.v24,
                      AppButton(
                        title: 'Save',
                        onPressed: () {
                          _controller.hasAttemptedSubmit.value = true;
                          if (_controller.manageUserFormKey.currentState!
                              .validate()) {
                            _controller.manageUser(
                              userId: widget.isEdit ? widget.userId! : 0,
                            );
                          }
                        },
                      ),
                    ],
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
}
