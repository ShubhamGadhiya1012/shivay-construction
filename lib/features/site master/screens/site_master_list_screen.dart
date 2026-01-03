// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/site%20master/controllers/site_master_list_controller.dart';
import 'package:shivay_construction/features/site%20master/screens/site_master_screen.dart';
import 'package:shivay_construction/features/site%20master/widgets/site_master_card.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_appbar.dart';
import 'package:shivay_construction/widgets/app_loading_overlay.dart';
import 'package:shivay_construction/widgets/app_text_form_field.dart';

class SiteMasterListScreen extends StatefulWidget {
  const SiteMasterListScreen({super.key});

  @override
  State<SiteMasterListScreen> createState() => _SiteMasterListScreenState();
}

class _SiteMasterListScreenState extends State<SiteMasterListScreen> {
  final SiteMasterListController _controller = Get.put(
    SiteMasterListController(),
  );

  int? expandedIndex;

  void _handleCardTap(int index) {
    setState(() {
      if (expandedIndex == index) {
        expandedIndex = null;
      } else {
        expandedIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);

    return Stack(
      children: [
        GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            appBar: AppAppbar(
              title: 'Site Master',
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: tablet ? 25 : 20,
                  color: kColorPrimary,
                ),
                onPressed: () => Get.back(),
              ),
            ),
            body: Padding(
              padding: tablet
                  ? AppPaddings.combined(horizontal: 24, vertical: 12)
                  : AppPaddings.p12,
              child: Column(
                children: [
                  AppTextFormField(
                    controller: _controller.searchController,
                    hintText: 'Search Site',
                    onChanged: (value) {
                      _controller.filterSites(value);

                      setState(() {
                        expandedIndex = null;
                      });
                    },
                  ),
                  tablet ? AppSpaces.v16 : AppSpaces.v12,
                  Obx(() {
                    if (_controller.filteredSites.isEmpty &&
                        !_controller.isLoading.value) {
                      return Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_city_outlined,
                                size: tablet ? 80 : 64,
                                color: kColorLightGrey,
                              ),
                              tablet ? AppSpaces.v20 : AppSpaces.v16,
                              Text(
                                'No Sites Found',
                                style: TextStyles.kMediumOutfit(
                                  fontSize: tablet
                                      ? FontSizes.k24FontSize
                                      : FontSizes.k18FontSize,
                                  color: kColorTextPrimary,
                                ),
                              ),
                              AppSpaces.v8,
                              Text(
                                'Add a new site to get started',
                                style: TextStyles.kRegularOutfit(
                                  fontSize: tablet
                                      ? FontSizes.k16FontSize
                                      : FontSizes.k14FontSize,
                                  color: kColorDarkGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Expanded(
                      child: RefreshIndicator(
                        backgroundColor: kColorWhite,
                        color: kColorPrimary,
                        strokeWidth: 2.5,
                        onRefresh: () async {
                          setState(() {
                            expandedIndex = null;
                          });
                          await _controller.getSites();
                        },
                        child: ListView.builder(
                          itemCount: _controller.filteredSites.length,
                          itemBuilder: (context, index) {
                            final site = _controller.filteredSites[index];
                            return SiteMasterCard(
                              site: site,
                              isExpanded: expandedIndex == index,
                              onTap: () => _handleCardTap(index),
                              onEdit: () {
                                Get.to(() => SiteMasterScreen(site: site));
                              },
                            );
                          },
                        ),
                      ),
                    );
                  }),
                ],
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
                  Get.to(() => SiteMasterScreen());
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
