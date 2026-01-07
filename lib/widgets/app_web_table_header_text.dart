import 'package:flutter/material.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';

class AppWebTableHeaderText extends StatelessWidget {
  const AppWebTableHeaderText({
    super.key,
    required this.headerText,
    this.textAlign = TextAlign.start,
    this.color = kColorPrimary,
    this.fontSize = FontSizes.k14FontSize,
  });

  final String headerText;
  final TextAlign textAlign;
  final Color color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      headerText,
      textAlign: textAlign,
      style: TextStyles.kSemiBoldOutfit(fontSize: fontSize, color: color),
    );
  }
}
