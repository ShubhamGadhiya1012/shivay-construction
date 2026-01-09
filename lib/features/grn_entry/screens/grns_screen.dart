// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/grn_entry/controllers/grns_controller.dart';
import 'package:shivay_construction/features/grn_entry/screens/grn_entry_screen.dart';
import 'package:shivay_construction/features/grn_entry/widgets/grn_card.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_appbar.dart';
import 'package:shivay_construction/widgets/app_loading_overlay.dart';
import 'package:shivay_construction/widgets/app_text_form_field.dart';

class GrnsScreen extends StatelessWidget {
  GrnsScreen({super.key});

  final GrnsController _controller = Get.put(GrnsController());

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            appBar: AppAppbar(
              title: 'GRN Entries',
              leading: IconButton(
                onPressed: () => Get.back(),
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: tablet ? 25 : 20,
                  color: kColorPrimary,
                ),
              ),
            ),
            body: RefreshIndicator(
              elevation: 0,
              backgroundColor: kColorWhite,
              color: kColorPrimary,
              onRefresh: () async {
                await _controller.getGrns();
              },
              child: Padding(
                padding: tablet
                    ? AppPaddings.combined(horizontal: 24, vertical: 12)
                    : AppPaddings.p12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextFormField(
                      controller: _controller.searchController,
                      hintText: 'Search GRN',
                      onChanged: (query) {
                        _controller.searchQuery.value = query;
                      },
                    ),
                    tablet ? AppSpaces.v16 : AppSpaces.v12,
                    Obx(() {
                      if (_controller.grns.isEmpty &&
                          !_controller.isLoading.value) {
                        return Expanded(
                          child: Center(
                            child: Text(
                              'No GRN entries found.',
                              style: TextStyles.kMediumOutfit(
                                fontSize: tablet
                                    ? FontSizes.k26FontSize
                                    : FontSizes.k20FontSize,
                              ),
                            ),
                          ),
                        );
                      }
                      return Expanded(
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (scrollNotification) {
                            if (scrollNotification is ScrollEndNotification &&
                                scrollNotification.metrics.extentAfter == 0) {
                              _controller.getGrns(loadMore: true);
                            }
                            return false;
                          },
                          child: Obx(() {
                            return ListView.builder(
                              itemCount:
                                  _controller.grns.length +
                                  (_controller.isLoadingMore.value ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index < _controller.grns.length) {
                                  final grn = _controller.grns[index];
                                  return GrnCard(
                                    grn: grn,
                                    controller: _controller,
                                  );
                                } else {
                                  return Padding(
                                    padding: tablet
                                        ? AppPaddings.pv12
                                        : AppPaddings.pv8,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: kColorPrimary,
                                      ),
                                    ),
                                  );
                                }
                              },
                            );
                          }),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(tablet ? 16 : 12),
                boxShadow: [
                  BoxShadow(
                    color: kColorPrimary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: () {
                  Get.to(() => const GrnEntryScreen(isEdit: false));
                },
                backgroundColor: kColorPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(tablet ? 16 : 12),
                ),
                icon: Icon(
                  Icons.add,
                  color: kColorWhite,
                  size: tablet ? 24 : 20,
                ),
                label: Text(
                  'Add New',
                  style: TextStyles.kSemiBoldOutfit(
                    fontSize: tablet
                        ? FontSizes.k16FontSize
                        : FontSizes.k14FontSize,
                    color: kColorWhite,
                  ),
                ),
              ),
            ),
          ),
        ),
        Obx(() => AppLoadingOverlay(isLoading: _controller.isLoading.value)),
      ],
    );
  }
}
