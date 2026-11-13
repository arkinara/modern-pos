//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Expense {
  /// Returns a new [Expense] instance.
  Expense({
    required this.id,
    required this.outletId,
    required this.categoryId,
    required this.categoryName,
    required this.amountMinor,
    required this.incurredOn,
    required this.note,
    required this.createdById,
    required this.createdAt,
  });

  String id;

  String outletId;

  String categoryId;

  String categoryName;

  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int amountMinor;

  DateTime incurredOn;

  String note;

  String createdById;

  DateTime createdAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Expense &&
    other.id == id &&
    other.outletId == outletId &&
    other.categoryId == categoryId &&
    other.categoryName == categoryName &&
    other.amountMinor == amountMinor &&
    other.incurredOn == incurredOn &&
    other.note == note &&
    other.createdById == createdById &&
    other.createdAt == createdAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (outletId.hashCode) +
    (categoryId.hashCode) +
    (categoryName.hashCode) +
    (amountMinor.hashCode) +
    (incurredOn.hashCode) +
    (note.hashCode) +
    (createdById.hashCode) +
    (createdAt.hashCode);

  @override
  String toString() => 'Expense[id=$id, outletId=$outletId, categoryId=$categoryId, categoryName=$categoryName, amountMinor=$amountMinor, incurredOn=$incurredOn, note=$note, createdById=$createdById, createdAt=$createdAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'outletId'] = this.outletId;
      json[r'categoryId'] = this.categoryId;
      json[r'categoryName'] = this.categoryName;
      json[r'amountMinor'] = this.amountMinor;
      json[r'incurredOn'] = _dateFormatter.format(this.incurredOn);
      json[r'note'] = this.note;
      json[r'createdById'] = this.createdById;
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [Expense] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Expense? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "Expense[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "Expense[id]" has a null value in JSON.');
        assert(json.containsKey(r'outletId'), 'Required key "Expense[outletId]" is missing from JSON.');
        assert(json[r'outletId'] != null, 'Required key "Expense[outletId]" has a null value in JSON.');
        assert(json.containsKey(r'categoryId'), 'Required key "Expense[categoryId]" is missing from JSON.');
        assert(json[r'categoryId'] != null, 'Required key "Expense[categoryId]" has a null value in JSON.');
        assert(json.containsKey(r'categoryName'), 'Required key "Expense[categoryName]" is missing from JSON.');
        assert(json[r'categoryName'] != null, 'Required key "Expense[categoryName]" has a null value in JSON.');
        assert(json.containsKey(r'amountMinor'), 'Required key "Expense[amountMinor]" is missing from JSON.');
        assert(json[r'amountMinor'] != null, 'Required key "Expense[amountMinor]" has a null value in JSON.');
        assert(json.containsKey(r'incurredOn'), 'Required key "Expense[incurredOn]" is missing from JSON.');
        assert(json[r'incurredOn'] != null, 'Required key "Expense[incurredOn]" has a null value in JSON.');
        assert(json.containsKey(r'note'), 'Required key "Expense[note]" is missing from JSON.');
        assert(json[r'note'] != null, 'Required key "Expense[note]" has a null value in JSON.');
        assert(json.containsKey(r'createdById'), 'Required key "Expense[createdById]" is missing from JSON.');
        assert(json[r'createdById'] != null, 'Required key "Expense[createdById]" has a null value in JSON.');
        assert(json.containsKey(r'createdAt'), 'Required key "Expense[createdAt]" is missing from JSON.');
        assert(json[r'createdAt'] != null, 'Required key "Expense[createdAt]" has a null value in JSON.');
        return true;
      }());

      return Expense(
        id: mapValueOfType<String>(json, r'id')!,
        outletId: mapValueOfType<String>(json, r'outletId')!,
        categoryId: mapValueOfType<String>(json, r'categoryId')!,
        categoryName: mapValueOfType<String>(json, r'categoryName')!,
        amountMinor: mapValueOfType<int>(json, r'amountMinor')!,
        incurredOn: mapDateTime(json, r'incurredOn', r'')!,
        note: mapValueOfType<String>(json, r'note')!,
        createdById: mapValueOfType<String>(json, r'createdById')!,
        createdAt: mapDateTime(json, r'createdAt', r'')!,
      );
    }
    return null;
  }

  static List<Expense> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Expense>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Expense.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Expense> mapFromJson(dynamic json) {
    final map = <String, Expense>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Expense.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Expense-objects as value to a dart map
  static Map<String, List<Expense>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Expense>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Expense.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'outletId',
    'categoryId',
    'categoryName',
    'amountMinor',
    'incurredOn',
    'note',
    'createdById',
    'createdAt',
  };
}

