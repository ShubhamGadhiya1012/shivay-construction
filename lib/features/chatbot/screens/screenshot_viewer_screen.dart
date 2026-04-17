// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';

class ScreenshotViewerScreen extends StatefulWidget {
  final List<String> screenshots;
  final int initialIndex;

  const ScreenshotViewerScreen({
    super.key,
    required this.screenshots,
    this.initialIndex = 0,
  });

  @override
  State<ScreenshotViewerScreen> createState() => _ScreenshotViewerScreenState();
}

class _ScreenshotViewerScreenState extends State<ScreenshotViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios, size: tablet ? 25 : 20),
        ),
        title: Text(
          'Screenshot ${_currentIndex + 1} of ${widget.screenshots.length}',
          style: TextStyles.kMediumOutfit(
            color: Colors.white,
            fontSize: tablet ? FontSizes.k18FontSize : FontSizes.k16FontSize,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.close, size: tablet ? 26 : 24),
            onPressed: () => Get.back(),
            tooltip: 'Close',
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.screenshots.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return Center(
            child: Image.network(
              widget.screenshots[index],
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                    color: kColorPrimary,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error,
                        color: Colors.red,
                        size: tablet ? 60 : 48,
                      ),
                      tablet ? AppSpaces.v20 : AppSpaces.v16,
                      Text(
                        'Failed to load image',
                        style: TextStyles.kMediumOutfit(
                          color: Colors.white,
                          fontSize: tablet
                              ? FontSizes.k16FontSize
                              : FontSizes.k14FontSize,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: widget.screenshots.length > 1
          ? Container(
              color: Colors.black87,
              padding: tablet
                  ? AppPaddings.combined(vertical: 20, horizontal: 24)
                  : AppPaddings.combined(vertical: 16, horizontal: 20),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: tablet ? 28 : 24,
                      ),
                      onPressed: _currentIndex > 0
                          ? () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          : null,
                      tooltip: 'Previous',
                    ),
                    Container(
                      padding: tablet
                          ? AppPaddings.combined(horizontal: 20, vertical: 10)
                          : AppPaddings.combined(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: kColorPrimary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(tablet ? 24 : 20),
                        border: Border.all(
                          color: kColorPrimary.withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        '${_currentIndex + 1} / ${widget.screenshots.length}',
                        style: TextStyles.kBoldOutfit(
                          color: Colors.white,
                          fontSize: tablet
                              ? FontSizes.k18FontSize
                              : FontSizes.k16FontSize,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: tablet ? 28 : 24,
                      ),
                      onPressed: _currentIndex < widget.screenshots.length - 1
                          ? () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          : null,
                      tooltip: 'Next',
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
