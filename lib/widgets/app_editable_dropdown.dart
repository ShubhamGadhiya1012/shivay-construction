import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/extensions/app_size_extensions.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';

class EditableDropdownTextField extends StatefulWidget {
  const EditableDropdownTextField({
    super.key,
    required this.value,
    required this.hintText,
    required this.options,
    this.onFieldSubmitted,
    this.validator,
    this.fillColor,
    this.suffixIcon,
    this.maxLines,
    this.minLines,
    this.inputFormatters,
    this.keyboardType,
    this.enabled,
  });

  final String value;
  final String hintText;
  final List<String> options;
  final void Function(String)? onFieldSubmitted;
  final String? Function(String?)? validator;
  final Color? fillColor;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? minLines;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final bool? enabled;

  @override
  State<EditableDropdownTextField> createState() =>
      _EditableDropdownTextFieldState();
}

class _EditableDropdownTextFieldState extends State<EditableDropdownTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant EditableDropdownTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.text = widget.value;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool web = AppScreenUtils.isWeb;
    final bool tablet = AppScreenUtils.isTablet(context);

    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        return widget.options;
      },
      onSelected: (String selection) {
        _controller.text = selection;
        widget.onFieldSubmitted?.call(selection);
      },
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_controller.text != textEditingController.text) {
                textEditingController.text = _controller.text;
              }
            });

            textEditingController.addListener(() {
              if (_controller.text != textEditingController.text) {
                _controller.text = textEditingController.text;
              }
            });

            return TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              enabled: widget.enabled ?? true,
              validator: widget.validator,
              inputFormatters: widget.inputFormatters,
              maxLines: widget.maxLines ?? 1,
              minLines: widget.minLines ?? 1,
              keyboardType: widget.keyboardType ?? TextInputType.text,
              onFieldSubmitted: widget.onFieldSubmitted,

              cursorColor: kColorBlack,
              cursorHeight: web ? 22 : (tablet ? 26 : 20),

              style: TextStyles.kRegularOutfit(
                fontSize: _font(web, tablet),
                color: kColorBlack,
              ),

              decoration: InputDecoration(
                labelText: widget.hintText,
                hintText: widget.hintText,

                hintStyle: TextStyles.kRegularOutfit(
                  fontSize: _font(web, tablet),
                  color: kColorDarkGrey,
                ),

                labelStyle: TextStyles.kRegularOutfit(
                  fontSize: _font(web, tablet),
                  color: kColorDarkGrey,
                ),

                floatingLabelBehavior: FloatingLabelBehavior.auto,

                floatingLabelStyle: TextStyles.kMediumOutfit(
                  fontSize: _floatingFont(web, tablet),
                  color: kColorBlack,
                ),

                errorStyle: TextStyles.kRegularOutfit(
                  fontSize: _errorFont(web, tablet),
                  color: kColorRed,
                ),

                suffixIcon:
                    widget.suffixIcon ??
                    Icon(
                      Icons.arrow_drop_down,
                      color: kColorBlack,
                      size: web ? 24 : (tablet ? 28 : 24),
                    ),

                filled: true,
                fillColor: widget.fillColor ?? kColorWhite,

                contentPadding: _padding(web, tablet),

                border: _border(web, tablet, kColorDarkGrey, 1),
                enabledBorder: _border(web, tablet, kColorDarkGrey, 1),
                disabledBorder: _border(web, tablet, kColorDarkGrey, 1),
                focusedBorder: _border(web, tablet, kColorBlack, web ? 1.5 : 1),
                errorBorder: _border(web, tablet, kColorRed, 1),
                focusedErrorBorder: _border(
                  web,
                  tablet,
                  kColorRed,
                  web ? 1.5 : 1,
                ),
              ),
            );
          },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(web ? 10 : (tablet ? 20 : 10)),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: web ? 300 : (tablet ? 450 : 300),
              ),
              decoration: BoxDecoration(
                color: kColorWhite,
                borderRadius: BorderRadius.circular(
                  web ? 10 : (tablet ? 20 : 10),
                ),
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return InkWell(
                    onTap: () => onSelected(option),
                    child: Padding(
                      padding: AppPaddings.p10,
                      child: Text(
                        option,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.kRegularOutfit(
                          fontSize: _font(web, tablet),
                          color: kColorBlack,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  /* ----------------------- Helpers (MATCH AppDropdown) ---------------------- */

  double _font(bool web, bool tablet) {
    if (web) return FontSizes.k16FontSize;
    return tablet ? FontSizes.k22FontSize : FontSizes.k16FontSize;
  }

  double _floatingFont(bool web, bool tablet) {
    if (web) return FontSizes.k18FontSize;
    return tablet ? FontSizes.k24FontSize : FontSizes.k18FontSize;
  }

  double _errorFont(bool web, bool tablet) {
    if (web) return FontSizes.k14FontSize;
    return tablet ? FontSizes.k18FontSize : FontSizes.k14FontSize;
  }

  EdgeInsets _padding(bool web, bool tablet) {
    if (web) return AppPaddings.combined(horizontal: 16, vertical: 12);

    return tablet
        ? AppPaddings.combined(horizontal: 20, vertical: 12)
        : AppPaddings.combined(horizontal: 16.appWidth, vertical: 8.appHeight);
  }

  OutlineInputBorder _border(bool web, bool tablet, Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(web ? 10 : (tablet ? 20 : 10)),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
