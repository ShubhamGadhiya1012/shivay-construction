import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shivay_construction/features/dlr_entry/controllers/dlr_list_controller.dart';
import 'package:shivay_construction/features/dlr_entry/models/dlr_dm.dart';
import 'package:shivay_construction/features/dlr_entry/repos/dlr_repo.dart';
import 'package:shivay_construction/features/party_masters/models/party_master_dm.dart';
import 'package:shivay_construction/features/party_masters/repos/party_master_list_repo.dart';
import 'package:shivay_construction/features/site_master/models/site_master_dm.dart';
import 'package:shivay_construction/features/site_master/repos/site_master_list_repo.dart';
import 'package:shivay_construction/features/user_settings/models/user_dm.dart';
import 'package:shivay_construction/features/user_settings/repos/users_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';
import 'package:shivay_construction/utils/helpers/device_helper.dart';

class ActivityDm {
  final String value;
  ActivityDm({required this.value});
  factory ActivityDm.fromJson(Map<String, dynamic> json) {
    return ActivityDm(value: json['value'] ?? '');
  }
}

class DlrEntryController extends GetxController {
  var isLoading = false.obs;
  final dlrFormKey = GlobalKey<FormState>();
  final dlrItemFormKey = GlobalKey<FormState>();

  var dateController = TextEditingController();

  var shifts = ['Morning', 'Night'].obs;
  var selectedShift = ''.obs;

  var sites = <SiteMasterDm>[].obs;
  var siteNames = <String>[].obs;
  var selectedSiteName = ''.obs;
  var selectedSiteCode = ''.obs;

  var parties = <PartyMasterDm>[].obs;
  var partyNames = <String>[].obs;
  var selectedPartyName = ''.obs;
  var selectedPartyCode = ''.obs;

  var skillController = TextEditingController();
  var skillRateController = TextEditingController();
  var unskillController = TextEditingController();
  var unskillRateController = TextEditingController();
  var remarkController = TextEditingController();

  var supervisors = <UserDm>[].obs;
  var supervisorNames = <String>[].obs;
  var selectedSupervisorName = ''.obs;
  var selectedSupervisorId = 0.obs;

  // Dynamic activities fetched from API
  var activityList = <ActivityDm>[].obs;
  var activityNames = <String>[].obs;
  var selectedActivityName = ''.obs;

  var dlrItems = <Map<String, dynamic>>[].obs;
  var isEditingItem = false.obs;
  var editingItemIndex = (-1).obs;

  var isEditMode = false.obs;
  var currentInvNo = ''.obs;

  @override
  void onInit() async {
    super.onInit();
    dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    await getSites();
    await getParties();
    await getSupervisors();
    await getActivities();
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

  void onSiteSelected(String? siteName) {
    selectedSiteName.value = siteName ?? '';
    var selectedSiteObj = sites.firstWhereOrNull(
      (site) => site.siteName == siteName,
    );
    selectedSiteCode.value = selectedSiteObj?.siteCode ?? '';
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
    try {
      isLoading.value = true;
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

  Future<void> getActivities() async {
    try {
      isLoading.value = true;
      final data = await DlrRepo.getActivities();
      activityList.assignAll(data);
      activityNames.assignAll(data.map((e) => e.value).toList());
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void onActivitySelected(String? activityName) {
    selectedActivityName.value = activityName ?? '';
  }

  void addNewActivity(String value) {
    final newActivity = ActivityDm(value: value);
    activityList.add(newActivity);
    activityNames.add(value);
    selectedActivityName.value = value;
  }

  void onShiftSelected(String? shift) {
    selectedShift.value = shift ?? '';
  }

  void prepareAddItem() {
    clearItemForm();
    isEditingItem.value = false;
    editingItemIndex.value = -1;
  }

  void prepareEditItem(int index) {
    isLoading.value = true;
    try {
      final item = dlrItems[index];
      selectedPartyName.value = item['partyName'] ?? '';
      selectedPartyCode.value = item['PCode'] ?? '';
      skillController.text = (item['Skill'] ?? '').toString();
      skillRateController.text = (item['SkillRate'] ?? '').toString();
      unskillController.text = (item['UnSkill'] ?? '').toString();
      unskillRateController.text = (item['UnSkillRate'] ?? '').toString();
      selectedSupervisorName.value = item['supervisorName'] ?? '';
      selectedSupervisorId.value = item['Supervisor'] ?? 0;
      selectedActivityName.value = item['Activity'] ?? '';
      remarkController.text = item['Remark'] ?? '';
      isEditingItem.value = true;
      editingItemIndex.value = index;
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  void clearItemForm() {
    selectedPartyName.value = '';
    selectedPartyCode.value = '';
    skillController.clear();
    skillRateController.clear();
    unskillController.clear();
    unskillRateController.clear();
    selectedSupervisorName.value = '';
    selectedSupervisorId.value = 0;
    selectedActivityName.value = '';
    remarkController.clear();
  }

  void addOrUpdateItem() {
    if (!isEditingItem.value) {
      final isDuplicate = dlrItems.any(
        (item) => item['PCode'] == selectedPartyCode.value,
      );
      if (isDuplicate) {
        showErrorSnackbar(
          'Duplicate Party',
          'This party is already added. Please select a different party.',
        );
        return;
      }
    }

    final Map<String, dynamic> itemData = {
      'PCode': selectedPartyCode.value,
      'partyName': selectedPartyName.value,
      'Skill': double.tryParse(skillController.text) ?? 0.0,
      'SkillRate': double.tryParse(skillRateController.text) ?? 0.0,
      'UnSkill': double.tryParse(unskillController.text) ?? 0.0,
      'UnSkillRate': double.tryParse(unskillRateController.text) ?? 0.0,
      'Supervisor': selectedSupervisorId.value,
      'supervisorName': selectedSupervisorName.value,
      'Activity': selectedActivityName.value,
      'Remark': remarkController.text.trim(),
    };

    if (isEditingItem.value) {
      dlrItems[editingItemIndex.value] = itemData;
    } else {
      dlrItems.add(itemData);
    }

    Get.back();
  }

  void deleteItem(int index) {
    if (index >= 0 && index < dlrItems.length) {
      dlrItems.removeAt(index);
    }
  }

  void autoFillDataForEdit(DlrDm dlr) {
    isEditMode.value = true;
    currentInvNo.value = dlr.invno;
    dateController.text = _convertyyyyMMddToddMMyyyy(dlr.date);
    selectedShift.value = dlr.shift;
    selectedSiteCode.value = dlr.siteCode;
    selectedSiteName.value = dlr.siteName;

    dlrItems.assignAll(
      dlr.dlrData.map((d) {
        return {
          'PCode': d.pCode,
          'partyName': d.vendorName,
          'Skill': d.skill,
          'SkillRate': d.skillRate,
          'UnSkill': d.unSkill,
          'UnSkillRate': d.unSkillRate,
          'Supervisor': d.supervisor,
          'supervisorName': d.supervisorName,
          'Activity': d.activity,
          'Remark': d.remark,
        };
      }).toList(),
    );
  }

  String _convertyyyyMMddToddMMyyyy(String dateStr) {
    if (dateStr.isEmpty) return '';
    final parts = dateStr.split('-');
    if (parts.length == 3) return '${parts[2]}-${parts[1]}-${parts[0]}';
    return dateStr;
  }

  String _convertToApiDateFormat(String dateStr) {
    if (dateStr.isEmpty) return '';
    final parts = dateStr.split('-');
    if (parts.length == 3) return '${parts[2]}-${parts[1]}-${parts[0]}';
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
      final List<Map<String, dynamic>> dlrData = dlrItems.map((item) {
        return {
          'PCode': item['PCode'],
          'Skill': item['Skill'],
          'SkillRate': item['SkillRate'],
          'UnSkill': item['UnSkill'],
          'UnSkillRate': item['UnSkillRate'],
          'Supervisor': item['Supervisor'],
          'Activity': item['Activity'],
          'Remark': item['Remark'] ?? '',
        };
      }).toList();

      var response = await DlrRepo.saveDlrEntry(
        invno: isEditMode.value ? currentInvNo.value : '',
        date: _convertToApiDateFormat(dateController.text),
        shift: selectedShift.value,
        deviceId: deviceId,
        siteCode: selectedSiteCode.value,
        dlrData: dlrData,
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
    selectedShift.value = '';
    selectedSiteName.value = '';
    selectedSiteCode.value = '';
    dlrItems.clear();
    clearItemForm();
    isEditMode.value = false;
  }
}
