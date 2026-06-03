// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insight_story.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetInsightStoryCollection on Isar {
  IsarCollection<InsightStory> get insightStorys => this.collection();
}

const InsightStorySchema = CollectionSchema(
  name: r'InsightStory',
  id: -2195786010203318811,
  properties: {
    r'contentHash': PropertySchema(
      id: 0,
      name: r'contentHash',
      type: IsarType.string,
    ),
    r'expiresAt': PropertySchema(
      id: 1,
      name: r'expiresAt',
      type: IsarType.dateTime,
    ),
    r'generatedAt': PropertySchema(
      id: 2,
      name: r'generatedAt',
      type: IsarType.dateTime,
    ),
    r'payloadJson': PropertySchema(
      id: 3,
      name: r'payloadJson',
      type: IsarType.string,
    ),
    r'periodEnd': PropertySchema(
      id: 4,
      name: r'periodEnd',
      type: IsarType.dateTime,
    ),
    r'periodStart': PropertySchema(
      id: 5,
      name: r'periodStart',
      type: IsarType.dateTime,
    ),
    r'seenAt': PropertySchema(id: 6, name: r'seenAt', type: IsarType.dateTime),
    r'seenSlides': PropertySchema(
      id: 7,
      name: r'seenSlides',
      type: IsarType.longList,
    ),
    r'storyKey': PropertySchema(
      id: 8,
      name: r'storyKey',
      type: IsarType.string,
    ),
    r'type': PropertySchema(id: 9, name: r'type', type: IsarType.string),
  },

  estimateSize: _insightStoryEstimateSize,
  serialize: _insightStorySerialize,
  deserialize: _insightStoryDeserialize,
  deserializeProp: _insightStoryDeserializeProp,
  idName: r'id',
  indexes: {
    r'storyKey': IndexSchema(
      id: -4444372188062609597,
      name: r'storyKey',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'storyKey',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'type_generatedAt': IndexSchema(
      id: 3321690703236641525,
      name: r'type_generatedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'type',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'generatedAt',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'generatedAt': IndexSchema(
      id: 4527473099475400258,
      name: r'generatedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'generatedAt',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'expiresAt': IndexSchema(
      id: 4994901953235663716,
      name: r'expiresAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'expiresAt',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _insightStoryGetId,
  getLinks: _insightStoryGetLinks,
  attach: _insightStoryAttach,
  version: '3.3.2',
);

int _insightStoryEstimateSize(
  InsightStory object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.contentHash;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.payloadJson.length * 3;
  bytesCount += 3 + object.seenSlides.length * 8;
  bytesCount += 3 + object.storyKey.length * 3;
  bytesCount += 3 + object.type.length * 3;
  return bytesCount;
}

void _insightStorySerialize(
  InsightStory object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.contentHash);
  writer.writeDateTime(offsets[1], object.expiresAt);
  writer.writeDateTime(offsets[2], object.generatedAt);
  writer.writeString(offsets[3], object.payloadJson);
  writer.writeDateTime(offsets[4], object.periodEnd);
  writer.writeDateTime(offsets[5], object.periodStart);
  writer.writeDateTime(offsets[6], object.seenAt);
  writer.writeLongList(offsets[7], object.seenSlides);
  writer.writeString(offsets[8], object.storyKey);
  writer.writeString(offsets[9], object.type);
}

InsightStory _insightStoryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = InsightStory();
  object.contentHash = reader.readStringOrNull(offsets[0]);
  object.expiresAt = reader.readDateTime(offsets[1]);
  object.generatedAt = reader.readDateTime(offsets[2]);
  object.id = id;
  object.payloadJson = reader.readString(offsets[3]);
  object.periodEnd = reader.readDateTimeOrNull(offsets[4]);
  object.periodStart = reader.readDateTimeOrNull(offsets[5]);
  object.seenAt = reader.readDateTimeOrNull(offsets[6]);
  object.seenSlides = reader.readLongList(offsets[7]) ?? [];
  object.storyKey = reader.readString(offsets[8]);
  object.type = reader.readString(offsets[9]);
  return object;
}

P _insightStoryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readLongList(offset) ?? []) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _insightStoryGetId(InsightStory object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _insightStoryGetLinks(InsightStory object) {
  return [];
}

void _insightStoryAttach(
  IsarCollection<dynamic> col,
  Id id,
  InsightStory object,
) {
  object.id = id;
}

extension InsightStoryByIndex on IsarCollection<InsightStory> {
  Future<InsightStory?> getByStoryKey(String storyKey) {
    return getByIndex(r'storyKey', [storyKey]);
  }

  InsightStory? getByStoryKeySync(String storyKey) {
    return getByIndexSync(r'storyKey', [storyKey]);
  }

  Future<bool> deleteByStoryKey(String storyKey) {
    return deleteByIndex(r'storyKey', [storyKey]);
  }

  bool deleteByStoryKeySync(String storyKey) {
    return deleteByIndexSync(r'storyKey', [storyKey]);
  }

  Future<List<InsightStory?>> getAllByStoryKey(List<String> storyKeyValues) {
    final values = storyKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'storyKey', values);
  }

  List<InsightStory?> getAllByStoryKeySync(List<String> storyKeyValues) {
    final values = storyKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'storyKey', values);
  }

  Future<int> deleteAllByStoryKey(List<String> storyKeyValues) {
    final values = storyKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'storyKey', values);
  }

  int deleteAllByStoryKeySync(List<String> storyKeyValues) {
    final values = storyKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'storyKey', values);
  }

  Future<Id> putByStoryKey(InsightStory object) {
    return putByIndex(r'storyKey', object);
  }

  Id putByStoryKeySync(InsightStory object, {bool saveLinks = true}) {
    return putByIndexSync(r'storyKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByStoryKey(List<InsightStory> objects) {
    return putAllByIndex(r'storyKey', objects);
  }

  List<Id> putAllByStoryKeySync(
    List<InsightStory> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'storyKey', objects, saveLinks: saveLinks);
  }
}

extension InsightStoryQueryWhereSort
    on QueryBuilder<InsightStory, InsightStory, QWhere> {
  QueryBuilder<InsightStory, InsightStory, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterWhere> anyGeneratedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'generatedAt'),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterWhere> anyExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'expiresAt'),
      );
    });
  }
}

extension InsightStoryQueryWhere
    on QueryBuilder<InsightStory, InsightStory, QWhereClause> {
  QueryBuilder<InsightStory, InsightStory, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
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

  QueryBuilder<InsightStory, InsightStory, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterWhereClause> idBetween(
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

  QueryBuilder<InsightStory, InsightStory, QAfterWhereClause> storyKeyEqualTo(
    String storyKey,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'storyKey', value: [storyKey]),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterWhereClause>
  storyKeyNotEqualTo(String storyKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'storyKey',
                lower: [],
                upper: [storyKey],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'storyKey',
                lower: [storyKey],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'storyKey',
                lower: [storyKey],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'storyKey',
                lower: [],
                upper: [storyKey],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterWhereClause>
  typeEqualToAnyGeneratedAt(String type) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'type_generatedAt', value: [type]),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterWhereClause>
  typeNotEqualToAnyGeneratedAt(String type) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'type_generatedAt',
                lower: [],
                upper: [type],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'type_generatedAt',
                lower: [type],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'type_generatedAt',
                lower: [type],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'type_generatedAt',
                lower: [],
                upper: [type],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterWhereClause>
  typeGeneratedAtEqualTo(String type, DateTime generatedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'type_generatedAt',
          value: [type, generatedAt],
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterWhereClause>
  typeEqualToGeneratedAtNotEqualTo(String type, DateTime generatedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'type_generatedAt',
                lower: [type],
                upper: [type, generatedAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'type_generatedAt',
                lower: [type, generatedAt],
                includeLower: false,
                upper: [type],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'type_generatedAt',
                lower: [type, generatedAt],
                includeLower: false,
                upper: [type],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'type_generatedAt',
                lower: [type],
                upper: [type, generatedAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterWhereClause>
  typeEqualToGeneratedAtGreaterThan(
    String type,
    DateTime generatedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'type_generatedAt',
          lower: [type, generatedAt],
          includeLower: include,
          upper: [type],
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterWhereClause>
  typeEqualToGeneratedAtLessThan(
    String type,
    DateTime generatedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'type_generatedAt',
          lower: [type],
          upper: [type, generatedAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterWhereClause>
  typeEqualToGeneratedAtBetween(
    String type,
    DateTime lowerGeneratedAt,
    DateTime upperGeneratedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'type_generatedAt',
          lower: [type, lowerGeneratedAt],
          includeLower: includeLower,
          upper: [type, upperGeneratedAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterWhereClause>
  generatedAtEqualTo(DateTime generatedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'generatedAt',
          value: [generatedAt],
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterWhereClause>
  generatedAtNotEqualTo(DateTime generatedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'generatedAt',
                lower: [],
                upper: [generatedAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'generatedAt',
                lower: [generatedAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'generatedAt',
                lower: [generatedAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'generatedAt',
                lower: [],
                upper: [generatedAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterWhereClause>
  generatedAtGreaterThan(DateTime generatedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'generatedAt',
          lower: [generatedAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterWhereClause>
  generatedAtLessThan(DateTime generatedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'generatedAt',
          lower: [],
          upper: [generatedAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterWhereClause>
  generatedAtBetween(
    DateTime lowerGeneratedAt,
    DateTime upperGeneratedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'generatedAt',
          lower: [lowerGeneratedAt],
          includeLower: includeLower,
          upper: [upperGeneratedAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterWhereClause> expiresAtEqualTo(
    DateTime expiresAt,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'expiresAt', value: [expiresAt]),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterWhereClause>
  expiresAtNotEqualTo(DateTime expiresAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'expiresAt',
                lower: [],
                upper: [expiresAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'expiresAt',
                lower: [expiresAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'expiresAt',
                lower: [expiresAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'expiresAt',
                lower: [],
                upper: [expiresAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterWhereClause>
  expiresAtGreaterThan(DateTime expiresAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'expiresAt',
          lower: [expiresAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterWhereClause> expiresAtLessThan(
    DateTime expiresAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'expiresAt',
          lower: [],
          upper: [expiresAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterWhereClause> expiresAtBetween(
    DateTime lowerExpiresAt,
    DateTime upperExpiresAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'expiresAt',
          lower: [lowerExpiresAt],
          includeLower: includeLower,
          upper: [upperExpiresAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension InsightStoryQueryFilter
    on QueryBuilder<InsightStory, InsightStory, QFilterCondition> {
  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  contentHashIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'contentHash'),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  contentHashIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'contentHash'),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  contentHashEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'contentHash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  contentHashGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'contentHash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  contentHashLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'contentHash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  contentHashBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'contentHash',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  contentHashStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'contentHash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  contentHashEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'contentHash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  contentHashContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'contentHash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  contentHashMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'contentHash',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  contentHashIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'contentHash', value: ''),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  contentHashIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'contentHash', value: ''),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  expiresAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'expiresAt', value: value),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  expiresAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'expiresAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  expiresAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'expiresAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  expiresAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'expiresAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  generatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'generatedAt', value: value),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  generatedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'generatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  generatedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'generatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  generatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'generatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
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

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
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

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition> idBetween(
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

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  payloadJsonEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'payloadJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  payloadJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'payloadJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  payloadJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'payloadJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  payloadJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'payloadJson',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  payloadJsonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'payloadJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  payloadJsonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'payloadJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  payloadJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'payloadJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  payloadJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'payloadJson',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  payloadJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'payloadJson', value: ''),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  payloadJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'payloadJson', value: ''),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  periodEndIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'periodEnd'),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  periodEndIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'periodEnd'),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  periodEndEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'periodEnd', value: value),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  periodEndGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'periodEnd',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  periodEndLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'periodEnd',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  periodEndBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'periodEnd',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  periodStartIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'periodStart'),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  periodStartIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'periodStart'),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  periodStartEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'periodStart', value: value),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  periodStartGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'periodStart',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  periodStartLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'periodStart',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  periodStartBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'periodStart',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  seenAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'seenAt'),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  seenAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'seenAt'),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition> seenAtEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'seenAt', value: value),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  seenAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'seenAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  seenAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'seenAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition> seenAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'seenAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  seenSlidesElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'seenSlides', value: value),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  seenSlidesElementGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'seenSlides',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  seenSlidesElementLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'seenSlides',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  seenSlidesElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'seenSlides',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  seenSlidesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'seenSlides', length, true, length, true);
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  seenSlidesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'seenSlides', 0, true, 0, true);
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  seenSlidesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'seenSlides', 0, false, 999999, true);
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  seenSlidesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'seenSlides', 0, true, length, include);
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  seenSlidesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'seenSlides', length, include, 999999, true);
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  seenSlidesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'seenSlides',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  storyKeyEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'storyKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  storyKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'storyKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  storyKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'storyKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  storyKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'storyKey',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  storyKeyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'storyKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  storyKeyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'storyKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  storyKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'storyKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  storyKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'storyKey',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  storyKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'storyKey', value: ''),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  storyKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'storyKey', value: ''),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition> typeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  typeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition> typeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition> typeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'type',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  typeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition> typeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition> typeContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition> typeMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'type',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'type', value: ''),
      );
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterFilterCondition>
  typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'type', value: ''),
      );
    });
  }
}

extension InsightStoryQueryObject
    on QueryBuilder<InsightStory, InsightStory, QFilterCondition> {}

extension InsightStoryQueryLinks
    on QueryBuilder<InsightStory, InsightStory, QFilterCondition> {}

extension InsightStoryQuerySortBy
    on QueryBuilder<InsightStory, InsightStory, QSortBy> {
  QueryBuilder<InsightStory, InsightStory, QAfterSortBy> sortByContentHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentHash', Sort.asc);
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterSortBy>
  sortByContentHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentHash', Sort.desc);
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterSortBy> sortByExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.asc);
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterSortBy> sortByExpiresAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.desc);
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterSortBy> sortByGeneratedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generatedAt', Sort.asc);
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterSortBy>
  sortByGeneratedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generatedAt', Sort.desc);
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterSortBy> sortByPayloadJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payloadJson', Sort.asc);
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterSortBy>
  sortByPayloadJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payloadJson', Sort.desc);
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterSortBy> sortByPeriodEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodEnd', Sort.asc);
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterSortBy> sortByPeriodEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodEnd', Sort.desc);
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterSortBy> sortByPeriodStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodStart', Sort.asc);
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterSortBy>
  sortByPeriodStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodStart', Sort.desc);
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterSortBy> sortBySeenAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seenAt', Sort.asc);
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterSortBy> sortBySeenAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seenAt', Sort.desc);
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterSortBy> sortByStoryKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storyKey', Sort.asc);
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterSortBy> sortByStoryKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storyKey', Sort.desc);
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension InsightStoryQuerySortThenBy
    on QueryBuilder<InsightStory, InsightStory, QSortThenBy> {
  QueryBuilder<InsightStory, InsightStory, QAfterSortBy> thenByContentHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentHash', Sort.asc);
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterSortBy>
  thenByContentHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentHash', Sort.desc);
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterSortBy> thenByExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.asc);
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterSortBy> thenByExpiresAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.desc);
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterSortBy> thenByGeneratedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generatedAt', Sort.asc);
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterSortBy>
  thenByGeneratedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generatedAt', Sort.desc);
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterSortBy> thenByPayloadJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payloadJson', Sort.asc);
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterSortBy>
  thenByPayloadJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payloadJson', Sort.desc);
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterSortBy> thenByPeriodEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodEnd', Sort.asc);
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterSortBy> thenByPeriodEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodEnd', Sort.desc);
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterSortBy> thenByPeriodStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodStart', Sort.asc);
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterSortBy>
  thenByPeriodStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodStart', Sort.desc);
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterSortBy> thenBySeenAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seenAt', Sort.asc);
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterSortBy> thenBySeenAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seenAt', Sort.desc);
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterSortBy> thenByStoryKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storyKey', Sort.asc);
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterSortBy> thenByStoryKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storyKey', Sort.desc);
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<InsightStory, InsightStory, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension InsightStoryQueryWhereDistinct
    on QueryBuilder<InsightStory, InsightStory, QDistinct> {
  QueryBuilder<InsightStory, InsightStory, QDistinct> distinctByContentHash({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contentHash', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InsightStory, InsightStory, QDistinct> distinctByExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expiresAt');
    });
  }

  QueryBuilder<InsightStory, InsightStory, QDistinct> distinctByGeneratedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'generatedAt');
    });
  }

  QueryBuilder<InsightStory, InsightStory, QDistinct> distinctByPayloadJson({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'payloadJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InsightStory, InsightStory, QDistinct> distinctByPeriodEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'periodEnd');
    });
  }

  QueryBuilder<InsightStory, InsightStory, QDistinct> distinctByPeriodStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'periodStart');
    });
  }

  QueryBuilder<InsightStory, InsightStory, QDistinct> distinctBySeenAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'seenAt');
    });
  }

  QueryBuilder<InsightStory, InsightStory, QDistinct> distinctBySeenSlides() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'seenSlides');
    });
  }

  QueryBuilder<InsightStory, InsightStory, QDistinct> distinctByStoryKey({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'storyKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InsightStory, InsightStory, QDistinct> distinctByType({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }
}

extension InsightStoryQueryProperty
    on QueryBuilder<InsightStory, InsightStory, QQueryProperty> {
  QueryBuilder<InsightStory, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<InsightStory, String?, QQueryOperations> contentHashProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contentHash');
    });
  }

  QueryBuilder<InsightStory, DateTime, QQueryOperations> expiresAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expiresAt');
    });
  }

  QueryBuilder<InsightStory, DateTime, QQueryOperations> generatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'generatedAt');
    });
  }

  QueryBuilder<InsightStory, String, QQueryOperations> payloadJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'payloadJson');
    });
  }

  QueryBuilder<InsightStory, DateTime?, QQueryOperations> periodEndProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'periodEnd');
    });
  }

  QueryBuilder<InsightStory, DateTime?, QQueryOperations>
  periodStartProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'periodStart');
    });
  }

  QueryBuilder<InsightStory, DateTime?, QQueryOperations> seenAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'seenAt');
    });
  }

  QueryBuilder<InsightStory, List<int>, QQueryOperations> seenSlidesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'seenSlides');
    });
  }

  QueryBuilder<InsightStory, String, QQueryOperations> storyKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'storyKey');
    });
  }

  QueryBuilder<InsightStory, String, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}
