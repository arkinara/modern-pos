//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class StationJobStateWrite {
  /// Returns a new [StationJobStateWrite] instance.
  StationJobStateWrite({
    required this.state,
    required this.attempts,
    this.lastError,
  });

  StationJobStateWriteStateEnum state;

  /// Minimum value: 0
  int attempts;

  String? lastError;

  @override
  bool operator ==(Object other) => identical(this, other) || other is StationJobStateWrite &&
    other.state == state &&
    other.attempts == attempts &&
    other.lastError == lastError;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (state.hashCode) +
    (attempts.hashCode) +
    (lastError == null ? 0 : lastError!.hashCode);

  @override
  String toString() => 'StationJobStateWrite[state=$state, attempts=$attempts, lastError=$lastError]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'state'] = this.state;
      json[r'attempts'] = this.attempts;
    if (this.lastError != null) {
      json[r'lastError'] = this.lastError;
    } else {
      json[r'lastError'] = null;
    }
    return json;
  }

  /// Returns a new [StationJobStateWrite] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static StationJobStateWrite? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'state'), 'Required key "StationJobStateWrite[state]" is missing from JSON.');
        assert(json[r'state'] != null, 'Required key "StationJobStateWrite[state]" has a null value in JSON.');
        assert(json.containsKey(r'attempts'), 'Required key "StationJobStateWrite[attempts]" is missing from JSON.');
        assert(json[r'attempts'] != null, 'Required key "StationJobStateWrite[attempts]" has a null value in JSON.');
        return true;
      }());

      return StationJobStateWrite(
        state: StationJobStateWriteStateEnum.fromJson(json[r'state'])!,
        attempts: mapValueOfType<int>(json, r'attempts')!,
        lastError: mapValueOfType<String>(json, r'lastError'),
      );
    }
    return null;
  }

  static List<StationJobStateWrite> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <StationJobStateWrite>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = StationJobStateWrite.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, StationJobStateWrite> mapFromJson(dynamic json) {
    final map = <String, StationJobStateWrite>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = StationJobStateWrite.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of StationJobStateWrite-objects as value to a dart map
  static Map<String, List<StationJobStateWrite>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<StationJobStateWrite>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = StationJobStateWrite.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'state',
    'attempts',
  };
}


enum StationJobStateWriteStateEnum {
  QUEUED._(r'QUEUED'),
  SENDING._(r'SENDING'),
  SENT._(r'SENT'),
  FAILED._(r'FAILED'),
  UNKNOWN._(r'UNKNOWN'),
  ;

  /// Instantiate a new enum with the provided value.
  const StationJobStateWriteStateEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [StationJobStateWriteStateEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static StationJobStateWriteStateEnum? fromJson(dynamic value) => StationJobStateWriteStateEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [StationJobStateWriteStateEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<StationJobStateWriteStateEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <StationJobStateWriteStateEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = StationJobStateWriteStateEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [StationJobStateWriteStateEnum] to String,
/// and [decode] dynamic data back to [StationJobStateWriteStateEnum].
class StationJobStateWriteStateEnumTypeTransformer {
  factory StationJobStateWriteStateEnumTypeTransformer() => _instance ??= const StationJobStateWriteStateEnumTypeTransformer._();

  const StationJobStateWriteStateEnumTypeTransformer._();

  String encode(StationJobStateWriteStateEnum data) => data._value;

  /// Returns the instance of [StationJobStateWriteStateEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  StationJobStateWriteStateEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is StationJobStateWriteStateEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'QUEUED': return StationJobStateWriteStateEnum.QUEUED;
        case r'SENDING': return StationJobStateWriteStateEnum.SENDING;
        case r'SENT': return StationJobStateWriteStateEnum.SENT;
        case r'FAILED': return StationJobStateWriteStateEnum.FAILED;
        case r'UNKNOWN': return StationJobStateWriteStateEnum.UNKNOWN;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static StationJobStateWriteStateEnumTypeTransformer? _instance;
}


