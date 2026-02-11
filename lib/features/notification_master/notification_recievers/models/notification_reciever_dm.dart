class NotificationRecieverDm {
  final int userId;
  final String fullName;
  final String username;
  final int nid;

  NotificationRecieverDm({
    required this.userId,
    required this.fullName,
    required this.username,
    required this.nid,
  });

  factory NotificationRecieverDm.fromJson(Map<String, dynamic> json) {
    return NotificationRecieverDm(
      userId: json['USERID'],
      fullName: json['FullName'],
      username: json['UserName'],
      nid: json['NID'],
    );
  }
}
