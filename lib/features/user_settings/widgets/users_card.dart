// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/features/user_settings/controllers/users_controller.dart';
import 'package:shivay_construction/features/user_settings/models/user_dm.dart';
import 'package:shivay_construction/features/user_settings/screens/user_access_screen.dart';
import 'package:shivay_construction/features/user_settings/screens/user_management_screen.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_card.dart';
import 'package:shivay_construction/widgets/app_title_value_container.dart';

class UsersCard extends StatelessWidget {
  const UsersCard({
    super.key,
    required this.user,
    required this.fromWhere,
    required UsersController controller,
  }) : _controller = controller;

  final UserDm user;
  final UsersController _controller;
  final String fromWhere;

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user.fullName,
            style: TextStyles.kSemiBoldOutfit(
              fontSize: tablet ? FontSizes.k24FontSize : FontSizes.k18FontSize,
            ),
          ),
          tablet ? AppSpaces.v16 : AppSpaces.v10,
          Row(
            children: [
              Expanded(
                child: AppTitleValueContainer(
                  title: 'Designation',
                  value: _controller.getUserDesignation(user.userType),
                ),
              ),
              AppSpaces.h10,
              Expanded(
                child: AppTitleValueContainer(
                  title: 'Mobile No.',
                  value: user.mobileNo,
                ),
              ),
            ],
          ),
        ],
      ),
      onTap: () {
        if (fromWhere == 'R') {
          Get.to(
            () => UserAccessScreen(
              fullName: user.fullName,
              userId: user.userId,
              appAccess: user.appAccess,
              indentAuth: user.indentAuth,
              poAuth: user.poAuth,
            ),
          );
        } else if (fromWhere == 'M') {
          Get.to(
            () => UserManagementScreen(
              isEdit: true,
              fullName: user.fullName,
              mobileNo: user.mobileNo,
              userId: user.userId,
              isAppAccess: user.appAccess,
              userType: user.userType,
              seCodes: user.seCodes,
              pCodes: user.pCodes,
              eCodes: '',
              gdCodes: user.gdCodes,
            ),
          );
        }
      },
    );
  }
}
