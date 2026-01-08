class UserDm {
  final int userId;
  final String fullName;
  final bool appAccess;
  final bool indentAuth;
  final bool poAuth;
  final String mobileNo;
  final int userType;
  final String seCodes;
  final String pCodes;
  final String gdCodes;

  UserDm({
    required this.userId,
    required this.fullName,
    required this.appAccess,
    required this.indentAuth,
    required this.poAuth,
    required this.mobileNo,
    required this.userType,
    required this.seCodes,
    required this.pCodes,
    required this.gdCodes,
  });

  factory UserDm.fromJson(Map<String, dynamic> json) {
    return UserDm(
      userId: json['UserId'],
      fullName: json['FULLNAME'],
      appAccess: json['AppAccess'],
      indentAuth: json['IndentAuth'] ?? false,
      poAuth: json['POAuth'] ?? false,
      mobileNo: json['MOBILENO'],
      userType: json['USERTYPE'],
      seCodes: json['SECODEs'],
      pCodes: json['PCODEs'],
      gdCodes: json['GDCODEs'] ?? '',
    );
  }
}
