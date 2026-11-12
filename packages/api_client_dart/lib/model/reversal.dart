//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Reversal {
  /// Returns a new [Reversal] instance.
  Reversal({
    required this.id,
    required this.saleId,
    required this.reason,
    required this.createdAt,
    this.restock = const [],
    required this.externalRefundPerformed,
    this.kind,
    this.refundMinor,
    this.lines = const [],
  });

  String id;

  String saleId;

  String reason;

  DateTime createdAt;

  List<Restock> restock;

  bool externalRefundPerformed;

  ReversalKindEnum? kind;

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

  List<RefundLine> lines;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Reversal &&
    other.id == id &&
    other.saleId == saleId &&
    other.reason == reason &&
    other.createdAt == createdAt &&
    _deepEquality.equals(other.restock, restock) &&
    other.externalRefundPerformed == externalRefundPerformed &&
    other.kind == kind &&
    other.refundMinor == refundMinor &&
    _deepEquality.equals(other.lines, lines);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (saleId.hashCode) +
    (reason.hashCode) +
    (createdAt.hashCode) +
    (restock.hashCode) +
    (externalRefundPerformed.hashCode) +
    (kind == null ? 0 : kind!.hashCode) +
    (refundMinor == null ? 0 : refundMinor!.hashCode) +
    (lines.hashCode);

  @override
  String toString() => 'Reversal[id=$id, saleId=$saleId, reason=$reason, createdAt=$createdAt, restock=$restock, externalRefundPerformed=$externalRefundPerformed, kind=$kind, refundMinor=$refundMinor, lines=$lines]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'saleId'] = this.saleId;
      json[r'reason'] = this.reason;
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
      json[r'restock'] = this.restock;
      json[r'externalRefundPerformed'] = this.externalRefundPerformed;
    if (this.kind != null) {
      json[r'kind'] = this.kind;
    } else {
      json[r'kind'] = null;
    }
    if (this.refundMinor != null) {
      json[r'refundMinor'] = this.refundMinor;
    } else {
      json[r'refundMinor'] = null;
    }
      json[r'lines'] = this.lines;
    return json;
  }

  /// Returns a new [Reversal] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Reversal? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "Reversal[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "Reversal[id]" has a null value in JSON.');
        assert(json.containsKey(r'saleId'), 'Required key "Reversal[saleId]" is missing from JSON.');
        assert(json[r'saleId'] != null, 'Required key "Reversal[saleId]" has a null value in JSON.');
        assert(json.containsKey(r'reason'), 'Required key "Reversal[reason]" is missing from JSON.');
        assert(json[r'reason'] != null, 'Required key "Reversal[reason]" has a null value in JSON.');
        assert(json.containsKey(r'createdAt'), 'Required key "Reversal[createdAt]" is missing from JSON.');
        assert(json[r'createdAt'] != null, 'Required key "Reversal[createdAt]" has a null value in JSON.');
        assert(json.containsKey(r'restock'), 'Required key "Reversal[restock]" is missing from JSON.');
        assert(json[r'restock'] != null, 'Required key "Reversal[restock]" has a null value in JSON.');
        assert(json.containsKey(r'externalRefundPerformed'), 'Required key "Reversal[externalRefundPerformed]" is missing from JSON.');
        assert(json[r'externalRefundPerformed'] != null, 'Required key "Reversal[externalRefundPerformed]" has a null value in JSON.');
        return true;
      }());

      return Reversal(
        id: mapValueOfType<String>(json, r'id')!,
        saleId: mapValueOfType<String>(json, r'saleId')!,
        reason: mapValueOfType<String>(json, r'reason')!,
        createdAt: mapDateTime(json, r'createdAt', r'')!,
        restock: Restock.listFromJson(json[r'restock']),
        externalRefundPerformed: mapValueOfType<bool>(json, r'externalRefundPerformed')!,
        kind: ReversalKindEnum.fromJson(json[r'kind']),
        refundMinor: mapValueOfType<int>(json, r'refundMinor'),
        lines: RefundLine.listFromJson(json[r'lines']),
      );
    }
    return null;
  }

  static List<Reversal> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Reversal>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Reversal.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Reversal> mapFromJson(dynamic json) {
    final map = <String, Reversal>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Reversal.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Reversal-objects as value to a dart map
  static Map<String, List<Reversal>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Reversal>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Reversal.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'saleId',
    'reason',
    'createdAt',
    'restock',
    'externalRefundPerformed',
  };
}


enum ReversalKindEnum {
  FULL._(r'FULL'),
  PARTIAL._(r'PARTIAL'),
  ;

  /// Instantiate a new enum with the provided value.
  const ReversalKindEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [ReversalKindEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static ReversalKindEnum? fromJson(dynamic value) => ReversalKindEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [ReversalKindEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<ReversalKindEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ReversalKindEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ReversalKindEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ReversalKindEnum] to String,
/// and [decode] dynamic data back to [ReversalKindEnum].
class ReversalKindEnumTypeTransformer {
  factory ReversalKindEnumTypeTransformer() => _instance ??= const ReversalKindEnumTypeTransformer._();

  const ReversalKindEnumTypeTransformer._();

  String encode(ReversalKindEnum data) => data._value;

  /// Returns the instance of [ReversalKindEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ReversalKindEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is ReversalKindEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'FULL': return ReversalKindEnum.FULL;
        case r'PARTIAL': return ReversalKindEnum.PARTIAL;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static ReversalKindEnumTypeTransformer? _instance;
}


