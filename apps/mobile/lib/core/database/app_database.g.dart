// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $RecoveryJobsTable extends RecoveryJobs
    with TableInfo<$RecoveryJobsTable, RecoveryJob> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecoveryJobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _referenceMeta = const VerificationMeta(
    'reference',
  );
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
    'reference',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, reference, payload, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recovery_jobs';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecoveryJob> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('reference')) {
      context.handle(
        _referenceMeta,
        reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta),
      );
    } else if (isInserting) {
      context.missing(_referenceMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecoveryJob map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecoveryJob(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      reference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $RecoveryJobsTable createAlias(String alias) {
    return $RecoveryJobsTable(attachedDatabase, alias);
  }
}

class RecoveryJob extends DataClass implements Insertable<RecoveryJob> {
  final int id;
  final String reference;
  final String payload;
  final DateTime createdAt;
  const RecoveryJob({
    required this.id,
    required this.reference,
    required this.payload,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['reference'] = Variable<String>(reference);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RecoveryJobsCompanion toCompanion(bool nullToAbsent) {
    return RecoveryJobsCompanion(
      id: Value(id),
      reference: Value(reference),
      payload: Value(payload),
      createdAt: Value(createdAt),
    );
  }

  factory RecoveryJob.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecoveryJob(
      id: serializer.fromJson<int>(json['id']),
      reference: serializer.fromJson<String>(json['reference']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'reference': serializer.toJson<String>(reference),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  RecoveryJob copyWith({
    int? id,
    String? reference,
    String? payload,
    DateTime? createdAt,
  }) => RecoveryJob(
    id: id ?? this.id,
    reference: reference ?? this.reference,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
  );
  RecoveryJob copyWithCompanion(RecoveryJobsCompanion data) {
    return RecoveryJob(
      id: data.id.present ? data.id.value : this.id,
      reference: data.reference.present ? data.reference.value : this.reference,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecoveryJob(')
          ..write('id: $id, ')
          ..write('reference: $reference, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, reference, payload, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecoveryJob &&
          other.id == this.id &&
          other.reference == this.reference &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt);
}

class RecoveryJobsCompanion extends UpdateCompanion<RecoveryJob> {
  final Value<int> id;
  final Value<String> reference;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  const RecoveryJobsCompanion({
    this.id = const Value.absent(),
    this.reference = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  RecoveryJobsCompanion.insert({
    this.id = const Value.absent(),
    required String reference,
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : reference = Value(reference);
  static Insertable<RecoveryJob> custom({
    Expression<int>? id,
    Expression<String>? reference,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (reference != null) 'reference': reference,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  RecoveryJobsCompanion copyWith({
    Value<int>? id,
    Value<String>? reference,
    Value<String>? payload,
    Value<DateTime>? createdAt,
  }) {
    return RecoveryJobsCompanion(
      id: id ?? this.id,
      reference: reference ?? this.reference,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecoveryJobsCompanion(')
          ..write('id: $id, ')
          ..write('reference: $reference, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $CartEntriesTable extends CartEntries
    with TableInfo<$CartEntriesTable, CartEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CartEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _menuIdMeta = const VerificationMeta('menuId');
  @override
  late final GeneratedColumn<String> menuId = GeneratedColumn<String>(
    'menu_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _variantIdMeta = const VerificationMeta(
    'variantId',
  );
  @override
  late final GeneratedColumn<String> variantId = GeneratedColumn<String>(
    'variant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemNameMeta = const VerificationMeta(
    'itemName',
  );
  @override
  late final GeneratedColumn<String> itemName = GeneratedColumn<String>(
    'item_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _variantNameMeta = const VerificationMeta(
    'variantName',
  );
  @override
  late final GeneratedColumn<String> variantName = GeneratedColumn<String>(
    'variant_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitPriceMinorMeta = const VerificationMeta(
    'unitPriceMinor',
  );
  @override
  late final GeneratedColumn<int> unitPriceMinor = GeneratedColumn<int>(
    'unit_price_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('IDR'),
  );
  static const VerificationMeta _currencyExponentMeta = const VerificationMeta(
    'currencyExponent',
  );
  @override
  late final GeneratedColumn<int> currencyExponent = GeneratedColumn<int>(
    'currency_exponent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    menuId,
    variantId,
    itemName,
    variantName,
    unitPriceMinor,
    quantity,
    currency,
    currencyExponent,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cart_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<CartEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('menu_id')) {
      context.handle(
        _menuIdMeta,
        menuId.isAcceptableOrUnknown(data['menu_id']!, _menuIdMeta),
      );
    } else if (isInserting) {
      context.missing(_menuIdMeta);
    }
    if (data.containsKey('variant_id')) {
      context.handle(
        _variantIdMeta,
        variantId.isAcceptableOrUnknown(data['variant_id']!, _variantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_variantIdMeta);
    }
    if (data.containsKey('item_name')) {
      context.handle(
        _itemNameMeta,
        itemName.isAcceptableOrUnknown(data['item_name']!, _itemNameMeta),
      );
    } else if (isInserting) {
      context.missing(_itemNameMeta);
    }
    if (data.containsKey('variant_name')) {
      context.handle(
        _variantNameMeta,
        variantName.isAcceptableOrUnknown(
          data['variant_name']!,
          _variantNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_variantNameMeta);
    }
    if (data.containsKey('unit_price_minor')) {
      context.handle(
        _unitPriceMinorMeta,
        unitPriceMinor.isAcceptableOrUnknown(
          data['unit_price_minor']!,
          _unitPriceMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unitPriceMinorMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('currency_exponent')) {
      context.handle(
        _currencyExponentMeta,
        currencyExponent.isAcceptableOrUnknown(
          data['currency_exponent']!,
          _currencyExponentMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {menuId, variantId};
  @override
  CartEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CartEntry(
      menuId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}menu_id'],
      )!,
      variantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}variant_id'],
      )!,
      itemName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_name'],
      )!,
      variantName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}variant_name'],
      )!,
      unitPriceMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_price_minor'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      currencyExponent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}currency_exponent'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CartEntriesTable createAlias(String alias) {
    return $CartEntriesTable(attachedDatabase, alias);
  }
}

class CartEntry extends DataClass implements Insertable<CartEntry> {
  final String menuId;
  final String variantId;
  final String itemName;
  final String variantName;
  final int unitPriceMinor;
  final int quantity;
  final String currency;
  final int currencyExponent;
  final DateTime updatedAt;
  const CartEntry({
    required this.menuId,
    required this.variantId,
    required this.itemName,
    required this.variantName,
    required this.unitPriceMinor,
    required this.quantity,
    required this.currency,
    required this.currencyExponent,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['menu_id'] = Variable<String>(menuId);
    map['variant_id'] = Variable<String>(variantId);
    map['item_name'] = Variable<String>(itemName);
    map['variant_name'] = Variable<String>(variantName);
    map['unit_price_minor'] = Variable<int>(unitPriceMinor);
    map['quantity'] = Variable<int>(quantity);
    map['currency'] = Variable<String>(currency);
    map['currency_exponent'] = Variable<int>(currencyExponent);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CartEntriesCompanion toCompanion(bool nullToAbsent) {
    return CartEntriesCompanion(
      menuId: Value(menuId),
      variantId: Value(variantId),
      itemName: Value(itemName),
      variantName: Value(variantName),
      unitPriceMinor: Value(unitPriceMinor),
      quantity: Value(quantity),
      currency: Value(currency),
      currencyExponent: Value(currencyExponent),
      updatedAt: Value(updatedAt),
    );
  }

  factory CartEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CartEntry(
      menuId: serializer.fromJson<String>(json['menuId']),
      variantId: serializer.fromJson<String>(json['variantId']),
      itemName: serializer.fromJson<String>(json['itemName']),
      variantName: serializer.fromJson<String>(json['variantName']),
      unitPriceMinor: serializer.fromJson<int>(json['unitPriceMinor']),
      quantity: serializer.fromJson<int>(json['quantity']),
      currency: serializer.fromJson<String>(json['currency']),
      currencyExponent: serializer.fromJson<int>(json['currencyExponent']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'menuId': serializer.toJson<String>(menuId),
      'variantId': serializer.toJson<String>(variantId),
      'itemName': serializer.toJson<String>(itemName),
      'variantName': serializer.toJson<String>(variantName),
      'unitPriceMinor': serializer.toJson<int>(unitPriceMinor),
      'quantity': serializer.toJson<int>(quantity),
      'currency': serializer.toJson<String>(currency),
      'currencyExponent': serializer.toJson<int>(currencyExponent),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CartEntry copyWith({
    String? menuId,
    String? variantId,
    String? itemName,
    String? variantName,
    int? unitPriceMinor,
    int? quantity,
    String? currency,
    int? currencyExponent,
    DateTime? updatedAt,
  }) => CartEntry(
    menuId: menuId ?? this.menuId,
    variantId: variantId ?? this.variantId,
    itemName: itemName ?? this.itemName,
    variantName: variantName ?? this.variantName,
    unitPriceMinor: unitPriceMinor ?? this.unitPriceMinor,
    quantity: quantity ?? this.quantity,
    currency: currency ?? this.currency,
    currencyExponent: currencyExponent ?? this.currencyExponent,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CartEntry copyWithCompanion(CartEntriesCompanion data) {
    return CartEntry(
      menuId: data.menuId.present ? data.menuId.value : this.menuId,
      variantId: data.variantId.present ? data.variantId.value : this.variantId,
      itemName: data.itemName.present ? data.itemName.value : this.itemName,
      variantName: data.variantName.present
          ? data.variantName.value
          : this.variantName,
      unitPriceMinor: data.unitPriceMinor.present
          ? data.unitPriceMinor.value
          : this.unitPriceMinor,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      currency: data.currency.present ? data.currency.value : this.currency,
      currencyExponent: data.currencyExponent.present
          ? data.currencyExponent.value
          : this.currencyExponent,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CartEntry(')
          ..write('menuId: $menuId, ')
          ..write('variantId: $variantId, ')
          ..write('itemName: $itemName, ')
          ..write('variantName: $variantName, ')
          ..write('unitPriceMinor: $unitPriceMinor, ')
          ..write('quantity: $quantity, ')
          ..write('currency: $currency, ')
          ..write('currencyExponent: $currencyExponent, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    menuId,
    variantId,
    itemName,
    variantName,
    unitPriceMinor,
    quantity,
    currency,
    currencyExponent,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CartEntry &&
          other.menuId == this.menuId &&
          other.variantId == this.variantId &&
          other.itemName == this.itemName &&
          other.variantName == this.variantName &&
          other.unitPriceMinor == this.unitPriceMinor &&
          other.quantity == this.quantity &&
          other.currency == this.currency &&
          other.currencyExponent == this.currencyExponent &&
          other.updatedAt == this.updatedAt);
}

class CartEntriesCompanion extends UpdateCompanion<CartEntry> {
  final Value<String> menuId;
  final Value<String> variantId;
  final Value<String> itemName;
  final Value<String> variantName;
  final Value<int> unitPriceMinor;
  final Value<int> quantity;
  final Value<String> currency;
  final Value<int> currencyExponent;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CartEntriesCompanion({
    this.menuId = const Value.absent(),
    this.variantId = const Value.absent(),
    this.itemName = const Value.absent(),
    this.variantName = const Value.absent(),
    this.unitPriceMinor = const Value.absent(),
    this.quantity = const Value.absent(),
    this.currency = const Value.absent(),
    this.currencyExponent = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CartEntriesCompanion.insert({
    required String menuId,
    required String variantId,
    required String itemName,
    required String variantName,
    required int unitPriceMinor,
    this.quantity = const Value.absent(),
    this.currency = const Value.absent(),
    this.currencyExponent = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : menuId = Value(menuId),
       variantId = Value(variantId),
       itemName = Value(itemName),
       variantName = Value(variantName),
       unitPriceMinor = Value(unitPriceMinor);
  static Insertable<CartEntry> custom({
    Expression<String>? menuId,
    Expression<String>? variantId,
    Expression<String>? itemName,
    Expression<String>? variantName,
    Expression<int>? unitPriceMinor,
    Expression<int>? quantity,
    Expression<String>? currency,
    Expression<int>? currencyExponent,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (menuId != null) 'menu_id': menuId,
      if (variantId != null) 'variant_id': variantId,
      if (itemName != null) 'item_name': itemName,
      if (variantName != null) 'variant_name': variantName,
      if (unitPriceMinor != null) 'unit_price_minor': unitPriceMinor,
      if (quantity != null) 'quantity': quantity,
      if (currency != null) 'currency': currency,
      if (currencyExponent != null) 'currency_exponent': currencyExponent,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CartEntriesCompanion copyWith({
    Value<String>? menuId,
    Value<String>? variantId,
    Value<String>? itemName,
    Value<String>? variantName,
    Value<int>? unitPriceMinor,
    Value<int>? quantity,
    Value<String>? currency,
    Value<int>? currencyExponent,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CartEntriesCompanion(
      menuId: menuId ?? this.menuId,
      variantId: variantId ?? this.variantId,
      itemName: itemName ?? this.itemName,
      variantName: variantName ?? this.variantName,
      unitPriceMinor: unitPriceMinor ?? this.unitPriceMinor,
      quantity: quantity ?? this.quantity,
      currency: currency ?? this.currency,
      currencyExponent: currencyExponent ?? this.currencyExponent,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (menuId.present) {
      map['menu_id'] = Variable<String>(menuId.value);
    }
    if (variantId.present) {
      map['variant_id'] = Variable<String>(variantId.value);
    }
    if (itemName.present) {
      map['item_name'] = Variable<String>(itemName.value);
    }
    if (variantName.present) {
      map['variant_name'] = Variable<String>(variantName.value);
    }
    if (unitPriceMinor.present) {
      map['unit_price_minor'] = Variable<int>(unitPriceMinor.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (currencyExponent.present) {
      map['currency_exponent'] = Variable<int>(currencyExponent.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CartEntriesCompanion(')
          ..write('menuId: $menuId, ')
          ..write('variantId: $variantId, ')
          ..write('itemName: $itemName, ')
          ..write('variantName: $variantName, ')
          ..write('unitPriceMinor: $unitPriceMinor, ')
          ..write('quantity: $quantity, ')
          ..write('currency: $currency, ')
          ..write('currencyExponent: $currencyExponent, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RecoveryJobsTable recoveryJobs = $RecoveryJobsTable(this);
  late final $CartEntriesTable cartEntries = $CartEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    recoveryJobs,
    cartEntries,
  ];
}

typedef $$RecoveryJobsTableCreateCompanionBuilder =
    RecoveryJobsCompanion Function({
      Value<int> id,
      required String reference,
      Value<String> payload,
      Value<DateTime> createdAt,
    });
typedef $$RecoveryJobsTableUpdateCompanionBuilder =
    RecoveryJobsCompanion Function({
      Value<int> id,
      Value<String> reference,
      Value<String> payload,
      Value<DateTime> createdAt,
    });

class $$RecoveryJobsTableFilterComposer
    extends Composer<_$AppDatabase, $RecoveryJobsTable> {
  $$RecoveryJobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecoveryJobsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecoveryJobsTable> {
  $$RecoveryJobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecoveryJobsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecoveryJobsTable> {
  $$RecoveryJobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$RecoveryJobsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecoveryJobsTable,
          RecoveryJob,
          $$RecoveryJobsTableFilterComposer,
          $$RecoveryJobsTableOrderingComposer,
          $$RecoveryJobsTableAnnotationComposer,
          $$RecoveryJobsTableCreateCompanionBuilder,
          $$RecoveryJobsTableUpdateCompanionBuilder,
          (
            RecoveryJob,
            BaseReferences<_$AppDatabase, $RecoveryJobsTable, RecoveryJob>,
          ),
          RecoveryJob,
          PrefetchHooks Function()
        > {
  $$RecoveryJobsTableTableManager(_$AppDatabase db, $RecoveryJobsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecoveryJobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecoveryJobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecoveryJobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> reference = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => RecoveryJobsCompanion(
                id: id,
                reference: reference,
                payload: payload,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String reference,
                Value<String> payload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => RecoveryJobsCompanion.insert(
                id: id,
                reference: reference,
                payload: payload,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RecoveryJobsTable, RecoveryJob>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $RecoveryJobsTable,
                    RecoveryJob
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecoveryJobsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecoveryJobsTable,
      RecoveryJob,
      $$RecoveryJobsTableFilterComposer,
      $$RecoveryJobsTableOrderingComposer,
      $$RecoveryJobsTableAnnotationComposer,
      $$RecoveryJobsTableCreateCompanionBuilder,
      $$RecoveryJobsTableUpdateCompanionBuilder,
      (
        RecoveryJob,
        BaseReferences<_$AppDatabase, $RecoveryJobsTable, RecoveryJob>,
      ),
      RecoveryJob,
      PrefetchHooks Function()
    >;
typedef $$CartEntriesTableCreateCompanionBuilder =
    CartEntriesCompanion Function({
      required String menuId,
      required String variantId,
      required String itemName,
      required String variantName,
      required int unitPriceMinor,
      Value<int> quantity,
      Value<String> currency,
      Value<int> currencyExponent,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$CartEntriesTableUpdateCompanionBuilder =
    CartEntriesCompanion Function({
      Value<String> menuId,
      Value<String> variantId,
      Value<String> itemName,
      Value<String> variantName,
      Value<int> unitPriceMinor,
      Value<int> quantity,
      Value<String> currency,
      Value<int> currencyExponent,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$CartEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $CartEntriesTable> {
  $$CartEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get menuId => $composableBuilder(
    column: $table.menuId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get variantId => $composableBuilder(
    column: $table.variantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemName => $composableBuilder(
    column: $table.itemName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get variantName => $composableBuilder(
    column: $table.variantName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitPriceMinor => $composableBuilder(
    column: $table.unitPriceMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currencyExponent => $composableBuilder(
    column: $table.currencyExponent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CartEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CartEntriesTable> {
  $$CartEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get menuId => $composableBuilder(
    column: $table.menuId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get variantId => $composableBuilder(
    column: $table.variantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemName => $composableBuilder(
    column: $table.itemName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get variantName => $composableBuilder(
    column: $table.variantName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitPriceMinor => $composableBuilder(
    column: $table.unitPriceMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currencyExponent => $composableBuilder(
    column: $table.currencyExponent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CartEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CartEntriesTable> {
  $$CartEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get menuId =>
      $composableBuilder(column: $table.menuId, builder: (column) => column);

  GeneratedColumn<String> get variantId =>
      $composableBuilder(column: $table.variantId, builder: (column) => column);

  GeneratedColumn<String> get itemName =>
      $composableBuilder(column: $table.itemName, builder: (column) => column);

  GeneratedColumn<String> get variantName => $composableBuilder(
    column: $table.variantName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unitPriceMinor => $composableBuilder(
    column: $table.unitPriceMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<int> get currencyExponent => $composableBuilder(
    column: $table.currencyExponent,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CartEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CartEntriesTable,
          CartEntry,
          $$CartEntriesTableFilterComposer,
          $$CartEntriesTableOrderingComposer,
          $$CartEntriesTableAnnotationComposer,
          $$CartEntriesTableCreateCompanionBuilder,
          $$CartEntriesTableUpdateCompanionBuilder,
          (
            CartEntry,
            BaseReferences<_$AppDatabase, $CartEntriesTable, CartEntry>,
          ),
          CartEntry,
          PrefetchHooks Function()
        > {
  $$CartEntriesTableTableManager(_$AppDatabase db, $CartEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CartEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CartEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CartEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> menuId = const Value.absent(),
                Value<String> variantId = const Value.absent(),
                Value<String> itemName = const Value.absent(),
                Value<String> variantName = const Value.absent(),
                Value<int> unitPriceMinor = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<int> currencyExponent = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CartEntriesCompanion(
                menuId: menuId,
                variantId: variantId,
                itemName: itemName,
                variantName: variantName,
                unitPriceMinor: unitPriceMinor,
                quantity: quantity,
                currency: currency,
                currencyExponent: currencyExponent,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String menuId,
                required String variantId,
                required String itemName,
                required String variantName,
                required int unitPriceMinor,
                Value<int> quantity = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<int> currencyExponent = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CartEntriesCompanion.insert(
                menuId: menuId,
                variantId: variantId,
                itemName: itemName,
                variantName: variantName,
                unitPriceMinor: unitPriceMinor,
                quantity: quantity,
                currency: currency,
                currencyExponent: currencyExponent,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CartEntriesTable, CartEntry>(table),
                  BaseReferences<_$AppDatabase, $CartEntriesTable, CartEntry>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CartEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CartEntriesTable,
      CartEntry,
      $$CartEntriesTableFilterComposer,
      $$CartEntriesTableOrderingComposer,
      $$CartEntriesTableAnnotationComposer,
      $$CartEntriesTableCreateCompanionBuilder,
      $$CartEntriesTableUpdateCompanionBuilder,
      (CartEntry, BaseReferences<_$AppDatabase, $CartEntriesTable, CartEntry>),
      CartEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RecoveryJobsTableTableManager get recoveryJobs =>
      $$RecoveryJobsTableTableManager(_db, _db.recoveryJobs);
  $$CartEntriesTableTableManager get cartEntries =>
      $$CartEntriesTableTableManager(_db, _db.cartEntries);
}
