// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'background_task_run.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBackgroundTaskRunCollection on Isar {
  IsarCollection<BackgroundTaskRun> get backgroundTaskRuns => this.collection();
}

const BackgroundTaskRunSchema = CollectionSchema(
  name: r'BackgroundTaskRun',
  id: 5803123738571118805,
  properties: {
    r'backupError': PropertySchema(
      id: 0,
      name: r'backupError',
      type: IsarType.string,
    ),
    r'backupStatus': PropertySchema(
      id: 1,
      name: r'backupStatus',
      type: IsarType.string,
    ),
    r'busySourceKeys': PropertySchema(
      id: 2,
      name: r'busySourceKeys',
      type: IsarType.stringList,
    ),
    r'failedOccurrences': PropertySchema(
      id: 3,
      name: r'failedOccurrences',
      type: IsarType.long,
    ),
    r'finishedAt': PropertySchema(
      id: 4,
      name: r'finishedAt',
      type: IsarType.dateTime,
    ),
    r'heartbeatAt': PropertySchema(
      id: 5,
      name: r'heartbeatAt',
      type: IsarType.dateTime,
    ),
    r'log': PropertySchema(id: 6, name: r'log', type: IsarType.stringList),
    r'maturedCount': PropertySchema(
      id: 7,
      name: r'maturedCount',
      type: IsarType.long,
    ),
    r'ownerPid': PropertySchema(id: 8, name: r'ownerPid', type: IsarType.long),
    r'postedEmis': PropertySchema(
      id: 9,
      name: r'postedEmis',
      type: IsarType.long,
    ),
    r'postedRecurring': PropertySchema(
      id: 10,
      name: r'postedRecurring',
      type: IsarType.long,
    ),
    r'postedSips': PropertySchema(
      id: 11,
      name: r'postedSips',
      type: IsarType.long,
    ),
    r'resultShown': PropertySchema(
      id: 12,
      name: r'resultShown',
      type: IsarType.bool,
    ),
    r'runId': PropertySchema(id: 13, name: r'runId', type: IsarType.string),
    r'snackbarDismissed': PropertySchema(
      id: 14,
      name: r'snackbarDismissed',
      type: IsarType.bool,
    ),
    r'startedAt': PropertySchema(
      id: 15,
      name: r'startedAt',
      type: IsarType.dateTime,
    ),
    r'status': PropertySchema(id: 16, name: r'status', type: IsarType.string),
    r'step': PropertySchema(id: 17, name: r'step', type: IsarType.string),
    r'stepDone': PropertySchema(id: 18, name: r'stepDone', type: IsarType.long),
    r'stepTotal': PropertySchema(
      id: 19,
      name: r'stepTotal',
      type: IsarType.long,
    ),
    r'trigger': PropertySchema(id: 20, name: r'trigger', type: IsarType.string),
  },

  estimateSize: _backgroundTaskRunEstimateSize,
  serialize: _backgroundTaskRunSerialize,
  deserialize: _backgroundTaskRunDeserialize,
  deserializeProp: _backgroundTaskRunDeserializeProp,
  idName: r'id',
  indexes: {
    r'runId': IndexSchema(
      id: -933908091583610493,
      name: r'runId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'runId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'startedAt': IndexSchema(
      id: 8114395319341636597,
      name: r'startedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'startedAt',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'status': IndexSchema(
      id: -107785170620420283,
      name: r'status',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'status',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _backgroundTaskRunGetId,
  getLinks: _backgroundTaskRunGetLinks,
  attach: _backgroundTaskRunAttach,
  version: '3.3.2',
);

int _backgroundTaskRunEstimateSize(
  BackgroundTaskRun object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.backupError;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.backupStatus.length * 3;
  bytesCount += 3 + object.busySourceKeys.length * 3;
  {
    for (var i = 0; i < object.busySourceKeys.length; i++) {
      final value = object.busySourceKeys[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.log.length * 3;
  {
    for (var i = 0; i < object.log.length; i++) {
      final value = object.log[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.runId.length * 3;
  bytesCount += 3 + object.status.length * 3;
  bytesCount += 3 + object.step.length * 3;
  bytesCount += 3 + object.trigger.length * 3;
  return bytesCount;
}

void _backgroundTaskRunSerialize(
  BackgroundTaskRun object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.backupError);
  writer.writeString(offsets[1], object.backupStatus);
  writer.writeStringList(offsets[2], object.busySourceKeys);
  writer.writeLong(offsets[3], object.failedOccurrences);
  writer.writeDateTime(offsets[4], object.finishedAt);
  writer.writeDateTime(offsets[5], object.heartbeatAt);
  writer.writeStringList(offsets[6], object.log);
  writer.writeLong(offsets[7], object.maturedCount);
  writer.writeLong(offsets[8], object.ownerPid);
  writer.writeLong(offsets[9], object.postedEmis);
  writer.writeLong(offsets[10], object.postedRecurring);
  writer.writeLong(offsets[11], object.postedSips);
  writer.writeBool(offsets[12], object.resultShown);
  writer.writeString(offsets[13], object.runId);
  writer.writeBool(offsets[14], object.snackbarDismissed);
  writer.writeDateTime(offsets[15], object.startedAt);
  writer.writeString(offsets[16], object.status);
  writer.writeString(offsets[17], object.step);
  writer.writeLong(offsets[18], object.stepDone);
  writer.writeLong(offsets[19], object.stepTotal);
  writer.writeString(offsets[20], object.trigger);
}

BackgroundTaskRun _backgroundTaskRunDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BackgroundTaskRun();
  object.backupError = reader.readStringOrNull(offsets[0]);
  object.backupStatus = reader.readString(offsets[1]);
  object.busySourceKeys = reader.readStringList(offsets[2]) ?? [];
  object.failedOccurrences = reader.readLong(offsets[3]);
  object.finishedAt = reader.readDateTimeOrNull(offsets[4]);
  object.heartbeatAt = reader.readDateTime(offsets[5]);
  object.id = id;
  object.log = reader.readStringList(offsets[6]) ?? [];
  object.maturedCount = reader.readLong(offsets[7]);
  object.ownerPid = reader.readLong(offsets[8]);
  object.postedEmis = reader.readLong(offsets[9]);
  object.postedRecurring = reader.readLong(offsets[10]);
  object.postedSips = reader.readLong(offsets[11]);
  object.resultShown = reader.readBool(offsets[12]);
  object.runId = reader.readString(offsets[13]);
  object.snackbarDismissed = reader.readBool(offsets[14]);
  object.startedAt = reader.readDateTime(offsets[15]);
  object.status = reader.readString(offsets[16]);
  object.step = reader.readString(offsets[17]);
  object.stepDone = reader.readLong(offsets[18]);
  object.stepTotal = reader.readLong(offsets[19]);
  object.trigger = reader.readString(offsets[20]);
  return object;
}

P _backgroundTaskRunDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readStringList(offset) ?? []) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readStringList(offset) ?? []) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (reader.readBool(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readBool(offset)) as P;
    case 15:
      return (reader.readDateTime(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    case 17:
      return (reader.readString(offset)) as P;
    case 18:
      return (reader.readLong(offset)) as P;
    case 19:
      return (reader.readLong(offset)) as P;
    case 20:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _backgroundTaskRunGetId(BackgroundTaskRun object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _backgroundTaskRunGetLinks(
  BackgroundTaskRun object,
) {
  return [];
}

void _backgroundTaskRunAttach(
  IsarCollection<dynamic> col,
  Id id,
  BackgroundTaskRun object,
) {
  object.id = id;
}

extension BackgroundTaskRunByIndex on IsarCollection<BackgroundTaskRun> {
  Future<BackgroundTaskRun?> getByRunId(String runId) {
    return getByIndex(r'runId', [runId]);
  }

  BackgroundTaskRun? getByRunIdSync(String runId) {
    return getByIndexSync(r'runId', [runId]);
  }

  Future<bool> deleteByRunId(String runId) {
    return deleteByIndex(r'runId', [runId]);
  }

  bool deleteByRunIdSync(String runId) {
    return deleteByIndexSync(r'runId', [runId]);
  }

  Future<List<BackgroundTaskRun?>> getAllByRunId(List<String> runIdValues) {
    final values = runIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'runId', values);
  }

  List<BackgroundTaskRun?> getAllByRunIdSync(List<String> runIdValues) {
    final values = runIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'runId', values);
  }

  Future<int> deleteAllByRunId(List<String> runIdValues) {
    final values = runIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'runId', values);
  }

  int deleteAllByRunIdSync(List<String> runIdValues) {
    final values = runIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'runId', values);
  }

  Future<Id> putByRunId(BackgroundTaskRun object) {
    return putByIndex(r'runId', object);
  }

  Id putByRunIdSync(BackgroundTaskRun object, {bool saveLinks = true}) {
    return putByIndexSync(r'runId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByRunId(List<BackgroundTaskRun> objects) {
    return putAllByIndex(r'runId', objects);
  }

  List<Id> putAllByRunIdSync(
    List<BackgroundTaskRun> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'runId', objects, saveLinks: saveLinks);
  }
}

extension BackgroundTaskRunQueryWhereSort
    on QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QWhere> {
  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterWhere>
  anyStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'startedAt'),
      );
    });
  }
}

extension BackgroundTaskRunQueryWhere
    on QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QWhereClause> {
  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterWhereClause>
  idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterWhereClause>
  idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterWhereClause>
  runIdEqualTo(String runId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'runId', value: [runId]),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterWhereClause>
  runIdNotEqualTo(String runId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'runId',
                lower: [],
                upper: [runId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'runId',
                lower: [runId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'runId',
                lower: [runId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'runId',
                lower: [],
                upper: [runId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterWhereClause>
  startedAtEqualTo(DateTime startedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'startedAt', value: [startedAt]),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterWhereClause>
  startedAtNotEqualTo(DateTime startedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'startedAt',
                lower: [],
                upper: [startedAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'startedAt',
                lower: [startedAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'startedAt',
                lower: [startedAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'startedAt',
                lower: [],
                upper: [startedAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterWhereClause>
  startedAtGreaterThan(DateTime startedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'startedAt',
          lower: [startedAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterWhereClause>
  startedAtLessThan(DateTime startedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'startedAt',
          lower: [],
          upper: [startedAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterWhereClause>
  startedAtBetween(
    DateTime lowerStartedAt,
    DateTime upperStartedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'startedAt',
          lower: [lowerStartedAt],
          includeLower: includeLower,
          upper: [upperStartedAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterWhereClause>
  statusEqualTo(String status) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'status', value: [status]),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterWhereClause>
  statusNotEqualTo(String status) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'status',
                lower: [],
                upper: [status],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'status',
                lower: [status],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'status',
                lower: [status],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'status',
                lower: [],
                upper: [status],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension BackgroundTaskRunQueryFilter
    on QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QFilterCondition> {
  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  backupErrorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'backupError'),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  backupErrorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'backupError'),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  backupErrorEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'backupError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  backupErrorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'backupError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  backupErrorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'backupError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  backupErrorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'backupError',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  backupErrorStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'backupError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  backupErrorEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'backupError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  backupErrorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'backupError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  backupErrorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'backupError',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  backupErrorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'backupError', value: ''),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  backupErrorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'backupError', value: ''),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  backupStatusEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'backupStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  backupStatusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'backupStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  backupStatusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'backupStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  backupStatusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'backupStatus',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  backupStatusStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'backupStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  backupStatusEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'backupStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  backupStatusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'backupStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  backupStatusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'backupStatus',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  backupStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'backupStatus', value: ''),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  backupStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'backupStatus', value: ''),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  busySourceKeysElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'busySourceKeys',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  busySourceKeysElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'busySourceKeys',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  busySourceKeysElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'busySourceKeys',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  busySourceKeysElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'busySourceKeys',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  busySourceKeysElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'busySourceKeys',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  busySourceKeysElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'busySourceKeys',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  busySourceKeysElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'busySourceKeys',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  busySourceKeysElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'busySourceKeys',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  busySourceKeysElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'busySourceKeys', value: ''),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  busySourceKeysElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'busySourceKeys', value: ''),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  busySourceKeysLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'busySourceKeys', length, true, length, true);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  busySourceKeysIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'busySourceKeys', 0, true, 0, true);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  busySourceKeysIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'busySourceKeys', 0, false, 999999, true);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  busySourceKeysLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'busySourceKeys', 0, true, length, include);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  busySourceKeysLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'busySourceKeys', length, include, 999999, true);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  busySourceKeysLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'busySourceKeys',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  failedOccurrencesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'failedOccurrences', value: value),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  failedOccurrencesGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'failedOccurrences',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  failedOccurrencesLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'failedOccurrences',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  failedOccurrencesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'failedOccurrences',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  finishedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'finishedAt'),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  finishedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'finishedAt'),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  finishedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'finishedAt', value: value),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  finishedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'finishedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  finishedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'finishedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  finishedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'finishedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  heartbeatAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'heartbeatAt', value: value),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  heartbeatAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'heartbeatAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  heartbeatAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'heartbeatAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  heartbeatAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'heartbeatAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  logElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'log',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  logElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'log',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  logElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'log',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  logElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'log',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  logElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'log',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  logElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'log',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  logElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'log',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  logElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'log',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  logElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'log', value: ''),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  logElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'log', value: ''),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  logLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'log', length, true, length, true);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  logIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'log', 0, true, 0, true);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  logIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'log', 0, false, 999999, true);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  logLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'log', 0, true, length, include);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  logLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'log', length, include, 999999, true);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  logLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'log', lower, includeLower, upper, includeUpper);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  maturedCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'maturedCount', value: value),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  maturedCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'maturedCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  maturedCountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'maturedCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  maturedCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'maturedCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  ownerPidEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'ownerPid', value: value),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  ownerPidGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'ownerPid',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  ownerPidLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'ownerPid',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  ownerPidBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'ownerPid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  postedEmisEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'postedEmis', value: value),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  postedEmisGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'postedEmis',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  postedEmisLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'postedEmis',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  postedEmisBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'postedEmis',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  postedRecurringEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'postedRecurring', value: value),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  postedRecurringGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'postedRecurring',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  postedRecurringLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'postedRecurring',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  postedRecurringBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'postedRecurring',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  postedSipsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'postedSips', value: value),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  postedSipsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'postedSips',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  postedSipsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'postedSips',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  postedSipsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'postedSips',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  resultShownEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'resultShown', value: value),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  runIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'runId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  runIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'runId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  runIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'runId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  runIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'runId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  runIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'runId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  runIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'runId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  runIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'runId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  runIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'runId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  runIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'runId', value: ''),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  runIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'runId', value: ''),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  snackbarDismissedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'snackbarDismissed', value: value),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  startedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'startedAt', value: value),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  startedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'startedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  startedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'startedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  startedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'startedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  statusEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  statusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  statusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  statusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'status',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  statusStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  statusEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'status',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  stepEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'step',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  stepGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'step',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  stepLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'step',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  stepBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'step',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  stepStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'step',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  stepEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'step',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  stepContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'step',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  stepMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'step',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  stepIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'step', value: ''),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  stepIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'step', value: ''),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  stepDoneEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'stepDone', value: value),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  stepDoneGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'stepDone',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  stepDoneLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'stepDone',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  stepDoneBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'stepDone',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  stepTotalEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'stepTotal', value: value),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  stepTotalGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'stepTotal',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  stepTotalLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'stepTotal',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  stepTotalBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'stepTotal',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  triggerEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'trigger',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  triggerGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'trigger',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  triggerLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'trigger',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  triggerBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'trigger',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  triggerStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'trigger',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  triggerEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'trigger',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  triggerContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'trigger',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  triggerMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'trigger',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  triggerIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'trigger', value: ''),
      );
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterFilterCondition>
  triggerIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'trigger', value: ''),
      );
    });
  }
}

extension BackgroundTaskRunQueryObject
    on QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QFilterCondition> {}

extension BackgroundTaskRunQueryLinks
    on QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QFilterCondition> {}

extension BackgroundTaskRunQuerySortBy
    on QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QSortBy> {
  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  sortByBackupError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backupError', Sort.asc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  sortByBackupErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backupError', Sort.desc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  sortByBackupStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backupStatus', Sort.asc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  sortByBackupStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backupStatus', Sort.desc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  sortByFailedOccurrences() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failedOccurrences', Sort.asc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  sortByFailedOccurrencesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failedOccurrences', Sort.desc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  sortByFinishedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finishedAt', Sort.asc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  sortByFinishedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finishedAt', Sort.desc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  sortByHeartbeatAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heartbeatAt', Sort.asc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  sortByHeartbeatAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heartbeatAt', Sort.desc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  sortByMaturedCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maturedCount', Sort.asc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  sortByMaturedCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maturedCount', Sort.desc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  sortByOwnerPid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerPid', Sort.asc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  sortByOwnerPidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerPid', Sort.desc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  sortByPostedEmis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'postedEmis', Sort.asc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  sortByPostedEmisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'postedEmis', Sort.desc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  sortByPostedRecurring() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'postedRecurring', Sort.asc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  sortByPostedRecurringDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'postedRecurring', Sort.desc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  sortByPostedSips() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'postedSips', Sort.asc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  sortByPostedSipsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'postedSips', Sort.desc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  sortByResultShown() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resultShown', Sort.asc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  sortByResultShownDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resultShown', Sort.desc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  sortByRunId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'runId', Sort.asc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  sortByRunIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'runId', Sort.desc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  sortBySnackbarDismissed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snackbarDismissed', Sort.asc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  sortBySnackbarDismissedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snackbarDismissed', Sort.desc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  sortByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  sortByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  sortByStep() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'step', Sort.asc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  sortByStepDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'step', Sort.desc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  sortByStepDone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stepDone', Sort.asc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  sortByStepDoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stepDone', Sort.desc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  sortByStepTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stepTotal', Sort.asc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  sortByStepTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stepTotal', Sort.desc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  sortByTrigger() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trigger', Sort.asc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  sortByTriggerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trigger', Sort.desc);
    });
  }
}

extension BackgroundTaskRunQuerySortThenBy
    on QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QSortThenBy> {
  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  thenByBackupError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backupError', Sort.asc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  thenByBackupErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backupError', Sort.desc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  thenByBackupStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backupStatus', Sort.asc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  thenByBackupStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backupStatus', Sort.desc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  thenByFailedOccurrences() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failedOccurrences', Sort.asc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  thenByFailedOccurrencesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failedOccurrences', Sort.desc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  thenByFinishedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finishedAt', Sort.asc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  thenByFinishedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finishedAt', Sort.desc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  thenByHeartbeatAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heartbeatAt', Sort.asc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  thenByHeartbeatAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heartbeatAt', Sort.desc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  thenByMaturedCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maturedCount', Sort.asc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  thenByMaturedCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maturedCount', Sort.desc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  thenByOwnerPid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerPid', Sort.asc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  thenByOwnerPidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerPid', Sort.desc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  thenByPostedEmis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'postedEmis', Sort.asc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  thenByPostedEmisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'postedEmis', Sort.desc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  thenByPostedRecurring() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'postedRecurring', Sort.asc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  thenByPostedRecurringDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'postedRecurring', Sort.desc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  thenByPostedSips() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'postedSips', Sort.asc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  thenByPostedSipsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'postedSips', Sort.desc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  thenByResultShown() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resultShown', Sort.asc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  thenByResultShownDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resultShown', Sort.desc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  thenByRunId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'runId', Sort.asc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  thenByRunIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'runId', Sort.desc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  thenBySnackbarDismissed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snackbarDismissed', Sort.asc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  thenBySnackbarDismissedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snackbarDismissed', Sort.desc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  thenByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  thenByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  thenByStep() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'step', Sort.asc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  thenByStepDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'step', Sort.desc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  thenByStepDone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stepDone', Sort.asc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  thenByStepDoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stepDone', Sort.desc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  thenByStepTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stepTotal', Sort.asc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  thenByStepTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stepTotal', Sort.desc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  thenByTrigger() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trigger', Sort.asc);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QAfterSortBy>
  thenByTriggerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trigger', Sort.desc);
    });
  }
}

extension BackgroundTaskRunQueryWhereDistinct
    on QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QDistinct> {
  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QDistinct>
  distinctByBackupError({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'backupError', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QDistinct>
  distinctByBackupStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'backupStatus', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QDistinct>
  distinctByBusySourceKeys() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'busySourceKeys');
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QDistinct>
  distinctByFailedOccurrences() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'failedOccurrences');
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QDistinct>
  distinctByFinishedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'finishedAt');
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QDistinct>
  distinctByHeartbeatAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'heartbeatAt');
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QDistinct>
  distinctByLog() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'log');
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QDistinct>
  distinctByMaturedCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maturedCount');
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QDistinct>
  distinctByOwnerPid() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ownerPid');
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QDistinct>
  distinctByPostedEmis() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'postedEmis');
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QDistinct>
  distinctByPostedRecurring() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'postedRecurring');
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QDistinct>
  distinctByPostedSips() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'postedSips');
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QDistinct>
  distinctByResultShown() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'resultShown');
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QDistinct>
  distinctByRunId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'runId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QDistinct>
  distinctBySnackbarDismissed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'snackbarDismissed');
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QDistinct>
  distinctByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startedAt');
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QDistinct>
  distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QDistinct> distinctByStep({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'step', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QDistinct>
  distinctByStepDone() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stepDone');
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QDistinct>
  distinctByStepTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stepTotal');
    });
  }

  QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QDistinct>
  distinctByTrigger({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trigger', caseSensitive: caseSensitive);
    });
  }
}

extension BackgroundTaskRunQueryProperty
    on QueryBuilder<BackgroundTaskRun, BackgroundTaskRun, QQueryProperty> {
  QueryBuilder<BackgroundTaskRun, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BackgroundTaskRun, String?, QQueryOperations>
  backupErrorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'backupError');
    });
  }

  QueryBuilder<BackgroundTaskRun, String, QQueryOperations>
  backupStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'backupStatus');
    });
  }

  QueryBuilder<BackgroundTaskRun, List<String>, QQueryOperations>
  busySourceKeysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'busySourceKeys');
    });
  }

  QueryBuilder<BackgroundTaskRun, int, QQueryOperations>
  failedOccurrencesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'failedOccurrences');
    });
  }

  QueryBuilder<BackgroundTaskRun, DateTime?, QQueryOperations>
  finishedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'finishedAt');
    });
  }

  QueryBuilder<BackgroundTaskRun, DateTime, QQueryOperations>
  heartbeatAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'heartbeatAt');
    });
  }

  QueryBuilder<BackgroundTaskRun, List<String>, QQueryOperations>
  logProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'log');
    });
  }

  QueryBuilder<BackgroundTaskRun, int, QQueryOperations>
  maturedCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maturedCount');
    });
  }

  QueryBuilder<BackgroundTaskRun, int, QQueryOperations> ownerPidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ownerPid');
    });
  }

  QueryBuilder<BackgroundTaskRun, int, QQueryOperations> postedEmisProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'postedEmis');
    });
  }

  QueryBuilder<BackgroundTaskRun, int, QQueryOperations>
  postedRecurringProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'postedRecurring');
    });
  }

  QueryBuilder<BackgroundTaskRun, int, QQueryOperations> postedSipsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'postedSips');
    });
  }

  QueryBuilder<BackgroundTaskRun, bool, QQueryOperations>
  resultShownProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'resultShown');
    });
  }

  QueryBuilder<BackgroundTaskRun, String, QQueryOperations> runIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'runId');
    });
  }

  QueryBuilder<BackgroundTaskRun, bool, QQueryOperations>
  snackbarDismissedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'snackbarDismissed');
    });
  }

  QueryBuilder<BackgroundTaskRun, DateTime, QQueryOperations>
  startedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startedAt');
    });
  }

  QueryBuilder<BackgroundTaskRun, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<BackgroundTaskRun, String, QQueryOperations> stepProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'step');
    });
  }

  QueryBuilder<BackgroundTaskRun, int, QQueryOperations> stepDoneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stepDone');
    });
  }

  QueryBuilder<BackgroundTaskRun, int, QQueryOperations> stepTotalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stepTotal');
    });
  }

  QueryBuilder<BackgroundTaskRun, String, QQueryOperations> triggerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trigger');
    });
  }
}
