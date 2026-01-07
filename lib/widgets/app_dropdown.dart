import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/extensions/app_size_extensions.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';

class AppDropdown extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.items,
    this.floatingLabelRequired,
    this.selectedItem,
    required this.hintText,
    this.searchHintText,
    this.fillColor,
    this.showSearchBox,
    required this.onChanged,
    this.validatorText,
    this.enabled,
    this.clearButtonProps,
    this.borderRadius,
  });

  final List<String> items;
  final bool? floatingLabelRequired;
  final String? selectedItem;
  final String hintText;
  final String? searchHintText;
  final Color? fillColor;
  final bool? showSearchBox;
  final ValueChanged<String?>? onChanged;
  final String? validatorText;
  final bool? enabled;
  final ClearButtonProps? clearButtonProps;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);

    return DropdownSearch<String>(
      selectedItem: selectedItem,
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validatorText;
        }
        return null;
      },
      items: (filter, infiniteScrollProps) => items,
      enabled: enabled ?? true,
      suffixProps: DropdownSuffixProps(
        clearButtonProps:
            clearButtonProps ?? const ClearButtonProps(isVisible: false),
      ),
      decoratorProps: DropDownDecoratorProps(
        baseStyle: TextStyles.kRegularOutfit(
          fontSize: (tablet ? FontSizes.k22FontSize : FontSizes.k16FontSize),
          color: kColorBlack,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyles.kRegularOutfit(
            fontSize: tablet ? FontSizes.k20FontSize : FontSizes.k16FontSize,
            color: kColorDarkGrey,
          ),
          labelText: hintText,
          labelStyle: TextStyles.kRegularOutfit(
            fontSize: tablet ? FontSizes.k20FontSize : FontSizes.k16FontSize,
            color: kColorDarkGrey,
          ),
          floatingLabelBehavior: floatingLabelRequired ?? true
              ? FloatingLabelBehavior.auto
              : FloatingLabelBehavior.never,
          floatingLabelStyle: TextStyles.kMediumOutfit(
            fontSize: tablet ? FontSizes.k24FontSize : FontSizes.k18FontSize,
            color: kColorBlack,
          ),
          errorStyle: TextStyles.kRegularOutfit(
            fontSize: tablet ? FontSizes.k18FontSize : FontSizes.k14FontSize,
            color: kColorRed,
          ),
          border: outlineInputBorder(
            borderColor: kColorDarkGrey,
            borderWidth: 1,
            tablet: tablet,
          ),
          enabledBorder: outlineInputBorder(
            borderColor: kColorDarkGrey,
            borderWidth: 1,
            tablet: tablet,
          ),
          disabledBorder: outlineInputBorder(
            borderColor: kColorDarkGrey,
            borderWidth: 1,
            tablet: tablet,
          ),
          focusedBorder: outlineInputBorder(
            borderColor: kColorBlack,
            borderWidth: 1,
            tablet: tablet,
          ),
          errorBorder: outlineInputBorder(
            borderColor: kColorRed,
            borderWidth: 1,
            tablet: tablet,
          ),
          contentPadding: tablet
              ? AppPaddings.combined(horizontal: 20, vertical: 12)
              : AppPaddings.combined(
                  horizontal: 16.appWidth,
                  vertical: 8.appHeight,
                ),
          filled: true,
          fillColor: fillColor ?? kColorWhite,
          suffixIconColor: kColorBlack,
        ),
      ),
      popupProps: PopupProps.menu(
        fit: FlexFit.loose,
        constraints: BoxConstraints(maxHeight: tablet ? 450 : 300),
        menuProps: MenuProps(
          backgroundColor: kColorWhite,
          borderRadius: BorderRadius.circular(10),
        ),
        itemBuilder: (context, item, isDisabled, isSelected) => Padding(
          padding: AppPaddings.p10,
          child: Text(
            item,
            style: TextStyles.kRegularOutfit(
              color: kColorBlack,
              fontSize: tablet ? FontSizes.k20FontSize : FontSizes.k16FontSize,
            ).copyWith(height: 1),
          ),
        ),
        showSearchBox: showSearchBox ?? true,
        searchFieldProps: TextFieldProps(
          style: TextStyles.kRegularOutfit(
            fontSize: (tablet ? FontSizes.k22FontSize : FontSizes.k16FontSize),
            color: kColorBlack,
          ),
          cursorColor: kColorBlack,
          cursorHeight: tablet ? 26 : 20,
          decoration: InputDecoration(
            hintText: searchHintText ?? 'Search',
            hintStyle: TextStyles.kRegularOutfit(
              fontSize: tablet ? FontSizes.k20FontSize : FontSizes.k16FontSize,
              color: kColorDarkGrey,
            ),
            labelText: hintText,
            labelStyle: TextStyles.kRegularOutfit(
              fontSize: tablet ? FontSizes.k20FontSize : FontSizes.k16FontSize,
              color: kColorDarkGrey,
            ),
            floatingLabelBehavior: floatingLabelRequired ?? true
                ? FloatingLabelBehavior.auto
                : FloatingLabelBehavior.never,
            floatingLabelStyle: TextStyles.kMediumOutfit(
              fontSize: tablet ? FontSizes.k24FontSize : FontSizes.k18FontSize,
              color: kColorBlack,
            ),
            errorStyle: TextStyles.kRegularOutfit(
              fontSize: tablet ? FontSizes.k18FontSize : FontSizes.k14FontSize,
              color: kColorRed,
            ),
            border: outlineInputBorder(
              borderColor: kColorDarkGrey,
              borderWidth: 1,
              tablet: tablet,
            ),
            enabledBorder: outlineInputBorder(
              borderColor: kColorDarkGrey,
              borderWidth: 1,
              tablet: tablet,
            ),
            disabledBorder: outlineInputBorder(
              borderColor: kColorDarkGrey,
              borderWidth: 1,
              tablet: tablet,
            ),
            focusedBorder: outlineInputBorder(
              borderColor: kColorBlack,
              borderWidth: 1,
              tablet: tablet,
            ),
            errorBorder: outlineInputBorder(
              borderColor: kColorRed,
              borderWidth: 1,
              tablet: tablet,
            ),
            contentPadding: tablet
                ? AppPaddings.combined(horizontal: 20, vertical: 12)
                : AppPaddings.combined(
                    horizontal: 16.appWidth,
                    vertical: 8.appHeight,
                  ),
            filled: true,
            fillColor: fillColor ?? kColorWhite,
            suffixIconColor: kColorBlack,
          ),
        ),
      ),
    );
  }

  OutlineInputBorder outlineInputBorder({
    required Color borderColor,
    required double borderWidth,
    required bool tablet,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(tablet ? 20 : 10),
      borderSide: BorderSide(color: borderColor, width: borderWidth),
    );
  }
}
