import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/extensions/app_size_extensions.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';

class AppTimePickerField extends StatefulWidget {
  const AppTimePickerField({
    super.key,
    required this.timeController,
    required this.hintText,
    this.fillColor,
    this.enabled = true,
    this.validator,
  });

  final TextEditingController timeController;
  final String hintText;
  final Color? fillColor;
  final bool enabled;
  final String? Function(String?)? validator;

  @override
  State<AppTimePickerField> createState() => _AppTimePickerFieldState();
}

class _AppTimePickerFieldState extends State<AppTimePickerField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay currentTime =
        _parseTime(widget.timeController.text) ?? TimeOfDay.now();

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: currentTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(data: _buildTimePickerTheme(context), child: child!);
      },
    );

    if (pickedTime != null) {
      _focusNode.unfocus();
      final now = DateTime.now();
      final formattedTime = DateFormat('hh:mm a').format(
        DateTime(
          now.year,
          now.month,
          now.day,
          pickedTime.hour,
          pickedTime.minute,
        ),
      );
      setState(() {
        widget.timeController.text = formattedTime;
      });
    }
  }

  TimeOfDay? _parseTime(String timeString) {
    try {
      final format = DateFormat.jm();
      final DateTime dateTime = format.parse(timeString);
      return TimeOfDay.fromDateTime(dateTime);
    } catch (e) {
      return null;
    }
  }

  ThemeData _buildTimePickerTheme(BuildContext context) {
    final bool web = AppScreenUtils.isWeb;
    final bool tablet = AppScreenUtils.isTablet(context);

    return ThemeData.light().copyWith(
      primaryColor: kColorPrimary,
      colorScheme: const ColorScheme.light(
        primary: kColorPrimary,
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
        bodyLarge: TextStyles.kRegularOutfit(
          fontSize: web
              ? FontSizes.k16FontSize
              : (tablet ? FontSizes.k22FontSize : FontSizes.k18FontSize),
          color: kColorBlack,
        ),
        bodyMedium: TextStyles.kMediumOutfit(
          fontSize: web
              ? FontSizes.k14FontSize
              : (tablet ? FontSizes.k20FontSize : FontSizes.k16FontSize),
          color: kColorBlack,
        ),
        labelLarge: TextStyles.kMediumOutfit(
          fontSize: web
              ? FontSizes.k16FontSize
              : (tablet ? FontSizes.k22FontSize : FontSizes.k18FontSize),
          color: kColorPrimary,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: kColorWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(web ? 10 : (tablet ? 20 : 10)),
        ),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: kColorWhite,
        hourMinuteTextColor: kColorWhite,
        hourMinuteColor: kColorPrimary,
        dialHandColor: kColorPrimary,
        dialBackgroundColor: kColorWhite,
        entryModeIconColor: kColorPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool web = AppScreenUtils.isWeb;
    final bool tablet = AppScreenUtils.isTablet(context);

    return TextFormField(
      controller: widget.timeController,
      focusNode: _focusNode,
      keyboardType: TextInputType.datetime,
      readOnly: true,
      enabled: widget.enabled,
      cursorColor: kColorBlack,
      cursorHeight: web ? 20 : (tablet ? 26 : 20),
      style: TextStyles.kRegularOutfit(
        fontSize: web
            ? FontSizes.k16FontSize
            : (tablet ? FontSizes.k22FontSize : FontSizes.k16FontSize),
        color: kColorBlack,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: widget.fillColor ?? kColorWhite,
        hintText: widget.hintText,
        hintStyle: TextStyles.kRegularOutfit(
          fontSize: web
              ? FontSizes.k16FontSize
              : (tablet ? FontSizes.k20FontSize : FontSizes.k16FontSize),
          color: kColorDarkGrey,
        ),
        labelText: widget.hintText,
        labelStyle: TextStyles.kRegularOutfit(
          fontSize: web
              ? FontSizes.k16FontSize
              : (tablet ? FontSizes.k20FontSize : FontSizes.k16FontSize),
          color: kColorDarkGrey,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        floatingLabelStyle: TextStyles.kMediumOutfit(
          fontSize: web
              ? FontSizes.k18FontSize
              : (tablet ? FontSizes.k24FontSize : FontSizes.k18FontSize),
          color: kColorBlack,
        ),
        errorStyle: TextStyles.kRegularOutfit(
          fontSize: web
              ? FontSizes.k14FontSize
              : (tablet ? FontSizes.k18FontSize : FontSizes.k14FontSize),
          color: kColorRed,
        ),
        border: _outlineInputBorder(
          borderColor: kColorDarkGrey,
          borderWidth: 1,
          web: web,
          tablet: tablet,
        ),
        focusedBorder: _outlineInputBorder(
          borderColor: kColorBlack,
          borderWidth: web ? 1.5 : 1,
          web: web,
          tablet: tablet,
        ),
        enabledBorder: _outlineInputBorder(
          borderColor: kColorDarkGrey,
          borderWidth: 1,
          web: web,
          tablet: tablet,
        ),
        disabledBorder: _outlineInputBorder(
          borderColor: kColorDarkGrey,
          borderWidth: 1,
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
            ? AppPaddings.combined(horizontal: 16, vertical: 12)
            : (tablet
                  ? AppPaddings.combined(horizontal: 20, vertical: 12)
                  : AppPaddings.combined(
                      horizontal: 16.appWidth,
                      vertical: 8.appHeight,
                    )),
        suffixIcon: IconButton(
          icon: Icon(
            Icons.access_time_filled,
            size: web ? 20 : (tablet ? 25 : 20),
            color: kColorBlack,
          ),
          onPressed: widget.enabled ? () => _selectTime(context) : null,
        ),
        suffixIconColor: kColorBlack,
      ),
      validator:
          widget.validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter or select a time';
            }
            return null;
          },
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
