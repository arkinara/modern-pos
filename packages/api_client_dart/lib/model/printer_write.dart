//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PrinterWrite {
  /// Returns a new [PrinterWrite] instance.
  PrinterWrite({
    required this.deviceId,
    required this.name,
    required this.model,
    required this.transport,
    required this.paperWidthMm,
    required this.encoding,
    this.connectionSettings = const {},
  });

  String deviceId;

  String name;

  String model;

  PrinterWriteTransportEnum transport;

  PrinterWritePaperWidthMmEnum paperWidthMm;

  String encoding;

  Map<String, String> connectionSettings;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PrinterWrite &&
    other.deviceId == deviceId &&
    other.name == name &&
    other.model == model &&
    other.transport == transport &&
    other.paperWidthMm == paperWidthMm &&
    other.encoding == encoding &&
    _deepEquality.equals(other.connectionSettings, connectionSettings);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (deviceId.hashCode) +
    (name.hashCode) +
    (model.hashCode) +
    (transport.hashCode) +
    (paperWidthMm.hashCode) +
    (encoding.hashCode) +
    (connectionSettings.hashCode);

  @override
  String toString() => 'PrinterWrite[deviceId=$deviceId, name=$name, model=$model, transport=$transport, paperWidthMm=$paperWidthMm, encoding=$encoding, connectionSettings=$connectionSettings]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'deviceId'] = this.deviceId;
      json[r'name'] = this.name;
      json[r'model'] = this.model;
      json[r'transport'] = this.transport;
      json[r'paperWidthMm'] = this.paperWidthMm;
      json[r'encoding'] = this.encoding;
      json[r'connectionSettings'] = this.connectionSettings;
    return json;
  }

  /// Returns a new [PrinterWrite] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PrinterWrite? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'deviceId'), 'Required key "PrinterWrite[deviceId]" is missing from JSON.');
        assert(json[r'deviceId'] != null, 'Required key "PrinterWrite[deviceId]" has a null value in JSON.');
        assert(json.containsKey(r'name'), 'Required key "PrinterWrite[name]" is missing from JSON.');
        assert(json[r'name'] != null, 'Required key "PrinterWrite[name]" has a null value in JSON.');
        assert(json.containsKey(r'model'), 'Required key "PrinterWrite[model]" is missing from JSON.');
        assert(json[r'model'] != null, 'Required key "PrinterWrite[model]" has a null value in JSON.');
        assert(json.containsKey(r'transport'), 'Required key "PrinterWrite[transport]" is missing from JSON.');
        assert(json[r'transport'] != null, 'Required key "PrinterWrite[transport]" has a null value in JSON.');
        assert(json.containsKey(r'paperWidthMm'), 'Required key "PrinterWrite[paperWidthMm]" is missing from JSON.');
        assert(json[r'paperWidthMm'] != null, 'Required key "PrinterWrite[paperWidthMm]" has a null value in JSON.');
        assert(json.containsKey(r'encoding'), 'Required key "PrinterWrite[encoding]" is missing from JSON.');
        assert(json[r'encoding'] != null, 'Required key "PrinterWrite[encoding]" has a null value in JSON.');
        assert(json.containsKey(r'connectionSettings'), 'Required key "PrinterWrite[connectionSettings]" is missing from JSON.');
        assert(json[r'connectionSettings'] != null, 'Required key "PrinterWrite[connectionSettings]" has a null value in JSON.');
        return true;
      }());

      return PrinterWrite(
        deviceId: mapValueOfType<String>(json, r'deviceId')!,
        name: mapValueOfType<String>(json, r'name')!,
        model: mapValueOfType<String>(json, r'model')!,
        transport: PrinterWriteTransportEnum.fromJson(json[r'transport'])!,
        paperWidthMm: PrinterWritePaperWidthMmEnum.fromJson(json[r'paperWidthMm'])!,
        encoding: mapValueOfType<String>(json, r'encoding')!,
        connectionSettings: mapCastOfType<String, String>(json, r'connectionSettings')!,
      );
    }
    return null;
  }

  static List<PrinterWrite> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PrinterWrite>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PrinterWrite.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PrinterWrite> mapFromJson(dynamic json) {
    final map = <String, PrinterWrite>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PrinterWrite.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PrinterWrite-objects as value to a dart map
  static Map<String, List<PrinterWrite>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PrinterWrite>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PrinterWrite.listFromJson(entry.value, growable: growable,);
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
  };
}


enum PrinterWriteTransportEnum {
  BLUETOOTH._(r'BLUETOOTH'),
  LAN._(r'LAN'),
  USB._(r'USB'),
  ;

  /// Instantiate a new enum with the provided value.
  const PrinterWriteTransportEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [PrinterWriteTransportEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static PrinterWriteTransportEnum? fromJson(dynamic value) => PrinterWriteTransportEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [PrinterWriteTransportEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<PrinterWriteTransportEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PrinterWriteTransportEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PrinterWriteTransportEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [PrinterWriteTransportEnum] to String,
/// and [decode] dynamic data back to [PrinterWriteTransportEnum].
class PrinterWriteTransportEnumTypeTransformer {
  factory PrinterWriteTransportEnumTypeTransformer() => _instance ??= const PrinterWriteTransportEnumTypeTransformer._();

  const PrinterWriteTransportEnumTypeTransformer._();

  String encode(PrinterWriteTransportEnum data) => data._value;

  /// Returns the instance of [PrinterWriteTransportEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  PrinterWriteTransportEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is PrinterWriteTransportEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'BLUETOOTH': return PrinterWriteTransportEnum.BLUETOOTH;
        case r'LAN': return PrinterWriteTransportEnum.LAN;
        case r'USB': return PrinterWriteTransportEnum.USB;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static PrinterWriteTransportEnumTypeTransformer? _instance;
}



enum PrinterWritePaperWidthMmEnum {
  number58._(58),
  number80._(80),
  ;

  /// Instantiate a new enum with the provided value.
  const PrinterWritePaperWidthMmEnum._(this._value);

  /// The underlying value of this enum member.
  final int _value;

  @override
  String toString() => _value.toString();

  /// Encodes this enum as a value suitable for JSON.
  int toJson() => _value;

  /// Returns the instance of [PrinterWritePaperWidthMmEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static PrinterWritePaperWidthMmEnum? fromJson(dynamic value) => PrinterWritePaperWidthMmEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [PrinterWritePaperWidthMmEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<PrinterWritePaperWidthMmEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PrinterWritePaperWidthMmEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PrinterWritePaperWidthMmEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [PrinterWritePaperWidthMmEnum] to int,
/// and [decode] dynamic data back to [PrinterWritePaperWidthMmEnum].
class PrinterWritePaperWidthMmEnumTypeTransformer {
  factory PrinterWritePaperWidthMmEnumTypeTransformer() => _instance ??= const PrinterWritePaperWidthMmEnumTypeTransformer._();

  const PrinterWritePaperWidthMmEnumTypeTransformer._();

  int encode(PrinterWritePaperWidthMmEnum data) => data._value;

  /// Returns the instance of [PrinterWritePaperWidthMmEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  PrinterWritePaperWidthMmEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is PrinterWritePaperWidthMmEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case 58: return PrinterWritePaperWidthMmEnum.number58;
        case 80: return PrinterWritePaperWidthMmEnum.number80;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static PrinterWritePaperWidthMmEnumTypeTransformer? _instance;
}


