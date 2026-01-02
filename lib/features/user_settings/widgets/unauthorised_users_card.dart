// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/features/user_settings/models/unauthorised_user_dm.dart';
import 'package:shivay_construction/features/user_settings/screens/user_authorisation_screen.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_card.dart';
import 'package:shivay_construction/widgets/app_title_value_container.dart';

class UnauthorisedUsersCard extends StatelessWidget {
  const UnauthorisedUsersCard({super.key, required this.unauthorisedUser});

  final UnauthorisedUserDm unauthorisedUser;

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            unauthorisedUser.fullName,
            style: TextStyles.kSemiBoldOutfit(
              fontSize: tablet ? FontSizes.k24FontSize : FontSizes.k18FontSize,
            ),
          ),
          tablet ? AppSpaces.v16 : AppSpaces.v10,

          AppTitleValueContainer(
            title: 'Mobile No.',
            value: unauthorisedUser.mobileNo,
          ),
        ],
      ),
      onTap: () {
        Get.to(
          () => UserAuthorisationScreen(
            userId: unauthorisedUser.userId,
            fullName: unauthorisedUser.fullName,
            mobileNo: unauthorisedUser.mobileNo,
          ),
        );
      },
    );
  }
}
