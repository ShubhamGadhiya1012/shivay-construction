// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/item_help/controllers/item_help_items_controller.dart';
import 'package:shivay_construction/features/item_help/widgets/item_help_item_card.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_appbar.dart';
import 'package:shivay_construction/widgets/app_loading_overlay.dart';

class ItemHelpItemsScreen extends StatefulWidget {
  const ItemHelpItemsScreen({
    super.key,
    required this.cCode,
    required this.igCode,
    required this.icCode,
    required this.iCode,
  });

  final String cCode;
  final String igCode;
  final String icCode;
  final String iCode;

  @override
  State<ItemHelpItemsScreen> createState() => _ItemHelpItemsScreenState();
}

class _ItemHelpItemsScreenState extends State<ItemHelpItemsScreen> {
  final ItemHelpItemsController _controller = Get.put(
    ItemHelpItemsController(),
  );

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() async {
    await _controller.getItems(
      cCode: widget.cCode,
      igCode: widget.igCode,
      icCode: widget.icCode,
      iCode: widget.iCode,
    );
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
              title: 'Items',
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
                  Obx(() {
                    if (_controller.items.isEmpty &&
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
                                'No Items Found',
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
                        itemCount: _controller.items.length,
                        itemBuilder: (context, index) {
                          final item = _controller.items[index];
                          return ItemHelpItemCard(item: item);
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
