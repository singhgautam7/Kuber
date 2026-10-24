// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'processed_occurrence.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetProcessedOccurrenceCollection on Isar {
  IsarCollection<ProcessedOccurrence> get processedOccurrences =>
      this.collection();
}

const ProcessedOccurrenceSchema = CollectionSchema(
  name: r'ProcessedOccurrence',
  id: -8961790304712908225,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'key': PropertySchema(id: 1, name: r'key', type: IsarType.string),
    r'occurrenceDate': PropertySchema(
      id: 2,
      name: r'occurrenceDate',
      type: IsarType.long,
    ),
    r'runId': PropertySchema(id: 3, name: r'runId', type: IsarType.string),
    r'sourceId': PropertySchema(
      id: 4,
      name: r'sourceId',
      type: IsarType.string,
    ),
    r'sourceType': PropertySchema(
      id: 5,
      name: r'sourceType',
      type: IsarType.string,
    ),
    r'status': PropertySchema(id: 6, name: r'status', type: IsarType.string),
    r'transactionId': PropertySchema(
      id: 7,
      name: r'transactionId',
      type: IsarType.long,
    ),
  },

  estimateSize: _processedOccurrenceEstimateSize,
  serialize: _processedOccurrenceSerialize,
  deserialize: _processedOccurrenceDeserialize,
  deserializeProp: _processedOccurrenceDeserializeProp,
  idName: r'id',
  indexes: {
    r'key': IndexSchema(
      id: -4906094122524121629,
      name: r'key',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'key',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'sourceType_sourceId': IndexSchema(
      id: 347912564415106540,
      name: r'sourceType_sourceId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'sourceType',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'sourceId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _processedOccurrenceGetId,
  getLinks: _processedOccurrenceGetLinks,
  attach: _processedOccurrenceAttach,
  version: '3.3.2',
);

int _processedOccurrenceEstimateSize(
  ProcessedOccurrence object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.key.length * 3;
  {
    final value = object.runId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.sourceId.length * 3;
  bytesCount += 3 + object.sourceType.length * 3;
  bytesCount += 3 + object.status.length * 3;
  return bytesCount;
}

void _processedOccurrenceSerialize(
  ProcessedOccurrence object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeString(offsets[1], object.key);
  writer.writeLong(offsets[2], object.occurrenceDate);
  writer.writeString(offsets[3], object.runId);
  writer.writeString(offsets[4], object.sourceId);
  writer.writeString(offsets[5], object.sourceType);
  writer.writeString(offsets[6], object.status);
  writer.writeLong(offsets[7], object.transactionId);
}

ProcessedOccurrence _processedOccurrenceDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ProcessedOccurrence();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.id = id;
  object.key = reader.readString(offsets[1]);
  object.occurrenceDate = reader.readLong(offsets[2]);
  object.runId = reader.readStringOrNull(offsets[3]);
  object.sourceId = reader.readString(offsets[4]);
  object.sourceType = reader.readString(offsets[5]);
  object.status = reader.readString(offsets[6]);
  object.transactionId = reader.readLongOrNull(offsets[7]);
  return object;
}

P _processedOccurrenceDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _processedOccurrenceGetId(ProcessedOccurrence object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _processedOccurrenceGetLinks(
  ProcessedOccurrence object,
) {
  return [];
}

void _processedOccurrenceAttach(
  IsarCollection<dynamic> col,
  Id id,
  ProcessedOccurrence object,
) {
  object.id = id;
}

extension ProcessedOccurrenceByIndex on IsarCollection<ProcessedOccurrence> {
  Future<ProcessedOccurrence?> getByKey(String key) {
    return getByIndex(r'key', [key]);
  }

  ProcessedOccurrence? getByKeySync(String key) {
    return getByIndexSync(r'key', [key]);
  }

  Future<bool> deleteByKey(String key) {
    return deleteByIndex(r'key', [key]);
  }

  bool deleteByKeySync(String key) {
    return deleteByIndexSync(r'key', [key]);
  }

  Future<List<ProcessedOccurrence?>> getAllByKey(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return getAllByIndex(r'key', values);
  }

  List<ProcessedOccurrence?> getAllByKeySync(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'key', values);
  }

  Future<int> deleteAllByKey(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'key', values);
  }

  int deleteAllByKeySync(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'key', values);
  }

  Future<Id> putByKey(ProcessedOccurrence object) {
    return putByIndex(r'key', object);
  }

  Id putByKeySync(ProcessedOccurrence object, {bool saveLinks = true}) {
    return putByIndexSync(r'key', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByKey(List<ProcessedOccurrence> objects) {
    return putAllByIndex(r'key', objects);
  }

  List<Id> putAllByKeySync(
    List<ProcessedOccurrence> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'key', objects, saveLinks: saveLinks);
  }
}

extension ProcessedOccurrenceQueryWhereSort
    on QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QWhere> {
  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ProcessedOccurrenceQueryWhere
    on QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QWhereClause> {
  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterWhereClause>
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

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterWhereClause>
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

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterWhereClause>
  keyEqualTo(String key) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'key', value: [key]),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterWhereClause>
  keyNotEqualTo(String key) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'key',
                lower: [],
                upper: [key],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'key',
                lower: [key],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'key',
                lower: [key],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'key',
                lower: [],
                upper: [key],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterWhereClause>
  sourceTypeEqualToAnySourceId(String sourceType) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'sourceType_sourceId',
          value: [sourceType],
        ),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterWhereClause>
  sourceTypeNotEqualToAnySourceId(String sourceType) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'sourceType_sourceId',
                lower: [],
                upper: [sourceType],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'sourceType_sourceId',
                lower: [sourceType],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'sourceType_sourceId',
                lower: [sourceType],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'sourceType_sourceId',
                lower: [],
                upper: [sourceType],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterWhereClause>
  sourceTypeSourceIdEqualTo(String sourceType, String sourceId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'sourceType_sourceId',
          value: [sourceType, sourceId],
        ),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterWhereClause>
  sourceTypeEqualToSourceIdNotEqualTo(String sourceType, String sourceId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'sourceType_sourceId',
                lower: [sourceType],
                upper: [sourceType, sourceId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'sourceType_sourceId',
                lower: [sourceType, sourceId],
                includeLower: false,
                upper: [sourceType],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'sourceType_sourceId',
                lower: [sourceType, sourceId],
                includeLower: false,
                upper: [sourceType],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'sourceType_sourceId',
                lower: [sourceType],
                upper: [sourceType, sourceId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension ProcessedOccurrenceQueryFilter
    on
        QueryBuilder<
          ProcessedOccurrence,
          ProcessedOccurrence,
          QFilterCondition
        > {
  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  createdAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  createdAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
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

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
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

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
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

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  keyEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  keyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  keyLessThan(String value, {bool include = false, bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  keyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'key',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  keyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  keyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  keyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  keyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'key',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  keyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'key', value: ''),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  keyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'key', value: ''),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  occurrenceDateEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'occurrenceDate', value: value),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  occurrenceDateGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'occurrenceDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  occurrenceDateLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'occurrenceDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  occurrenceDateBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'occurrenceDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  runIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'runId'),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  runIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'runId'),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  runIdEqualTo(String? value, {bool caseSensitive = true}) {
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

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  runIdGreaterThan(
    String? value, {
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

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  runIdLessThan(
    String? value, {
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

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  runIdBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
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

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
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

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
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

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
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

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  runIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'runId', value: ''),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  runIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'runId', value: ''),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  sourceIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'sourceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  sourceIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sourceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  sourceIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sourceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  sourceIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sourceId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  sourceIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'sourceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  sourceIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'sourceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  sourceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'sourceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  sourceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'sourceId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  sourceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sourceId', value: ''),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  sourceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'sourceId', value: ''),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  sourceTypeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'sourceType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  sourceTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sourceType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  sourceTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sourceType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  sourceTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sourceType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  sourceTypeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'sourceType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  sourceTypeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'sourceType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  sourceTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'sourceType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  sourceTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'sourceType',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  sourceTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sourceType', value: ''),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  sourceTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'sourceType', value: ''),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
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

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
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

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
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

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
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

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
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

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
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

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
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

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
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

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  transactionIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'transactionId'),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  transactionIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'transactionId'),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  transactionIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'transactionId', value: value),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  transactionIdGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'transactionId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  transactionIdLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'transactionId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterFilterCondition>
  transactionIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'transactionId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension ProcessedOccurrenceQueryObject
    on
        QueryBuilder<
          ProcessedOccurrence,
          ProcessedOccurrence,
          QFilterCondition
        > {}

extension ProcessedOccurrenceQueryLinks
    on
        QueryBuilder<
          ProcessedOccurrence,
          ProcessedOccurrence,
          QFilterCondition
        > {}

extension ProcessedOccurrenceQuerySortBy
    on QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QSortBy> {
  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterSortBy>
  sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterSortBy>
  sortByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterSortBy>
  sortByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterSortBy>
  sortByOccurrenceDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occurrenceDate', Sort.asc);
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterSortBy>
  sortByOccurrenceDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occurrenceDate', Sort.desc);
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterSortBy>
  sortByRunId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'runId', Sort.asc);
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterSortBy>
  sortByRunIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'runId', Sort.desc);
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterSortBy>
  sortBySourceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceId', Sort.asc);
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterSortBy>
  sortBySourceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceId', Sort.desc);
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterSortBy>
  sortBySourceType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceType', Sort.asc);
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterSortBy>
  sortBySourceTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceType', Sort.desc);
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterSortBy>
  sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterSortBy>
  sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterSortBy>
  sortByTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionId', Sort.asc);
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterSortBy>
  sortByTransactionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionId', Sort.desc);
    });
  }
}

extension ProcessedOccurrenceQuerySortThenBy
    on QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QSortThenBy> {
  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterSortBy>
  thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterSortBy>
  thenByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterSortBy>
  thenByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterSortBy>
  thenByOccurrenceDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occurrenceDate', Sort.asc);
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterSortBy>
  thenByOccurrenceDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occurrenceDate', Sort.desc);
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterSortBy>
  thenByRunId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'runId', Sort.asc);
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterSortBy>
  thenByRunIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'runId', Sort.desc);
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterSortBy>
  thenBySourceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceId', Sort.asc);
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterSortBy>
  thenBySourceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceId', Sort.desc);
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterSortBy>
  thenBySourceType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceType', Sort.asc);
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterSortBy>
  thenBySourceTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceType', Sort.desc);
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterSortBy>
  thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterSortBy>
  thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterSortBy>
  thenByTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionId', Sort.asc);
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QAfterSortBy>
  thenByTransactionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionId', Sort.desc);
    });
  }
}

extension ProcessedOccurrenceQueryWhereDistinct
    on QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QDistinct> {
  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QDistinct>
  distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QDistinct>
  distinctByKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'key', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QDistinct>
  distinctByOccurrenceDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'occurrenceDate');
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QDistinct>
  distinctByRunId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'runId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QDistinct>
  distinctBySourceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QDistinct>
  distinctBySourceType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QDistinct>
  distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QDistinct>
  distinctByTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'transactionId');
    });
  }
}

extension ProcessedOccurrenceQueryProperty
    on QueryBuilder<ProcessedOccurrence, ProcessedOccurrence, QQueryProperty> {
  QueryBuilder<ProcessedOccurrence, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ProcessedOccurrence, DateTime, QQueryOperations>
  createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<ProcessedOccurrence, String, QQueryOperations> keyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'key');
    });
  }

  QueryBuilder<ProcessedOccurrence, int, QQueryOperations>
  occurrenceDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'occurrenceDate');
    });
  }

  QueryBuilder<ProcessedOccurrence, String?, QQueryOperations> runIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'runId');
    });
  }

  QueryBuilder<ProcessedOccurrence, String, QQueryOperations>
  sourceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceId');
    });
  }

  QueryBuilder<ProcessedOccurrence, String, QQueryOperations>
  sourceTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceType');
    });
  }

  QueryBuilder<ProcessedOccurrence, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<ProcessedOccurrence, int?, QQueryOperations>
  transactionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'transactionId');
    });
  }
}
