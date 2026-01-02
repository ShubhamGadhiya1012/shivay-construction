import 'package:flutter/material.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:lottie/lottie.dart';

class AppLoadingOverlay extends StatelessWidget {
  final bool isLoading;

  const AppLoadingOverlay({super.key, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: kColorBlackWithOpacity,
      child: const Center(child: AppProgressIndicator()),
    );
  }
}

class AppProgressIndicator extends StatelessWidget {
  const AppProgressIndicator({super.key, this.size});

  final double? size;

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);
    final bool web = AppScreenUtils.isWeb;

    final double finalSize =
        size ??
        (web
            ? 150
            : tablet
            ? 250
            : 150);

    return SizedBox(
      width: finalSize,
      height: finalSize,
      child: Lottie.asset(
        'assets/jinee_lottie.json',
        width: finalSize,
        height: finalSize,
        fit: BoxFit.fill,
      ),
    );
  }
}
