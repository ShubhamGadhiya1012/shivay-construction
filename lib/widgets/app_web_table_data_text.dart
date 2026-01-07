import 'package:flutter/material.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';

class AppWebTableDataText extends StatelessWidget {
  const AppWebTableDataText({
    super.key,
    required this.dataText,
    this.color,
    this.isBold = false,
    this.underline = false,
    this.maxLines = 5,
    this.textAlign = TextAlign.start,
  });

  final String dataText;
  final Color? color;
  final bool isBold;
  final bool underline;
  final int maxLines;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final baseStyle = isBold
        ? TextStyles.kSemiBoldOutfit(
            fontSize: FontSizes.k12FontSize,
            color: color ?? kColorPrimary,
          )
        : TextStyles.kMediumOutfit(
            fontSize: FontSizes.k12FontSize,
            color: color ?? kColorPrimary,
          );

    return Text(
      dataText,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: baseStyle.copyWith(
        decoration: underline ? TextDecoration.underline : null,
      ),
    );
  }
}
