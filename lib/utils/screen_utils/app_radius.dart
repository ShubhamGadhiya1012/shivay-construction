import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';

class AppRadius {
  AppRadius._();

  //* ---------------- Radius values ---------------- */

  static double sm(BuildContext context) {
    if (AppScreenUtils.isWeb) return 4;
    if (AppScreenUtils.isTablet(context)) return 12;
    return 8;
  }

  static double md(BuildContext context) {
    if (AppScreenUtils.isWeb) return 6;
    if (AppScreenUtils.isTablet(context)) return 16;
    return 10;
  }

  static double lg(BuildContext context) {
    if (AppScreenUtils.isWeb) return 8;
    if (AppScreenUtils.isTablet(context)) return 20;
    return 12;
  }

  //* ---------------- Core resolver ---------------- */

  static double _r(
    BuildContext? context,
    double Function(BuildContext) resolver,
  ) {
    final ctx = context ?? Get.context!;
    return resolver(ctx);
  }

  //* ---------------- Circular ---------------- */

  static BorderRadius allSm([BuildContext? context]) =>
      BorderRadius.circular(_r(context, sm));

  static BorderRadius allMd([BuildContext? context]) =>
      BorderRadius.circular(_r(context, md));

  static BorderRadius allLg([BuildContext? context]) =>
      BorderRadius.circular(_r(context, lg));

  //* ---------------- Only ---------------- */

  static BorderRadius onlySm({
    BuildContext? context,
    bool topLeft = false,
    bool topRight = false,
    bool bottomLeft = false,
    bool bottomRight = false,
  }) {
    final r = _r(context, sm);
    return BorderRadius.only(
      topLeft: topLeft ? Radius.circular(r) : Radius.zero,
      topRight: topRight ? Radius.circular(r) : Radius.zero,
      bottomLeft: bottomLeft ? Radius.circular(r) : Radius.zero,
      bottomRight: bottomRight ? Radius.circular(r) : Radius.zero,
    );
  }

  static BorderRadius onlyMd({
    BuildContext? context,
    bool topLeft = false,
    bool topRight = false,
    bool bottomLeft = false,
    bool bottomRight = false,
  }) {
    final r = _r(context, md);
    return BorderRadius.only(
      topLeft: topLeft ? Radius.circular(r) : Radius.zero,
      topRight: topRight ? Radius.circular(r) : Radius.zero,
      bottomLeft: bottomLeft ? Radius.circular(r) : Radius.zero,
      bottomRight: bottomRight ? Radius.circular(r) : Radius.zero,
    );
  }

  static BorderRadius onlyLg({
    BuildContext? context,
    bool topLeft = false,
    bool topRight = false,
    bool bottomLeft = false,
    bool bottomRight = false,
  }) {
    final r = _r(context, lg);
    return BorderRadius.only(
      topLeft: topLeft ? Radius.circular(r) : Radius.zero,
      topRight: topRight ? Radius.circular(r) : Radius.zero,
      bottomLeft: bottomLeft ? Radius.circular(r) : Radius.zero,
      bottomRight: bottomRight ? Radius.circular(r) : Radius.zero,
    );
  }

  //* ---------------- Horizontal / Vertical ---------------- */

  static BorderRadius verticalSm([BuildContext? context]) {
    final r = _r(context, sm);
    return BorderRadius.vertical(
      top: Radius.circular(r),
      bottom: Radius.circular(r),
    );
  }

  static BorderRadius verticalMd([BuildContext? context]) {
    final r = _r(context, md);
    return BorderRadius.vertical(
      top: Radius.circular(r),
      bottom: Radius.circular(r),
    );
  }

  static BorderRadius horizontalSm([BuildContext? context]) {
    final r = _r(context, sm);
    return BorderRadius.horizontal(
      left: Radius.circular(r),
      right: Radius.circular(r),
    );
  }

  static BorderRadius horizontalMd([BuildContext? context]) {
    final r = _r(context, md);
    return BorderRadius.horizontal(
      left: Radius.circular(r),
      right: Radius.circular(r),
    );
  }
}
