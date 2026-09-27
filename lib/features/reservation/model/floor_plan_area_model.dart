import 'package:flutter/material.dart';

/// A dining area from the floor-plan response `areas` array.
class FloorPlanAreaModel {
  const FloorPlanAreaModel({
    required this.id,
    required this.name,
    required this.sortOrder,
    this.color,
    this.positionX,
    this.positionY,
    this.width,
    this.height,
  });

  final String id;
  final String name;
  final int sortOrder;

  /// Backend `#RRGGBB` when present.
  final String? color;

  /// Present only when the floor-plan area payload includes its own box.
  final double? positionX;
  final double? positionY;
  final double? width;
  final double? height;

  bool get hasExplicitBounds =>
      positionX != null &&
      positionY != null &&
      width != null &&
      height != null &&
      width! > 0 &&
      height! > 0;

  Color? get colorValue => colorFromHex(color);

  /// English translation key when [name] is a known dining-area label.
  ///
  /// The floor-plan payload stores one name, often Arabic, and does not
  /// localize it. Unknown names stay as sent.
  static String? translationKeyFor(String raw) {
    final String normalized = raw
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ')
        .toLowerCase();
    return _translationKeys[normalized];
  }

  static const Map<String, String> _translationKeys = <String, String>{
    'الصالة الرئيسية': 'Main Hall',
    'صالة رئيسية': 'Main Hall',
    'القاعة الرئيسية': 'Main Hall',
    'قاعة رئيسية': 'Main Hall',
    'main hall': 'Main Hall',
    'the main hall': 'Main Hall',
    'غرفة vip': 'VIP',
    'غرفة كبار الشخصيات': 'VIP',
    'vip': 'VIP',
    'vip room': 'VIP',
    'the vip room': 'VIP',
    'التراس': 'Terrace',
    'تراس': 'Terrace',
    'الشرفة': 'Terrace',
    'terrace': 'Terrace',
    'the terrace': 'Terrace',
  };

  static FloorPlanAreaModel? fromJson(Map<String, dynamic> json) {
    final String id =
        (json['floorPlanAreaId'] as String?)?.trim() ??
        (json['id'] as String?)?.trim() ??
        '';
    if (id.isEmpty) {
      return null;
    }
    final String? rawColor = (json['color'] as String?)?.trim();
    return FloorPlanAreaModel(
      id: id,
      name: (json['name'] as String?)?.trim() ?? '',
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      color: rawColor == null || rawColor.isEmpty ? null : rawColor,
      positionX: _readDouble(json, 'positionX') ?? _readDouble(json, 'x'),
      positionY: _readDouble(json, 'positionY') ?? _readDouble(json, 'y'),
      width: _readDouble(json, 'width'),
      height: _readDouble(json, 'height'),
    );
  }

  static double? _readDouble(Map<String, dynamic> json, String key) {
    final Object? value = json[key];
    if (value is num) {
      return value.toDouble();
    }
    return null;
  }

  static Color? colorFromHex(String? raw) {
    if (raw == null) {
      return null;
    }
    String hex = raw.trim();
    if (hex.startsWith('#')) {
      hex = hex.substring(1);
    }
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    if (hex.length != 8) {
      return null;
    }
    final int? value = int.tryParse(hex, radix: 16);
    if (value == null) {
      return null;
    }
    return Color(value);
  }
}
