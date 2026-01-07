// import 'package:dropdown_search/dropdown_search.dart';
// import 'package:flutter/material.dart';
// import 'package:shivay_construction/constants/color_constants.dart';
// import 'package:shivay_construction/styles/font_sizes.dart';
// import 'package:shivay_construction/styles/text_styles.dart';
// import 'package:shivay_construction/utils/extensions/app_size_extensions.dart';
// import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
// import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';

// class AppDropdown extends StatelessWidget {
//   const AppDropdown({
//     super.key,
//     required this.items,
//     required this.hintText,
//     required this.onChanged,
//     this.selectedItem,
//     this.searchHintText,
//     this.fillColor,
//     this.showSearchBox,
//     this.validatorText,
//     this.enabled,
//     this.clearButtonProps,
//     this.floatingLabelRequired,
//   });

//   final List<String> items;
//   final String? selectedItem;
//   final String hintText;
//   final String? searchHintText;
//   final bool? showSearchBox;
//   final Color? fillColor;
//   final String? validatorText;
//   final bool? enabled;
//   final ClearButtonProps? clearButtonProps;
//   final ValueChanged<String?>? onChanged;
//   final bool? floatingLabelRequired;

//   @override
//   Widget build(BuildContext context) {
//     final bool web = AppScreenUtils.isWeb;
//     final bool tablet = AppScreenUtils.isTablet(context);

//     return DropdownSearch<String>(
//       enabled: enabled ?? true,
//       selectedItem: selectedItem,
//       items: (f, p) => items,
//       onChanged: onChanged,

//       validator: (value) {
//         if (value == null || value.isEmpty) return validatorText;
//         return null;
//       },

//       suffixProps: DropdownSuffixProps(
//         clearButtonProps:
//             clearButtonProps ?? const ClearButtonProps(isVisible: false),
//       ),

//       decoratorProps: DropDownDecoratorProps(
//         baseStyle: TextStyles.kRegularOutfit(
//           fontSize: _font(web, tablet),
//           color: kColorBlack,
//         ),

//         decoration: InputDecoration(
//           labelText: hintText,
//           hintText: hintText,

//           hintStyle: TextStyles.kRegularOutfit(
//             fontSize: _font(web, tablet),
//             color: kColorDarkGrey,
//           ),

//           labelStyle: TextStyles.kRegularOutfit(
//             fontSize: _font(web, tablet),
//             color: kColorDarkGrey,
//           ),

//           floatingLabelBehavior: (floatingLabelRequired ?? true)
//               ? FloatingLabelBehavior.auto
//               : FloatingLabelBehavior.never,

//           floatingLabelStyle: TextStyles.kMediumOutfit(
//             fontSize: _floatingFont(web, tablet),
//             color: kColorBlack,
//           ),

//           errorStyle: TextStyles.kRegularOutfit(
//             fontSize: _errorFont(web, tablet),
//             color: kColorRed,
//           ),

//           border: _border(web, tablet, kColorDarkGrey, 1),
//           enabledBorder: _border(web, tablet, kColorDarkGrey, 1),
//           disabledBorder: _border(web, tablet, kColorDarkGrey, 1),
//           focusedBorder: _border(web, tablet, kColorBlack, web ? 1.5 : 1),
//           errorBorder: _border(web, tablet, kColorRed, 1),
//           focusedErrorBorder: _border(web, tablet, kColorRed, web ? 1.5 : 1),

//           contentPadding: _padding(web, tablet),
//           filled: true,
//           fillColor: fillColor ?? kColorWhite,
//         ),
//       ),

//       // Add dropdownBuilder to control selected item display
//       dropdownBuilder: (context, selectedItem) {
//         return Text(
//           selectedItem ?? '',
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//           style: TextStyles.kRegularOutfit(
//             fontSize: _font(web, tablet),
//             color: kColorBlack,
//           ),
//         );
//       },

//       popupProps: PopupProps.menu(
//         fit: FlexFit.loose,
//         constraints: BoxConstraints(
//           maxHeight: web
//               ? 300
//               : tablet
//               ? 450
//               : 300,
//         ),

//         menuProps: MenuProps(
//           backgroundColor: kColorWhite,
//           borderRadius: BorderRadius.circular(
//             web
//                 ? 10
//                 : tablet
//                 ? 20
//                 : 10,
//           ),
//         ),

//         itemBuilder: (context, item, disabled, selected) => Padding(
//           padding: AppPaddings.p10,
//           child: Text(
//             item,
//             style: TextStyles.kRegularOutfit(
//               fontSize: _font(web, tablet),
//               color: kColorBlack,
//             ),
//           ),
//         ),

//         showSearchBox: showSearchBox ?? true,

//         searchFieldProps: TextFieldProps(
//           cursorColor: kColorBlack,
//           cursorHeight: web ? 22 : (tablet ? 26 : 20),

//           style: TextStyles.kRegularOutfit(
//             fontSize: _font(web, tablet),
//             color: kColorBlack,
//           ),

//           decoration: InputDecoration(
//             hintText: searchHintText ?? "Search",

//             hintStyle: TextStyles.kRegularOutfit(
//               fontSize: _font(web, tablet),
//               color: kColorDarkGrey,
//             ),

//             border: _border(web, tablet, kColorDarkGrey, 1),
//             enabledBorder: _border(web, tablet, kColorDarkGrey, 1),
//             focusedBorder: _border(web, tablet, kColorBlack, 1),
//             errorBorder: _border(web, tablet, kColorRed, 1),

//             contentPadding: _padding(web, tablet),
//             filled: true,
//             fillColor: fillColor ?? kColorWhite,
//           ),
//         ),
//       ),
//     );
//   }

//   double _font(bool web, bool tablet) {
//     if (web) return FontSizes.k16FontSize;
//     return tablet ? FontSizes.k22FontSize : FontSizes.k16FontSize;
//   }

//   double _floatingFont(bool web, bool tablet) {
//     if (web) return FontSizes.k18FontSize;
//     return tablet ? FontSizes.k24FontSize : FontSizes.k18FontSize;
//   }

//   double _errorFont(bool web, bool tablet) {
//     if (web) return FontSizes.k14FontSize;
//     return tablet ? FontSizes.k18FontSize : FontSizes.k14FontSize;
//   }

//   EdgeInsets _padding(bool web, bool tablet) {
//     if (web) return AppPaddings.combined(horizontal: 16, vertical: 12);

//     return tablet
//         ? AppPaddings.combined(horizontal: 20, vertical: 12)
//         : AppPaddings.combined(horizontal: 16.appWidth, vertical: 8.appHeight);
//   }

//   OutlineInputBorder _border(bool web, bool tablet, Color color, double width) {
//     return OutlineInputBorder(
//       borderRadius: BorderRadius.circular(web ? 10 : (tablet ? 20 : 10)),
//       borderSide: BorderSide(color: color, width: width),
//     );
//   }
// }
