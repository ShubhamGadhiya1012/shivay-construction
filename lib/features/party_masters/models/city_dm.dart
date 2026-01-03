class CityDm {
  final String value;

  CityDm({required this.value});

  factory CityDm.fromJson(Map<String, dynamic> json) {
    return CityDm(value: json['value'] ?? '');
  }
}
