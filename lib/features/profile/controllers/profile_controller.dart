import 'package:get/get.dart';
import 'package:shivay_construction/features/auth/screens/login_screen.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';
import 'package:shivay_construction/utils/helpers/version_helper.dart';

class ProfileController extends GetxController {
  var isLoading = false.obs;

  var fullName = ''.obs;
  var userType = ''.obs;
  var mobileNumber = ''.obs;
  var gdName = ''.obs;
  var appVersion = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserInfo();
    loadAppVersion();
  }

  Future<void> loadUserInfo() async {
    try {
      fullName.value = await SecureStorageHelper.read('fullName') ?? 'Unknown';
      userType.value = await SecureStorageHelper.read('userType') ?? 'guest';
      mobileNumber.value = await SecureStorageHelper.read('mobileNo') ?? '';
      gdName.value = await SecureStorageHelper.read('company') ?? '';
    } catch (e) {
      showErrorSnackbar(
        'Failed to Load User Info',
        'There was an issue loading your profile data. Please try again.',
      );
    }
  }

  Future<void> loadAppVersion() async {
    try {
      appVersion.value = await VersionHelper.getVersion();
    } catch (e) {
      appVersion.value = 'N/A';
    }
  }

  // Future<void> redirectToPlayStore() async {
  //   const playStoreUrl =
  //       'https://play.google.com/store/apps/details?id=com.jinee.pro_manage';

  //   final uri = Uri.parse(playStoreUrl);
  //   if (await canLaunchUrl(uri)) {
  //     await launchUrl(uri, mode: LaunchMode.externalApplication);
  //   } else {
  //     showErrorSnackbar('Error', 'Could not launch the Play Store.');
  //   }
  // }

  Future<void> logoutUser() async {
    isLoading.value = true;
    try {
      await SecureStorageHelper.clearAll();
      Get.offAll(() => LoginScreen());
      showSuccessSnackbar(
        'Logged Out',
        'You have been successfully logged out.',
      );
    } catch (e) {
      showErrorSnackbar(
        'Logout Failed',
        'Something went wrong. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }
}
