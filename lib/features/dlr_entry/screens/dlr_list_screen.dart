// ignore_for_file: deprecated_member_use

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/dlr_entry/controllers/dlr_list_controller.dart';
import 'package:shivay_construction/features/dlr_entry/screens/dlr_entry_screen.dart';
import 'package:shivay_construction/features/dlr_entry/widgets/dlr_card.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_appbar.dart';
import 'package:shivay_construction/widgets/app_button.dart';
import 'package:shivay_construction/widgets/app_dropdown.dart';
import 'package:shivay_construction/widgets/app_loading_overlay.dart';
import 'package:shivay_construction/widgets/app_text_button.dart';
import 'package:shivay_construction/widgets/app_text_form_field.dart';

class DlrListScreen extends StatefulWidget {
  const DlrListScreen({super.key});

  @override
  State<DlrListScreen> createState() => _DlrListScreenState();
}

class _DlrListScreenState extends State<DlrListScreen> {
  final DlrListController _controller = Get.put(DlrListController());
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
              title: 'DLR Entry',
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: tablet ? 25 : 20,
                  color: kColorPrimary,
                ),
                onPressed: () => Get.back(),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.filter_alt_outlined,
                    size: tablet ? 25 : 20,
                    color: kColorPrimary,
                  ),
                  onPressed: () => _showFilterBottomSheet(context),
                ),
              ],
            ),
            body: Padding(
              padding: tablet
                  ? AppPaddings.combined(horizontal: 24, vertical: 12)
                  : AppPaddings.p12,
              child: Column(
                children: [
                  AppTextFormField(
                    controller: _controller.searchController,
                    hintText: 'Search DLR',
                    onChanged: (value) {
                      _controller.searchQuery.value = value;
                      setState(() {
                        expandedIndex = null;
                      });
                    },
                  ),
                  tablet ? AppSpaces.v16 : AppSpaces.v12,
                  Obx(() {
                    if (_controller.dlrList.isEmpty &&
                        !_controller.isLoading.value) {
                      return Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: tablet ? 80 : 64,
                                color: kColorLightGrey,
                              ),
                              tablet ? AppSpaces.v20 : AppSpaces.v16,
                              Text(
                                'No DLR Entries Found',
                                style: TextStyles.kMediumOutfit(
                                  fontSize: tablet
                                      ? FontSizes.k24FontSize
                                      : FontSizes.k18FontSize,
                                  color: kColorTextPrimary,
                                ),
                              ),
                              AppSpaces.v8,
                              Text(
                                'Add a new DLR entry to get started',
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
                          await _controller.getDlrList();
                        },
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (scrollNotification) {
                            if (scrollNotification is ScrollEndNotification &&
                                scrollNotification.metrics.extentAfter == 0) {
                              _controller.getDlrList(loadMore: true);
                            }
                            return false;
                          },
                          child: ListView.builder(
                            itemCount:
                                _controller.dlrList.length +
                                (_controller.isLoadingMore.value ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index < _controller.dlrList.length) {
                                final dlr = _controller.dlrList[index];
                                return DlrCard(
                                  dlr: dlr,
                                  isExpanded: expandedIndex == index,
                                  onTap: () => _handleCardTap(index),
                                  onEdit: () {
                                    Get.to(() => DlrEntryScreen(dlr: dlr));
                                  },
                                  onDelete: () async {
                                    await _controller.deleteDlr(dlr.invno);
                                  },
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
                          ),
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
                  Get.to(() => DlrEntryScreen());
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

  Future<void> _showFilterBottomSheet(BuildContext context) async {
    final bool tablet = AppScreenUtils.isTablet(context);
    final mediaQuery = MediaQuery.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kColorWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) {
        return Padding(
          padding: mediaQuery.viewInsets,
          child: SizedBox(
            height: mediaQuery.size.height * 0.6,
            child: Stack(
              children: [
                Padding(
                  padding: AppPaddings.custom(bottom: 80),
                  child: SingleChildScrollView(
                    padding: tablet
                        ? AppPaddings.combined(horizontal: 24, vertical: 16)
                        : AppPaddings.p16,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Filter Entries',
                          style: TextStyles.kSemiBoldOutfit(
                            fontSize: tablet
                                ? FontSizes.k20FontSize
                                : FontSizes.k16FontSize,
                          ),
                        ),
                        tablet ? AppSpaces.v16 : AppSpaces.v12,

                        Obx(
                          () => AppDropdown(
                            items: _controller.partyNames,
                            selectedItem:
                                _controller.selectedPartyName.value.isNotEmpty
                                ? _controller.selectedPartyName.value
                                : null,
                            hintText: 'Party',
                            onChanged: _controller.onPartySelected,
                            clearButtonProps: ClearButtonProps(
                              isVisible: _controller
                                  .selectedPartyName
                                  .value
                                  .isNotEmpty,
                            ),
                          ),
                        ),
                        tablet ? AppSpaces.v16 : AppSpaces.v12,

                        Obx(
                          () => AppDropdown(
                            items: _controller.siteNames,
                            selectedItem:
                                _controller.selectedSiteName.value.isNotEmpty
                                ? _controller.selectedSiteName.value
                                : null,
                            hintText: 'Site',
                            onChanged: _controller.onSiteSelected,
                            clearButtonProps: ClearButtonProps(
                              isVisible:
                                  _controller.selectedSiteName.value.isNotEmpty,
                            ),
                          ),
                        ),
                        tablet ? AppSpaces.v12 : AppSpaces.v8,

                        Obx(
                          () => AppDropdown(
                            items: _controller.godownNames,
                            selectedItem:
                                _controller.selectedGodownName.value.isNotEmpty
                                ? _controller.selectedGodownName.value
                                : null,
                            hintText: 'Godown',
                            onChanged: _controller.onGodownSelected,
                            clearButtonProps: ClearButtonProps(
                              isVisible: _controller
                                  .selectedGodownName
                                  .value
                                  .isNotEmpty,
                            ),
                          ),
                        ),
                        tablet ? AppSpaces.v16 : AppSpaces.v12,
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Row(
                    children: [
                      Expanded(
                        child: AppTextButton(
                          title: 'Clear',
                          color: kColorPrimary,
                          onPressed: () {
                            _controller.clearFilters();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          title: 'Apply Filter',
                          onPressed: () {
                            _controller.getDlrList();
                            Get.back();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
