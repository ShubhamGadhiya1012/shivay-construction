import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shivay_construction/features/dlr_entry/controllers/dlr_list_controller.dart';
import 'package:shivay_construction/features/dlr_entry/models/dlr_dm.dart';
import 'package:shivay_construction/features/dlr_entry/repos/dlr_repo.dart';
import 'package:shivay_construction/features/godown_master/models/godown_master_dm.dart';
import 'package:shivay_construction/features/godown_master/repos/godown_master_repo.dart';
import 'package:shivay_construction/features/party_masters/models/party_master_dm.dart';
import 'package:shivay_construction/features/party_masters/repos/party_master_list_repo.dart';
import 'package:shivay_construction/features/site_master/models/site_master_dm.dart';
import 'package:shivay_construction/features/site_master/repos/site_master_list_repo.dart';
import 'package:shivay_construction/features/user_settings/models/user_dm.dart';
import 'package:shivay_construction/features/user_settings/repos/users_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';
import 'package:shivay_construction/utils/helpers/device_helper.dart';

class DlrEntryController extends GetxController {
  var isLoading = false.obs;
  final dlrFormKey = GlobalKey<FormState>();

  var dateController = TextEditingController();

  var parties = <PartyMasterDm>[].obs;
  var partyNames = <String>[].obs;
  var selectedPartyName = ''.obs;
  var selectedPartyCode = ''.obs;

  var shifts = ['Morning', 'Night'].obs;
  var selectedShift = ''.obs;

  var skillController = TextEditingController();
  var skillRateController = TextEditingController();
  var unskillController = TextEditingController();
  var unskillRateController = TextEditingController();

  var supervisors = <UserDm>[].obs;
  var supervisorNames = <String>[].obs;
  var selectedSupervisorName = ''.obs;
  var selectedSupervisorId = 0.obs;

  var sites = <SiteMasterDm>[].obs;
  var siteNames = <String>[].obs;
  var selectedSiteName = ''.obs;
  var selectedSiteCode = ''.obs;

  var godowns = <GodownMasterDm>[].obs;
  var godownNames = <String>[].obs;
  var selectedGodownName = ''.obs;
  var selectedGodownCode = ''.obs;

  var isEditMode = false.obs;
  var currentInvNo = ''.obs;

  @override
  void onInit() async {
    super.onInit();
    dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());

    await getSupervisors();
    await getSites();
    await getGodowns();
    await getParties();
  }

  Future<void> getParties() async {
    try {
      isLoading.value = true;
      final fetchedParties = await PartyMasterListRepo.getParties();
      parties.assignAll(fetchedParties);
      partyNames.assignAll(fetchedParties.map((p) => p.accountName).toList());
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void onPartySelected(String? partyName) {
    selectedPartyName.value = partyName ?? '';
    var selectedPartyObj = parties.firstWhereOrNull(
      (p) => p.accountName == partyName,
    );
    selectedPartyCode.value = selectedPartyObj?.pCode ?? '';
  }

  Future<void> getSupervisors() async {
    isLoading.value = true;
    try {
      final fetchedUsers = await UsersRepo.getUsers();
      supervisors.assignAll(fetchedUsers);
      supervisorNames.assignAll(
        fetchedUsers.map((user) => user.fullName).toList(),
      );
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void onSupervisorSelected(String? supervisorName) {
    selectedSupervisorName.value = supervisorName ?? '';
    var selectedSupervisor = supervisors.firstWhereOrNull(
      (user) => user.fullName == supervisorName,
    );
    selectedSupervisorId.value = selectedSupervisor?.userId ?? 0;
  }

  Future<void> getSites() async {
    try {
      isLoading.value = true;
      final fetchedSites = await SiteMasterListRepo.getSites();
      sites.assignAll(fetchedSites);
      siteNames.assignAll(fetchedSites.map((site) => site.siteName).toList());
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void onSiteSelected(String? siteName) async {
    selectedSiteName.value = siteName ?? '';
    var selectedSiteObj = sites.firstWhereOrNull(
      (site) => site.siteName == siteName,
    );
    selectedSiteCode.value = selectedSiteObj?.siteCode ?? '';

    selectedGodownName.value = '';
    selectedGodownCode.value = '';

    if (selectedSiteCode.value.isNotEmpty) {
      await getGodowns(selectedSiteCode.value);
    } else {
      await getGodowns();
    }
  }

  Future<void> getGodowns([String siteCode = '']) async {
    try {
      isLoading.value = true;
      final fetchedGodowns = await GodownMasterRepo.getGodowns(
        siteCode: siteCode,
      );
      godowns.assignAll(fetchedGodowns);
      godownNames.assignAll(fetchedGodowns.map((gd) => gd.gdName).toList());
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void onGodownSelected(String? godownName) {
    selectedGodownName.value = godownName ?? '';
    var selectedGodownObj = godowns.firstWhereOrNull(
      (gd) => gd.gdName == godownName,
    );
    selectedGodownCode.value = selectedGodownObj?.gdCode ?? '';

    if (selectedGodownObj?.siteCode.isNotEmpty ?? false) {
      final site = sites.firstWhereOrNull(
        (s) => s.siteCode == selectedGodownObj!.siteCode,
      );
      if (site != null) {
        selectedSiteName.value = site.siteName;
        selectedSiteCode.value = site.siteCode;
      }
    }
  }

  void onShiftSelected(String? shift) {
    selectedShift.value = shift ?? '';
  }

  void autoFillDataForEdit(DlrDm dlr) {
    isEditMode.value = true;
    currentInvNo.value = dlr.invno;

    dateController.text = _convertyyyyMMddToddMMyyyy(dlr.date);

    selectedPartyCode.value = dlr.pcode;
    selectedPartyName.value = dlr.vendorName;

    selectedShift.value = dlr.shift;
    skillController.text = dlr.skill.toString();
    skillRateController.text = dlr.skillRate.toString();
    unskillController.text = dlr.unSkill.toString();
    unskillRateController.text = dlr.unSkillRate.toString();

    selectedSupervisorId.value = dlr.supervisor;
    selectedSupervisorName.value = dlr.supervisorName;

    selectedSiteCode.value = dlr.siteCode;
    selectedSiteName.value = dlr.siteName;

    selectedGodownCode.value = dlr.gdCode;
    selectedGodownName.value = dlr.gdName;

    if (dlr.siteCode.isNotEmpty) {
      getGodowns(dlr.siteCode);
    }
  }

  String _convertyyyyMMddToddMMyyyy(String dateStr) {
    if (dateStr.isEmpty) return '';
    final parts = dateStr.split('-');
    if (parts.length == 3) {
      return '${parts[2]}-${parts[1]}-${parts[0]}';
    }
    return dateStr;
  }

  String _convertToApiDateFormat(String dateStr) {
    if (dateStr.isEmpty) return '';
    final parts = dateStr.split('-');
    if (parts.length == 3) {
      return '${parts[2]}-${parts[1]}-${parts[0]}';
    }
    return dateStr;
  }

  Future<void> saveDlrEntry() async {
    isLoading.value = true;

    String? deviceId = await DeviceHelper().getDeviceId();
    if (deviceId == null) {
      showErrorSnackbar('Error', 'Unable to fetch device ID.');
      isLoading.value = false;
      return;
    }

    try {
      var response = await DlrRepo.saveDlrEntry(
        invno: isEditMode.value ? currentInvNo.value : '',
        pCode: selectedPartyCode.value,
        date: _convertToApiDateFormat(dateController.text),
        shift: selectedShift.value,
        skill: double.tryParse(skillController.text) ?? 0.0,
        skillRate: double.tryParse(skillRateController.text) ?? 0.0,
        unSkill: double.tryParse(unskillController.text) ?? 0.0,
        unSkillRate: double.tryParse(unskillRateController.text) ?? 0.0,
        supervisor: selectedSupervisorId.value,
        deviceId: deviceId,
        siteCode: selectedSiteCode.value,
        gdCode: selectedGodownCode.value,
      );

      if (response != null && response.containsKey('message')) {
        String message = response['message'];

        if (Get.isRegistered<DlrListController>()) {
          final listController = Get.find<DlrListController>();
          await listController.getDlrList();
        }

        Get.back();
        showSuccessSnackbar('Success', message);
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
    currentInvNo.value = '';
    dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());

    selectedPartyName.value = '';
    selectedPartyCode.value = '';

    selectedShift.value = '';
    skillController.clear();
    skillRateController.clear();
    unskillController.clear();
    unskillRateController.clear();
    selectedSupervisorName.value = '';
    selectedSupervisorId.value = 0;
    selectedSiteName.value = '';
    selectedSiteCode.value = '';
    selectedGodownName.value = '';
    selectedGodownCode.value = '';
    isEditMode.value = false;
  }
}
