class DlrDataDm {
  final String pCode;
  final String vendorName;
  final double skill;
  final double skillRate;
  final double unSkill;
  final double unSkillRate;
  final String activity;
  final int supervisor;
  final String supervisorName;
  final String remark;
  final String description;

  DlrDataDm({
    required this.pCode,
    required this.vendorName,
    required this.skill,
    required this.skillRate,
    required this.unSkill,
    required this.unSkillRate,
    required this.activity,
    required this.supervisor,
    required this.supervisorName,
    required this.remark,
    required this.description,
  });

  factory DlrDataDm.fromJson(Map<String, dynamic> json) {
    return DlrDataDm(
      pCode: json['pCode'] ?? '',
      vendorName: json['vendorName'] ?? '',
      skill: (json['skill'] as num?)?.toDouble() ?? 0.0,
      skillRate: (json['skillRate'] as num?)?.toDouble() ?? 0.0,
      unSkill: (json['unSkill'] as num?)?.toDouble() ?? 0.0,
      unSkillRate: (json['unSkillRate'] as num?)?.toDouble() ?? 0.0,
      activity: json['activity'] ?? '',
      supervisor: json['supervisor'] ?? 0,
      supervisorName: json['supervisorName'] ?? '',
      remark: json['remark'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pCode': pCode,
      'vendorName': vendorName,
      'skill': skill,
      'skillRate': skillRate,
      'unSkill': unSkill,
      'unSkillRate': unSkillRate,
      'activity': activity,
      'supervisor': supervisor,
      'supervisorName': supervisorName,
      'remark': remark,
      'description': description,
    };
  }
}

class DlrDm {
  final String invno;
  final String date;
  final String shift;
  final String siteCode;
  final String siteName;
  final List<DlrDataDm> dlrData;

  DlrDm({
    required this.invno,
    required this.date,
    required this.shift,
    required this.siteCode,
    required this.siteName,
    required this.dlrData,
  });

  factory DlrDm.fromJson(Map<String, dynamic> json) {
    return DlrDm(
      invno: json['invno'] ?? '',
      date: json['date'] ?? '',
      shift: json['shift'] ?? '',
      siteCode: json['siteCode'] ?? '',
      siteName: json['siteName'] ?? '',
      dlrData:
          (json['dlrData'] as List<dynamic>?)
              ?.map((item) => DlrDataDm.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invno': invno,
      'date': date,
      'shift': shift,
      'siteCode': siteCode,
      'siteName': siteName,
      'dlrData': dlrData.map((d) => d.toJson()).toList(),
    };
  }
}
