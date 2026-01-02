import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/user_settings/controllers/user_access_controller.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/extensions/app_size_extensions.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_appbar.dart';
import 'package:shivay_construction/widgets/app_card.dart';
import 'package:shivay_construction/widgets/app_date_picker_text_form_field.dart';
import 'package:shivay_construction/widgets/app_loading_overlay.dart';

// ignore: must_be_immutable
class UserAccessScreen extends StatefulWidget {
  UserAccessScreen({
    super.key,
    required this.fullName,
    required this.userId,
    required this.appAccess,
  });

  final String fullName;
  final int userId;
  bool appAccess;

  @override
  State<UserAccessScreen> createState() => _UserAccessScreenState();
}

class _UserAccessScreenState extends State<UserAccessScreen> {
  final UserAccessController _controller = Get.put(UserAccessController());

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() async {
    await _controller.getUserAccess(userId: widget.userId);
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
              title: widget.fullName,
              leading: IconButton(
                onPressed: () => Get.back(),
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: tablet ? 25 : 20,
                  color: kColorPrimary,
                ),
              ),
            ),
            body: Padding(
              padding: tablet
                  ? AppPaddings.combined(horizontal: 24, vertical: 12)
                  : AppPaddings.p12,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    AppCard(
                      onTap: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'App Access',
                                style: TextStyles.kSemiBoldOutfit(
                                  fontSize: tablet
                                      ? FontSizes.k24FontSize
                                      : FontSizes.k18FontSize,
                                ),
                              ),
                              Text(
                                'Allow user to access app',
                                style: TextStyles.kRegularOutfit(
                                  fontSize: tablet
                                      ? FontSizes.k20FontSize
                                      : FontSizes.k16FontSize,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: widget.appAccess,
                            activeColor: kColorWhite,
                            inactiveThumbColor: kColorWhite,
                            inactiveTrackColor: kColorGrey,
                            activeTrackColor: kColorSecondary,
                            onChanged: (value) async {
                              await _controller.setAppAccess(
                                userId: widget.userId,
                                appAccess: value,
                              );
                              setState(() {
                                widget.appAccess = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    AppSpaces.v10,
                    Visibility(
                      visible: widget.appAccess,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Ledger Start',
                                style: TextStyles.kMediumOutfit(
                                  fontSize: tablet
                                      ? FontSizes.k24FontSize
                                      : FontSizes.k18FontSize,
                                ),
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: tablet
                                        ? 0.3.screenWidth
                                        : 0.45.screenWidth,
                                    child: AppDatePickerTextFormField(
                                      dateController:
                                          _controller.ledgerStartDateController,
                                      hintText: 'Ledger Start',
                                      onChanged: (value) {
                                        _controller.setLedger(
                                          userId: widget.userId,
                                        );
                                      },
                                    ),
                                  ),
                                  tablet ? AppSpaces.h16 : AppSpaces.h10,
                                  InkWell(
                                    onTap: () {
                                      _controller.ledgerStartDateController
                                          .clear();

                                      _controller.setLedger(
                                        userId: widget.userId,
                                      );
                                    },
                                    child: Icon(
                                      Icons.clear,
                                      size: tablet ? 25 : 20,
                                      color: kColorPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          AppSpaces.v10,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Ledger End',
                                style: TextStyles.kMediumOutfit(
                                  fontSize: tablet
                                      ? FontSizes.k24FontSize
                                      : FontSizes.k18FontSize,
                                ),
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: tablet
                                        ? 0.3.screenWidth
                                        : 0.45.screenWidth,
                                    child: AppDatePickerTextFormField(
                                      dateController:
                                          _controller.ledgerEndDateController,
                                      hintText: 'Ledger End',
                                      onChanged: (value) {
                                        _controller.setLedger(
                                          userId: widget.userId,
                                        );
                                      },
                                    ),
                                  ),
                                  tablet ? AppSpaces.h16 : AppSpaces.h10,
                                  InkWell(
                                    onTap: () {
                                      _controller.ledgerEndDateController
                                          .clear();

                                      _controller.setLedger(
                                        userId: widget.userId,
                                      );
                                    },
                                    child: Icon(
                                      Icons.clear,
                                      size: tablet ? 25 : 20,
                                      color: kColorPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    tablet ? AppSpaces.v20 : AppSpaces.v16,
                    Visibility(
                      visible: widget.appAccess,
                      child: Obx(
                        () => ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _controller.menuAccess.length,
                          itemBuilder: (context, index) {
                            final menuAccess = _controller.menuAccess[index];

                            return Column(
                              children: [
                                ListTile(
                                  contentPadding: EdgeInsets.all(0),
                                  leading: Text(
                                    menuAccess.menuName,
                                    style: TextStyles.kMediumOutfit(
                                      fontSize: tablet
                                          ? FontSizes.k24FontSize
                                          : FontSizes.k18FontSize,
                                    ),
                                  ),
                                  trailing: Switch(
                                    value: menuAccess.access,
                                    activeColor: kColorWhite,
                                    inactiveThumbColor: kColorWhite,
                                    inactiveTrackColor: kColorGrey,
                                    activeTrackColor: kColorSecondary,
                                    onChanged: (value) async {
                                      await _controller.setMenuAccess(
                                        userId: widget.userId,
                                        menuId: menuAccess.menuId,
                                        menuAccess: value,
                                      );
                                      setState(() {
                                        menuAccess.access = value;

                                        if (!value) {
                                          for (var subMenu
                                              in menuAccess.subMenu) {
                                            subMenu.subMenuAccess = false;
                                          }
                                        }
                                      });
                                    },
                                  ),
                                ),
                                if (menuAccess.access &&
                                    menuAccess.subMenu.isNotEmpty)
                                  Padding(
                                    padding: AppPaddings.custom(
                                      left: tablet ? 40 : 20,
                                    ),
                                    child: Column(
                                      children: menuAccess.subMenu.map((
                                        subMenu,
                                      ) {
                                        return ListTile(
                                          contentPadding: EdgeInsets.all(0),
                                          leading: Text(
                                            subMenu.subMenuName,
                                            style: TextStyles.kRegularOutfit(
                                              fontSize: tablet
                                                  ? FontSizes.k20FontSize
                                                  : FontSizes.k16FontSize,
                                            ),
                                          ),
                                          trailing: Switch(
                                            value: subMenu.subMenuAccess,
                                            activeColor: kColorWhite,
                                            inactiveThumbColor: kColorWhite,
                                            inactiveTrackColor: kColorGrey,
                                            activeTrackColor: kColorSecondary,
                                            onChanged: menuAccess.access
                                                ? (value) async {
                                                    await _controller
                                                        .setMenuAccess(
                                                          userId: widget.userId,
                                                          menuId:
                                                              menuAccess.menuId,
                                                          subMenuId:
                                                              subMenu.subMenuId,
                                                          menuAccess: value,
                                                        );
                                                    setState(() {
                                                      subMenu.subMenuAccess =
                                                          value;
                                                    });
                                                  }
                                                : null,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
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
