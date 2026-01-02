import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/user_settings/controllers/users_controller.dart';
import 'package:shivay_construction/features/user_settings/screens/user_management_screen.dart';
import 'package:shivay_construction/features/user_settings/widgets/users_card.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_appbar.dart';
import 'package:shivay_construction/widgets/app_loading_overlay.dart';
import 'package:shivay_construction/widgets/app_text_form_field.dart';

class UsersScreen extends StatelessWidget {
  UsersScreen({super.key, required this.fromWhere});

  final String fromWhere;

  final UsersController _controller = Get.put(UsersController());

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
              title: 'Users',
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
              child: Column(
                children: [
                  AppTextFormField(
                    controller: _controller.searchController,
                    hintText: 'Search User',
                    onChanged: (value) {
                      _controller.filterUsers(value);
                    },
                  ),
                  tablet ? AppSpaces.v20 : AppSpaces.v16,
                  Obx(() {
                    if (_controller.filteredUsers.isEmpty &&
                        !_controller.isLoading.value) {
                      return Expanded(
                        child: Center(
                          child: Text(
                            'No users found.',
                            style: TextStyles.kMediumOutfit(
                              fontSize: tablet
                                  ? FontSizes.k26FontSize
                                  : FontSizes.k20FontSize,
                            ),
                          ),
                        ),
                      );
                    }

                    return Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _controller.filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = _controller.filteredUsers[index];

                          return UsersCard(
                            user: user,
                            controller: _controller,
                            fromWhere: fromWhere,
                          );
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
            floatingActionButton: fromWhere == 'M'
                ? tablet
                      ? FloatingActionButton.large(
                          onPressed: () {
                            // Get.to(() => UserManagementScreen(isEdit: false));
                          },
                          shape: const CircleBorder(),
                          backgroundColor: kColorSecondary,
                          child: Icon(
                            Icons.add,
                            color: kColorPrimary,
                            size: 40,
                          ),
                        )
                      : FloatingActionButton(
                          onPressed: () {
                            Get.to(() => UserManagementScreen(isEdit: false));
                          },
                          shape: const CircleBorder(),
                          backgroundColor: kColorSecondary,
                          child: Icon(
                            Icons.add,
                            color: kColorPrimary,
                            size: 25,
                          ),
                        )
                : null,
          ),
        ),
        Obx(() => AppLoadingOverlay(isLoading: _controller.isLoading.value)),
      ],
    );
  }
}
