import 'package:flutter/material.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.color,
    this.borderColor,
    this.borderRadius,
    this.elevation,
    this.padding,
    this.margin,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final double? borderRadius;
  final double? elevation;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    final bool web = AppScreenUtils.isWeb;
    final bool tablet = AppScreenUtils.isTablet(context);

    return MouseRegion(
      cursor: web && onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          color: color ?? kColorWhite,
          elevation: elevation ?? (web ? 3 : 5),
          margin:
              margin ??
              (web
                  ? AppPaddings.custom(bottom: 10)
                  : AppPaddings.custom(bottom: tablet ? 16 : 10)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              borderRadius ?? (web ? 10 : (tablet ? 20 : 10)),
            ),
            side: BorderSide(color: borderColor ?? kColorGrey),
          ),
          child: Padding(
            padding:
                padding ??
                (web
                    ? AppPaddings.combined(horizontal: 16, vertical: 12)
                    : tablet
                    ? AppPaddings.combined(horizontal: 20, vertical: 15)
                    : AppPaddings.p12),
            child: child,
          ),
        ),
      ),
    );
  }
}
