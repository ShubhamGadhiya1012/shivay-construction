// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/tax_master/controllers/tax_master_list_controller.dart';
import 'package:shivay_construction/features/tax_master/screens/tax_master_screen.dart';
import 'package:shivay_construction/features/tax_master/widgets/tax_master_card.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_appbar.dart';
import 'package:shivay_construction/widgets/app_loading_overlay.dart';
import 'package:shivay_construction/widgets/app_text_form_field.dart';

class TaxMasterListScreen extends StatefulWidget {
  const TaxMasterListScreen({super.key});

  @override
  State<TaxMasterListScreen> createState() => _TaxMasterListScreenState();
}

class _TaxMasterListScreenState extends State<TaxMasterListScreen> {
  final TaxMasterListController _controller = Get.put(
    TaxMasterListController(),
  );

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);

    return Stack(
      children: [
        GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            appBar: AppAppbar(
              title: 'Tax Master',
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
                    hintText: 'Search Tax',
                    onChanged: (value) {
                      _controller.filterTaxList(value);
                    },
                  ),
                  tablet ? AppSpaces.v16 : AppSpaces.v12,
                  Obx(() {
                    if (_controller.filteredTaxList.isEmpty &&
                        !_controller.isLoading.value) {
                      return Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.percent_rounded,
                                size: tablet ? 80 : 64,
                                color: kColorLightGrey,
                              ),
                              tablet ? AppSpaces.v20 : AppSpaces.v16,
                              Text(
                                'No Tax Found',
                                style: TextStyles.kMediumOutfit(
                                  fontSize: tablet
                                      ? FontSizes.k24FontSize
                                      : FontSizes.k18FontSize,
                                  color: kColorTextPrimary,
                                ),
                              ),
                              AppSpaces.v8,
                              Text(
                                'Add a new tax to get started',
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
                          await _controller.getTaxList();
                        },
                        child: ListView.builder(
                          itemCount: _controller.filteredTaxList.length,
                          itemBuilder: (context, index) {
                            final tax = _controller.filteredTaxList[index];
                            return TaxMasterCard(
                              tax: tax,
                              onEdit: () {
                                Get.to(() => TaxMasterScreen(tax: tax));
                              },
                              onDelete: () async {
                                await _controller.deleteTax(tax.tCode);
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
                  Get.to(() => TaxMasterScreen());
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
