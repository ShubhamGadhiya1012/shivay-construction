// ignore_for_file: deprecated_member_use, unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/hsn_master/controllers/hsn_master_list_controller.dart';
import 'package:shivay_construction/features/hsn_master/screens/hsn_master_screen.dart';
import 'package:shivay_construction/features/hsn_master/widgets/hsn_master_card.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_appbar.dart';
import 'package:shivay_construction/widgets/app_loading_overlay.dart';
import 'package:shivay_construction/widgets/app_text_form_field.dart';

class HsnMasterListScreen extends StatefulWidget {
  const HsnMasterListScreen({super.key});

  @override
  State<HsnMasterListScreen> createState() => _HsnMasterListScreenState();
}

class _HsnMasterListScreenState extends State<HsnMasterListScreen> {
  final HsnMasterListController _controller = Get.put(
    HsnMasterListController(),
  );

  void _handleCardTap(int index) async {
    final hsnNo = _controller.filteredHsnList[index].hsnNo;
    await _controller.getHsnDetail(hsnNo: hsnNo);
    _controller.expandedIndex.value = _controller.expandedIndex.value == index
        ? null
        : index;
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
              title: 'HSN Master',
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
                    hintText: 'Search HSN',
                    onChanged: (value) {
                      _controller.filterHsnList(value);
                      setState(() {
                        _controller.expandedIndex.value = null;
                      });
                    },
                  ),
                  tablet ? AppSpaces.v16 : AppSpaces.v12,
                  Obx(() {
                    if (_controller.filteredHsnList.isEmpty &&
                        !_controller.isLoading.value) {
                      return Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: tablet ? 80 : 64,
                                color: kColorLightGrey,
                              ),
                              tablet ? AppSpaces.v20 : AppSpaces.v16,
                              Text(
                                'No HSN Found',
                                style: TextStyles.kMediumOutfit(
                                  fontSize: tablet
                                      ? FontSizes.k24FontSize
                                      : FontSizes.k18FontSize,
                                  color: kColorTextPrimary,
                                ),
                              ),
                              AppSpaces.v8,
                              Text(
                                'Add a new HSN to get started',
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
                          setState(
                            () => _controller.expandedIndex.value = null,
                          );
                          await _controller.getHsnList();
                        },
                        child: ListView.builder(
                          itemCount: _controller.filteredHsnList.length,
                          itemBuilder: (context, index) {
                            final hsn = _controller.filteredHsnList[index];
                            return HsnMasterCard(
                              hsn: hsn,
                              isExpanded:
                                  _controller.expandedIndex.value == index,
                              onTap: () => _handleCardTap(index),
                              hsnDetails: _controller.expandedIndex == index
                                  ? _controller.hsnDetails.toList()
                                  : [],
                              onEdit: () async {
                                await _controller.getHsnDetail(
                                  hsnNo: hsn.hsnNo,
                                );
                                Get.to(
                                  () => HsnMasterScreen(
                                    hsn: hsn,
                                    hsnDetails: _controller.hsnDetails.toList(),
                                  ),
                                );
                              },
                              onDelete: () async {
                                await _controller.deleteHsn(hsn.hsnNo);
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
                  Get.to(() => HsnMasterScreen());
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
