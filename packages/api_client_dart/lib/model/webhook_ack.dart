//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class WebhookAck {
  /// Returns a new [WebhookAck] instance.
  WebhookAck({
    required this.received,
    required this.duplicate,
    this.status,
    required this.eventId,
  });

  bool received;

  bool duplicate;

  WebhookAckStatusEnum? status;

  String eventId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is WebhookAck &&
    other.received == received &&
    other.duplicate == duplicate &&
    other.status == status &&
    other.eventId == eventId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (received.hashCode) +
    (duplicate.hashCode) +
    (status == null ? 0 : status!.hashCode) +
    (eventId.hashCode);

  @override
  String toString() => 'WebhookAck[received=$received, duplicate=$duplicate, status=$status, eventId=$eventId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'received'] = this.received;
      json[r'duplicate'] = this.duplicate;
    if (this.status != null) {
      json[r'status'] = this.status;
    } else {
      json[r'status'] = null;
    }
      json[r'eventId'] = this.eventId;
    return json;
  }

  /// Returns a new [WebhookAck] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static WebhookAck? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'received'), 'Required key "WebhookAck[received]" is missing from JSON.');
        assert(json[r'received'] != null, 'Required key "WebhookAck[received]" has a null value in JSON.');
        assert(json.containsKey(r'duplicate'), 'Required key "WebhookAck[duplicate]" is missing from JSON.');
        assert(json[r'duplicate'] != null, 'Required key "WebhookAck[duplicate]" has a null value in JSON.');
        assert(json.containsKey(r'eventId'), 'Required key "WebhookAck[eventId]" is missing from JSON.');
        assert(json[r'eventId'] != null, 'Required key "WebhookAck[eventId]" has a null value in JSON.');
        return true;
      }());

      return WebhookAck(
        received: mapValueOfType<bool>(json, r'received')!,
        duplicate: mapValueOfType<bool>(json, r'duplicate')!,
        status: WebhookAckStatusEnum.fromJson(json[r'status']),
        eventId: mapValueOfType<String>(json, r'eventId')!,
      );
    }
    return null;
  }

  static List<WebhookAck> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <WebhookAck>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = WebhookAck.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, WebhookAck> mapFromJson(dynamic json) {
    final map = <String, WebhookAck>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = WebhookAck.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of WebhookAck-objects as value to a dart map
  static Map<String, List<WebhookAck>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<WebhookAck>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = WebhookAck.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'received',
    'duplicate',
    'eventId',
  };
}


enum WebhookAckStatusEnum {
  PENDING._(r'PENDING'),
  SUCCEEDED._(r'SUCCEEDED'),
  FAILED._(r'FAILED'),
  REFUNDED._(r'REFUNDED'),
  PARTIALLY_REFUNDED._(r'PARTIALLY_REFUNDED'),
  ;

  /// Instantiate a new enum with the provided value.
  const WebhookAckStatusEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [WebhookAckStatusEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static WebhookAckStatusEnum? fromJson(dynamic value) => WebhookAckStatusEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [WebhookAckStatusEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<WebhookAckStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <WebhookAckStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = WebhookAckStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [WebhookAckStatusEnum] to String,
/// and [decode] dynamic data back to [WebhookAckStatusEnum].
class WebhookAckStatusEnumTypeTransformer {
  factory WebhookAckStatusEnumTypeTransformer() => _instance ??= const WebhookAckStatusEnumTypeTransformer._();

  const WebhookAckStatusEnumTypeTransformer._();

  String encode(WebhookAckStatusEnum data) => data._value;

  /// Returns the instance of [WebhookAckStatusEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  WebhookAckStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is WebhookAckStatusEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'PENDING': return WebhookAckStatusEnum.PENDING;
        case r'SUCCEEDED': return WebhookAckStatusEnum.SUCCEEDED;
        case r'FAILED': return WebhookAckStatusEnum.FAILED;
        case r'REFUNDED': return WebhookAckStatusEnum.REFUNDED;
        case r'PARTIALLY_REFUNDED': return WebhookAckStatusEnum.PARTIALLY_REFUNDED;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static WebhookAckStatusEnumTypeTransformer? _instance;
}


