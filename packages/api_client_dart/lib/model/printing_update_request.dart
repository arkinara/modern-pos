//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PrintingUpdateRequest {
  /// Returns a new [PrintingUpdateRequest] instance.
  PrintingUpdateRequest({
    required this.deviceId,
    required this.name,
    required this.model,
    required this.transport,
    required this.paperWidthMm,
    required this.encoding,
    this.connectionSettings = const {},
    required this.revision,
  });

  String deviceId;

  String name;

  String model;

  PrintingUpdateRequestTransportEnum transport;

  PrintingUpdateRequestPaperWidthMmEnum paperWidthMm;

  String encoding;

  Map<String, String> connectionSettings;

  /// Minimum value: 1
  int revision;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PrintingUpdateRequest &&
    other.deviceId == deviceId &&
    other.name == name &&
    other.model == model &&
    other.transport == transport &&
    other.paperWidthMm == paperWidthMm &&
    other.encoding == encoding &&
    _deepEquality.equals(other.connectionSettings, connectionSettings) &&
    other.revision == revision;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (deviceId.hashCode) +
    (name.hashCode) +
    (model.hashCode) +
    (transport.hashCode) +
    (paperWidthMm.hashCode) +
    (encoding.hashCode) +
    (connectionSettings.hashCode) +
    (revision.hashCode);

  @override
  String toString() => 'PrintingUpdateRequest[deviceId=$deviceId, name=$name, model=$model, transport=$transport, paperWidthMm=$paperWidthMm, encoding=$encoding, connectionSettings=$connectionSettings, revision=$revision]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'deviceId'] = this.deviceId;
      json[r'name'] = this.name;
      json[r'model'] = this.model;
      json[r'transport'] = this.transport;
      json[r'paperWidthMm'] = this.paperWidthMm;
      json[r'encoding'] = this.encoding;
      json[r'connectionSettings'] = this.connectionSettings;
      json[r'revision'] = this.revision;
    return json;
  }

  /// Returns a new [PrintingUpdateRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PrintingUpdateRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'deviceId'), 'Required key "PrintingUpdateRequest[deviceId]" is missing from JSON.');
        assert(json[r'deviceId'] != null, 'Required key "PrintingUpdateRequest[deviceId]" has a null value in JSON.');
        assert(json.containsKey(r'name'), 'Required key "PrintingUpdateRequest[name]" is missing from JSON.');
        assert(json[r'name'] != null, 'Required key "PrintingUpdateRequest[name]" has a null value in JSON.');
        assert(json.containsKey(r'model'), 'Required key "PrintingUpdateRequest[model]" is missing from JSON.');
        assert(json[r'model'] != null, 'Required key "PrintingUpdateRequest[model]" has a null value in JSON.');
        assert(json.containsKey(r'transport'), 'Required key "PrintingUpdateRequest[transport]" is missing from JSON.');
        assert(json[r'transport'] != null, 'Required key "PrintingUpdateRequest[transport]" has a null value in JSON.');
        assert(json.containsKey(r'paperWidthMm'), 'Required key "PrintingUpdateRequest[paperWidthMm]" is missing from JSON.');
        assert(json[r'paperWidthMm'] != null, 'Required key "PrintingUpdateRequest[paperWidthMm]" has a null value in JSON.');
        assert(json.containsKey(r'encoding'), 'Required key "PrintingUpdateRequest[encoding]" is missing from JSON.');
        assert(json[r'encoding'] != null, 'Required key "PrintingUpdateRequest[encoding]" has a null value in JSON.');
        assert(json.containsKey(r'connectionSettings'), 'Required key "PrintingUpdateRequest[connectionSettings]" is missing from JSON.');
        assert(json[r'connectionSettings'] != null, 'Required key "PrintingUpdateRequest[connectionSettings]" has a null value in JSON.');
        assert(json.containsKey(r'revision'), 'Required key "PrintingUpdateRequest[revision]" is missing from JSON.');
        assert(json[r'revision'] != null, 'Required key "PrintingUpdateRequest[revision]" has a null value in JSON.');
        return true;
      }());

      return PrintingUpdateRequest(
        deviceId: mapValueOfType<String>(json, r'deviceId')!,
        name: mapValueOfType<String>(json, r'name')!,
        model: mapValueOfType<String>(json, r'model')!,
        transport: PrintingUpdateRequestTransportEnum.fromJson(json[r'transport'])!,
        paperWidthMm: PrintingUpdateRequestPaperWidthMmEnum.fromJson(json[r'paperWidthMm'])!,
        encoding: mapValueOfType<String>(json, r'encoding')!,
        connectionSettings: mapCastOfType<String, String>(json, r'connectionSettings')!,
        revision: mapValueOfType<int>(json, r'revision')!,
      );
    }
    return null;
  }

  static List<PrintingUpdateRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PrintingUpdateRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PrintingUpdateRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PrintingUpdateRequest> mapFromJson(dynamic json) {
    final map = <String, PrintingUpdateRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PrintingUpdateRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PrintingUpdateRequest-objects as value to a dart map
  static Map<String, List<PrintingUpdateRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PrintingUpdateRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PrintingUpdateRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'deviceId',
    'name',
    'model',
    'transport',
    'paperWidthMm',
    'encoding',
    'connectionSettings',
    'revision',
  };
}


enum PrintingUpdateRequestTransportEnum {
  BLUETOOTH._(r'BLUETOOTH'),
  LAN._(r'LAN'),
  USB._(r'USB'),
  ;

  /// Instantiate a new enum with the provided value.
  const PrintingUpdateRequestTransportEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [PrintingUpdateRequestTransportEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static PrintingUpdateRequestTransportEnum? fromJson(dynamic value) => PrintingUpdateRequestTransportEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [PrintingUpdateRequestTransportEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<PrintingUpdateRequestTransportEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PrintingUpdateRequestTransportEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PrintingUpdateRequestTransportEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [PrintingUpdateRequestTransportEnum] to String,
/// and [decode] dynamic data back to [PrintingUpdateRequestTransportEnum].
class PrintingUpdateRequestTransportEnumTypeTransformer {
  factory PrintingUpdateRequestTransportEnumTypeTransformer() => _instance ??= const PrintingUpdateRequestTransportEnumTypeTransformer._();

  const PrintingUpdateRequestTransportEnumTypeTransformer._();

  String encode(PrintingUpdateRequestTransportEnum data) => data._value;

  /// Returns the instance of [PrintingUpdateRequestTransportEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  PrintingUpdateRequestTransportEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is PrintingUpdateRequestTransportEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'BLUETOOTH': return PrintingUpdateRequestTransportEnum.BLUETOOTH;
        case r'LAN': return PrintingUpdateRequestTransportEnum.LAN;
        case r'USB': return PrintingUpdateRequestTransportEnum.USB;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static PrintingUpdateRequestTransportEnumTypeTransformer? _instance;
}



enum PrintingUpdateRequestPaperWidthMmEnum {
  number58._(58),
  number80._(80),
  ;

  /// Instantiate a new enum with the provided value.
  const PrintingUpdateRequestPaperWidthMmEnum._(this._value);

  /// The underlying value of this enum member.
  final int _value;

  @override
  String toString() => _value.toString();

  /// Encodes this enum as a value suitable for JSON.
  int toJson() => _value;

  /// Returns the instance of [PrintingUpdateRequestPaperWidthMmEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static PrintingUpdateRequestPaperWidthMmEnum? fromJson(dynamic value) => PrintingUpdateRequestPaperWidthMmEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [PrintingUpdateRequestPaperWidthMmEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<PrintingUpdateRequestPaperWidthMmEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PrintingUpdateRequestPaperWidthMmEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PrintingUpdateRequestPaperWidthMmEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [PrintingUpdateRequestPaperWidthMmEnum] to int,
/// and [decode] dynamic data back to [PrintingUpdateRequestPaperWidthMmEnum].
class PrintingUpdateRequestPaperWidthMmEnumTypeTransformer {
  factory PrintingUpdateRequestPaperWidthMmEnumTypeTransformer() => _instance ??= const PrintingUpdateRequestPaperWidthMmEnumTypeTransformer._();

  const PrintingUpdateRequestPaperWidthMmEnumTypeTransformer._();

  int encode(PrintingUpdateRequestPaperWidthMmEnum data) => data._value;

  /// Returns the instance of [PrintingUpdateRequestPaperWidthMmEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  PrintingUpdateRequestPaperWidthMmEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is PrintingUpdateRequestPaperWidthMmEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case 58: return PrintingUpdateRequestPaperWidthMmEnum.number58;
        case 80: return PrintingUpdateRequestPaperWidthMmEnum.number80;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static PrintingUpdateRequestPaperWidthMmEnumTypeTransformer? _instance;
}


