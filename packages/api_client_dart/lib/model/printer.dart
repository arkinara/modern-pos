//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Printer {
  /// Returns a new [Printer] instance.
  Printer({
    required this.id,
    required this.deviceId,
    required this.name,
    required this.model,
    required this.transport,
    required this.paperWidthMm,
    required this.encoding,
    required this.revision,
  });

  String id;

  String deviceId;

  String name;

  String model;

  PrinterTransportEnum transport;

  PrinterPaperWidthMmEnum paperWidthMm;

  String encoding;

  /// Minimum value: 1
  int revision;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Printer &&
    other.id == id &&
    other.deviceId == deviceId &&
    other.name == name &&
    other.model == model &&
    other.transport == transport &&
    other.paperWidthMm == paperWidthMm &&
    other.encoding == encoding &&
    other.revision == revision;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (deviceId.hashCode) +
    (name.hashCode) +
    (model.hashCode) +
    (transport.hashCode) +
    (paperWidthMm.hashCode) +
    (encoding.hashCode) +
    (revision.hashCode);

  @override
  String toString() => 'Printer[id=$id, deviceId=$deviceId, name=$name, model=$model, transport=$transport, paperWidthMm=$paperWidthMm, encoding=$encoding, revision=$revision]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'deviceId'] = this.deviceId;
      json[r'name'] = this.name;
      json[r'model'] = this.model;
      json[r'transport'] = this.transport;
      json[r'paperWidthMm'] = this.paperWidthMm;
      json[r'encoding'] = this.encoding;
      json[r'revision'] = this.revision;
    return json;
  }

  /// Returns a new [Printer] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Printer? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "Printer[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "Printer[id]" has a null value in JSON.');
        assert(json.containsKey(r'deviceId'), 'Required key "Printer[deviceId]" is missing from JSON.');
        assert(json[r'deviceId'] != null, 'Required key "Printer[deviceId]" has a null value in JSON.');
        assert(json.containsKey(r'name'), 'Required key "Printer[name]" is missing from JSON.');
        assert(json[r'name'] != null, 'Required key "Printer[name]" has a null value in JSON.');
        assert(json.containsKey(r'model'), 'Required key "Printer[model]" is missing from JSON.');
        assert(json[r'model'] != null, 'Required key "Printer[model]" has a null value in JSON.');
        assert(json.containsKey(r'transport'), 'Required key "Printer[transport]" is missing from JSON.');
        assert(json[r'transport'] != null, 'Required key "Printer[transport]" has a null value in JSON.');
        assert(json.containsKey(r'paperWidthMm'), 'Required key "Printer[paperWidthMm]" is missing from JSON.');
        assert(json[r'paperWidthMm'] != null, 'Required key "Printer[paperWidthMm]" has a null value in JSON.');
        assert(json.containsKey(r'encoding'), 'Required key "Printer[encoding]" is missing from JSON.');
        assert(json[r'encoding'] != null, 'Required key "Printer[encoding]" has a null value in JSON.');
        assert(json.containsKey(r'revision'), 'Required key "Printer[revision]" is missing from JSON.');
        assert(json[r'revision'] != null, 'Required key "Printer[revision]" has a null value in JSON.');
        return true;
      }());

      return Printer(
        id: mapValueOfType<String>(json, r'id')!,
        deviceId: mapValueOfType<String>(json, r'deviceId')!,
        name: mapValueOfType<String>(json, r'name')!,
        model: mapValueOfType<String>(json, r'model')!,
        transport: PrinterTransportEnum.fromJson(json[r'transport'])!,
        paperWidthMm: PrinterPaperWidthMmEnum.fromJson(json[r'paperWidthMm'])!,
        encoding: mapValueOfType<String>(json, r'encoding')!,
        revision: mapValueOfType<int>(json, r'revision')!,
      );
    }
    return null;
  }

  static List<Printer> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Printer>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Printer.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Printer> mapFromJson(dynamic json) {
    final map = <String, Printer>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Printer.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Printer-objects as value to a dart map
  static Map<String, List<Printer>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Printer>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Printer.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'deviceId',
    'name',
    'model',
    'transport',
    'paperWidthMm',
    'encoding',
    'revision',
  };
}


enum PrinterTransportEnum {
  BLUETOOTH._(r'BLUETOOTH'),
  LAN._(r'LAN'),
  USB._(r'USB'),
  ;

  /// Instantiate a new enum with the provided value.
  const PrinterTransportEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [PrinterTransportEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static PrinterTransportEnum? fromJson(dynamic value) => PrinterTransportEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [PrinterTransportEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<PrinterTransportEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PrinterTransportEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PrinterTransportEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [PrinterTransportEnum] to String,
/// and [decode] dynamic data back to [PrinterTransportEnum].
class PrinterTransportEnumTypeTransformer {
  factory PrinterTransportEnumTypeTransformer() => _instance ??= const PrinterTransportEnumTypeTransformer._();

  const PrinterTransportEnumTypeTransformer._();

  String encode(PrinterTransportEnum data) => data._value;

  /// Returns the instance of [PrinterTransportEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  PrinterTransportEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is PrinterTransportEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'BLUETOOTH': return PrinterTransportEnum.BLUETOOTH;
        case r'LAN': return PrinterTransportEnum.LAN;
        case r'USB': return PrinterTransportEnum.USB;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static PrinterTransportEnumTypeTransformer? _instance;
}



enum PrinterPaperWidthMmEnum {
  number58._(58),
  number80._(80),
  ;

  /// Instantiate a new enum with the provided value.
  const PrinterPaperWidthMmEnum._(this._value);

  /// The underlying value of this enum member.
  final int _value;

  @override
  String toString() => _value.toString();

  /// Encodes this enum as a value suitable for JSON.
  int toJson() => _value;

  /// Returns the instance of [PrinterPaperWidthMmEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static PrinterPaperWidthMmEnum? fromJson(dynamic value) => PrinterPaperWidthMmEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [PrinterPaperWidthMmEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<PrinterPaperWidthMmEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PrinterPaperWidthMmEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PrinterPaperWidthMmEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [PrinterPaperWidthMmEnum] to int,
/// and [decode] dynamic data back to [PrinterPaperWidthMmEnum].
class PrinterPaperWidthMmEnumTypeTransformer {
  factory PrinterPaperWidthMmEnumTypeTransformer() => _instance ??= const PrinterPaperWidthMmEnumTypeTransformer._();

  const PrinterPaperWidthMmEnumTypeTransformer._();

  int encode(PrinterPaperWidthMmEnum data) => data._value;

  /// Returns the instance of [PrinterPaperWidthMmEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  PrinterPaperWidthMmEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is PrinterPaperWidthMmEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case 58: return PrinterPaperWidthMmEnum.number58;
        case 80: return PrinterPaperWidthMmEnum.number80;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static PrinterPaperWidthMmEnumTypeTransformer? _instance;
}


