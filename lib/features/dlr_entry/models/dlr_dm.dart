class DlrDm {
  final String invno;
  final String date;
  final String pcode;
  final String vendorName;
  final String shift;
  final double skill;
  final double skillRate;
  final double unSkill;
  final double unSkillRate;
  final String siteCode;
  final String siteName;
  final String gdCode;
  final String gdName;
  final int supervisor;
  final String supervisorName;

  DlrDm({
    required this.invno,
    required this.date,
    required this.pcode,
    required this.vendorName,
    required this.shift,
    required this.skill,
    required this.skillRate,
    required this.unSkill,
    required this.unSkillRate,
    required this.siteCode,
    required this.siteName,
    required this.gdCode,
    required this.gdName,
    required this.supervisor,
    required this.supervisorName,
  });

  factory DlrDm.fromJson(Map<String, dynamic> json) {
    return DlrDm(
      invno: json['Invno'] ?? '',
      date: json['Date'] ?? '',
      pcode: json['Pcode'] ?? '',
      vendorName: json['VendorName'] ?? '',
      shift: json['Shift'] ?? '',
      skill: (json['Skill'] as num?)?.toDouble() ?? 0.0,
      skillRate: (json['SkillRate'] as num?)?.toDouble() ?? 0.0,
      unSkill: (json['UnSkill'] as num?)?.toDouble() ?? 0.0,
      unSkillRate: (json['UnSkillRate'] as num?)?.toDouble() ?? 0.0,
      siteCode: json['SiteCode'] ?? '',
      siteName: json['SiteName'] ?? '',
      gdCode: json['GDCode'] ?? '',
      gdName: json['GDName'] ?? '',
      supervisor: json['Supervisor'] ?? 0,
      supervisorName: json['SuperisorName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Invno': invno,
      'Date': date,
      'Pcode': pcode,
      'VendorName': vendorName,
      'Shift': shift,
      'Skill': skill,
      'SkillRate': skillRate,
      'UnSkill': unSkill,
      'UnSkillRate': unSkillRate,
      'SiteCode': siteCode,
      'SiteName': siteName,
      'GDCode': gdCode,
      'GDName': gdName,
      'Supervisor': supervisor,
      'SupervisorName': supervisorName,
    };
  }
}
