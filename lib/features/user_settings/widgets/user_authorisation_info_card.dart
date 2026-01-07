import 'package:flutter/material.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_card.dart';
import 'package:shivay_construction/widgets/app_title_value_container.dart';

class UserAuthorisationInfoCard extends StatelessWidget {
  const UserAuthorisationInfoCard({
    super.key,
    required this.fullName,
    required this.mobileNo,
  });

  final String fullName;
  final String mobileNo;

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fullName,
            style: TextStyles.kSemiBoldOutfit(
              fontSize: tablet ? FontSizes.k24FontSize : FontSizes.k18FontSize,
            ),
          ),
          tablet ? AppSpaces.v16 : AppSpaces.v10,
          AppTitleValueContainer(title: 'Mobile No.', value: mobileNo),
        ],
      ),
      onTap: () {},
    );
  }
}
