// ignore_for_file: deprecated_member_use

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/item_help/controllers/item_help_last_grn_controller.dart';
import 'package:shivay_construction/features/item_help/widgets/item_help_last_grn_card.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/extensions/app_size_extensions.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_appbar.dart';
import 'package:shivay_construction/widgets/app_dropdown.dart';
import 'package:shivay_construction/widgets/app_loading_overlay.dart';
import 'package:shivay_construction/widgets/app_text_form_field.dart';

class ItemHelpLastGrnScreen extends StatefulWidget {
  const ItemHelpLastGrnScreen({super.key, required this.iCode});

  final String iCode;

  @override
  State<ItemHelpLastGrnScreen> createState() => _ItemHelpLastGrnScreenState();
}

class _ItemHelpLastGrnScreenState extends State<ItemHelpLastGrnScreen> {
  final ItemHelpLastGrnController _controller = Get.put(
    ItemHelpLastGrnController(),
  );

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() async {
    await _controller.getLastGrn(iCode: widget.iCode);
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
              title: 'Last GRN',
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () => AppDropdown(
                      items: _controller.partyNames,
                      hintText: 'Party',
                      onChanged: (partyName) {
                        _controller.onPartySelected(partyName, widget.iCode);
                      },
                      selectedItem: _controller.selectedParty.value.isNotEmpty
                          ? _controller.selectedParty.value
                          : null,
                      clearButtonProps: ClearButtonProps(
                        isVisible: _controller.selectedParty.value.isNotEmpty,
                      ),
                    ),
                  ),
                  tablet ? AppSpaces.v16 : AppSpaces.v10,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'LATEST GRN',
                        style: TextStyles.kSemiBoldOutfit(
                          fontSize: tablet
                              ? FontSizes.k18FontSize
                              : FontSizes.k16FontSize,
                          color: kColorTextPrimary,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove, size: tablet ? 24 : 20),
                            onPressed: () =>
                                _controller.decrementCount(widget.iCode),
                          ),
                          SizedBox(
                            width: 0.25.screenWidth,
                            child: AppTextFormField(
                              controller: _controller.countController,
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                _controller.onCountChanged(value, widget.iCode);
                              },
                              hintText: 'Count',
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add, size: tablet ? 24 : 20),
                            onPressed: () =>
                                _controller.incrementCount(widget.iCode),
                          ),
                        ],
                      ),
                    ],
                  ),
                  tablet ? AppSpaces.v16 : AppSpaces.v12,
                  Obx(() {
                    if (_controller.lastGrnList.isEmpty &&
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
                                'No GRN Found',
                                style: TextStyles.kMediumOutfit(
                                  fontSize: tablet
                                      ? FontSizes.k24FontSize
                                      : FontSizes.k18FontSize,
                                  color: kColorTextPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Expanded(
                      child: ListView.builder(
                        itemCount: _controller.lastGrnList.length,
                        itemBuilder: (context, index) {
                          final grn = _controller.lastGrnList[index];
                          return ItemHelpLastGrnCard(grn: grn);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
        Obx(() => AppLoadingOverlay(isLoading: _controller.isLoading.value)),
      ],
    );
  }
}
