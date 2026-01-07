import 'package:flutter/material.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';

class ProfileListTile extends StatelessWidget {
  const ProfileListTile({
    super.key,
    required this.leading,
    required this.title,
    required this.onTap,
  });

  final IconData leading;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);
    return ListTile(
      onTap: onTap,
      leading: Icon(leading, size: tablet ? 26 : 20, color: kColorPrimary),
      title: Text(
        title,
        style: TextStyles.kRegularOutfit(
          fontSize: tablet ? FontSizes.k24FontSize : FontSizes.k18FontSize,
          color: kColorPrimary,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: tablet ? 26 : 20,
        color: kColorPrimary,
      ),
    );
  }
}
