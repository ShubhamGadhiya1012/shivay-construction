class LocationDm {
  final String value;

  LocationDm({required this.value});

  factory LocationDm.fromJson(Map<String, dynamic> json) {
    return LocationDm(value: json['value'] ?? '');
  }
}
