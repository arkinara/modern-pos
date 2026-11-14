//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class DigitalReceipt {
  /// Returns a new [DigitalReceipt] instance.
  DigitalReceipt({
    required this.id,
    required this.receiptNumber,
    required this.saleId,
    required this.channelOrderId,
    required this.customerId,
    required this.token,
    required this.url,
    required this.issuedAt,
    required this.expiresAt,
    required this.html,
    required this.text,
  });

  String id;

  String receiptNumber;

  String? saleId;

  String? channelOrderId;

  String? customerId;

  String token;

  String url;

  DateTime issuedAt;

  DateTime expiresAt;

  String html;

  String text;

  @override
  bool operator ==(Object other) => identical(this, other) || other is DigitalReceipt &&
    other.id == id &&
    other.receiptNumber == receiptNumber &&
    other.saleId == saleId &&
    other.channelOrderId == channelOrderId &&
    other.customerId == customerId &&
    other.token == token &&
    other.url == url &&
    other.issuedAt == issuedAt &&
    other.expiresAt == expiresAt &&
    other.html == html &&
    other.text == text;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (receiptNumber.hashCode) +
    (saleId == null ? 0 : saleId!.hashCode) +
    (channelOrderId == null ? 0 : channelOrderId!.hashCode) +
    (customerId == null ? 0 : customerId!.hashCode) +
    (token.hashCode) +
    (url.hashCode) +
    (issuedAt.hashCode) +
    (expiresAt.hashCode) +
    (html.hashCode) +
    (text.hashCode);

  @override
  String toString() => 'DigitalReceipt[id=$id, receiptNumber=$receiptNumber, saleId=$saleId, channelOrderId=$channelOrderId, customerId=$customerId, token=$token, url=$url, issuedAt=$issuedAt, expiresAt=$expiresAt, html=$html, text=$text]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'receiptNumber'] = this.receiptNumber;
    if (this.saleId != null) {
      json[r'saleId'] = this.saleId;
    } else {
      json[r'saleId'] = null;
    }
    if (this.channelOrderId != null) {
      json[r'channelOrderId'] = this.channelOrderId;
    } else {
      json[r'channelOrderId'] = null;
    }
    if (this.customerId != null) {
      json[r'customerId'] = this.customerId;
    } else {
      json[r'customerId'] = null;
    }
      json[r'token'] = this.token;
      json[r'url'] = this.url;
      json[r'issuedAt'] = this.issuedAt.toUtc().toIso8601String();
      json[r'expiresAt'] = this.expiresAt.toUtc().toIso8601String();
      json[r'html'] = this.html;
      json[r'text'] = this.text;
    return json;
  }

  /// Returns a new [DigitalReceipt] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DigitalReceipt? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "DigitalReceipt[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "DigitalReceipt[id]" has a null value in JSON.');
        assert(json.containsKey(r'receiptNumber'), 'Required key "DigitalReceipt[receiptNumber]" is missing from JSON.');
        assert(json[r'receiptNumber'] != null, 'Required key "DigitalReceipt[receiptNumber]" has a null value in JSON.');
        assert(json.containsKey(r'saleId'), 'Required key "DigitalReceipt[saleId]" is missing from JSON.');
        assert(json.containsKey(r'channelOrderId'), 'Required key "DigitalReceipt[channelOrderId]" is missing from JSON.');
        assert(json.containsKey(r'customerId'), 'Required key "DigitalReceipt[customerId]" is missing from JSON.');
        assert(json.containsKey(r'token'), 'Required key "DigitalReceipt[token]" is missing from JSON.');
        assert(json[r'token'] != null, 'Required key "DigitalReceipt[token]" has a null value in JSON.');
        assert(json.containsKey(r'url'), 'Required key "DigitalReceipt[url]" is missing from JSON.');
        assert(json[r'url'] != null, 'Required key "DigitalReceipt[url]" has a null value in JSON.');
        assert(json.containsKey(r'issuedAt'), 'Required key "DigitalReceipt[issuedAt]" is missing from JSON.');
        assert(json[r'issuedAt'] != null, 'Required key "DigitalReceipt[issuedAt]" has a null value in JSON.');
        assert(json.containsKey(r'expiresAt'), 'Required key "DigitalReceipt[expiresAt]" is missing from JSON.');
        assert(json[r'expiresAt'] != null, 'Required key "DigitalReceipt[expiresAt]" has a null value in JSON.');
        assert(json.containsKey(r'html'), 'Required key "DigitalReceipt[html]" is missing from JSON.');
        assert(json[r'html'] != null, 'Required key "DigitalReceipt[html]" has a null value in JSON.');
        assert(json.containsKey(r'text'), 'Required key "DigitalReceipt[text]" is missing from JSON.');
        assert(json[r'text'] != null, 'Required key "DigitalReceipt[text]" has a null value in JSON.');
        return true;
      }());

      return DigitalReceipt(
        id: mapValueOfType<String>(json, r'id')!,
        receiptNumber: mapValueOfType<String>(json, r'receiptNumber')!,
        saleId: mapValueOfType<String>(json, r'saleId'),
        channelOrderId: mapValueOfType<String>(json, r'channelOrderId'),
        customerId: mapValueOfType<String>(json, r'customerId'),
        token: mapValueOfType<String>(json, r'token')!,
        url: mapValueOfType<String>(json, r'url')!,
        issuedAt: mapDateTime(json, r'issuedAt', r'')!,
        expiresAt: mapDateTime(json, r'expiresAt', r'')!,
        html: mapValueOfType<String>(json, r'html')!,
        text: mapValueOfType<String>(json, r'text')!,
      );
    }
    return null;
  }

  static List<DigitalReceipt> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DigitalReceipt>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DigitalReceipt.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DigitalReceipt> mapFromJson(dynamic json) {
    final map = <String, DigitalReceipt>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DigitalReceipt.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DigitalReceipt-objects as value to a dart map
  static Map<String, List<DigitalReceipt>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<DigitalReceipt>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DigitalReceipt.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'receiptNumber',
    'saleId',
    'channelOrderId',
    'customerId',
    'token',
    'url',
    'issuedAt',
    'expiresAt',
    'html',
    'text',
  };
}

