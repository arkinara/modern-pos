//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ReceiptWrite {
  /// Returns a new [ReceiptWrite] instance.
  ReceiptWrite({
    this.customerId,
    this.expiresInMinutes,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? customerId;

  /// Minimum value: 1
  /// Maximum value: 10080
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? expiresInMinutes;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ReceiptWrite &&
    other.customerId == customerId &&
    other.expiresInMinutes == expiresInMinutes;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (customerId == null ? 0 : customerId!.hashCode) +
    (expiresInMinutes == null ? 0 : expiresInMinutes!.hashCode);

  @override
  String toString() => 'ReceiptWrite[customerId=$customerId, expiresInMinutes=$expiresInMinutes]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.customerId != null) {
      json[r'customerId'] = this.customerId;
    } else {
      json[r'customerId'] = null;
    }
    if (this.expiresInMinutes != null) {
      json[r'expiresInMinutes'] = this.expiresInMinutes;
    } else {
      json[r'expiresInMinutes'] = null;
    }
    return json;
  }

  /// Returns a new [ReceiptWrite] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ReceiptWrite? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        return true;
      }());

      return ReceiptWrite(
        customerId: mapValueOfType<String>(json, r'customerId'),
        expiresInMinutes: mapValueOfType<int>(json, r'expiresInMinutes'),
      );
    }
    return null;
  }

  static List<ReceiptWrite> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ReceiptWrite>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ReceiptWrite.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ReceiptWrite> mapFromJson(dynamic json) {
    final map = <String, ReceiptWrite>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ReceiptWrite.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ReceiptWrite-objects as value to a dart map
  static Map<String, List<ReceiptWrite>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ReceiptWrite>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ReceiptWrite.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

