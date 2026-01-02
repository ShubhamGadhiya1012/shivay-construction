class UnauthorisedUserDm {
  final int userId;
  final String fullName;
  final String mobileNo;

  UnauthorisedUserDm({
    required this.userId,
    required this.fullName,
    required this.mobileNo,
  });

  factory UnauthorisedUserDm.fromJson(Map<String, dynamic> json) {
    return UnauthorisedUserDm(
      userId: json['UserId'],
      fullName: json['FULLNAME'],
      mobileNo: json['MobileNO'],
    );
  }
}
