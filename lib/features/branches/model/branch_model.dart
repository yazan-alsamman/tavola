class BranchModel {
  const BranchModel({
    required this.id,
    required this.city,
    required this.district,
    required this.address,
    required this.phone,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String city;
  final String district;
  final String address;
  final String phone;
  final double? latitude;
  final double? longitude;

  bool get hasCoordinates => latitude != null && longitude != null;

  /// Matches Details location / footer display (address → district → city).
  String get locationLabel {
    final List<String> parts = <String>[
      if (address.isNotEmpty) address,
      if (district.isNotEmpty) district,
      if (city.isNotEmpty) city,
    ];
    return parts.join(', ');
  }

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: (json['branchId'] as String?) ?? (json['id'] as String?) ?? '',
      city: (json['city'] as String?)?.trim() ?? '',
      district: (json['district'] as String?)?.trim() ?? '',
      address: (json['address'] as String?)?.trim() ?? '',
      phone: (json['phone'] as String?)?.trim() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}
