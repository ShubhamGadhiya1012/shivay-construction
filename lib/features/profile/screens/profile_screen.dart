import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/auth/screens/reset_password_screen.dart';
import 'package:shivay_construction/features/profile/controllers/profile_controller.dart';
import 'package:shivay_construction/features/profile/widgets/profile_list_tile.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_appbar.dart';
import 'package:shivay_construction/widgets/app_loading_overlay.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final ProfileController _controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);

    return Stack(
      children: [
        Scaffold(
          appBar: AppAppbar(
            title: 'Profile',
            leading: IconButton(
              onPressed: () => Get.back(),
              icon: Icon(
                Icons.arrow_back_ios,
                size: tablet ? 25 : 20,
                color: kColorPrimary,
              ),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: tablet
                    ? AppPaddings.combined(horizontal: 30, vertical: 15)
                    : AppPaddings.p12,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: kColorWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: kColorLightGrey, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: kColorGrey,
                        spreadRadius: 1,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: tablet
                      ? AppPaddings.combined(horizontal: 30, vertical: 15)
                      : AppPaddings.p10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AppSpaces.v10,
                      Container(
                        width: tablet ? 120 : 80,
                        height: tablet ? 120 : 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: kColorPrimary,
                        ),
                        child: Center(
                          child: Obx(
                            () => Text(
                              _controller.fullName.value
                                  .trim()
                                  .split(' ')
                                  .map(
                                    (e) =>
                                        e.isNotEmpty ? e[0].toUpperCase() : '',
                                  )
                                  .take(2)
                                  .join(),
                              style: TextStyles.kMediumOutfit(
                                fontSize: FontSizes.k30FontSize,
                                fontWeight: FontWeight.w800,
                                color: kColorWhite,
                              ),
                            ),
                          ),
                        ),
                      ),
                      AppSpaces.v10,
                      Text(
                        'Welcome,',
                        style: TextStyles.kRegularOutfit().copyWith(
                          fontSize: tablet
                              ? FontSizes.k22FontSize
                              : FontSizes.k16FontSize,
                        ),
                      ),
                      Obx(
                        () => Text(
                          _controller.fullName.value,
                          style: TextStyles.kMediumOutfit(
                            fontSize: tablet
                                ? FontSizes.k40FontSize
                                : FontSizes.k30FontSize,
                            color: kColorPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      tablet ? AppSpaces.v16 : AppSpaces.v10,
                      Container(
                        padding: tablet
                            ? AppPaddings.combined(horizontal: 16, vertical: 8)
                            : AppPaddings.combined(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: kColorLightGrey,
                          borderRadius: BorderRadius.circular(tablet ? 20 : 10),
                          border: Border.all(color: kColorGrey, width: 1),
                        ),
                        child: Obx(
                          () => Text(
                            _controller.gdName.value,
                            style: TextStyles.kBoldOutfit(
                              fontSize: tablet
                                  ? FontSizes.k22FontSize
                                  : FontSizes.k16FontSize,
                              color: kColorPrimary,
                            ),
                          ),
                        ),
                      ),
                      AppSpaces.v10,
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: tablet
                      ? AppPaddings.combined(horizontal: 30, vertical: 15)
                      : AppPaddings.p10,
                  child: Column(
                    children: [
                      AppSpaces.v10,
                      Container(
                        padding: tablet
                            ? AppPaddings.combined(horizontal: 10, vertical: 15)
                            : AppPaddings.p10,
                        decoration: BoxDecoration(
                          color: kColorWhite,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: kColorGrey,
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            ProfileListTile(
                              leading: Icons.lock_reset,
                              title: 'Reset Password',
                              onTap: () {
                                Get.to(
                                  () => ResetPasswordScreen(
                                    mobileNumber:
                                        _controller.mobileNumber.value,
                                    fullName: _controller.fullName.value,
                                  ),
                                );
                              },
                            ),

                            Divider(
                              indent: tablet ? 40 : 20,
                              endIndent: tablet ? 40 : 20,
                              color: kColorGrey,
                            ),
                            ProfileListTile(
                              leading: Icons.system_update,
                              title: 'Check For Updates',
                              onTap: () async {
                                await redirectToPlayStore();
                              },
                            ),
                            Divider(
                              indent: tablet ? 40 : 20,
                              endIndent: tablet ? 40 : 20,
                              color: kColorGrey,
                            ),
                            ProfileListTile(
                              leading: Icons.logout,
                              title: 'Logout',
                              onTap: () {
                                _controller.logoutUser();
                              },
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Obx(
                          () => Text(
                            'v${_controller.appVersion.value}',
                            style: TextStyles.kRegularOutfit(
                              fontSize: tablet
                                  ? FontSizes.k22FontSize
                                  : FontSizes.k16FontSize,
                              color: kColorPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Obx(() => AppLoadingOverlay(isLoading: _controller.isLoading.value)),
      ],
    );
  }

  Future<void> redirectToPlayStore() async {
    const playStoreUrl =
        'https://play.google.com/store/apps/details?id=com.jinee.shivay_construction';

    final uri = Uri.parse(playStoreUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      showErrorSnackbar('Error', 'Could not launch the Play Store.');
    }
  }
}
