//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ChannelOrderEvent {
  /// Returns a new [ChannelOrderEvent] instance.
  ChannelOrderEvent({
    required this.id,
    required this.fromState,
    required this.toState,
    required this.actorId,
    required this.reason,
    required this.createdAt,
  });

  String id;

  ChannelOrderState fromState;

  ChannelOrderState toState;

  String? actorId;

  String reason;

  DateTime createdAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ChannelOrderEvent &&
    other.id == id &&
    other.fromState == fromState &&
    other.toState == toState &&
    other.actorId == actorId &&
    other.reason == reason &&
    other.createdAt == createdAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (fromState.hashCode) +
    (toState.hashCode) +
    (actorId == null ? 0 : actorId!.hashCode) +
    (reason.hashCode) +
    (createdAt.hashCode);

  @override
  String toString() => 'ChannelOrderEvent[id=$id, fromState=$fromState, toState=$toState, actorId=$actorId, reason=$reason, createdAt=$createdAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'fromState'] = this.fromState;
      json[r'toState'] = this.toState;
    if (this.actorId != null) {
      json[r'actorId'] = this.actorId;
    } else {
      json[r'actorId'] = null;
    }
      json[r'reason'] = this.reason;
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [ChannelOrderEvent] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ChannelOrderEvent? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "ChannelOrderEvent[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "ChannelOrderEvent[id]" has a null value in JSON.');
        assert(json.containsKey(r'fromState'), 'Required key "ChannelOrderEvent[fromState]" is missing from JSON.');
        assert(json[r'fromState'] != null, 'Required key "ChannelOrderEvent[fromState]" has a null value in JSON.');
        assert(json.containsKey(r'toState'), 'Required key "ChannelOrderEvent[toState]" is missing from JSON.');
        assert(json[r'toState'] != null, 'Required key "ChannelOrderEvent[toState]" has a null value in JSON.');
        assert(json.containsKey(r'actorId'), 'Required key "ChannelOrderEvent[actorId]" is missing from JSON.');
        assert(json.containsKey(r'reason'), 'Required key "ChannelOrderEvent[reason]" is missing from JSON.');
        assert(json[r'reason'] != null, 'Required key "ChannelOrderEvent[reason]" has a null value in JSON.');
        assert(json.containsKey(r'createdAt'), 'Required key "ChannelOrderEvent[createdAt]" is missing from JSON.');
        assert(json[r'createdAt'] != null, 'Required key "ChannelOrderEvent[createdAt]" has a null value in JSON.');
        return true;
      }());

      return ChannelOrderEvent(
        id: mapValueOfType<String>(json, r'id')!,
        fromState: ChannelOrderState.fromJson(json[r'fromState'])!,
        toState: ChannelOrderState.fromJson(json[r'toState'])!,
        actorId: mapValueOfType<String>(json, r'actorId'),
        reason: mapValueOfType<String>(json, r'reason')!,
        createdAt: mapDateTime(json, r'createdAt', r'')!,
      );
    }
    return null;
  }

  static List<ChannelOrderEvent> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ChannelOrderEvent>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ChannelOrderEvent.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ChannelOrderEvent> mapFromJson(dynamic json) {
    final map = <String, ChannelOrderEvent>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ChannelOrderEvent.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ChannelOrderEvent-objects as value to a dart map
  static Map<String, List<ChannelOrderEvent>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ChannelOrderEvent>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ChannelOrderEvent.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'fromState',
    'toState',
    'actorId',
    'reason',
    'createdAt',
  };
}

