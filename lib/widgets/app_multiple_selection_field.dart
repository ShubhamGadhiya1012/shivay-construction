// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/extensions/app_size_extensions.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';

class AppMultipleSelectionField extends StatelessWidget {
  final String placeholder;
  final List<String> selectedItems;
  final VoidCallback onTap;
  final bool showFullList;
  final int maxItemsToShow;

  const AppMultipleSelectionField({
    super.key,
    required this.placeholder,
    required this.selectedItems,
    required this.onTap,
    this.showFullList = false,
    this.maxItemsToShow = 1,
  });

  @override
  Widget build(BuildContext context) {
    final bool web = AppScreenUtils.isWeb;
    final bool tablet = AppScreenUtils.isTablet(context);

    return GestureDetector(
      onTap: onTap,
      child: Obx(() {
        final isEmpty = selectedItems.isEmpty;

        final text = isEmpty
            ? ""
            : showFullList
            ? selectedItems.join(', ')
            : selectedItems.length <= maxItemsToShow
            ? selectedItems.join(', ')
            : '${selectedItems.take(maxItemsToShow).join(', ')}, ...';

        return InputDecorator(
          decoration: InputDecoration(
            hintText: placeholder,
            labelText: placeholder,
            floatingLabelBehavior: isEmpty
                ? FloatingLabelBehavior.never
                : FloatingLabelBehavior.always,

            // ----- match AppTextFormField -----
            hintStyle: TextStyles.kRegularOutfit(
              fontSize: web
                  ? FontSizes.k14FontSize
                  : tablet
                  ? FontSizes.k20FontSize
                  : FontSizes.k16FontSize,
              color: kColorDarkGrey,
            ),

            labelStyle: TextStyles.kRegularOutfit(
              fontSize: web
                  ? FontSizes.k14FontSize
                  : tablet
                  ? FontSizes.k20FontSize
                  : FontSizes.k16FontSize,
              color: kColorDarkGrey,
            ),

            floatingLabelStyle: TextStyles.kMediumOutfit(
              fontSize: web
                  ? FontSizes.k16FontSize
                  : tablet
                  ? FontSizes.k24FontSize
                  : FontSizes.k18FontSize,
              color: kColorPrimary,
            ),

            border: _border(web, tablet, kColorDarkGrey, 1),
            enabledBorder: _border(
              web,
              tablet,
              kColorPrimary.withOpacity(0.75),
              1,
            ),
            focusedBorder: _border(web, tablet, kColorPrimary, web ? 1.5 : 1),

            contentPadding: web
                ? AppPaddings.combined(horizontal: 16, vertical: 6)
                : (tablet
                      ? AppPaddings.combined(horizontal: 20, vertical: 12)
                      : AppPaddings.combined(
                          horizontal: 16.appWidth,
                          vertical: 8.appHeight,
                        )),
            filled: true,
            fillColor: kColorWhite,
          ),

          child: Text(
            isEmpty ? placeholder : text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.kRegularOutfit(
              fontSize: web
                  ? FontSizes.k14FontSize
                  : tablet
                  ? FontSizes.k22FontSize
                  : FontSizes.k16FontSize,
              color: isEmpty ? kColorDarkGrey : kColorPrimary,
            ).copyWith(fontWeight: FontWeight.w400),
          ),
        );
      }),
    );
  }

  OutlineInputBorder _border(bool web, bool tablet, Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(web ? 10 : (tablet ? 20 : 10)),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
