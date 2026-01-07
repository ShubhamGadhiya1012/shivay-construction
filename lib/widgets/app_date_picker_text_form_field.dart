// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/extensions/app_size_extensions.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';

class AppDatePickerTextFormField extends StatefulWidget {
  const AppDatePickerTextFormField({
    super.key,
    required this.dateController,
    required this.hintText,
    this.fillColor,
    this.enabled = true,
    this.validator,
    this.onChanged,
  });

  final TextEditingController dateController;
  final String hintText;
  final Color? fillColor;
  final bool enabled;
  final String? Function(String? value)? validator;
  final void Function(String value)? onChanged;

  @override
  State<AppDatePickerTextFormField> createState() =>
      _AppDatePickerTextFormFieldState();
}

class _AppDatePickerTextFormFieldState
    extends State<AppDatePickerTextFormField> {
  static const String dateFormat = 'dd-MM-yyyy';

  Future<void> _selectDate(BuildContext context) async {
    final DateTime currentDate =
        _parseDate(widget.dateController.text) ?? DateTime.now();

    final bool web = AppScreenUtils.isWeb;
    final bool tablet = AppScreenUtils.isTablet(context);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: kColorPrimary,
            colorScheme: const ColorScheme.light(
              primary: kColorPrimary,
              secondary: kColorSecondary,
              onPrimary: kColorWhite,
              surface: kColorWhite,
            ),
            textTheme: TextTheme(
              headlineLarge: TextStyles.kMediumOutfit(
                fontSize: web
                    ? FontSizes.k20FontSize
                    : (tablet ? FontSizes.k32FontSize : FontSizes.k24FontSize),
                color: kColorWhite,
              ),
              headlineMedium: TextStyles.kMediumOutfit(
                fontSize: web
                    ? FontSizes.k16FontSize
                    : (tablet ? FontSizes.k32FontSize : FontSizes.k24FontSize),
                color: kColorWhite,
              ),
              // Day numbers in calendar grid
              bodyLarge: TextStyles.kRegularOutfit(
                fontSize: web
                    ? FontSizes.k16FontSize
                    : (tablet ? FontSizes.k22FontSize : FontSizes.k18FontSize),
                color: kColorPrimary,
              ),
              // Selected day
              bodyMedium: TextStyles.kMediumOutfit(
                fontSize: web
                    ? FontSizes.k16FontSize
                    : (tablet ? FontSizes.k24FontSize : FontSizes.k18FontSize),
                color: kColorWhite,
              ),
              // Week day labels (S M T W T F S)
              labelMedium: TextStyles.kMediumOutfit(
                fontSize: web
                    ? FontSizes.k14FontSize
                    : (tablet ? FontSizes.k22FontSize : FontSizes.k16FontSize),
                color: kColorPrimary,
              ),
              // Action buttons (Cancel, OK)
              labelLarge: TextStyles.kMediumOutfit(
                fontSize: web
                    ? FontSizes.k16FontSize
                    : (tablet ? FontSizes.k24FontSize : FontSizes.k18FontSize),
                color: kColorPrimary,
              ),
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: kColorWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  web ? 10 : (tablet ? 20 : 10),
                ),
              ),
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: kColorWhite,
              headerBackgroundColor: kColorPrimary,
              headerForegroundColor: kColorWhite,
            ),
          ),
          child: Transform.scale(
            scale: web ? 1.0 : (tablet ? 1.3 : 1.0),
            child: child!,
          ),
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        widget.dateController.text = DateFormat(dateFormat).format(pickedDate);
      });

      if (widget.onChanged != null) {
        widget.onChanged!(widget.dateController.text);
      }
    }
  }

  DateTime? _parseDate(String dateString) {
    try {
      return DateFormat(dateFormat).parseStrict(dateString);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool web = AppScreenUtils.isWeb;
    final bool tablet = AppScreenUtils.isTablet(context);

    return TextFormField(
      controller: widget.dateController,
      cursorColor: kColorPrimary,
      cursorHeight: web ? null : (tablet ? 26 : 20),
      enabled: widget.enabled,
      validator: widget.validator,
      style: TextStyles.kRegularOutfit(
        fontSize: web
            ? FontSizes.k14FontSize
            : (tablet ? FontSizes.k22FontSize : FontSizes.k16FontSize),
        color: kColorPrimary,
      ),
      readOnly: true,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyles.kRegularOutfit(
          fontSize: web
              ? FontSizes.k14FontSize
              : (tablet ? FontSizes.k20FontSize : FontSizes.k16FontSize),
          color: kColorDarkGrey,
        ),
        labelText: widget.hintText,
        labelStyle: TextStyles.kRegularOutfit(
          fontSize: web
              ? FontSizes.k14FontSize
              : (tablet ? FontSizes.k20FontSize : FontSizes.k16FontSize),
          color: kColorDarkGrey,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        floatingLabelStyle: TextStyles.kMediumOutfit(
          fontSize: web
              ? FontSizes.k16FontSize
              : (tablet ? FontSizes.k24FontSize : FontSizes.k18FontSize),
          color: kColorBlack,
        ),
        errorStyle: TextStyles.kRegularOutfit(
          fontSize: web
              ? FontSizes.k14FontSize
              : (tablet ? FontSizes.k20FontSize : FontSizes.k14FontSize),
          color: kColorRed,
        ),
        border: _outlineInputBorder(
          borderColor: kColorWhite,
          borderWidth: 1,
          web: web,
          tablet: tablet,
        ),
        enabledBorder: _outlineInputBorder(
          borderColor: kColorPrimary.withOpacity(0.75),
          borderWidth: 1,
          web: web,
          tablet: tablet,
        ),
        disabledBorder: _outlineInputBorder(
          borderColor: kColorPrimary.withOpacity(0.75),
          borderWidth: 1,
          web: web,
          tablet: tablet,
        ),
        focusedBorder: _outlineInputBorder(
          borderColor: kColorPrimary,
          borderWidth: web ? 1.5 : 1,
          web: web,
          tablet: tablet,
        ),
        errorBorder: _outlineInputBorder(
          borderColor: kColorRed,
          borderWidth: 1,
          web: web,
          tablet: tablet,
        ),
        focusedErrorBorder: _outlineInputBorder(
          borderColor: kColorRed,
          borderWidth: web ? 1.5 : 1,
          web: web,
          tablet: tablet,
        ),
        contentPadding: web
            ? null
            : (tablet
                  ? AppPaddings.combined(horizontal: 20, vertical: 12)
                  : AppPaddings.combined(
                      horizontal: 16.appWidth,
                      vertical: 8.appHeight,
                    )),
        filled: true,
        fillColor: widget.fillColor ?? kColorWhite,
        suffixIcon: IconButton(
          icon: Icon(
            Icons.calendar_today_rounded,
            size: web ? 20 : (tablet ? 25 : 20),
            color: kColorPrimary,
          ),
          onPressed: widget.enabled ? () => _selectDate(context) : null,
        ),
        suffixIconColor: kColorPrimary,
      ),
    );
  }

  OutlineInputBorder _outlineInputBorder({
    required Color borderColor,
    required double borderWidth,
    required bool web,
    required bool tablet,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(web ? 10 : (tablet ? 20 : 10)),
      borderSide: BorderSide(color: borderColor, width: borderWidth),
    );
  }
}
