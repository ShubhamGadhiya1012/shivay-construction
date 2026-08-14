class DlrReportDm {
  final int coCode;
  final String coName;
  final String siteCode;
  final String siteName;
  final String activity;
  final int srNo;
  final String agencyName;
  final double skill;
  final double unSkill;
  final double total;
  final String remark;
  final String description;
  final String inTime;
  final String outTime;
  final String date;

  DlrReportDm({
    required this.date,
    required this.coCode,
    required this.coName,
    required this.siteCode,
    required this.siteName,
    required this.activity,
    required this.srNo,
    required this.agencyName,
    required this.skill,
    required this.unSkill,
    required this.total,
    required this.remark,
    required this.description,
    this.inTime = '00:00:00',
    this.outTime = '00:00:00',
  });

  factory DlrReportDm.fromJson(Map<String, dynamic> json) {
    return DlrReportDm(
      coCode: json['CoCode'] ?? 0,
      date: json['Date'] ?? '',
      coName: json['CoName'] ?? '',
      siteCode: json['SiteCode'] ?? '',
      siteName: json['SiteName'] ?? '',
      activity: json['Activity'] ?? '',
      srNo: json['SrNo'] ?? 0,
      agencyName: json['AgencyName'] ?? '',
      skill: (json['Skill'] ?? 0).toDouble(),
      unSkill: (json['UnSkill'] ?? 0).toDouble(),
      total: (json['Total'] ?? 0).toDouble(),
      remark: json['Remark'] ?? '',
      description: json['Description'] ?? '',
      inTime: (json['InTime'] ?? '00:00:00').toString(),
      outTime: (json['OutTime'] ?? '00:00:00').toString(),
    );
  }

  double get skillAmount => skill;
  double get unSkillAmount => unSkill;
  double get totalAmount => skill + unSkill;

  bool get isNight =>
      (inTime.isNotEmpty && inTime != '00:00:00') ||
      (outTime.isNotEmpty && outTime != '00:00:00');
}
