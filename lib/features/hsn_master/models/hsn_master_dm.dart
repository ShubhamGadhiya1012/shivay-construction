class HsnMasterDm {
  final String hsnNo;
  final String orgHsnNo;
  final String chapterNo;
  final String unit;
  final String description;
  final String ewbUnit;
  final bool sac;

  HsnMasterDm({
    required this.hsnNo,
    required this.orgHsnNo,
    required this.chapterNo,
    required this.unit,
    required this.description,
    required this.ewbUnit,
    required this.sac,
  });

  factory HsnMasterDm.fromJson(Map<String, dynamic> json) {
    return HsnMasterDm(
      hsnNo: json['HSNNO'] ?? '',
      orgHsnNo: json['OrgHSNNo'] ?? '',
      chapterNo: json['ChapterNo'] ?? '',
      unit: json['Unit'] ?? '',
      description: json['Description'] ?? '',
      ewbUnit: json['EWBUnit'] ?? '',
      sac: json['SAC'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'HSNNO': hsnNo,
      'OrgHSNNo': orgHsnNo,
      'ChapterNo': chapterNo,
      'Unit': unit,
      'Description': description,
      'EWBUnit': ewbUnit,
      'SAC': sac,
    };
  }
}
