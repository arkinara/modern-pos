//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ChannelOrderPayment {
  /// Returns a new [ChannelOrderPayment] instance.
  ChannelOrderPayment({
    required this.id,
    required this.amountMinor,
    required this.status,
    required this.method,
    required this.reference,
    required this.createdAt,
  });

  String id;

  int amountMinor;

  ChannelPaymentStatus status;

  ChannelPaymentMode method;

  String? reference;

  DateTime createdAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ChannelOrderPayment &&
    other.id == id &&
    other.amountMinor == amountMinor &&
    other.status == status &&
    other.method == method &&
    other.reference == reference &&
    other.createdAt == createdAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (amountMinor.hashCode) +
    (status.hashCode) +
    (method.hashCode) +
    (reference == null ? 0 : reference!.hashCode) +
    (createdAt.hashCode);

  @override
  String toString() => 'ChannelOrderPayment[id=$id, amountMinor=$amountMinor, status=$status, method=$method, reference=$reference, createdAt=$createdAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'amountMinor'] = this.amountMinor;
      json[r'status'] = this.status;
      json[r'method'] = this.method;
    if (this.reference != null) {
      json[r'reference'] = this.reference;
    } else {
      json[r'reference'] = null;
    }
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [ChannelOrderPayment] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ChannelOrderPayment? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "ChannelOrderPayment[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "ChannelOrderPayment[id]" has a null value in JSON.');
        assert(json.containsKey(r'amountMinor'), 'Required key "ChannelOrderPayment[amountMinor]" is missing from JSON.');
        assert(json[r'amountMinor'] != null, 'Required key "ChannelOrderPayment[amountMinor]" has a null value in JSON.');
        assert(json.containsKey(r'status'), 'Required key "ChannelOrderPayment[status]" is missing from JSON.');
        assert(json[r'status'] != null, 'Required key "ChannelOrderPayment[status]" has a null value in JSON.');
        assert(json.containsKey(r'method'), 'Required key "ChannelOrderPayment[method]" is missing from JSON.');
        assert(json[r'method'] != null, 'Required key "ChannelOrderPayment[method]" has a null value in JSON.');
        assert(json.containsKey(r'reference'), 'Required key "ChannelOrderPayment[reference]" is missing from JSON.');
        assert(json.containsKey(r'createdAt'), 'Required key "ChannelOrderPayment[createdAt]" is missing from JSON.');
        assert(json[r'createdAt'] != null, 'Required key "ChannelOrderPayment[createdAt]" has a null value in JSON.');
        return true;
      }());

      return ChannelOrderPayment(
        id: mapValueOfType<String>(json, r'id')!,
        amountMinor: mapValueOfType<int>(json, r'amountMinor')!,
        status: ChannelPaymentStatus.fromJson(json[r'status'])!,
        method: ChannelPaymentMode.fromJson(json[r'method'])!,
        reference: mapValueOfType<String>(json, r'reference'),
        createdAt: mapDateTime(json, r'createdAt', r'')!,
      );
    }
    return null;
  }

  static List<ChannelOrderPayment> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ChannelOrderPayment>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ChannelOrderPayment.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ChannelOrderPayment> mapFromJson(dynamic json) {
    final map = <String, ChannelOrderPayment>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ChannelOrderPayment.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ChannelOrderPayment-objects as value to a dart map
  static Map<String, List<ChannelOrderPayment>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ChannelOrderPayment>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ChannelOrderPayment.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'amountMinor',
    'status',
    'method',
    'reference',
    'createdAt',
  };
}

