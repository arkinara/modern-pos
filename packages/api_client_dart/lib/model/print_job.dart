//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PrintJob {
  /// Returns a new [PrintJob] instance.
  PrintJob({
    required this.id,
    required this.saleId,
    required this.deviceId,
    required this.state,
    required this.copy,
    required this.attempts,
    required this.lastError,
  });

  String id;

  String saleId;

  String deviceId;

  PrintJobStateEnum state;

  bool copy;

  /// Minimum value: 0
  int attempts;

  String? lastError;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PrintJob &&
    other.id == id &&
    other.saleId == saleId &&
    other.deviceId == deviceId &&
    other.state == state &&
    other.copy == copy &&
    other.attempts == attempts &&
    other.lastError == lastError;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (saleId.hashCode) +
    (deviceId.hashCode) +
    (state.hashCode) +
    (copy.hashCode) +
    (attempts.hashCode) +
    (lastError == null ? 0 : lastError!.hashCode);

  @override
  String toString() => 'PrintJob[id=$id, saleId=$saleId, deviceId=$deviceId, state=$state, copy=$copy, attempts=$attempts, lastError=$lastError]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'saleId'] = this.saleId;
      json[r'deviceId'] = this.deviceId;
      json[r'state'] = this.state;
      json[r'copy'] = this.copy;
      json[r'attempts'] = this.attempts;
    if (this.lastError != null) {
      json[r'lastError'] = this.lastError;
    } else {
      json[r'lastError'] = null;
    }
    return json;
  }

  /// Returns a new [PrintJob] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PrintJob? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "PrintJob[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "PrintJob[id]" has a null value in JSON.');
        assert(json.containsKey(r'saleId'), 'Required key "PrintJob[saleId]" is missing from JSON.');
        assert(json[r'saleId'] != null, 'Required key "PrintJob[saleId]" has a null value in JSON.');
        assert(json.containsKey(r'deviceId'), 'Required key "PrintJob[deviceId]" is missing from JSON.');
        assert(json[r'deviceId'] != null, 'Required key "PrintJob[deviceId]" has a null value in JSON.');
        assert(json.containsKey(r'state'), 'Required key "PrintJob[state]" is missing from JSON.');
        assert(json[r'state'] != null, 'Required key "PrintJob[state]" has a null value in JSON.');
        assert(json.containsKey(r'copy'), 'Required key "PrintJob[copy]" is missing from JSON.');
        assert(json[r'copy'] != null, 'Required key "PrintJob[copy]" has a null value in JSON.');
        assert(json.containsKey(r'attempts'), 'Required key "PrintJob[attempts]" is missing from JSON.');
        assert(json[r'attempts'] != null, 'Required key "PrintJob[attempts]" has a null value in JSON.');
        assert(json.containsKey(r'lastError'), 'Required key "PrintJob[lastError]" is missing from JSON.');
        return true;
      }());

      return PrintJob(
        id: mapValueOfType<String>(json, r'id')!,
        saleId: mapValueOfType<String>(json, r'saleId')!,
        deviceId: mapValueOfType<String>(json, r'deviceId')!,
        state: PrintJobStateEnum.fromJson(json[r'state'])!,
        copy: mapValueOfType<bool>(json, r'copy')!,
        attempts: mapValueOfType<int>(json, r'attempts')!,
        lastError: mapValueOfType<String>(json, r'lastError'),
      );
    }
    return null;
  }

  static List<PrintJob> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PrintJob>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PrintJob.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PrintJob> mapFromJson(dynamic json) {
    final map = <String, PrintJob>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PrintJob.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PrintJob-objects as value to a dart map
  static Map<String, List<PrintJob>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PrintJob>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PrintJob.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'saleId',
    'deviceId',
    'state',
    'copy',
    'attempts',
    'lastError',
  };
}


enum PrintJobStateEnum {
  QUEUED._(r'QUEUED'),
  SENDING._(r'SENDING'),
  SENT._(r'SENT'),
  FAILED._(r'FAILED'),
  UNKNOWN._(r'UNKNOWN'),
  ;

  /// Instantiate a new enum with the provided value.
  const PrintJobStateEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [PrintJobStateEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static PrintJobStateEnum? fromJson(dynamic value) => PrintJobStateEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [PrintJobStateEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<PrintJobStateEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PrintJobStateEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PrintJobStateEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [PrintJobStateEnum] to String,
/// and [decode] dynamic data back to [PrintJobStateEnum].
class PrintJobStateEnumTypeTransformer {
  factory PrintJobStateEnumTypeTransformer() => _instance ??= const PrintJobStateEnumTypeTransformer._();

  const PrintJobStateEnumTypeTransformer._();

  String encode(PrintJobStateEnum data) => data._value;

  /// Returns the instance of [PrintJobStateEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  PrintJobStateEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is PrintJobStateEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'QUEUED': return PrintJobStateEnum.QUEUED;
        case r'SENDING': return PrintJobStateEnum.SENDING;
        case r'SENT': return PrintJobStateEnum.SENT;
        case r'FAILED': return PrintJobStateEnum.FAILED;
        case r'UNKNOWN': return PrintJobStateEnum.UNKNOWN;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static PrintJobStateEnumTypeTransformer? _instance;
}


