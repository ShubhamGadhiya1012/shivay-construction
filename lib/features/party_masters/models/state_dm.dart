class StateDm {
  final String value;

  StateDm({required this.value});

  factory StateDm.fromJson(Map<String, dynamic> json) {
    return StateDm(value: json['value'] ?? '');
  }
}
