// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/indent_entry/controllers/indents_controller.dart';
import 'package:shivay_construction/features/indent_entry/screens/indent_entry_screen.dart';
import 'package:shivay_construction/features/indent_entry/widgets/indent_card.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_appbar.dart';
import 'package:shivay_construction/widgets/app_loading_overlay.dart';
import 'package:shivay_construction/widgets/app_text_form_field.dart';

class IndentsScreen extends StatefulWidget {
  const IndentsScreen({super.key});

  @override
  State<IndentsScreen> createState() => _IndentsScreenState();
}

class _IndentsScreenState extends State<IndentsScreen> {
  final IndentsController _controller = Get.put(IndentsController());
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
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            appBar: AppAppbar(
              title: 'Indents',
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
                await _controller.getIndents();
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
                      hintText: 'Search Indent',
                      onChanged: (query) {
                        _controller.searchQuery.value = query;

                        setState(() {
                          expandedIndex = null; // Reset expansion on search
                        });
                      },
                    ),
                    tablet ? AppSpaces.v12 : AppSpaces.v8,
                    Obx(() {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _controller.filters.keys.map((key) {
                            final isSelected =
                                _controller.selectedFilter.value ==
                                _controller.filters[key];
                            return Padding(
                              padding: AppPaddings.custom(right: 8),
                              child: ChoiceChip(
                                label: Text(
                                  key,
                                  style: TextStyles.kMediumOutfit(
                                    fontSize: tablet
                                        ? FontSizes.k14FontSize
                                        : FontSizes.k12FontSize,
                                    color: isSelected
                                        ? kColorWhite
                                        : kColorTextPrimary,
                                  ).copyWith(height: 1),
                                ),
                                selected: isSelected,
                                onSelected: (_) =>
                                    _controller.onFilterSelected(key),
                                selectedColor: kColorPrimary,
                                showCheckmark: false,
                                backgroundColor: kColorWhite,
                                side: BorderSide(
                                  color: isSelected
                                      ? kColorPrimary
                                      : kColorLightGrey,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }),
                    tablet ? AppSpaces.v16 : AppSpaces.v12,
                    Obx(() {
                      if (_controller.indents.isEmpty &&
                          !_controller.isLoading.value) {
                        return Expanded(
                          child: Center(
                            child: Text(
                              'No indents found.',
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
                              _controller.getIndents(loadMore: true);
                            }
                            return false;
                          },
                          child: Obx(() {
                            return ListView.builder(
                              itemCount:
                                  _controller.indents.length +
                                  (_controller.isLoadingMore.value ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index < _controller.indents.length) {
                                  final indent = _controller.indents[index];
                                  return IndentCard(
                                    indent: indent,
                                    controller: _controller,
                                    isExpanded: expandedIndex == index,
                                    onTap: () => _handleCardTap(index),
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
                  Get.to(() => const IndentEntryScreen(isEdit: false));
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
