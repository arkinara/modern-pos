//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PrintJobWrite {
  /// Returns a new [PrintJobWrite] instance.
  PrintJobWrite({
    required this.id,
    required this.saleId,
    required this.deviceId,
    required this.printerConfigId,
    required this.copy,
  });

  String id;

  String saleId;

  String deviceId;

  String printerConfigId;

  bool copy;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PrintJobWrite &&
    other.id == id &&
    other.saleId == saleId &&
    other.deviceId == deviceId &&
    other.printerConfigId == printerConfigId &&
    other.copy == copy;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (saleId.hashCode) +
    (deviceId.hashCode) +
    (printerConfigId.hashCode) +
    (copy.hashCode);

  @override
  String toString() => 'PrintJobWrite[id=$id, saleId=$saleId, deviceId=$deviceId, printerConfigId=$printerConfigId, copy=$copy]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'saleId'] = this.saleId;
      json[r'deviceId'] = this.deviceId;
      json[r'printerConfigId'] = this.printerConfigId;
      json[r'copy'] = this.copy;
    return json;
  }

  /// Returns a new [PrintJobWrite] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PrintJobWrite? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "PrintJobWrite[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "PrintJobWrite[id]" has a null value in JSON.');
        assert(json.containsKey(r'saleId'), 'Required key "PrintJobWrite[saleId]" is missing from JSON.');
        assert(json[r'saleId'] != null, 'Required key "PrintJobWrite[saleId]" has a null value in JSON.');
        assert(json.containsKey(r'deviceId'), 'Required key "PrintJobWrite[deviceId]" is missing from JSON.');
        assert(json[r'deviceId'] != null, 'Required key "PrintJobWrite[deviceId]" has a null value in JSON.');
        assert(json.containsKey(r'printerConfigId'), 'Required key "PrintJobWrite[printerConfigId]" is missing from JSON.');
        assert(json[r'printerConfigId'] != null, 'Required key "PrintJobWrite[printerConfigId]" has a null value in JSON.');
        assert(json.containsKey(r'copy'), 'Required key "PrintJobWrite[copy]" is missing from JSON.');
        assert(json[r'copy'] != null, 'Required key "PrintJobWrite[copy]" has a null value in JSON.');
        return true;
      }());

      return PrintJobWrite(
        id: mapValueOfType<String>(json, r'id')!,
        saleId: mapValueOfType<String>(json, r'saleId')!,
        deviceId: mapValueOfType<String>(json, r'deviceId')!,
        printerConfigId: mapValueOfType<String>(json, r'printerConfigId')!,
        copy: mapValueOfType<bool>(json, r'copy')!,
      );
    }
    return null;
  }

  static List<PrintJobWrite> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PrintJobWrite>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PrintJobWrite.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PrintJobWrite> mapFromJson(dynamic json) {
    final map = <String, PrintJobWrite>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PrintJobWrite.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PrintJobWrite-objects as value to a dart map
  static Map<String, List<PrintJobWrite>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PrintJobWrite>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PrintJobWrite.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'saleId',
    'deviceId',
    'printerConfigId',
    'copy',
  };
}

