import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/extensions/app_size_extensions.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';

class AppTextFormField extends StatelessWidget {
  const AppTextFormField({
    super.key,
    required this.controller,
    this.focusNode,
    this.floatingLabelRequired,
    this.enabled,
    this.maxLines,
    this.minLines,
    this.onChanged,
    this.validator,
    required this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.fillColor,
    this.suffixIcon,
    this.isObscure = false,
    this.inputFormatters,
    this.onFieldSubmitted,
    this.onSubmitted,
    this.onTap,
    this.fontSize,
    this.fontWeight,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool? floatingLabelRequired;
  final bool? enabled;
  final int? maxLines;
  final int? minLines;
  final void Function(String value)? onChanged;
  final String? Function(String? value)? validator;
  final String hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Color? fillColor;
  final Widget? suffixIcon;
  final bool? isObscure;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onFieldSubmitted;
  final void Function(String)? onSubmitted;
  final VoidCallback? onTap;
  final double? fontSize;
  final FontWeight? fontWeight;

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      cursorColor: kColorBlack,
      cursorHeight: tablet ? 26 : 20,
      inputFormatters: inputFormatters,
      enabled: enabled ?? true,
      maxLines: maxLines ?? 1,
      minLines: minLines ?? 1,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      onTap: onTap,
      textInputAction: textInputAction ?? TextInputAction.done,
      keyboardType: keyboardType ?? TextInputType.text,
      style: TextStyles.kRegularOutfit(
        fontSize:
            fontSize ??
            (tablet ? FontSizes.k22FontSize : FontSizes.k16FontSize),
        color: kColorBlack,
      ).copyWith(fontWeight: fontWeight ?? FontWeight.w400),
      obscureText: isObscure!,
      onEditingComplete: () {
        if (onSubmitted != null) {
          onSubmitted!(controller.text);
        }
        FocusScope.of(context).unfocus();
      },
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
        floatingLabelBehavior: (floatingLabelRequired ?? true)
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
        suffixIcon: suffixIcon,
        suffixIconColor: kColorBlack,
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
