import 'package:flutter/material.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/extensions/app_size_extensions.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';

class AppCheckboxRow extends StatelessWidget {
  final String title;
  final bool value;
  final VoidCallback onChanged;

  const AppCheckboxRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);
    final bool web = AppScreenUtils.isWeb;

    return InkWell(
      onTap: onChanged,
      child: Container(
        padding: web
            ? AppPaddings.combined(horizontal: 20, vertical: 12)
            : tablet
            ? AppPaddings.combined(horizontal: 20, vertical: 12)
            : AppPaddings.combined(
                horizontal: 16.appWidth,
                vertical: 8.appHeight,
              ),
        decoration: BoxDecoration(
          color: kColorWhite,
          border: Border.all(color: kColorDarkGrey, width: 1),
          borderRadius: BorderRadius.circular(web ? 10 : (tablet ? 20 : 10)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyles.kRegularOutfit(
                  fontSize: web
                      ? FontSizes.k16FontSize
                      : tablet
                      ? FontSizes.k22FontSize
                      : FontSizes.k16FontSize,
                  color: kColorBlack,
                  fontWeight: FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            SizedBox(
              height: tablet ? 24 : (web ? 26 : 24),
              width: tablet ? 24 : (web ? 26 : 24),
              child: Checkbox(
                value: value,
                onChanged: (_) => onChanged(),
                activeColor: kColorPrimary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
