// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';

class AppWebTableHeaderRow extends StatelessWidget {
  const AppWebTableHeaderRow({
    super.key,
    required this.isNarrow,
    required this.narrowHeader,
    required this.fullHeader,
    this.minHeight = 42,
  });

  final bool isNarrow;
  final Widget narrowHeader;
  final Widget fullHeader;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: minHeight),
      decoration: BoxDecoration(
        color: kColorPrimary.withOpacity(0.125),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Padding(
        padding: AppPaddings.combined(horizontal: 12, vertical: 8),
        child: isNarrow ? narrowHeader : fullHeader,
      ),
    );
  }
}
