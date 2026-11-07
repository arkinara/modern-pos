import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Small durable recovery queue for print jobs and in-flight references.
/// Offline sale reconciliation remains out of scope until Phase 2.
class RecoveryJobs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get reference => text().unique()();
  TextColumn get payload => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [RecoveryJobs])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, 'modern_pos.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
