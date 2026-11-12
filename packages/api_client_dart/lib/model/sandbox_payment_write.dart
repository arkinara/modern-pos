//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SandboxPaymentWrite {
  /// Returns a new [SandboxPaymentWrite] instance.
  SandboxPaymentWrite({
    required this.idempotencyKey,
    required this.amountMinor,
    required this.currency,
  });

  String idempotencyKey;

  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int amountMinor;

  String currency;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SandboxPaymentWrite &&
    other.idempotencyKey == idempotencyKey &&
    other.amountMinor == amountMinor &&
    other.currency == currency;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (idempotencyKey.hashCode) +
    (amountMinor.hashCode) +
    (currency.hashCode);

  @override
  String toString() => 'SandboxPaymentWrite[idempotencyKey=$idempotencyKey, amountMinor=$amountMinor, currency=$currency]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'idempotencyKey'] = this.idempotencyKey;
      json[r'amountMinor'] = this.amountMinor;
      json[r'currency'] = this.currency;
    return json;
  }

  /// Returns a new [SandboxPaymentWrite] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SandboxPaymentWrite? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'idempotencyKey'), 'Required key "SandboxPaymentWrite[idempotencyKey]" is missing from JSON.');
        assert(json[r'idempotencyKey'] != null, 'Required key "SandboxPaymentWrite[idempotencyKey]" has a null value in JSON.');
        assert(json.containsKey(r'amountMinor'), 'Required key "SandboxPaymentWrite[amountMinor]" is missing from JSON.');
        assert(json[r'amountMinor'] != null, 'Required key "SandboxPaymentWrite[amountMinor]" has a null value in JSON.');
        assert(json.containsKey(r'currency'), 'Required key "SandboxPaymentWrite[currency]" is missing from JSON.');
        assert(json[r'currency'] != null, 'Required key "SandboxPaymentWrite[currency]" has a null value in JSON.');
        return true;
      }());

      return SandboxPaymentWrite(
        idempotencyKey: mapValueOfType<String>(json, r'idempotencyKey')!,
        amountMinor: mapValueOfType<int>(json, r'amountMinor')!,
        currency: mapValueOfType<String>(json, r'currency')!,
      );
    }
    return null;
  }

  static List<SandboxPaymentWrite> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SandboxPaymentWrite>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SandboxPaymentWrite.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SandboxPaymentWrite> mapFromJson(dynamic json) {
    final map = <String, SandboxPaymentWrite>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SandboxPaymentWrite.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SandboxPaymentWrite-objects as value to a dart map
  static Map<String, List<SandboxPaymentWrite>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SandboxPaymentWrite>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SandboxPaymentWrite.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'idempotencyKey',
    'amountMinor',
    'currency',
  };
}

