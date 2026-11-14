//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class DigitalReceiptPublic {
  /// Returns a new [DigitalReceiptPublic] instance.
  DigitalReceiptPublic({
    required this.receiptNumber,
    required this.issuedAt,
    required this.expiresAt,
    required this.html,
    required this.text,
  });

  String receiptNumber;

  DateTime issuedAt;

  DateTime expiresAt;

  String html;

  String text;

  @override
  bool operator ==(Object other) => identical(this, other) || other is DigitalReceiptPublic &&
    other.receiptNumber == receiptNumber &&
    other.issuedAt == issuedAt &&
    other.expiresAt == expiresAt &&
    other.html == html &&
    other.text == text;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (receiptNumber.hashCode) +
    (issuedAt.hashCode) +
    (expiresAt.hashCode) +
    (html.hashCode) +
    (text.hashCode);

  @override
  String toString() => 'DigitalReceiptPublic[receiptNumber=$receiptNumber, issuedAt=$issuedAt, expiresAt=$expiresAt, html=$html, text=$text]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'receiptNumber'] = this.receiptNumber;
      json[r'issuedAt'] = this.issuedAt.toUtc().toIso8601String();
      json[r'expiresAt'] = this.expiresAt.toUtc().toIso8601String();
      json[r'html'] = this.html;
      json[r'text'] = this.text;
    return json;
  }

  /// Returns a new [DigitalReceiptPublic] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DigitalReceiptPublic? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'receiptNumber'), 'Required key "DigitalReceiptPublic[receiptNumber]" is missing from JSON.');
        assert(json[r'receiptNumber'] != null, 'Required key "DigitalReceiptPublic[receiptNumber]" has a null value in JSON.');
        assert(json.containsKey(r'issuedAt'), 'Required key "DigitalReceiptPublic[issuedAt]" is missing from JSON.');
        assert(json[r'issuedAt'] != null, 'Required key "DigitalReceiptPublic[issuedAt]" has a null value in JSON.');
        assert(json.containsKey(r'expiresAt'), 'Required key "DigitalReceiptPublic[expiresAt]" is missing from JSON.');
        assert(json[r'expiresAt'] != null, 'Required key "DigitalReceiptPublic[expiresAt]" has a null value in JSON.');
        assert(json.containsKey(r'html'), 'Required key "DigitalReceiptPublic[html]" is missing from JSON.');
        assert(json[r'html'] != null, 'Required key "DigitalReceiptPublic[html]" has a null value in JSON.');
        assert(json.containsKey(r'text'), 'Required key "DigitalReceiptPublic[text]" is missing from JSON.');
        assert(json[r'text'] != null, 'Required key "DigitalReceiptPublic[text]" has a null value in JSON.');
        return true;
      }());

      return DigitalReceiptPublic(
        receiptNumber: mapValueOfType<String>(json, r'receiptNumber')!,
        issuedAt: mapDateTime(json, r'issuedAt', r'')!,
        expiresAt: mapDateTime(json, r'expiresAt', r'')!,
        html: mapValueOfType<String>(json, r'html')!,
        text: mapValueOfType<String>(json, r'text')!,
      );
    }
    return null;
  }

  static List<DigitalReceiptPublic> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DigitalReceiptPublic>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DigitalReceiptPublic.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DigitalReceiptPublic> mapFromJson(dynamic json) {
    final map = <String, DigitalReceiptPublic>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DigitalReceiptPublic.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DigitalReceiptPublic-objects as value to a dart map
  static Map<String, List<DigitalReceiptPublic>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<DigitalReceiptPublic>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DigitalReceiptPublic.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'receiptNumber',
    'issuedAt',
    'expiresAt',
    'html',
    'text',
  };
}

