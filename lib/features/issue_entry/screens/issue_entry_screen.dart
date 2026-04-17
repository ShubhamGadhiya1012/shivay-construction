// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/issue_entry/controllers/issue_entry_controller.dart';
import 'package:shivay_construction/features/issue_entry/models/grn_item_dm.dart';
import 'package:shivay_construction/features/issue_entry/widgets/grn_item_card.dart';
import 'package:shivay_construction/features/issue_entry/widgets/issue_selected_item_card.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/extensions/app_size_extensions.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_appbar.dart';
import 'package:shivay_construction/widgets/app_button.dart';
import 'package:shivay_construction/widgets/app_date_picker_text_form_field.dart';
import 'package:shivay_construction/widgets/app_loading_overlay.dart';
import 'package:shivay_construction/widgets/app_text_form_field.dart';

class IssueEntryScreen extends StatefulWidget {
  const IssueEntryScreen({super.key});

  @override
  State<IssueEntryScreen> createState() => _IssueEntryScreenState();
}

class _IssueEntryScreenState extends State<IssueEntryScreen> {
  final IssueEntryController _controller = Get.put(IssueEntryController());

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() async {
    super.initState();
    _controller.dateController.text = DateFormat(
      'dd-MM-yyyy',
    ).format(DateTime.now());
    await _controller.getGrnItems();
    await _controller.getGodowns();
  }

  void _handleBackPress() {
    if (_controller.currentStep.value == 1) {
      _controller.goBackToSelection();
    } else {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _handleBackPress();
      },
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Scaffold(
              appBar: AppAppbar(
                title: 'Add Issue',
                leading: IconButton(
                  onPressed: _handleBackPress,
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size: tablet ? 25 : 20,
                    color: kColorPrimary,
                  ),
                ),
              ),
              body: Obx(() {
                if (_controller.currentStep.value == 0) {
                  return _buildStepZero(tablet);
                }
                return _buildStepOne(tablet);
              }),
            ),
          ),
          Obx(() => AppLoadingOverlay(isLoading: _controller.isLoading.value)),
        ],
      ),
    );
  }

  Widget _buildStepZero(bool tablet) {
    return Padding(
      padding: tablet
          ? AppPaddings.combined(horizontal: 24, vertical: 12)
          : AppPaddings.p12,
      child: Column(
        children: [
          // Selection mode banner
          Obx(() {
            if (_controller.isInSelectionMode.value) {
              return Container(
                padding: tablet ? AppPaddings.p12 : AppPaddings.p10,
                decoration: BoxDecoration(
                  color: kColorPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selection Mode',
                          style: TextStyles.kSemiBoldOutfit(
                            fontSize: tablet
                                ? FontSizes.k16FontSize
                                : FontSizes.k14FontSize,
                            color: kColorPrimary,
                          ),
                        ),
                        Obx(() {
                          if (_controller.lockedGrnInvNo.value.isNotEmpty) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'GRN: ${_controller.lockedGrnInvNo.value}',
                                  style: TextStyles.kRegularOutfit(
                                    fontSize: tablet
                                        ? FontSizes.k12FontSize
                                        : FontSizes.k10FontSize,
                                    color: kColorDarkGrey,
                                  ),
                                ),
                                Text(
                                  'Party: ${_controller.lockedGrnPName.value}',
                                  style: TextStyles.kRegularOutfit(
                                    fontSize: tablet
                                        ? FontSizes.k12FontSize
                                        : FontSizes.k10FontSize,
                                    color: kColorDarkGrey,
                                  ),
                                ),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        }),
                      ],
                    ),
                    TextButton(
                      onPressed: () => _controller.deselectAllItems(),
                      child: Text(
                        'Deselect All',
                        style: TextStyles.kMediumOutfit(
                          fontSize: tablet
                              ? FontSizes.k14FontSize
                              : FontSizes.k12FontSize,
                          color: kColorRed,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // Info hint
          Obx(() {
            if (!_controller.isInSelectionMode.value &&
                _controller.grnItems.isNotEmpty) {
              return Container(
                margin: tablet
                    ? AppPaddings.custom(top: 12, bottom: 4)
                    : AppPaddings.custom(top: 10, bottom: 4),
                padding: tablet
                    ? AppPaddings.combined(horizontal: 14, vertical: 10)
                    : AppPaddings.combined(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      kColorPrimary.withOpacity(0.08),
                      kColorPrimary.withOpacity(0.03),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kColorPrimary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: tablet ? AppPaddings.p8 : AppPaddings.p6,
                      decoration: const BoxDecoration(
                        color: kColorPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.info_outline,
                        color: kColorWhite,
                        size: tablet ? 18 : 16,
                      ),
                    ),
                    tablet ? AppSpaces.h12 : AppSpaces.h10,
                    Expanded(
                      child: Text(
                        'Long press on an item to start selection. Only items from the same GRN can be selected.',
                        style: TextStyles.kMediumOutfit(
                          fontSize: tablet
                              ? FontSizes.k14FontSize
                              : FontSizes.k12FontSize,
                          color: kColorTextPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          tablet ? AppSpaces.v12 : AppSpaces.v10,

          Expanded(
            child: Obx(() {
              if (_controller.grnItems.isEmpty &&
                  !_controller.isLoading.value) {
                return Center(
                  child: Text(
                    'No GRN items available',
                    style: TextStyles.kMediumOutfit(
                      fontSize: tablet
                          ? FontSizes.k18FontSize
                          : FontSizes.k16FontSize,
                    ),
                  ),
                );
              }
              return ListView.builder(
                itemCount: _controller.grnItems.length,
                itemBuilder: (context, index) {
                  final grn = _controller.grnItems[index];
                  return Obx(() {
                    return _GrnCardForIssue(
                      grn: grn,
                      grnIndex: index,
                      isExpanded: _controller.expandedGrnIndices.contains(
                        index,
                      ),
                      controller: _controller,
                    );
                  });
                },
              );
            }),
          ),

          Obx(() {
            if (_controller.selectedItems.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              children: [
                AppButton(
                  title:
                      'Proceed (${_controller.selectedItems.length} selected)',
                  buttonHeight: tablet ? 54 : 48,
                  onPressed: () => _controller.proceedToForm(),
                ),
                tablet ? AppSpaces.v10 : AppSpaces.v8,
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStepOne(bool tablet) {
    return Padding(
      padding: tablet
          ? AppPaddings.combined(horizontal: 24, vertical: 12)
          : AppPaddings.p12,
      child: Form(
        key: _controller.issueFormKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    AppSpaces.v10,
                    AppDatePickerTextFormField(
                      dateController: _controller.dateController,
                      hintText: 'Date *',
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please select date'
                          : null,
                    ),
                    tablet ? AppSpaces.v16 : AppSpaces.v10,

                    // Locked site display
                    Obx(() {
                      return Container(
                        padding: tablet
                            ? AppPaddings.combined(horizontal: 12, vertical: 12)
                            : AppPaddings.combined(horizontal: 8, vertical: 8),
                        decoration: BoxDecoration(
                          color: kColorPrimary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: kColorPrimary.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: kColorPrimary,
                              size: tablet ? 20 : 18,
                            ),
                            AppSpaces.h8,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Site',
                                    style: TextStyles.kRegularOutfit(
                                      fontSize: tablet
                                          ? FontSizes.k12FontSize
                                          : FontSizes.k10FontSize,
                                      color: kColorDarkGrey,
                                    ),
                                  ),
                                  Text(
                                    _controller
                                            .lockedGrnSiteName
                                            .value
                                            .isNotEmpty
                                        ? _controller.lockedGrnSiteName.value
                                        : '—',
                                    style: TextStyles.kMediumOutfit(
                                      fontSize: tablet
                                          ? FontSizes.k14FontSize
                                          : FontSizes.k12FontSize,
                                      color: kColorTextPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.lock_outline,
                              color: kColorDarkGrey,
                              size: tablet ? 16 : 14,
                            ),
                          ],
                        ),
                      );
                    }),
                    tablet ? AppSpaces.v16 : AppSpaces.v10,

                    // Locked party display
                    Obx(() {
                      return Container(
                        padding: tablet
                            ? AppPaddings.combined(horizontal: 12, vertical: 12)
                            : AppPaddings.combined(horizontal: 8, vertical: 8),
                        decoration: BoxDecoration(
                          color: kColorPrimary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: kColorPrimary.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              color: kColorPrimary,
                              size: tablet ? 20 : 18,
                            ),
                            AppSpaces.h8,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Party',
                                    style: TextStyles.kRegularOutfit(
                                      fontSize: tablet
                                          ? FontSizes.k12FontSize
                                          : FontSizes.k10FontSize,
                                      color: kColorDarkGrey,
                                    ),
                                  ),
                                  Text(
                                    _controller.lockedGrnPName.value.isNotEmpty
                                        ? _controller.lockedGrnPName.value
                                        : '—',
                                    style: TextStyles.kMediumOutfit(
                                      fontSize: tablet
                                          ? FontSizes.k14FontSize
                                          : FontSizes.k12FontSize,
                                      color: kColorTextPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.lock_outline,
                              color: kColorDarkGrey,
                              size: tablet ? 16 : 14,
                            ),
                          ],
                        ),
                      );
                    }),
                    tablet ? AppSpaces.v16 : AppSpaces.v10,

                    AppTextFormField(
                      controller: _controller.remarkController,
                      hintText: 'Remark (Optional)',
                      maxLines: 3,
                    ),

                    tablet ? AppSpaces.v20 : AppSpaces.v14,

                    Obx(
                      () => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Selected Items (${_controller.selectedItems.length})',
                            style: TextStyles.kMediumOutfit(
                              fontSize: tablet
                                  ? FontSizes.k16FontSize
                                  : FontSizes.k14FontSize,
                              color: kColorTextPrimary,
                            ),
                          ),
                          AppButton(
                            buttonWidth: tablet
                                ? 0.35.screenWidth
                                : 0.42.screenWidth,
                            buttonHeight: tablet ? 40 : 35,
                            buttonColor: kColorPrimary,
                            title: '+ Add / Edit',
                            titleSize: tablet
                                ? FontSizes.k14FontSize
                                : FontSizes.k12FontSize,
                            onPressed: () => _controller.goBackToSelection(),
                          ),
                        ],
                      ),
                    ),
                    tablet ? AppSpaces.v10 : AppSpaces.v6,

                    Obx(() {
                      if (_controller.selectedItems.isNotEmpty) {
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _controller.selectedItems.length,
                          itemBuilder: (context, index) {
                            final entry = _controller.selectedItems.entries
                                .elementAt(index);
                            final key = entry.key;
                            final itemData = entry.value;
                            return Padding(
                              padding: AppPaddings.custom(bottom: 8),
                              child: IssueSelectedItemCard(
                                itemData: itemData,
                                onRemove: () =>
                                    _controller.removeSelectedItem(key),
                              ),
                            );
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),
              ),
            ),

            Obx(() {
              if (_controller.selectedItems.isNotEmpty) {
                return Column(
                  children: [
                    AppButton(
                      title: 'Save',
                      buttonHeight: tablet ? 54 : 48,
                      onPressed: () => _controller.saveIssueEntry(),
                    ),
                    tablet ? AppSpaces.v20 : AppSpaces.v10,
                  ],
                );
              }
              return AppSpaces.shrink;
            }),
          ],
        ),
      ),
    );
  }
}

class _GrnCardForIssue extends StatelessWidget {
  const _GrnCardForIssue({
    required this.grn,
    required this.grnIndex,
    required this.isExpanded,
    required this.controller,
  });

  final GrnItemForIssueDm grn;
  final int grnIndex;
  final bool isExpanded;
  final IssueEntryController controller;

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);

    return Container(
      margin: tablet
          ? AppPaddings.custom(bottom: 12)
          : AppPaddings.custom(bottom: 10),
      decoration: BoxDecoration(
        color: kColorWhite,
        borderRadius: BorderRadius.circular(tablet ? 14 : 12),
        border: Border.all(color: kColorLightGrey.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: kColorPrimary.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.toggleGrnExpansion(grnIndex),
          borderRadius: BorderRadius.circular(tablet ? 14 : 12),
          child: Padding(
            padding: tablet
                ? AppPaddings.combined(horizontal: 18, vertical: 16)
                : AppPaddings.combined(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            grn.grnInvNo,
                            style: TextStyles.kBoldOutfit(
                              fontSize: tablet
                                  ? FontSizes.k18FontSize
                                  : FontSizes.k16FontSize,
                              color: kColorPrimary,
                            ),
                          ),
                          AppSpaces.v4,
                          Text(
                            'Date: ${grn.grnDate}',
                            style: TextStyles.kRegularOutfit(
                              fontSize: tablet
                                  ? FontSizes.k12FontSize
                                  : FontSizes.k10FontSize,
                              color: kColorDarkGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: tablet ? 28 : 24,
                        color: kColorPrimary,
                      ),
                    ),
                  ],
                ),
                AppSpaces.v6,
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Party: ${grn.pName}',
                        style: TextStyles.kRegularOutfit(
                          fontSize: tablet
                              ? FontSizes.k14FontSize
                              : FontSizes.k12FontSize,
                          color: kColorDarkGrey,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Site: ${grn.siteName}',
                        style: TextStyles.kRegularOutfit(
                          fontSize: tablet
                              ? FontSizes.k14FontSize
                              : FontSizes.k12FontSize,
                          color: kColorDarkGrey,
                        ),
                      ),
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      tablet ? AppSpaces.v16 : AppSpaces.v12,
                      Divider(
                        height: 1,
                        color: kColorLightGrey.withOpacity(0.5),
                      ),
                      tablet ? AppSpaces.v12 : AppSpaces.v8,
                      Text(
                        'Items (${grn.items.length})',
                        style: TextStyles.kSemiBoldOutfit(
                          fontSize: tablet
                              ? FontSizes.k16FontSize
                              : FontSizes.k14FontSize,
                          color: kColorTextPrimary,
                        ),
                      ),
                      tablet ? AppSpaces.v10 : AppSpaces.v8,
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: grn.items.length,
                        itemBuilder: (context, itemIndex) {
                          final item = grn.items[itemIndex];
                          return Padding(
                            padding: AppPaddings.custom(bottom: 8),
                            child: GrnItemCardForIssue(
                              grn: grn,
                              item: item,
                              controller: controller,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
