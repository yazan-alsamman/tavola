class BranchModel {
  const BranchModel({
    required this.id,
    required this.city,
    required this.district,
    required this.address,
    this.latitude,
    this.longitude,
    this.priceLevel,
  });

  final String id;
  final String city;
  final String district;
  final String address;
  final double? latitude;
  final double? longitude;

  /// Price level 1–4 computed from this branch's menu (backend ADR-046);
  /// null until the branch has prices.
  final int? priceLevel;

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
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      priceLevel: _readPriceLevel(json['priceLevel']),
    );
  }

  static int? _readPriceLevel(Object? raw) {
    final int? level = raw is num ? raw.toInt() : int.tryParse('${raw ?? ''}');
    return level != null && level >= 1 ? level : null;
  }
}
