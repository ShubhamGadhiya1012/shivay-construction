class DlrReportDm {
  final String dlrInvNo;
  final String dlrDate;
  final String pCode;
  final String pName;
  final String siteCode;
  final String siteName;
  final String gdCode;
  final String gdName;
  final String shift;
  final double skill;
  final double unSkill;
  final double skillRate;
  final double unSkillRate;
  final int supervisor;
  final String supervisorName;
  final String remarks;

  DlrReportDm({
    required this.dlrInvNo,
    required this.dlrDate,
    required this.pCode,
    required this.pName,
    required this.siteCode,
    required this.siteName,
    required this.gdCode,
    required this.gdName,
    required this.shift,
    required this.skill,
    required this.unSkill,
    required this.skillRate,
    required this.unSkillRate,
    required this.supervisor,
    required this.supervisorName,
    required this.remarks,
  });

  factory DlrReportDm.fromJson(Map<String, dynamic> json) {
    return DlrReportDm(
      dlrInvNo: json['DLRInvNo'] ?? '',
      dlrDate: json['DLRDate'] ?? '',
      pCode: json['PCode'] ?? '',
      pName: json['PName'] ?? '',
      siteCode: json['SiteCode'] ?? '',
      siteName: json['SiteName'] ?? '',
      gdCode: json['GDCode'] ?? '',
      gdName: json['GDName'] ?? '',
      shift: json['Shift'] ?? '',
      skill: (json['Skill'] ?? 0).toDouble(),
      unSkill: (json['UnSkill'] ?? 0).toDouble(),
      skillRate: (json['SkillRate'] ?? 0).toDouble(),
      unSkillRate: (json['UnSkillRate'] ?? 0).toDouble(),
      supervisor: json['Supervisor'] ?? 0,
      supervisorName: json['SupervisorName'] ?? '',
      remarks: json['Remarks'] ?? '',
    );
  }

  double get skillAmount => skill * skillRate;
  double get unSkillAmount => unSkill * unSkillRate;
  double get totalAmount => skillAmount + unSkillAmount;
}
