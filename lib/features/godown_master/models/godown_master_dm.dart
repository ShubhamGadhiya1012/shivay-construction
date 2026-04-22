class GodownMasterDm {
  final String gdCode;
  final String gdName;
  final String siteCode;
  final bool isSubGodown;
  final bool isAuto;

  GodownMasterDm({
    required this.gdCode,
    required this.gdName,
    required this.siteCode,
    this.isSubGodown = false,
    this.isAuto = false,
  });

  factory GodownMasterDm.fromJson(Map<String, dynamic> json) {
    return GodownMasterDm(
      gdCode: json['GDCODE'] ?? '',
      gdName: json['GDNAME'] ?? '',
      siteCode: json['SITECODE'] ?? '',
      isSubGodown: json['IsSubGodown'] ?? false,
      isAuto: json['IsAuto'] ?? false,
    );
  }
}
