//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PrintingStateRequest {
  /// Returns a new [PrintingStateRequest] instance.
  PrintingStateRequest({
    required this.deviceId,
    required this.state,
    required this.attempts,
    required this.lastError,
  });

  String deviceId;

  PrintingStateRequestStateEnum state;

  /// Minimum value: 0
  int attempts;

  String? lastError;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PrintingStateRequest &&
    other.deviceId == deviceId &&
    other.state == state &&
    other.attempts == attempts &&
    other.lastError == lastError;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (deviceId.hashCode) +
    (state.hashCode) +
    (attempts.hashCode) +
    (lastError == null ? 0 : lastError!.hashCode);

  @override
  String toString() => 'PrintingStateRequest[deviceId=$deviceId, state=$state, attempts=$attempts, lastError=$lastError]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'deviceId'] = this.deviceId;
      json[r'state'] = this.state;
      json[r'attempts'] = this.attempts;
    if (this.lastError != null) {
      json[r'lastError'] = this.lastError;
    } else {
      json[r'lastError'] = null;
    }
    return json;
  }

  /// Returns a new [PrintingStateRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PrintingStateRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'deviceId'), 'Required key "PrintingStateRequest[deviceId]" is missing from JSON.');
        assert(json[r'deviceId'] != null, 'Required key "PrintingStateRequest[deviceId]" has a null value in JSON.');
        assert(json.containsKey(r'state'), 'Required key "PrintingStateRequest[state]" is missing from JSON.');
        assert(json[r'state'] != null, 'Required key "PrintingStateRequest[state]" has a null value in JSON.');
        assert(json.containsKey(r'attempts'), 'Required key "PrintingStateRequest[attempts]" is missing from JSON.');
        assert(json[r'attempts'] != null, 'Required key "PrintingStateRequest[attempts]" has a null value in JSON.');
        assert(json.containsKey(r'lastError'), 'Required key "PrintingStateRequest[lastError]" is missing from JSON.');
        return true;
      }());

      return PrintingStateRequest(
        deviceId: mapValueOfType<String>(json, r'deviceId')!,
        state: PrintingStateRequestStateEnum.fromJson(json[r'state'])!,
        attempts: mapValueOfType<int>(json, r'attempts')!,
        lastError: mapValueOfType<String>(json, r'lastError'),
      );
    }
    return null;
  }

  static List<PrintingStateRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PrintingStateRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PrintingStateRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PrintingStateRequest> mapFromJson(dynamic json) {
    final map = <String, PrintingStateRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PrintingStateRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PrintingStateRequest-objects as value to a dart map
  static Map<String, List<PrintingStateRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PrintingStateRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PrintingStateRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'deviceId',
    'state',
    'attempts',
    'lastError',
  };
}


enum PrintingStateRequestStateEnum {
  QUEUED._(r'QUEUED'),
  SENDING._(r'SENDING'),
  SENT._(r'SENT'),
  FAILED._(r'FAILED'),
  UNKNOWN._(r'UNKNOWN'),
  ;

  /// Instantiate a new enum with the provided value.
  const PrintingStateRequestStateEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [PrintingStateRequestStateEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static PrintingStateRequestStateEnum? fromJson(dynamic value) => PrintingStateRequestStateEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [PrintingStateRequestStateEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<PrintingStateRequestStateEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PrintingStateRequestStateEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PrintingStateRequestStateEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [PrintingStateRequestStateEnum] to String,
/// and [decode] dynamic data back to [PrintingStateRequestStateEnum].
class PrintingStateRequestStateEnumTypeTransformer {
  factory PrintingStateRequestStateEnumTypeTransformer() => _instance ??= const PrintingStateRequestStateEnumTypeTransformer._();

  const PrintingStateRequestStateEnumTypeTransformer._();

  String encode(PrintingStateRequestStateEnum data) => data._value;

  /// Returns the instance of [PrintingStateRequestStateEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  PrintingStateRequestStateEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is PrintingStateRequestStateEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'QUEUED': return PrintingStateRequestStateEnum.QUEUED;
        case r'SENDING': return PrintingStateRequestStateEnum.SENDING;
        case r'SENT': return PrintingStateRequestStateEnum.SENT;
        case r'FAILED': return PrintingStateRequestStateEnum.FAILED;
        case r'UNKNOWN': return PrintingStateRequestStateEnum.UNKNOWN;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static PrintingStateRequestStateEnumTypeTransformer? _instance;
}


