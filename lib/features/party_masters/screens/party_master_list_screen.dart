// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/party_masters/controllers/party_master_list_controller.dart';
import 'package:shivay_construction/features/party_masters/screens/party_master_screen.dart';
import 'package:shivay_construction/features/party_masters/widgets/party_master_card.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_appbar.dart';
import 'package:shivay_construction/widgets/app_loading_overlay.dart';
import 'package:shivay_construction/widgets/app_text_form_field.dart';

class PartyMasterListScreen extends StatefulWidget {
  const PartyMasterListScreen({super.key});

  @override
  State<PartyMasterListScreen> createState() => _PartyMasterListScreenState();
}

class _PartyMasterListScreenState extends State<PartyMasterListScreen> {
  final PartyMasterListController _controller = Get.put(
    PartyMasterListController(),
  );

  int? expandedIndex;

  void _handleCardTap(int index) {
    setState(() {
      expandedIndex = expandedIndex == index ? null : index;
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
              title: 'Party Master',
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
                  // ── Search ──
                  AppTextFormField(
                    controller: _controller.searchController,
                    hintText: 'Search Party',
                    onChanged: (value) {
                      _controller.filterParties(value);
                      setState(() => expandedIndex = null);
                    },
                  ),
                  tablet ? AppSpaces.v12 : AppSpaces.v10,

                  // ── Filter Chips ──
                  Obx(
                    () => Row(
                      children: [
                        _FilterChip(
                          label: 'All',
                          isSelected:
                              _controller.selectedFilter.value ==
                              PartyFilterType.all,
                          tablet: tablet,
                          onTap: () {
                            setState(() => expandedIndex = null);
                            _controller.onFilterChanged(PartyFilterType.all);
                          },
                        ),
                        AppSpaces.h8,
                        _FilterChip(
                          label: 'Vendor',
                          isSelected:
                              _controller.selectedFilter.value ==
                              PartyFilterType.vendor,
                          tablet: tablet,
                          onTap: () {
                            setState(() => expandedIndex = null);
                            _controller.onFilterChanged(PartyFilterType.vendor);
                          },
                        ),
                        AppSpaces.h8,
                        _FilterChip(
                          label: 'Contractor',
                          isSelected:
                              _controller.selectedFilter.value ==
                              PartyFilterType.contractor,
                          tablet: tablet,
                          onTap: () {
                            setState(() => expandedIndex = null);
                            _controller.onFilterChanged(
                              PartyFilterType.contractor,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  tablet ? AppSpaces.v12 : AppSpaces.v10,

                  // ── List ──
                  Obx(() {
                    if (_controller.filteredParties.isEmpty &&
                        !_controller.isLoading.value) {
                      return Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: tablet ? 80 : 64,
                                color: kColorLightGrey,
                              ),
                              tablet ? AppSpaces.v20 : AppSpaces.v16,
                              Text(
                                'No Parties Found',
                                style: TextStyles.kMediumOutfit(
                                  fontSize: tablet
                                      ? FontSizes.k24FontSize
                                      : FontSizes.k18FontSize,
                                  color: kColorTextPrimary,
                                ),
                              ),
                              AppSpaces.v8,
                              Text(
                                'Add a new party to get started',
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
                          setState(() => expandedIndex = null);
                          await _controller.getParties();
                        },
                        child: ListView.builder(
                          itemCount: _controller.filteredParties.length,
                          itemBuilder: (context, index) {
                            final party = _controller.filteredParties[index];
                            return PartyMasterCard(
                              party: party,
                              isExpanded: expandedIndex == index,
                              onTap: () => _handleCardTap(index),
                              onEdit: () {
                                Get.to(() => PartyMasterScreen(party: party));
                              },
                              onDelete: () async {
                                await _controller.deletePartyMaster(
                                  party.pCode,
                                );
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
                  Get.to(() => PartyMasterScreen());
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.tablet,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool tablet;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: tablet ? 18 : 14,
          vertical: tablet ? 8 : 6,
        ),
        decoration: BoxDecoration(
          color: isSelected ? kColorPrimary : kColorWhite,
          borderRadius: BorderRadius.circular(tablet ? 10 : 8),
          border: Border.all(
            color: isSelected ? kColorPrimary : kColorLightGrey,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: kColorPrimary.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyles.kSemiBoldOutfit(
            fontSize: tablet ? FontSizes.k14FontSize : FontSizes.k12FontSize,
            color: isSelected ? kColorWhite : kColorDarkGrey,
          ),
        ),
      ),
    );
  }
}
