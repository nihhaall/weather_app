class UVResponse {
  final double value;

  UVResponse({required this.value});

  factory UVResponse.fromMap(Map<String, dynamic> map) {
    return UVResponse(
      value: map['value']?.toDouble() ?? 0.0,
    );
  }
}
