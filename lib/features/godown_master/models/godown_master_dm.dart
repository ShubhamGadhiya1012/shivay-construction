class GodownMasterDm {
  final String gdCode;
  final String gdName;
  final String siteCode;

  GodownMasterDm({
    required this.gdCode,
    required this.gdName,
    required this.siteCode,
  });

  factory GodownMasterDm.fromJson(Map<String, dynamic> json) {
    return GodownMasterDm(
      gdCode: json['GDCODE'] ?? '',
      gdName: json['GDNAME'] ?? '',
      siteCode: json['SiteCode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'GDCode': gdCode, 'GDName': gdName, 'SiteCode': siteCode};
  }
}
