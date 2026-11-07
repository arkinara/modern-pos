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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RecoveryJobsTable recoveryJobs = $RecoveryJobsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [recoveryJobs];
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RecoveryJobsTableTableManager get recoveryJobs =>
      $$RecoveryJobsTableTableManager(_db, _db.recoveryJobs);
}
