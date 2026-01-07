import 'package:flutter/material.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/fonts.dart';

class TextStyles {
  static TextStyle kLightOutfit({
    double fontSize = FontSizes.k20FontSize,
    Color color = kColorBlack,
    FontWeight fontWeight = FontWeight.w300,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontFamily: Fonts.outfitLight,
    );
  }

  static TextStyle kRegularOutfit({
    double fontSize = FontSizes.k20FontSize,
    Color color = kColorBlack,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontFamily: Fonts.outfitRegular,
    );
  }

  static TextStyle kMediumOutfit({
    double fontSize = FontSizes.k20FontSize,
    Color color = kColorBlack,
    FontWeight fontWeight = FontWeight.w500,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontFamily: Fonts.outfitMedium,
    );
  }

  static TextStyle kSemiBoldOutfit({
    double fontSize = FontSizes.k20FontSize,
    Color color = kColorBlack,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontFamily: Fonts.outfitSemiBold,
    );
  }

  static TextStyle kBoldOutfit({
    double fontSize = FontSizes.k20FontSize,
    Color color = kColorBlack,
    FontWeight fontWeight = FontWeight.w700,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontFamily: Fonts.outfitBold,
    );
  }
}
