//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ReversalWrite {
  /// Returns a new [ReversalWrite] instance.
  ReversalWrite({
    required this.reason,
    this.restock = const [],
    this.refundMinor,
    this.lines = const [],
  });

  String reason;

  List<Restock> restock;

  /// Currency minor units; IDR exponent 0 in demo.
  ///
  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? refundMinor;

  /// Omit for a full reversal; provide one or more lines for a partial refund.
  List<RefundLine> lines;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ReversalWrite &&
    other.reason == reason &&
    _deepEquality.equals(other.restock, restock) &&
    other.refundMinor == refundMinor &&
    _deepEquality.equals(other.lines, lines);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (reason.hashCode) +
    (restock.hashCode) +
    (refundMinor == null ? 0 : refundMinor!.hashCode) +
    (lines.hashCode);

  @override
  String toString() => 'ReversalWrite[reason=$reason, restock=$restock, refundMinor=$refundMinor, lines=$lines]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'reason'] = this.reason;
      json[r'restock'] = this.restock;
    if (this.refundMinor != null) {
      json[r'refundMinor'] = this.refundMinor;
    } else {
      json[r'refundMinor'] = null;
    }
      json[r'lines'] = this.lines;
    return json;
  }

  /// Returns a new [ReversalWrite] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ReversalWrite? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'reason'), 'Required key "ReversalWrite[reason]" is missing from JSON.');
        assert(json[r'reason'] != null, 'Required key "ReversalWrite[reason]" has a null value in JSON.');
        assert(json.containsKey(r'restock'), 'Required key "ReversalWrite[restock]" is missing from JSON.');
        assert(json[r'restock'] != null, 'Required key "ReversalWrite[restock]" has a null value in JSON.');
        return true;
      }());

      return ReversalWrite(
        reason: mapValueOfType<String>(json, r'reason')!,
        restock: Restock.listFromJson(json[r'restock']),
        refundMinor: mapValueOfType<int>(json, r'refundMinor'),
        lines: RefundLine.listFromJson(json[r'lines']),
      );
    }
    return null;
  }

  static List<ReversalWrite> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ReversalWrite>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ReversalWrite.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ReversalWrite> mapFromJson(dynamic json) {
    final map = <String, ReversalWrite>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ReversalWrite.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ReversalWrite-objects as value to a dart map
  static Map<String, List<ReversalWrite>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ReversalWrite>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ReversalWrite.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'reason',
    'restock',
  };
}

