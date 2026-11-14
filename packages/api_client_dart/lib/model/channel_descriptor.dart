//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ChannelDescriptor {
  /// Returns a new [ChannelDescriptor] instance.
  ChannelDescriptor({
    required this.channel,
    required this.label,
    required this.availability,
    required this.reason,
    required this.inboundWebhook,
  });

  OrderChannel channel;

  String label;

  ChannelDescriptorAvailabilityEnum availability;

  String? reason;

  bool inboundWebhook;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ChannelDescriptor &&
    other.channel == channel &&
    other.label == label &&
    other.availability == availability &&
    other.reason == reason &&
    other.inboundWebhook == inboundWebhook;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (channel.hashCode) +
    (label.hashCode) +
    (availability.hashCode) +
    (reason == null ? 0 : reason!.hashCode) +
    (inboundWebhook.hashCode);

  @override
  String toString() => 'ChannelDescriptor[channel=$channel, label=$label, availability=$availability, reason=$reason, inboundWebhook=$inboundWebhook]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'channel'] = this.channel;
      json[r'label'] = this.label;
      json[r'availability'] = this.availability;
    if (this.reason != null) {
      json[r'reason'] = this.reason;
    } else {
      json[r'reason'] = null;
    }
      json[r'inboundWebhook'] = this.inboundWebhook;
    return json;
  }

  /// Returns a new [ChannelDescriptor] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ChannelDescriptor? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'channel'), 'Required key "ChannelDescriptor[channel]" is missing from JSON.');
        assert(json[r'channel'] != null, 'Required key "ChannelDescriptor[channel]" has a null value in JSON.');
        assert(json.containsKey(r'label'), 'Required key "ChannelDescriptor[label]" is missing from JSON.');
        assert(json[r'label'] != null, 'Required key "ChannelDescriptor[label]" has a null value in JSON.');
        assert(json.containsKey(r'availability'), 'Required key "ChannelDescriptor[availability]" is missing from JSON.');
        assert(json[r'availability'] != null, 'Required key "ChannelDescriptor[availability]" has a null value in JSON.');
        assert(json.containsKey(r'reason'), 'Required key "ChannelDescriptor[reason]" is missing from JSON.');
        assert(json.containsKey(r'inboundWebhook'), 'Required key "ChannelDescriptor[inboundWebhook]" is missing from JSON.');
        assert(json[r'inboundWebhook'] != null, 'Required key "ChannelDescriptor[inboundWebhook]" has a null value in JSON.');
        return true;
      }());

      return ChannelDescriptor(
        channel: OrderChannel.fromJson(json[r'channel'])!,
        label: mapValueOfType<String>(json, r'label')!,
        availability: ChannelDescriptorAvailabilityEnum.fromJson(json[r'availability'])!,
        reason: mapValueOfType<String>(json, r'reason'),
        inboundWebhook: mapValueOfType<bool>(json, r'inboundWebhook')!,
      );
    }
    return null;
  }

  static List<ChannelDescriptor> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ChannelDescriptor>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ChannelDescriptor.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ChannelDescriptor> mapFromJson(dynamic json) {
    final map = <String, ChannelDescriptor>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ChannelDescriptor.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ChannelDescriptor-objects as value to a dart map
  static Map<String, List<ChannelDescriptor>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ChannelDescriptor>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ChannelDescriptor.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'channel',
    'label',
    'availability',
    'reason',
    'inboundWebhook',
  };
}


enum ChannelDescriptorAvailabilityEnum {
  AVAILABLE._(r'AVAILABLE'),
  PENDING_CREDENTIALS._(r'PENDING_CREDENTIALS'),
  ;

  /// Instantiate a new enum with the provided value.
  const ChannelDescriptorAvailabilityEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [ChannelDescriptorAvailabilityEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static ChannelDescriptorAvailabilityEnum? fromJson(dynamic value) => ChannelDescriptorAvailabilityEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [ChannelDescriptorAvailabilityEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<ChannelDescriptorAvailabilityEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ChannelDescriptorAvailabilityEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ChannelDescriptorAvailabilityEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ChannelDescriptorAvailabilityEnum] to String,
/// and [decode] dynamic data back to [ChannelDescriptorAvailabilityEnum].
class ChannelDescriptorAvailabilityEnumTypeTransformer {
  factory ChannelDescriptorAvailabilityEnumTypeTransformer() => _instance ??= const ChannelDescriptorAvailabilityEnumTypeTransformer._();

  const ChannelDescriptorAvailabilityEnumTypeTransformer._();

  String encode(ChannelDescriptorAvailabilityEnum data) => data._value;

  /// Returns the instance of [ChannelDescriptorAvailabilityEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ChannelDescriptorAvailabilityEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is ChannelDescriptorAvailabilityEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'AVAILABLE': return ChannelDescriptorAvailabilityEnum.AVAILABLE;
        case r'PENDING_CREDENTIALS': return ChannelDescriptorAvailabilityEnum.PENDING_CREDENTIALS;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static ChannelDescriptorAvailabilityEnumTypeTransformer? _instance;
}


