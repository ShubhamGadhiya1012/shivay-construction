class NotificationDm {
  final int nid;
  final String nName;

  NotificationDm({
    required this.nid,
    required this.nName,
  });

  factory NotificationDm.fromJson(Map<String, dynamic> json) {
    return NotificationDm(
      nid: json['NID'],
      nName: json['NName'],
    );
  }
}
