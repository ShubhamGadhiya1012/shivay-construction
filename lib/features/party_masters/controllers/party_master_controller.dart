import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/features/party_masters/controllers/party_master_list_controller.dart';
import 'package:shivay_construction/features/party_masters/models/city_dm.dart';
import 'package:shivay_construction/features/party_masters/models/location_dm.dart';
import 'package:shivay_construction/features/party_masters/models/party_master_dm.dart';
import 'package:shivay_construction/features/party_masters/models/state_dm.dart';
import 'package:shivay_construction/features/party_masters/repos/party_master_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';

class PartyMasterController extends GetxController {
  var isLoading = false.obs;
  final partyFormKey = GlobalKey<FormState>();

  var accountNameController = TextEditingController();
  var printNameController = TextEditingController();
  var addressLine1Controller = TextEditingController();
  var addressLine2Controller = TextEditingController();
  var addressLine3Controller = TextEditingController();
  var pinCodeController = TextEditingController();
  var personNameController = TextEditingController();
  var phone1Controller = TextEditingController();
  var phone2Controller = TextEditingController();
  var mobileController = TextEditingController();
  var gstNumberController = TextEditingController();
  var panNumberController = TextEditingController();

  var locationList = <LocationDm>[].obs;
  var locationNames = <String>[].obs;
  var selectedLocation = ''.obs;

  var cityList = <CityDm>[].obs;
  var cityNames = <String>[].obs;
  var selectedCity = ''.obs;

  var stateList = <StateDm>[].obs;
  var stateNames = <String>[].obs;
  var selectedState = ''.obs;

  var isEditMode = false.obs;
  var currentPCode = ''.obs;

  @override
  void onInit() async {
    super.onInit();
    await fetchDropdownData();
  }

  Future<void> fetchDropdownData() async {
    isLoading.value = true;
    await getLocations();
    await getCities();
    await getStates();
    isLoading.value = false;
  }

  Future<void> getLocations() async {
    try {
      final data = await PartyMasterRepo.getLocations();
      locationList.assignAll(data);
      locationNames.assignAll(data.map((e) => e.value));
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    }
  }

  void onLocationSelected(String? location) {
    selectedLocation.value = location ?? '';
  }

  void addNewLocation(String value) {
    final newLocation = LocationDm(value: value);
    locationList.add(newLocation);
    locationNames.add(value);
    selectedLocation.value = value;
  }

  Future<void> getCities() async {
    try {
      final data = await PartyMasterRepo.getCities();
      cityList.assignAll(data);
      cityNames.assignAll(data.map((e) => e.value));
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    }
  }

  void onCitySelected(String? city) {
    selectedCity.value = city ?? '';
  }

  void addNewCity(String value) {
    final newCity = CityDm(value: value);
    cityList.add(newCity);
    cityNames.add(value);
    selectedCity.value = value;
  }

  Future<void> getStates() async {
    try {
      final data = await PartyMasterRepo.getStates();
      stateList.assignAll(data);
      stateNames.assignAll(data.map((e) => e.value));
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    }
  }

  void onStateSelected(String? state) {
    selectedState.value = state ?? '';
  }

  void addNewState(String value) {
    final newState = StateDm(value: value);
    stateList.add(newState);
    stateNames.add(value);
    selectedState.value = value;
  }

  void autoFillDataForEdit(PartyMasterDm party) {
    isEditMode.value = true;
    currentPCode.value = party.pCode;

    accountNameController.text = party.accountName;
    printNameController.text = party.printName;
    addressLine1Controller.text = party.addressLine1;
    addressLine2Controller.text = party.addressLine2;
    addressLine3Controller.text = party.addressLine3;
    pinCodeController.text = party.pinCode;
    personNameController.text = party.personName;
    phone1Controller.text = party.phone1;
    phone2Controller.text = party.phone2;
    mobileController.text = party.mobile;
    gstNumberController.text = party.gstNumber;
    panNumberController.text = party.pan;

    if (party.location.isNotEmpty) {
      selectedLocation.value = party.location;
    }

    if (party.city.isNotEmpty) {
      selectedCity.value = party.city;
    }

    if (party.state.isNotEmpty) {
      selectedState.value = party.state;
    }
  }

  Future<void> addUpdatePartyMaster() async {
    isLoading.value = true;
    try {
      final response = await PartyMasterRepo.addUpdatePartyMaster(
        pCode: currentPCode.value,
        accountName: accountNameController.text.trim(),
        printName: printNameController.text.trim(),
        location: selectedLocation.value,
        addressLine1: addressLine1Controller.text.trim(),
        addressLine2: addressLine2Controller.text.trim(),
        addressLine3: addressLine3Controller.text.trim(),
        city: selectedCity.value,
        state: selectedState.value,
        pinCode: pinCodeController.text.trim(),
        personName: personNameController.text.trim(),
        phone1: phone1Controller.text.trim(),
        phone2: phone2Controller.text.trim(),
        mobile: mobileController.text.trim(),
        gstNumber: gstNumberController.text.trim(),
        panNumber: panNumberController.text.trim(),
      );

      if (response != null && response.containsKey('message')) {
        String message = response['message'];
        Get.back();
        showSuccessSnackbar('Success', message);

        if (Get.isRegistered<PartyMasterListController>()) {
          final listController = Get.find<PartyMasterListController>();
          await listController.getParties();
          listController.filterParties(listController.searchController.text);
        }

        clearAll();
      }
    } catch (e) {
      if (e is Map<String, dynamic>) {
        showErrorSnackbar('Error', e['message']);
      } else {
        showErrorSnackbar('Error', e.toString());
      }
    } finally {
      isLoading.value = false;
    }
  }

  void clearAll() {
    accountNameController.clear();
    printNameController.clear();
    addressLine1Controller.clear();
    addressLine2Controller.clear();
    addressLine3Controller.clear();
    pinCodeController.clear();
    personNameController.clear();
    phone1Controller.clear();
    phone2Controller.clear();
    mobileController.clear();
    gstNumberController.clear();
    panNumberController.clear();

    selectedLocation.value = '';
    selectedCity.value = '';
    selectedState.value = '';

    isEditMode.value = false;
    currentPCode.value = '';
  }
}
