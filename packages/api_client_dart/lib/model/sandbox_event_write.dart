//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SandboxEventWrite {
  /// Returns a new [SandboxEventWrite] instance.
  SandboxEventWrite({
    required this.type,
    this.eventId,
  });

  SandboxEventWriteTypeEnum type;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? eventId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SandboxEventWrite &&
    other.type == type &&
    other.eventId == eventId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (type.hashCode) +
    (eventId == null ? 0 : eventId!.hashCode);

  @override
  String toString() => 'SandboxEventWrite[type=$type, eventId=$eventId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'type'] = this.type;
    if (this.eventId != null) {
      json[r'eventId'] = this.eventId;
    } else {
      json[r'eventId'] = null;
    }
    return json;
  }

  /// Returns a new [SandboxEventWrite] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SandboxEventWrite? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'type'), 'Required key "SandboxEventWrite[type]" is missing from JSON.');
        assert(json[r'type'] != null, 'Required key "SandboxEventWrite[type]" has a null value in JSON.');
        return true;
      }());

      return SandboxEventWrite(
        type: SandboxEventWriteTypeEnum.fromJson(json[r'type'])!,
        eventId: mapValueOfType<String>(json, r'eventId'),
      );
    }
    return null;
  }

  static List<SandboxEventWrite> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SandboxEventWrite>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SandboxEventWrite.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SandboxEventWrite> mapFromJson(dynamic json) {
    final map = <String, SandboxEventWrite>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SandboxEventWrite.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SandboxEventWrite-objects as value to a dart map
  static Map<String, List<SandboxEventWrite>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SandboxEventWrite>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SandboxEventWrite.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'type',
  };
}


enum SandboxEventWriteTypeEnum {
  paymentPeriodPending._(r'payment.pending'),
  paymentPeriodSucceeded._(r'payment.succeeded'),
  paymentPeriodFailed._(r'payment.failed'),
  ;

  /// Instantiate a new enum with the provided value.
  const SandboxEventWriteTypeEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [SandboxEventWriteTypeEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static SandboxEventWriteTypeEnum? fromJson(dynamic value) => SandboxEventWriteTypeEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [SandboxEventWriteTypeEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<SandboxEventWriteTypeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SandboxEventWriteTypeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SandboxEventWriteTypeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [SandboxEventWriteTypeEnum] to String,
/// and [decode] dynamic data back to [SandboxEventWriteTypeEnum].
class SandboxEventWriteTypeEnumTypeTransformer {
  factory SandboxEventWriteTypeEnumTypeTransformer() => _instance ??= const SandboxEventWriteTypeEnumTypeTransformer._();

  const SandboxEventWriteTypeEnumTypeTransformer._();

  String encode(SandboxEventWriteTypeEnum data) => data._value;

  /// Returns the instance of [SandboxEventWriteTypeEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  SandboxEventWriteTypeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is SandboxEventWriteTypeEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'payment.pending': return SandboxEventWriteTypeEnum.paymentPeriodPending;
        case r'payment.succeeded': return SandboxEventWriteTypeEnum.paymentPeriodSucceeded;
        case r'payment.failed': return SandboxEventWriteTypeEnum.paymentPeriodFailed;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static SandboxEventWriteTypeEnumTypeTransformer? _instance;
}


