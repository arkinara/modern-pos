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

class $CheckoutIntentsTable extends CheckoutIntents
    with TableInfo<$CheckoutIntentsTable, CheckoutIntent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CheckoutIntentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _outletIdMeta = const VerificationMeta(
    'outletId',
  );
  @override
  late final GeneratedColumn<String> outletId = GeneratedColumn<String>(
    'outlet_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderIdMeta = const VerificationMeta(
    'orderId',
  );
  @override
  late final GeneratedColumn<String> orderId = GeneratedColumn<String>(
    'order_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quoteIdMeta = const VerificationMeta(
    'quoteId',
  );
  @override
  late final GeneratedColumn<String> quoteId = GeneratedColumn<String>(
    'quote_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentJsonMeta = const VerificationMeta(
    'paymentJson',
  );
  @override
  late final GeneratedColumn<String> paymentJson = GeneratedColumn<String>(
    'payment_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalMinorMeta = const VerificationMeta(
    'totalMinor',
  );
  @override
  late final GeneratedColumn<int> totalMinor = GeneratedColumn<int>(
    'total_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _saleReferenceMeta = const VerificationMeta(
    'saleReference',
  );
  @override
  late final GeneratedColumn<String> saleReference = GeneratedColumn<String>(
    'sale_reference',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    idempotencyKey,
    deviceId,
    outletId,
    orderId,
    quoteId,
    paymentJson,
    totalMinor,
    currency,
    currencyExponent,
    status,
    saleReference,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'checkout_intents';
  @override
  VerificationContext validateIntegrity(
    Insertable<CheckoutIntent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('outlet_id')) {
      context.handle(
        _outletIdMeta,
        outletId.isAcceptableOrUnknown(data['outlet_id']!, _outletIdMeta),
      );
    } else if (isInserting) {
      context.missing(_outletIdMeta);
    }
    if (data.containsKey('order_id')) {
      context.handle(
        _orderIdMeta,
        orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('quote_id')) {
      context.handle(
        _quoteIdMeta,
        quoteId.isAcceptableOrUnknown(data['quote_id']!, _quoteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_quoteIdMeta);
    }
    if (data.containsKey('payment_json')) {
      context.handle(
        _paymentJsonMeta,
        paymentJson.isAcceptableOrUnknown(
          data['payment_json']!,
          _paymentJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentJsonMeta);
    }
    if (data.containsKey('total_minor')) {
      context.handle(
        _totalMinorMeta,
        totalMinor.isAcceptableOrUnknown(data['total_minor']!, _totalMinorMeta),
      );
    } else if (isInserting) {
      context.missing(_totalMinorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('currency_exponent')) {
      context.handle(
        _currencyExponentMeta,
        currencyExponent.isAcceptableOrUnknown(
          data['currency_exponent']!,
          _currencyExponentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyExponentMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('sale_reference')) {
      context.handle(
        _saleReferenceMeta,
        saleReference.isAcceptableOrUnknown(
          data['sale_reference']!,
          _saleReferenceMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {idempotencyKey};
  @override
  CheckoutIntent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CheckoutIntent(
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      outletId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outlet_id'],
      )!,
      orderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_id'],
      )!,
      quoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quote_id'],
      )!,
      paymentJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_json'],
      )!,
      totalMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_minor'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      currencyExponent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}currency_exponent'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      saleReference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_reference'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CheckoutIntentsTable createAlias(String alias) {
    return $CheckoutIntentsTable(attachedDatabase, alias);
  }
}

class CheckoutIntent extends DataClass implements Insertable<CheckoutIntent> {
  final String idempotencyKey;
  final String deviceId;
  final String outletId;
  final String orderId;
  final String quoteId;
  final String paymentJson;
  final int totalMinor;
  final String currency;
  final int currencyExponent;
  final String status;
  final String? saleReference;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CheckoutIntent({
    required this.idempotencyKey,
    required this.deviceId,
    required this.outletId,
    required this.orderId,
    required this.quoteId,
    required this.paymentJson,
    required this.totalMinor,
    required this.currency,
    required this.currencyExponent,
    required this.status,
    this.saleReference,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['device_id'] = Variable<String>(deviceId);
    map['outlet_id'] = Variable<String>(outletId);
    map['order_id'] = Variable<String>(orderId);
    map['quote_id'] = Variable<String>(quoteId);
    map['payment_json'] = Variable<String>(paymentJson);
    map['total_minor'] = Variable<int>(totalMinor);
    map['currency'] = Variable<String>(currency);
    map['currency_exponent'] = Variable<int>(currencyExponent);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || saleReference != null) {
      map['sale_reference'] = Variable<String>(saleReference);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CheckoutIntentsCompanion toCompanion(bool nullToAbsent) {
    return CheckoutIntentsCompanion(
      idempotencyKey: Value(idempotencyKey),
      deviceId: Value(deviceId),
      outletId: Value(outletId),
      orderId: Value(orderId),
      quoteId: Value(quoteId),
      paymentJson: Value(paymentJson),
      totalMinor: Value(totalMinor),
      currency: Value(currency),
      currencyExponent: Value(currencyExponent),
      status: Value(status),
      saleReference: saleReference == null && nullToAbsent
          ? const Value.absent()
          : Value(saleReference),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CheckoutIntent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CheckoutIntent(
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      outletId: serializer.fromJson<String>(json['outletId']),
      orderId: serializer.fromJson<String>(json['orderId']),
      quoteId: serializer.fromJson<String>(json['quoteId']),
      paymentJson: serializer.fromJson<String>(json['paymentJson']),
      totalMinor: serializer.fromJson<int>(json['totalMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      currencyExponent: serializer.fromJson<int>(json['currencyExponent']),
      status: serializer.fromJson<String>(json['status']),
      saleReference: serializer.fromJson<String?>(json['saleReference']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'deviceId': serializer.toJson<String>(deviceId),
      'outletId': serializer.toJson<String>(outletId),
      'orderId': serializer.toJson<String>(orderId),
      'quoteId': serializer.toJson<String>(quoteId),
      'paymentJson': serializer.toJson<String>(paymentJson),
      'totalMinor': serializer.toJson<int>(totalMinor),
      'currency': serializer.toJson<String>(currency),
      'currencyExponent': serializer.toJson<int>(currencyExponent),
      'status': serializer.toJson<String>(status),
      'saleReference': serializer.toJson<String?>(saleReference),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CheckoutIntent copyWith({
    String? idempotencyKey,
    String? deviceId,
    String? outletId,
    String? orderId,
    String? quoteId,
    String? paymentJson,
    int? totalMinor,
    String? currency,
    int? currencyExponent,
    String? status,
    Value<String?> saleReference = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CheckoutIntent(
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    deviceId: deviceId ?? this.deviceId,
    outletId: outletId ?? this.outletId,
    orderId: orderId ?? this.orderId,
    quoteId: quoteId ?? this.quoteId,
    paymentJson: paymentJson ?? this.paymentJson,
    totalMinor: totalMinor ?? this.totalMinor,
    currency: currency ?? this.currency,
    currencyExponent: currencyExponent ?? this.currencyExponent,
    status: status ?? this.status,
    saleReference: saleReference.present
        ? saleReference.value
        : this.saleReference,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CheckoutIntent copyWithCompanion(CheckoutIntentsCompanion data) {
    return CheckoutIntent(
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      outletId: data.outletId.present ? data.outletId.value : this.outletId,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      quoteId: data.quoteId.present ? data.quoteId.value : this.quoteId,
      paymentJson: data.paymentJson.present
          ? data.paymentJson.value
          : this.paymentJson,
      totalMinor: data.totalMinor.present
          ? data.totalMinor.value
          : this.totalMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      currencyExponent: data.currencyExponent.present
          ? data.currencyExponent.value
          : this.currencyExponent,
      status: data.status.present ? data.status.value : this.status,
      saleReference: data.saleReference.present
          ? data.saleReference.value
          : this.saleReference,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CheckoutIntent(')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('deviceId: $deviceId, ')
          ..write('outletId: $outletId, ')
          ..write('orderId: $orderId, ')
          ..write('quoteId: $quoteId, ')
          ..write('paymentJson: $paymentJson, ')
          ..write('totalMinor: $totalMinor, ')
          ..write('currency: $currency, ')
          ..write('currencyExponent: $currencyExponent, ')
          ..write('status: $status, ')
          ..write('saleReference: $saleReference, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    idempotencyKey,
    deviceId,
    outletId,
    orderId,
    quoteId,
    paymentJson,
    totalMinor,
    currency,
    currencyExponent,
    status,
    saleReference,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CheckoutIntent &&
          other.idempotencyKey == this.idempotencyKey &&
          other.deviceId == this.deviceId &&
          other.outletId == this.outletId &&
          other.orderId == this.orderId &&
          other.quoteId == this.quoteId &&
          other.paymentJson == this.paymentJson &&
          other.totalMinor == this.totalMinor &&
          other.currency == this.currency &&
          other.currencyExponent == this.currencyExponent &&
          other.status == this.status &&
          other.saleReference == this.saleReference &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CheckoutIntentsCompanion extends UpdateCompanion<CheckoutIntent> {
  final Value<String> idempotencyKey;
  final Value<String> deviceId;
  final Value<String> outletId;
  final Value<String> orderId;
  final Value<String> quoteId;
  final Value<String> paymentJson;
  final Value<int> totalMinor;
  final Value<String> currency;
  final Value<int> currencyExponent;
  final Value<String> status;
  final Value<String?> saleReference;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CheckoutIntentsCompanion({
    this.idempotencyKey = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.outletId = const Value.absent(),
    this.orderId = const Value.absent(),
    this.quoteId = const Value.absent(),
    this.paymentJson = const Value.absent(),
    this.totalMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.currencyExponent = const Value.absent(),
    this.status = const Value.absent(),
    this.saleReference = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CheckoutIntentsCompanion.insert({
    required String idempotencyKey,
    required String deviceId,
    required String outletId,
    required String orderId,
    required String quoteId,
    required String paymentJson,
    required int totalMinor,
    required String currency,
    required int currencyExponent,
    this.status = const Value.absent(),
    this.saleReference = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : idempotencyKey = Value(idempotencyKey),
       deviceId = Value(deviceId),
       outletId = Value(outletId),
       orderId = Value(orderId),
       quoteId = Value(quoteId),
       paymentJson = Value(paymentJson),
       totalMinor = Value(totalMinor),
       currency = Value(currency),
       currencyExponent = Value(currencyExponent),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CheckoutIntent> custom({
    Expression<String>? idempotencyKey,
    Expression<String>? deviceId,
    Expression<String>? outletId,
    Expression<String>? orderId,
    Expression<String>? quoteId,
    Expression<String>? paymentJson,
    Expression<int>? totalMinor,
    Expression<String>? currency,
    Expression<int>? currencyExponent,
    Expression<String>? status,
    Expression<String>? saleReference,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (deviceId != null) 'device_id': deviceId,
      if (outletId != null) 'outlet_id': outletId,
      if (orderId != null) 'order_id': orderId,
      if (quoteId != null) 'quote_id': quoteId,
      if (paymentJson != null) 'payment_json': paymentJson,
      if (totalMinor != null) 'total_minor': totalMinor,
      if (currency != null) 'currency': currency,
      if (currencyExponent != null) 'currency_exponent': currencyExponent,
      if (status != null) 'status': status,
      if (saleReference != null) 'sale_reference': saleReference,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CheckoutIntentsCompanion copyWith({
    Value<String>? idempotencyKey,
    Value<String>? deviceId,
    Value<String>? outletId,
    Value<String>? orderId,
    Value<String>? quoteId,
    Value<String>? paymentJson,
    Value<int>? totalMinor,
    Value<String>? currency,
    Value<int>? currencyExponent,
    Value<String>? status,
    Value<String?>? saleReference,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CheckoutIntentsCompanion(
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      deviceId: deviceId ?? this.deviceId,
      outletId: outletId ?? this.outletId,
      orderId: orderId ?? this.orderId,
      quoteId: quoteId ?? this.quoteId,
      paymentJson: paymentJson ?? this.paymentJson,
      totalMinor: totalMinor ?? this.totalMinor,
      currency: currency ?? this.currency,
      currencyExponent: currencyExponent ?? this.currencyExponent,
      status: status ?? this.status,
      saleReference: saleReference ?? this.saleReference,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (outletId.present) {
      map['outlet_id'] = Variable<String>(outletId.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<String>(orderId.value);
    }
    if (quoteId.present) {
      map['quote_id'] = Variable<String>(quoteId.value);
    }
    if (paymentJson.present) {
      map['payment_json'] = Variable<String>(paymentJson.value);
    }
    if (totalMinor.present) {
      map['total_minor'] = Variable<int>(totalMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (currencyExponent.present) {
      map['currency_exponent'] = Variable<int>(currencyExponent.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (saleReference.present) {
      map['sale_reference'] = Variable<String>(saleReference.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('CheckoutIntentsCompanion(')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('deviceId: $deviceId, ')
          ..write('outletId: $outletId, ')
          ..write('orderId: $orderId, ')
          ..write('quoteId: $quoteId, ')
          ..write('paymentJson: $paymentJson, ')
          ..write('totalMinor: $totalMinor, ')
          ..write('currency: $currency, ')
          ..write('currencyExponent: $currencyExponent, ')
          ..write('status: $status, ')
          ..write('saleReference: $saleReference, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PrintQueueJobsTable extends PrintQueueJobs
    with TableInfo<$PrintQueueJobsTable, PrintQueueJob> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrintQueueJobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<String> saleId = GeneratedColumn<String>(
    'sale_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saleReferenceMeta = const VerificationMeta(
    'saleReference',
  );
  @override
  late final GeneratedColumn<String> saleReference = GeneratedColumn<String>(
    'sale_reference',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _outletIdMeta = const VerificationMeta(
    'outletId',
  );
  @override
  late final GeneratedColumn<String> outletId = GeneratedColumn<String>(
    'outlet_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _printerConfigIdMeta = const VerificationMeta(
    'printerConfigId',
  );
  @override
  late final GeneratedColumn<String> printerConfigId = GeneratedColumn<String>(
    'printer_config_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _printerConfigJsonMeta = const VerificationMeta(
    'printerConfigJson',
  );
  @override
  late final GeneratedColumn<String> printerConfigJson =
      GeneratedColumn<String>(
        'printer_config_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _receiptJsonMeta = const VerificationMeta(
    'receiptJson',
  );
  @override
  late final GeneratedColumn<String> receiptJson = GeneratedColumn<String>(
    'receipt_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('queued'),
  );
  static const VerificationMeta _copyMeta = const VerificationMeta('copy');
  @override
  late final GeneratedColumn<bool> copy = GeneratedColumn<bool>(
    'copy',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("copy" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverMirroredMeta = const VerificationMeta(
    'serverMirrored',
  );
  @override
  late final GeneratedColumn<bool> serverMirrored = GeneratedColumn<bool>(
    'server_mirrored',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("server_mirrored" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    saleId,
    saleReference,
    outletId,
    deviceId,
    printerConfigId,
    printerConfigJson,
    receiptJson,
    state,
    copy,
    attempts,
    lastError,
    serverMirrored,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'print_queue_jobs';
  @override
  VerificationContext validateIntegrity(
    Insertable<PrintQueueJob> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sale_id')) {
      context.handle(
        _saleIdMeta,
        saleId.isAcceptableOrUnknown(data['sale_id']!, _saleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_saleIdMeta);
    }
    if (data.containsKey('sale_reference')) {
      context.handle(
        _saleReferenceMeta,
        saleReference.isAcceptableOrUnknown(
          data['sale_reference']!,
          _saleReferenceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_saleReferenceMeta);
    }
    if (data.containsKey('outlet_id')) {
      context.handle(
        _outletIdMeta,
        outletId.isAcceptableOrUnknown(data['outlet_id']!, _outletIdMeta),
      );
    } else if (isInserting) {
      context.missing(_outletIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('printer_config_id')) {
      context.handle(
        _printerConfigIdMeta,
        printerConfigId.isAcceptableOrUnknown(
          data['printer_config_id']!,
          _printerConfigIdMeta,
        ),
      );
    }
    if (data.containsKey('printer_config_json')) {
      context.handle(
        _printerConfigJsonMeta,
        printerConfigJson.isAcceptableOrUnknown(
          data['printer_config_json']!,
          _printerConfigJsonMeta,
        ),
      );
    }
    if (data.containsKey('receipt_json')) {
      context.handle(
        _receiptJsonMeta,
        receiptJson.isAcceptableOrUnknown(
          data['receipt_json']!,
          _receiptJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_receiptJsonMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('copy')) {
      context.handle(
        _copyMeta,
        copy.isAcceptableOrUnknown(data['copy']!, _copyMeta),
      );
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('server_mirrored')) {
      context.handle(
        _serverMirroredMeta,
        serverMirrored.isAcceptableOrUnknown(
          data['server_mirrored']!,
          _serverMirroredMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PrintQueueJob map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PrintQueueJob(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      saleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_id'],
      )!,
      saleReference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_reference'],
      )!,
      outletId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outlet_id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      printerConfigId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}printer_config_id'],
      ),
      printerConfigJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}printer_config_json'],
      ),
      receiptJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_json'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      copy: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}copy'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      serverMirrored: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}server_mirrored'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PrintQueueJobsTable createAlias(String alias) {
    return $PrintQueueJobsTable(attachedDatabase, alias);
  }
}

class PrintQueueJob extends DataClass implements Insertable<PrintQueueJob> {
  final String id;
  final String saleId;
  final String saleReference;
  final String outletId;
  final String deviceId;
  final String? printerConfigId;
  final String? printerConfigJson;
  final String receiptJson;
  final String state;
  final bool copy;
  final int attempts;
  final String? lastError;
  final bool serverMirrored;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PrintQueueJob({
    required this.id,
    required this.saleId,
    required this.saleReference,
    required this.outletId,
    required this.deviceId,
    this.printerConfigId,
    this.printerConfigJson,
    required this.receiptJson,
    required this.state,
    required this.copy,
    required this.attempts,
    this.lastError,
    required this.serverMirrored,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sale_id'] = Variable<String>(saleId);
    map['sale_reference'] = Variable<String>(saleReference);
    map['outlet_id'] = Variable<String>(outletId);
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || printerConfigId != null) {
      map['printer_config_id'] = Variable<String>(printerConfigId);
    }
    if (!nullToAbsent || printerConfigJson != null) {
      map['printer_config_json'] = Variable<String>(printerConfigJson);
    }
    map['receipt_json'] = Variable<String>(receiptJson);
    map['state'] = Variable<String>(state);
    map['copy'] = Variable<bool>(copy);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['server_mirrored'] = Variable<bool>(serverMirrored);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PrintQueueJobsCompanion toCompanion(bool nullToAbsent) {
    return PrintQueueJobsCompanion(
      id: Value(id),
      saleId: Value(saleId),
      saleReference: Value(saleReference),
      outletId: Value(outletId),
      deviceId: Value(deviceId),
      printerConfigId: printerConfigId == null && nullToAbsent
          ? const Value.absent()
          : Value(printerConfigId),
      printerConfigJson: printerConfigJson == null && nullToAbsent
          ? const Value.absent()
          : Value(printerConfigJson),
      receiptJson: Value(receiptJson),
      state: Value(state),
      copy: Value(copy),
      attempts: Value(attempts),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      serverMirrored: Value(serverMirrored),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PrintQueueJob.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PrintQueueJob(
      id: serializer.fromJson<String>(json['id']),
      saleId: serializer.fromJson<String>(json['saleId']),
      saleReference: serializer.fromJson<String>(json['saleReference']),
      outletId: serializer.fromJson<String>(json['outletId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      printerConfigId: serializer.fromJson<String?>(json['printerConfigId']),
      printerConfigJson: serializer.fromJson<String?>(
        json['printerConfigJson'],
      ),
      receiptJson: serializer.fromJson<String>(json['receiptJson']),
      state: serializer.fromJson<String>(json['state']),
      copy: serializer.fromJson<bool>(json['copy']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      serverMirrored: serializer.fromJson<bool>(json['serverMirrored']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'saleId': serializer.toJson<String>(saleId),
      'saleReference': serializer.toJson<String>(saleReference),
      'outletId': serializer.toJson<String>(outletId),
      'deviceId': serializer.toJson<String>(deviceId),
      'printerConfigId': serializer.toJson<String?>(printerConfigId),
      'printerConfigJson': serializer.toJson<String?>(printerConfigJson),
      'receiptJson': serializer.toJson<String>(receiptJson),
      'state': serializer.toJson<String>(state),
      'copy': serializer.toJson<bool>(copy),
      'attempts': serializer.toJson<int>(attempts),
      'lastError': serializer.toJson<String?>(lastError),
      'serverMirrored': serializer.toJson<bool>(serverMirrored),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PrintQueueJob copyWith({
    String? id,
    String? saleId,
    String? saleReference,
    String? outletId,
    String? deviceId,
    Value<String?> printerConfigId = const Value.absent(),
    Value<String?> printerConfigJson = const Value.absent(),
    String? receiptJson,
    String? state,
    bool? copy,
    int? attempts,
    Value<String?> lastError = const Value.absent(),
    bool? serverMirrored,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PrintQueueJob(
    id: id ?? this.id,
    saleId: saleId ?? this.saleId,
    saleReference: saleReference ?? this.saleReference,
    outletId: outletId ?? this.outletId,
    deviceId: deviceId ?? this.deviceId,
    printerConfigId: printerConfigId.present
        ? printerConfigId.value
        : this.printerConfigId,
    printerConfigJson: printerConfigJson.present
        ? printerConfigJson.value
        : this.printerConfigJson,
    receiptJson: receiptJson ?? this.receiptJson,
    state: state ?? this.state,
    copy: copy ?? this.copy,
    attempts: attempts ?? this.attempts,
    lastError: lastError.present ? lastError.value : this.lastError,
    serverMirrored: serverMirrored ?? this.serverMirrored,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PrintQueueJob copyWithCompanion(PrintQueueJobsCompanion data) {
    return PrintQueueJob(
      id: data.id.present ? data.id.value : this.id,
      saleId: data.saleId.present ? data.saleId.value : this.saleId,
      saleReference: data.saleReference.present
          ? data.saleReference.value
          : this.saleReference,
      outletId: data.outletId.present ? data.outletId.value : this.outletId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      printerConfigId: data.printerConfigId.present
          ? data.printerConfigId.value
          : this.printerConfigId,
      printerConfigJson: data.printerConfigJson.present
          ? data.printerConfigJson.value
          : this.printerConfigJson,
      receiptJson: data.receiptJson.present
          ? data.receiptJson.value
          : this.receiptJson,
      state: data.state.present ? data.state.value : this.state,
      copy: data.copy.present ? data.copy.value : this.copy,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      serverMirrored: data.serverMirrored.present
          ? data.serverMirrored.value
          : this.serverMirrored,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PrintQueueJob(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('saleReference: $saleReference, ')
          ..write('outletId: $outletId, ')
          ..write('deviceId: $deviceId, ')
          ..write('printerConfigId: $printerConfigId, ')
          ..write('printerConfigJson: $printerConfigJson, ')
          ..write('receiptJson: $receiptJson, ')
          ..write('state: $state, ')
          ..write('copy: $copy, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError, ')
          ..write('serverMirrored: $serverMirrored, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    saleId,
    saleReference,
    outletId,
    deviceId,
    printerConfigId,
    printerConfigJson,
    receiptJson,
    state,
    copy,
    attempts,
    lastError,
    serverMirrored,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PrintQueueJob &&
          other.id == this.id &&
          other.saleId == this.saleId &&
          other.saleReference == this.saleReference &&
          other.outletId == this.outletId &&
          other.deviceId == this.deviceId &&
          other.printerConfigId == this.printerConfigId &&
          other.printerConfigJson == this.printerConfigJson &&
          other.receiptJson == this.receiptJson &&
          other.state == this.state &&
          other.copy == this.copy &&
          other.attempts == this.attempts &&
          other.lastError == this.lastError &&
          other.serverMirrored == this.serverMirrored &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PrintQueueJobsCompanion extends UpdateCompanion<PrintQueueJob> {
  final Value<String> id;
  final Value<String> saleId;
  final Value<String> saleReference;
  final Value<String> outletId;
  final Value<String> deviceId;
  final Value<String?> printerConfigId;
  final Value<String?> printerConfigJson;
  final Value<String> receiptJson;
  final Value<String> state;
  final Value<bool> copy;
  final Value<int> attempts;
  final Value<String?> lastError;
  final Value<bool> serverMirrored;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PrintQueueJobsCompanion({
    this.id = const Value.absent(),
    this.saleId = const Value.absent(),
    this.saleReference = const Value.absent(),
    this.outletId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.printerConfigId = const Value.absent(),
    this.printerConfigJson = const Value.absent(),
    this.receiptJson = const Value.absent(),
    this.state = const Value.absent(),
    this.copy = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.serverMirrored = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PrintQueueJobsCompanion.insert({
    required String id,
    required String saleId,
    required String saleReference,
    required String outletId,
    required String deviceId,
    this.printerConfigId = const Value.absent(),
    this.printerConfigJson = const Value.absent(),
    required String receiptJson,
    this.state = const Value.absent(),
    this.copy = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.serverMirrored = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       saleId = Value(saleId),
       saleReference = Value(saleReference),
       outletId = Value(outletId),
       deviceId = Value(deviceId),
       receiptJson = Value(receiptJson),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PrintQueueJob> custom({
    Expression<String>? id,
    Expression<String>? saleId,
    Expression<String>? saleReference,
    Expression<String>? outletId,
    Expression<String>? deviceId,
    Expression<String>? printerConfigId,
    Expression<String>? printerConfigJson,
    Expression<String>? receiptJson,
    Expression<String>? state,
    Expression<bool>? copy,
    Expression<int>? attempts,
    Expression<String>? lastError,
    Expression<bool>? serverMirrored,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (saleId != null) 'sale_id': saleId,
      if (saleReference != null) 'sale_reference': saleReference,
      if (outletId != null) 'outlet_id': outletId,
      if (deviceId != null) 'device_id': deviceId,
      if (printerConfigId != null) 'printer_config_id': printerConfigId,
      if (printerConfigJson != null) 'printer_config_json': printerConfigJson,
      if (receiptJson != null) 'receipt_json': receiptJson,
      if (state != null) 'state': state,
      if (copy != null) 'copy': copy,
      if (attempts != null) 'attempts': attempts,
      if (lastError != null) 'last_error': lastError,
      if (serverMirrored != null) 'server_mirrored': serverMirrored,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PrintQueueJobsCompanion copyWith({
    Value<String>? id,
    Value<String>? saleId,
    Value<String>? saleReference,
    Value<String>? outletId,
    Value<String>? deviceId,
    Value<String?>? printerConfigId,
    Value<String?>? printerConfigJson,
    Value<String>? receiptJson,
    Value<String>? state,
    Value<bool>? copy,
    Value<int>? attempts,
    Value<String?>? lastError,
    Value<bool>? serverMirrored,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PrintQueueJobsCompanion(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      saleReference: saleReference ?? this.saleReference,
      outletId: outletId ?? this.outletId,
      deviceId: deviceId ?? this.deviceId,
      printerConfigId: printerConfigId ?? this.printerConfigId,
      printerConfigJson: printerConfigJson ?? this.printerConfigJson,
      receiptJson: receiptJson ?? this.receiptJson,
      state: state ?? this.state,
      copy: copy ?? this.copy,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
      serverMirrored: serverMirrored ?? this.serverMirrored,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (saleId.present) {
      map['sale_id'] = Variable<String>(saleId.value);
    }
    if (saleReference.present) {
      map['sale_reference'] = Variable<String>(saleReference.value);
    }
    if (outletId.present) {
      map['outlet_id'] = Variable<String>(outletId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (printerConfigId.present) {
      map['printer_config_id'] = Variable<String>(printerConfigId.value);
    }
    if (printerConfigJson.present) {
      map['printer_config_json'] = Variable<String>(printerConfigJson.value);
    }
    if (receiptJson.present) {
      map['receipt_json'] = Variable<String>(receiptJson.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (copy.present) {
      map['copy'] = Variable<bool>(copy.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (serverMirrored.present) {
      map['server_mirrored'] = Variable<bool>(serverMirrored.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('PrintQueueJobsCompanion(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('saleReference: $saleReference, ')
          ..write('outletId: $outletId, ')
          ..write('deviceId: $deviceId, ')
          ..write('printerConfigId: $printerConfigId, ')
          ..write('printerConfigJson: $printerConfigJson, ')
          ..write('receiptJson: $receiptJson, ')
          ..write('state: $state, ')
          ..write('copy: $copy, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError, ')
          ..write('serverMirrored: $serverMirrored, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PrintQueueAuditsTable extends PrintQueueAudits
    with TableInfo<$PrintQueueAuditsTable, PrintQueueAudit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrintQueueAuditsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _jobIdMeta = const VerificationMeta('jobId');
  @override
  late final GeneratedColumn<String> jobId = GeneratedColumn<String>(
    'job_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<String> saleId = GeneratedColumn<String>(
    'sale_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actorIdMeta = const VerificationMeta(
    'actorId',
  );
  @override
  late final GeneratedColumn<String> actorId = GeneratedColumn<String>(
    'actor_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actorEmailMeta = const VerificationMeta(
    'actorEmail',
  );
  @override
  late final GeneratedColumn<String> actorEmail = GeneratedColumn<String>(
    'actor_email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _copyMeta = const VerificationMeta('copy');
  @override
  late final GeneratedColumn<bool> copy = GeneratedColumn<bool>(
    'copy',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("copy" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _detailMeta = const VerificationMeta('detail');
  @override
  late final GeneratedColumn<String> detail = GeneratedColumn<String>(
    'detail',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
  List<GeneratedColumn> get $columns => [
    id,
    jobId,
    saleId,
    action,
    actorId,
    actorEmail,
    copy,
    detail,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'print_queue_audits';
  @override
  VerificationContext validateIntegrity(
    Insertable<PrintQueueAudit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('job_id')) {
      context.handle(
        _jobIdMeta,
        jobId.isAcceptableOrUnknown(data['job_id']!, _jobIdMeta),
      );
    } else if (isInserting) {
      context.missing(_jobIdMeta);
    }
    if (data.containsKey('sale_id')) {
      context.handle(
        _saleIdMeta,
        saleId.isAcceptableOrUnknown(data['sale_id']!, _saleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_saleIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('actor_id')) {
      context.handle(
        _actorIdMeta,
        actorId.isAcceptableOrUnknown(data['actor_id']!, _actorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_actorIdMeta);
    }
    if (data.containsKey('actor_email')) {
      context.handle(
        _actorEmailMeta,
        actorEmail.isAcceptableOrUnknown(data['actor_email']!, _actorEmailMeta),
      );
    } else if (isInserting) {
      context.missing(_actorEmailMeta);
    }
    if (data.containsKey('copy')) {
      context.handle(
        _copyMeta,
        copy.isAcceptableOrUnknown(data['copy']!, _copyMeta),
      );
    }
    if (data.containsKey('detail')) {
      context.handle(
        _detailMeta,
        detail.isAcceptableOrUnknown(data['detail']!, _detailMeta),
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
  PrintQueueAudit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PrintQueueAudit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      jobId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}job_id'],
      )!,
      saleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_id'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      actorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor_id'],
      )!,
      actorEmail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor_email'],
      )!,
      copy: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}copy'],
      )!,
      detail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detail'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PrintQueueAuditsTable createAlias(String alias) {
    return $PrintQueueAuditsTable(attachedDatabase, alias);
  }
}

class PrintQueueAudit extends DataClass implements Insertable<PrintQueueAudit> {
  final int id;
  final String jobId;
  final String saleId;
  final String action;
  final String actorId;
  final String actorEmail;
  final bool copy;
  final String detail;
  final DateTime createdAt;
  const PrintQueueAudit({
    required this.id,
    required this.jobId,
    required this.saleId,
    required this.action,
    required this.actorId,
    required this.actorEmail,
    required this.copy,
    required this.detail,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['job_id'] = Variable<String>(jobId);
    map['sale_id'] = Variable<String>(saleId);
    map['action'] = Variable<String>(action);
    map['actor_id'] = Variable<String>(actorId);
    map['actor_email'] = Variable<String>(actorEmail);
    map['copy'] = Variable<bool>(copy);
    map['detail'] = Variable<String>(detail);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PrintQueueAuditsCompanion toCompanion(bool nullToAbsent) {
    return PrintQueueAuditsCompanion(
      id: Value(id),
      jobId: Value(jobId),
      saleId: Value(saleId),
      action: Value(action),
      actorId: Value(actorId),
      actorEmail: Value(actorEmail),
      copy: Value(copy),
      detail: Value(detail),
      createdAt: Value(createdAt),
    );
  }

  factory PrintQueueAudit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PrintQueueAudit(
      id: serializer.fromJson<int>(json['id']),
      jobId: serializer.fromJson<String>(json['jobId']),
      saleId: serializer.fromJson<String>(json['saleId']),
      action: serializer.fromJson<String>(json['action']),
      actorId: serializer.fromJson<String>(json['actorId']),
      actorEmail: serializer.fromJson<String>(json['actorEmail']),
      copy: serializer.fromJson<bool>(json['copy']),
      detail: serializer.fromJson<String>(json['detail']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'jobId': serializer.toJson<String>(jobId),
      'saleId': serializer.toJson<String>(saleId),
      'action': serializer.toJson<String>(action),
      'actorId': serializer.toJson<String>(actorId),
      'actorEmail': serializer.toJson<String>(actorEmail),
      'copy': serializer.toJson<bool>(copy),
      'detail': serializer.toJson<String>(detail),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PrintQueueAudit copyWith({
    int? id,
    String? jobId,
    String? saleId,
    String? action,
    String? actorId,
    String? actorEmail,
    bool? copy,
    String? detail,
    DateTime? createdAt,
  }) => PrintQueueAudit(
    id: id ?? this.id,
    jobId: jobId ?? this.jobId,
    saleId: saleId ?? this.saleId,
    action: action ?? this.action,
    actorId: actorId ?? this.actorId,
    actorEmail: actorEmail ?? this.actorEmail,
    copy: copy ?? this.copy,
    detail: detail ?? this.detail,
    createdAt: createdAt ?? this.createdAt,
  );
  PrintQueueAudit copyWithCompanion(PrintQueueAuditsCompanion data) {
    return PrintQueueAudit(
      id: data.id.present ? data.id.value : this.id,
      jobId: data.jobId.present ? data.jobId.value : this.jobId,
      saleId: data.saleId.present ? data.saleId.value : this.saleId,
      action: data.action.present ? data.action.value : this.action,
      actorId: data.actorId.present ? data.actorId.value : this.actorId,
      actorEmail: data.actorEmail.present
          ? data.actorEmail.value
          : this.actorEmail,
      copy: data.copy.present ? data.copy.value : this.copy,
      detail: data.detail.present ? data.detail.value : this.detail,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PrintQueueAudit(')
          ..write('id: $id, ')
          ..write('jobId: $jobId, ')
          ..write('saleId: $saleId, ')
          ..write('action: $action, ')
          ..write('actorId: $actorId, ')
          ..write('actorEmail: $actorEmail, ')
          ..write('copy: $copy, ')
          ..write('detail: $detail, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    jobId,
    saleId,
    action,
    actorId,
    actorEmail,
    copy,
    detail,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PrintQueueAudit &&
          other.id == this.id &&
          other.jobId == this.jobId &&
          other.saleId == this.saleId &&
          other.action == this.action &&
          other.actorId == this.actorId &&
          other.actorEmail == this.actorEmail &&
          other.copy == this.copy &&
          other.detail == this.detail &&
          other.createdAt == this.createdAt);
}

class PrintQueueAuditsCompanion extends UpdateCompanion<PrintQueueAudit> {
  final Value<int> id;
  final Value<String> jobId;
  final Value<String> saleId;
  final Value<String> action;
  final Value<String> actorId;
  final Value<String> actorEmail;
  final Value<bool> copy;
  final Value<String> detail;
  final Value<DateTime> createdAt;
  const PrintQueueAuditsCompanion({
    this.id = const Value.absent(),
    this.jobId = const Value.absent(),
    this.saleId = const Value.absent(),
    this.action = const Value.absent(),
    this.actorId = const Value.absent(),
    this.actorEmail = const Value.absent(),
    this.copy = const Value.absent(),
    this.detail = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PrintQueueAuditsCompanion.insert({
    this.id = const Value.absent(),
    required String jobId,
    required String saleId,
    required String action,
    required String actorId,
    required String actorEmail,
    this.copy = const Value.absent(),
    this.detail = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : jobId = Value(jobId),
       saleId = Value(saleId),
       action = Value(action),
       actorId = Value(actorId),
       actorEmail = Value(actorEmail);
  static Insertable<PrintQueueAudit> custom({
    Expression<int>? id,
    Expression<String>? jobId,
    Expression<String>? saleId,
    Expression<String>? action,
    Expression<String>? actorId,
    Expression<String>? actorEmail,
    Expression<bool>? copy,
    Expression<String>? detail,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (jobId != null) 'job_id': jobId,
      if (saleId != null) 'sale_id': saleId,
      if (action != null) 'action': action,
      if (actorId != null) 'actor_id': actorId,
      if (actorEmail != null) 'actor_email': actorEmail,
      if (copy != null) 'copy': copy,
      if (detail != null) 'detail': detail,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PrintQueueAuditsCompanion copyWith({
    Value<int>? id,
    Value<String>? jobId,
    Value<String>? saleId,
    Value<String>? action,
    Value<String>? actorId,
    Value<String>? actorEmail,
    Value<bool>? copy,
    Value<String>? detail,
    Value<DateTime>? createdAt,
  }) {
    return PrintQueueAuditsCompanion(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      saleId: saleId ?? this.saleId,
      action: action ?? this.action,
      actorId: actorId ?? this.actorId,
      actorEmail: actorEmail ?? this.actorEmail,
      copy: copy ?? this.copy,
      detail: detail ?? this.detail,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (jobId.present) {
      map['job_id'] = Variable<String>(jobId.value);
    }
    if (saleId.present) {
      map['sale_id'] = Variable<String>(saleId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (actorId.present) {
      map['actor_id'] = Variable<String>(actorId.value);
    }
    if (actorEmail.present) {
      map['actor_email'] = Variable<String>(actorEmail.value);
    }
    if (copy.present) {
      map['copy'] = Variable<bool>(copy.value);
    }
    if (detail.present) {
      map['detail'] = Variable<String>(detail.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PrintQueueAuditsCompanion(')
          ..write('id: $id, ')
          ..write('jobId: $jobId, ')
          ..write('saleId: $saleId, ')
          ..write('action: $action, ')
          ..write('actorId: $actorId, ')
          ..write('actorEmail: $actorEmail, ')
          ..write('copy: $copy, ')
          ..write('detail: $detail, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RecoveryJobsTable recoveryJobs = $RecoveryJobsTable(this);
  late final $CartEntriesTable cartEntries = $CartEntriesTable(this);
  late final $CheckoutIntentsTable checkoutIntents = $CheckoutIntentsTable(
    this,
  );
  late final $PrintQueueJobsTable printQueueJobs = $PrintQueueJobsTable(this);
  late final $PrintQueueAuditsTable printQueueAudits = $PrintQueueAuditsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    recoveryJobs,
    cartEntries,
    checkoutIntents,
    printQueueJobs,
    printQueueAudits,
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
typedef $$CheckoutIntentsTableCreateCompanionBuilder =
    CheckoutIntentsCompanion Function({
      required String idempotencyKey,
      required String deviceId,
      required String outletId,
      required String orderId,
      required String quoteId,
      required String paymentJson,
      required int totalMinor,
      required String currency,
      required int currencyExponent,
      Value<String> status,
      Value<String?> saleReference,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CheckoutIntentsTableUpdateCompanionBuilder =
    CheckoutIntentsCompanion Function({
      Value<String> idempotencyKey,
      Value<String> deviceId,
      Value<String> outletId,
      Value<String> orderId,
      Value<String> quoteId,
      Value<String> paymentJson,
      Value<int> totalMinor,
      Value<String> currency,
      Value<int> currencyExponent,
      Value<String> status,
      Value<String?> saleReference,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$CheckoutIntentsTableFilterComposer
    extends Composer<_$AppDatabase, $CheckoutIntentsTable> {
  $$CheckoutIntentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outletId => $composableBuilder(
    column: $table.outletId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orderId => $composableBuilder(
    column: $table.orderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quoteId => $composableBuilder(
    column: $table.quoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentJson => $composableBuilder(
    column: $table.paymentJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalMinor => $composableBuilder(
    column: $table.totalMinor,
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

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get saleReference => $composableBuilder(
    column: $table.saleReference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CheckoutIntentsTableOrderingComposer
    extends Composer<_$AppDatabase, $CheckoutIntentsTable> {
  $$CheckoutIntentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outletId => $composableBuilder(
    column: $table.outletId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orderId => $composableBuilder(
    column: $table.orderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quoteId => $composableBuilder(
    column: $table.quoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentJson => $composableBuilder(
    column: $table.paymentJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalMinor => $composableBuilder(
    column: $table.totalMinor,
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

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get saleReference => $composableBuilder(
    column: $table.saleReference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CheckoutIntentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CheckoutIntentsTable> {
  $$CheckoutIntentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get outletId =>
      $composableBuilder(column: $table.outletId, builder: (column) => column);

  GeneratedColumn<String> get orderId =>
      $composableBuilder(column: $table.orderId, builder: (column) => column);

  GeneratedColumn<String> get quoteId =>
      $composableBuilder(column: $table.quoteId, builder: (column) => column);

  GeneratedColumn<String> get paymentJson => $composableBuilder(
    column: $table.paymentJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalMinor => $composableBuilder(
    column: $table.totalMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<int> get currencyExponent => $composableBuilder(
    column: $table.currencyExponent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get saleReference => $composableBuilder(
    column: $table.saleReference,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CheckoutIntentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CheckoutIntentsTable,
          CheckoutIntent,
          $$CheckoutIntentsTableFilterComposer,
          $$CheckoutIntentsTableOrderingComposer,
          $$CheckoutIntentsTableAnnotationComposer,
          $$CheckoutIntentsTableCreateCompanionBuilder,
          $$CheckoutIntentsTableUpdateCompanionBuilder,
          (
            CheckoutIntent,
            BaseReferences<
              _$AppDatabase,
              $CheckoutIntentsTable,
              CheckoutIntent
            >,
          ),
          CheckoutIntent,
          PrefetchHooks Function()
        > {
  $$CheckoutIntentsTableTableManager(
    _$AppDatabase db,
    $CheckoutIntentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CheckoutIntentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CheckoutIntentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CheckoutIntentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> idempotencyKey = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> outletId = const Value.absent(),
                Value<String> orderId = const Value.absent(),
                Value<String> quoteId = const Value.absent(),
                Value<String> paymentJson = const Value.absent(),
                Value<int> totalMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<int> currencyExponent = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> saleReference = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CheckoutIntentsCompanion(
                idempotencyKey: idempotencyKey,
                deviceId: deviceId,
                outletId: outletId,
                orderId: orderId,
                quoteId: quoteId,
                paymentJson: paymentJson,
                totalMinor: totalMinor,
                currency: currency,
                currencyExponent: currencyExponent,
                status: status,
                saleReference: saleReference,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String idempotencyKey,
                required String deviceId,
                required String outletId,
                required String orderId,
                required String quoteId,
                required String paymentJson,
                required int totalMinor,
                required String currency,
                required int currencyExponent,
                Value<String> status = const Value.absent(),
                Value<String?> saleReference = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CheckoutIntentsCompanion.insert(
                idempotencyKey: idempotencyKey,
                deviceId: deviceId,
                outletId: outletId,
                orderId: orderId,
                quoteId: quoteId,
                paymentJson: paymentJson,
                totalMinor: totalMinor,
                currency: currency,
                currencyExponent: currencyExponent,
                status: status,
                saleReference: saleReference,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CheckoutIntentsTable, CheckoutIntent>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CheckoutIntentsTable,
                    CheckoutIntent
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CheckoutIntentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CheckoutIntentsTable,
      CheckoutIntent,
      $$CheckoutIntentsTableFilterComposer,
      $$CheckoutIntentsTableOrderingComposer,
      $$CheckoutIntentsTableAnnotationComposer,
      $$CheckoutIntentsTableCreateCompanionBuilder,
      $$CheckoutIntentsTableUpdateCompanionBuilder,
      (
        CheckoutIntent,
        BaseReferences<_$AppDatabase, $CheckoutIntentsTable, CheckoutIntent>,
      ),
      CheckoutIntent,
      PrefetchHooks Function()
    >;
typedef $$PrintQueueJobsTableCreateCompanionBuilder =
    PrintQueueJobsCompanion Function({
      required String id,
      required String saleId,
      required String saleReference,
      required String outletId,
      required String deviceId,
      Value<String?> printerConfigId,
      Value<String?> printerConfigJson,
      required String receiptJson,
      Value<String> state,
      Value<bool> copy,
      Value<int> attempts,
      Value<String?> lastError,
      Value<bool> serverMirrored,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$PrintQueueJobsTableUpdateCompanionBuilder =
    PrintQueueJobsCompanion Function({
      Value<String> id,
      Value<String> saleId,
      Value<String> saleReference,
      Value<String> outletId,
      Value<String> deviceId,
      Value<String?> printerConfigId,
      Value<String?> printerConfigJson,
      Value<String> receiptJson,
      Value<String> state,
      Value<bool> copy,
      Value<int> attempts,
      Value<String?> lastError,
      Value<bool> serverMirrored,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$PrintQueueJobsTableFilterComposer
    extends Composer<_$AppDatabase, $PrintQueueJobsTable> {
  $$PrintQueueJobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get saleId => $composableBuilder(
    column: $table.saleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get saleReference => $composableBuilder(
    column: $table.saleReference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outletId => $composableBuilder(
    column: $table.outletId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get printerConfigId => $composableBuilder(
    column: $table.printerConfigId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get printerConfigJson => $composableBuilder(
    column: $table.printerConfigJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receiptJson => $composableBuilder(
    column: $table.receiptJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get copy => $composableBuilder(
    column: $table.copy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get serverMirrored => $composableBuilder(
    column: $table.serverMirrored,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PrintQueueJobsTableOrderingComposer
    extends Composer<_$AppDatabase, $PrintQueueJobsTable> {
  $$PrintQueueJobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get saleId => $composableBuilder(
    column: $table.saleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get saleReference => $composableBuilder(
    column: $table.saleReference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outletId => $composableBuilder(
    column: $table.outletId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get printerConfigId => $composableBuilder(
    column: $table.printerConfigId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get printerConfigJson => $composableBuilder(
    column: $table.printerConfigJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptJson => $composableBuilder(
    column: $table.receiptJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get copy => $composableBuilder(
    column: $table.copy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get serverMirrored => $composableBuilder(
    column: $table.serverMirrored,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PrintQueueJobsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PrintQueueJobsTable> {
  $$PrintQueueJobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get saleId =>
      $composableBuilder(column: $table.saleId, builder: (column) => column);

  GeneratedColumn<String> get saleReference => $composableBuilder(
    column: $table.saleReference,
    builder: (column) => column,
  );

  GeneratedColumn<String> get outletId =>
      $composableBuilder(column: $table.outletId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get printerConfigId => $composableBuilder(
    column: $table.printerConfigId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get printerConfigJson => $composableBuilder(
    column: $table.printerConfigJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get receiptJson => $composableBuilder(
    column: $table.receiptJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<bool> get copy =>
      $composableBuilder(column: $table.copy, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<bool> get serverMirrored => $composableBuilder(
    column: $table.serverMirrored,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PrintQueueJobsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PrintQueueJobsTable,
          PrintQueueJob,
          $$PrintQueueJobsTableFilterComposer,
          $$PrintQueueJobsTableOrderingComposer,
          $$PrintQueueJobsTableAnnotationComposer,
          $$PrintQueueJobsTableCreateCompanionBuilder,
          $$PrintQueueJobsTableUpdateCompanionBuilder,
          (
            PrintQueueJob,
            BaseReferences<_$AppDatabase, $PrintQueueJobsTable, PrintQueueJob>,
          ),
          PrintQueueJob,
          PrefetchHooks Function()
        > {
  $$PrintQueueJobsTableTableManager(
    _$AppDatabase db,
    $PrintQueueJobsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PrintQueueJobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PrintQueueJobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PrintQueueJobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> saleId = const Value.absent(),
                Value<String> saleReference = const Value.absent(),
                Value<String> outletId = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String?> printerConfigId = const Value.absent(),
                Value<String?> printerConfigJson = const Value.absent(),
                Value<String> receiptJson = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<bool> copy = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<bool> serverMirrored = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PrintQueueJobsCompanion(
                id: id,
                saleId: saleId,
                saleReference: saleReference,
                outletId: outletId,
                deviceId: deviceId,
                printerConfigId: printerConfigId,
                printerConfigJson: printerConfigJson,
                receiptJson: receiptJson,
                state: state,
                copy: copy,
                attempts: attempts,
                lastError: lastError,
                serverMirrored: serverMirrored,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String saleId,
                required String saleReference,
                required String outletId,
                required String deviceId,
                Value<String?> printerConfigId = const Value.absent(),
                Value<String?> printerConfigJson = const Value.absent(),
                required String receiptJson,
                Value<String> state = const Value.absent(),
                Value<bool> copy = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<bool> serverMirrored = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PrintQueueJobsCompanion.insert(
                id: id,
                saleId: saleId,
                saleReference: saleReference,
                outletId: outletId,
                deviceId: deviceId,
                printerConfigId: printerConfigId,
                printerConfigJson: printerConfigJson,
                receiptJson: receiptJson,
                state: state,
                copy: copy,
                attempts: attempts,
                lastError: lastError,
                serverMirrored: serverMirrored,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PrintQueueJobsTable, PrintQueueJob>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PrintQueueJobsTable,
                    PrintQueueJob
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PrintQueueJobsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PrintQueueJobsTable,
      PrintQueueJob,
      $$PrintQueueJobsTableFilterComposer,
      $$PrintQueueJobsTableOrderingComposer,
      $$PrintQueueJobsTableAnnotationComposer,
      $$PrintQueueJobsTableCreateCompanionBuilder,
      $$PrintQueueJobsTableUpdateCompanionBuilder,
      (
        PrintQueueJob,
        BaseReferences<_$AppDatabase, $PrintQueueJobsTable, PrintQueueJob>,
      ),
      PrintQueueJob,
      PrefetchHooks Function()
    >;
typedef $$PrintQueueAuditsTableCreateCompanionBuilder =
    PrintQueueAuditsCompanion Function({
      Value<int> id,
      required String jobId,
      required String saleId,
      required String action,
      required String actorId,
      required String actorEmail,
      Value<bool> copy,
      Value<String> detail,
      Value<DateTime> createdAt,
    });
typedef $$PrintQueueAuditsTableUpdateCompanionBuilder =
    PrintQueueAuditsCompanion Function({
      Value<int> id,
      Value<String> jobId,
      Value<String> saleId,
      Value<String> action,
      Value<String> actorId,
      Value<String> actorEmail,
      Value<bool> copy,
      Value<String> detail,
      Value<DateTime> createdAt,
    });

class $$PrintQueueAuditsTableFilterComposer
    extends Composer<_$AppDatabase, $PrintQueueAuditsTable> {
  $$PrintQueueAuditsTableFilterComposer({
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

  ColumnFilters<String> get jobId => $composableBuilder(
    column: $table.jobId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get saleId => $composableBuilder(
    column: $table.saleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actorEmail => $composableBuilder(
    column: $table.actorEmail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get copy => $composableBuilder(
    column: $table.copy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detail => $composableBuilder(
    column: $table.detail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PrintQueueAuditsTableOrderingComposer
    extends Composer<_$AppDatabase, $PrintQueueAuditsTable> {
  $$PrintQueueAuditsTableOrderingComposer({
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

  ColumnOrderings<String> get jobId => $composableBuilder(
    column: $table.jobId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get saleId => $composableBuilder(
    column: $table.saleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actorEmail => $composableBuilder(
    column: $table.actorEmail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get copy => $composableBuilder(
    column: $table.copy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detail => $composableBuilder(
    column: $table.detail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PrintQueueAuditsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PrintQueueAuditsTable> {
  $$PrintQueueAuditsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get jobId =>
      $composableBuilder(column: $table.jobId, builder: (column) => column);

  GeneratedColumn<String> get saleId =>
      $composableBuilder(column: $table.saleId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get actorId =>
      $composableBuilder(column: $table.actorId, builder: (column) => column);

  GeneratedColumn<String> get actorEmail => $composableBuilder(
    column: $table.actorEmail,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get copy =>
      $composableBuilder(column: $table.copy, builder: (column) => column);

  GeneratedColumn<String> get detail =>
      $composableBuilder(column: $table.detail, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PrintQueueAuditsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PrintQueueAuditsTable,
          PrintQueueAudit,
          $$PrintQueueAuditsTableFilterComposer,
          $$PrintQueueAuditsTableOrderingComposer,
          $$PrintQueueAuditsTableAnnotationComposer,
          $$PrintQueueAuditsTableCreateCompanionBuilder,
          $$PrintQueueAuditsTableUpdateCompanionBuilder,
          (
            PrintQueueAudit,
            BaseReferences<
              _$AppDatabase,
              $PrintQueueAuditsTable,
              PrintQueueAudit
            >,
          ),
          PrintQueueAudit,
          PrefetchHooks Function()
        > {
  $$PrintQueueAuditsTableTableManager(
    _$AppDatabase db,
    $PrintQueueAuditsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PrintQueueAuditsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PrintQueueAuditsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PrintQueueAuditsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> jobId = const Value.absent(),
                Value<String> saleId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> actorId = const Value.absent(),
                Value<String> actorEmail = const Value.absent(),
                Value<bool> copy = const Value.absent(),
                Value<String> detail = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PrintQueueAuditsCompanion(
                id: id,
                jobId: jobId,
                saleId: saleId,
                action: action,
                actorId: actorId,
                actorEmail: actorEmail,
                copy: copy,
                detail: detail,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String jobId,
                required String saleId,
                required String action,
                required String actorId,
                required String actorEmail,
                Value<bool> copy = const Value.absent(),
                Value<String> detail = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PrintQueueAuditsCompanion.insert(
                id: id,
                jobId: jobId,
                saleId: saleId,
                action: action,
                actorId: actorId,
                actorEmail: actorEmail,
                copy: copy,
                detail: detail,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PrintQueueAuditsTable, PrintQueueAudit>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PrintQueueAuditsTable,
                    PrintQueueAudit
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PrintQueueAuditsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PrintQueueAuditsTable,
      PrintQueueAudit,
      $$PrintQueueAuditsTableFilterComposer,
      $$PrintQueueAuditsTableOrderingComposer,
      $$PrintQueueAuditsTableAnnotationComposer,
      $$PrintQueueAuditsTableCreateCompanionBuilder,
      $$PrintQueueAuditsTableUpdateCompanionBuilder,
      (
        PrintQueueAudit,
        BaseReferences<_$AppDatabase, $PrintQueueAuditsTable, PrintQueueAudit>,
      ),
      PrintQueueAudit,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RecoveryJobsTableTableManager get recoveryJobs =>
      $$RecoveryJobsTableTableManager(_db, _db.recoveryJobs);
  $$CartEntriesTableTableManager get cartEntries =>
      $$CartEntriesTableTableManager(_db, _db.cartEntries);
  $$CheckoutIntentsTableTableManager get checkoutIntents =>
      $$CheckoutIntentsTableTableManager(_db, _db.checkoutIntents);
  $$PrintQueueJobsTableTableManager get printQueueJobs =>
      $$PrintQueueJobsTableTableManager(_db, _db.printQueueJobs);
  $$PrintQueueAuditsTableTableManager get printQueueAudits =>
      $$PrintQueueAuditsTableTableManager(_db, _db.printQueueAudits);
}
