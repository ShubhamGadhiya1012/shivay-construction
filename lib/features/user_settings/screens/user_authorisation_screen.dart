import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/user_settings/controllers/user_authorisation_controller.dart';
import 'package:shivay_construction/features/user_settings/widgets/user_authorisation_info_card.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_appbar.dart';
import 'package:shivay_construction/widgets/app_button.dart';
import 'package:shivay_construction/widgets/app_dropdown.dart';
import 'package:shivay_construction/widgets/app_loading_overlay.dart';

class UserAuthorisationScreen extends StatelessWidget {
  UserAuthorisationScreen({
    super.key,
    required this.userId,
    required this.fullName,
    required this.mobileNo,
  });

  final int userId;
  final String fullName;
  final String mobileNo;

  final UserAuthorisationController _controller = Get.put(
    UserAuthorisationController(),
  );

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
              title: 'User Authorisation',
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
                  key: _controller.authUserFormKey,
                  child: Column(
                    children: [
                      tablet ? AppSpaces.v16 : AppSpaces.v10,
                      UserAuthorisationInfoCard(
                        fullName: fullName,
                        mobileNo: mobileNo,
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
                          if (_controller.authUserFormKey.currentState!
                              .validate()) {
                            _controller.authoriseUser(userId: userId);
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
