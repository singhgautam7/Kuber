// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_search.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetRecentSearchCollection on Isar {
  IsarCollection<RecentSearch> get recentSearchs => this.collection();
}

const RecentSearchSchema = CollectionSchema(
  name: r'RecentSearch',
  id: -7902452067171573026,
  properties: {
    r'query': PropertySchema(id: 0, name: r'query', type: IsarType.string),
    r'queryLower': PropertySchema(
      id: 1,
      name: r'queryLower',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 2,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _recentSearchEstimateSize,
  serialize: _recentSearchSerialize,
  deserialize: _recentSearchDeserialize,
  deserializeProp: _recentSearchDeserializeProp,
  idName: r'id',
  indexes: {
    r'queryLower': IndexSchema(
      id: 614885001346292932,
      name: r'queryLower',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'queryLower',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'updatedAt': IndexSchema(
      id: -6238191080293565125,
      name: r'updatedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'updatedAt',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _recentSearchGetId,
  getLinks: _recentSearchGetLinks,
  attach: _recentSearchAttach,
  version: '3.3.2',
);

int _recentSearchEstimateSize(
  RecentSearch object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.query.length * 3;
  bytesCount += 3 + object.queryLower.length * 3;
  return bytesCount;
}

void _recentSearchSerialize(
  RecentSearch object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.query);
  writer.writeString(offsets[1], object.queryLower);
  writer.writeDateTime(offsets[2], object.updatedAt);
}

RecentSearch _recentSearchDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RecentSearch();
  object.id = id;
  object.query = reader.readString(offsets[0]);
  object.queryLower = reader.readString(offsets[1]);
  object.updatedAt = reader.readDateTime(offsets[2]);
  return object;
}

P _recentSearchDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _recentSearchGetId(RecentSearch object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _recentSearchGetLinks(RecentSearch object) {
  return [];
}

void _recentSearchAttach(
  IsarCollection<dynamic> col,
  Id id,
  RecentSearch object,
) {
  object.id = id;
}

extension RecentSearchByIndex on IsarCollection<RecentSearch> {
  Future<RecentSearch?> getByQueryLower(String queryLower) {
    return getByIndex(r'queryLower', [queryLower]);
  }

  RecentSearch? getByQueryLowerSync(String queryLower) {
    return getByIndexSync(r'queryLower', [queryLower]);
  }

  Future<bool> deleteByQueryLower(String queryLower) {
    return deleteByIndex(r'queryLower', [queryLower]);
  }

  bool deleteByQueryLowerSync(String queryLower) {
    return deleteByIndexSync(r'queryLower', [queryLower]);
  }

  Future<List<RecentSearch?>> getAllByQueryLower(
    List<String> queryLowerValues,
  ) {
    final values = queryLowerValues.map((e) => [e]).toList();
    return getAllByIndex(r'queryLower', values);
  }

  List<RecentSearch?> getAllByQueryLowerSync(List<String> queryLowerValues) {
    final values = queryLowerValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'queryLower', values);
  }

  Future<int> deleteAllByQueryLower(List<String> queryLowerValues) {
    final values = queryLowerValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'queryLower', values);
  }

  int deleteAllByQueryLowerSync(List<String> queryLowerValues) {
    final values = queryLowerValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'queryLower', values);
  }

  Future<Id> putByQueryLower(RecentSearch object) {
    return putByIndex(r'queryLower', object);
  }

  Id putByQueryLowerSync(RecentSearch object, {bool saveLinks = true}) {
    return putByIndexSync(r'queryLower', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByQueryLower(List<RecentSearch> objects) {
    return putAllByIndex(r'queryLower', objects);
  }

  List<Id> putAllByQueryLowerSync(
    List<RecentSearch> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'queryLower', objects, saveLinks: saveLinks);
  }
}

extension RecentSearchQueryWhereSort
    on QueryBuilder<RecentSearch, RecentSearch, QWhere> {
  QueryBuilder<RecentSearch, RecentSearch, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<RecentSearch, RecentSearch, QAfterWhere> anyUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'updatedAt'),
      );
    });
  }
}

extension RecentSearchQueryWhere
    on QueryBuilder<RecentSearch, RecentSearch, QWhereClause> {
  QueryBuilder<RecentSearch, RecentSearch, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<RecentSearch, RecentSearch, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<RecentSearch, RecentSearch, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<RecentSearch, RecentSearch, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<RecentSearch, RecentSearch, QAfterWhereClause> idBetween(
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

  QueryBuilder<RecentSearch, RecentSearch, QAfterWhereClause> queryLowerEqualTo(
    String queryLower,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'queryLower', value: [queryLower]),
      );
    });
  }

  QueryBuilder<RecentSearch, RecentSearch, QAfterWhereClause>
  queryLowerNotEqualTo(String queryLower) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'queryLower',
                lower: [],
                upper: [queryLower],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'queryLower',
                lower: [queryLower],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'queryLower',
                lower: [queryLower],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'queryLower',
                lower: [],
                upper: [queryLower],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<RecentSearch, RecentSearch, QAfterWhereClause> updatedAtEqualTo(
    DateTime updatedAt,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'updatedAt', value: [updatedAt]),
      );
    });
  }

  QueryBuilder<RecentSearch, RecentSearch, QAfterWhereClause>
  updatedAtNotEqualTo(DateTime updatedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'updatedAt',
                lower: [],
                upper: [updatedAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'updatedAt',
                lower: [updatedAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'updatedAt',
                lower: [updatedAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'updatedAt',
                lower: [],
                upper: [updatedAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<RecentSearch, RecentSearch, QAfterWhereClause>
  updatedAtGreaterThan(DateTime updatedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'updatedAt',
          lower: [updatedAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<RecentSearch, RecentSearch, QAfterWhereClause> updatedAtLessThan(
    DateTime updatedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'updatedAt',
          lower: [],
          upper: [updatedAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<RecentSearch, RecentSearch, QAfterWhereClause> updatedAtBetween(
    DateTime lowerUpdatedAt,
    DateTime upperUpdatedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'updatedAt',
          lower: [lowerUpdatedAt],
          includeLower: includeLower,
          upper: [upperUpdatedAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension RecentSearchQueryFilter
    on QueryBuilder<RecentSearch, RecentSearch, QFilterCondition> {
  QueryBuilder<RecentSearch, RecentSearch, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<RecentSearch, RecentSearch, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<RecentSearch, RecentSearch, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<RecentSearch, RecentSearch, QAfterFilterCondition> idBetween(
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

  QueryBuilder<RecentSearch, RecentSearch, QAfterFilterCondition> queryEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'query',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecentSearch, RecentSearch, QAfterFilterCondition>
  queryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'query',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecentSearch, RecentSearch, QAfterFilterCondition> queryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'query',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecentSearch, RecentSearch, QAfterFilterCondition> queryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'query',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecentSearch, RecentSearch, QAfterFilterCondition>
  queryStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'query',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecentSearch, RecentSearch, QAfterFilterCondition> queryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'query',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecentSearch, RecentSearch, QAfterFilterCondition> queryContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'query',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecentSearch, RecentSearch, QAfterFilterCondition> queryMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'query',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecentSearch, RecentSearch, QAfterFilterCondition>
  queryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'query', value: ''),
      );
    });
  }

  QueryBuilder<RecentSearch, RecentSearch, QAfterFilterCondition>
  queryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'query', value: ''),
      );
    });
  }

  QueryBuilder<RecentSearch, RecentSearch, QAfterFilterCondition>
  queryLowerEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'queryLower',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecentSearch, RecentSearch, QAfterFilterCondition>
  queryLowerGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'queryLower',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecentSearch, RecentSearch, QAfterFilterCondition>
  queryLowerLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'queryLower',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecentSearch, RecentSearch, QAfterFilterCondition>
  queryLowerBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'queryLower',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecentSearch, RecentSearch, QAfterFilterCondition>
  queryLowerStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'queryLower',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecentSearch, RecentSearch, QAfterFilterCondition>
  queryLowerEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'queryLower',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecentSearch, RecentSearch, QAfterFilterCondition>
  queryLowerContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'queryLower',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecentSearch, RecentSearch, QAfterFilterCondition>
  queryLowerMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'queryLower',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecentSearch, RecentSearch, QAfterFilterCondition>
  queryLowerIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'queryLower', value: ''),
      );
    });
  }

  QueryBuilder<RecentSearch, RecentSearch, QAfterFilterCondition>
  queryLowerIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'queryLower', value: ''),
      );
    });
  }

  QueryBuilder<RecentSearch, RecentSearch, QAfterFilterCondition>
  updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<RecentSearch, RecentSearch, QAfterFilterCondition>
  updatedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecentSearch, RecentSearch, QAfterFilterCondition>
  updatedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecentSearch, RecentSearch, QAfterFilterCondition>
  updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'updatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension RecentSearchQueryObject
    on QueryBuilder<RecentSearch, RecentSearch, QFilterCondition> {}

extension RecentSearchQueryLinks
    on QueryBuilder<RecentSearch, RecentSearch, QFilterCondition> {}

extension RecentSearchQuerySortBy
    on QueryBuilder<RecentSearch, RecentSearch, QSortBy> {
  QueryBuilder<RecentSearch, RecentSearch, QAfterSortBy> sortByQuery() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'query', Sort.asc);
    });
  }

  QueryBuilder<RecentSearch, RecentSearch, QAfterSortBy> sortByQueryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'query', Sort.desc);
    });
  }

  QueryBuilder<RecentSearch, RecentSearch, QAfterSortBy> sortByQueryLower() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'queryLower', Sort.asc);
    });
  }

  QueryBuilder<RecentSearch, RecentSearch, QAfterSortBy>
  sortByQueryLowerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'queryLower', Sort.desc);
    });
  }

  QueryBuilder<RecentSearch, RecentSearch, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<RecentSearch, RecentSearch, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension RecentSearchQuerySortThenBy
    on QueryBuilder<RecentSearch, RecentSearch, QSortThenBy> {
  QueryBuilder<RecentSearch, RecentSearch, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<RecentSearch, RecentSearch, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<RecentSearch, RecentSearch, QAfterSortBy> thenByQuery() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'query', Sort.asc);
    });
  }

  QueryBuilder<RecentSearch, RecentSearch, QAfterSortBy> thenByQueryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'query', Sort.desc);
    });
  }

  QueryBuilder<RecentSearch, RecentSearch, QAfterSortBy> thenByQueryLower() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'queryLower', Sort.asc);
    });
  }

  QueryBuilder<RecentSearch, RecentSearch, QAfterSortBy>
  thenByQueryLowerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'queryLower', Sort.desc);
    });
  }

  QueryBuilder<RecentSearch, RecentSearch, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<RecentSearch, RecentSearch, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension RecentSearchQueryWhereDistinct
    on QueryBuilder<RecentSearch, RecentSearch, QDistinct> {
  QueryBuilder<RecentSearch, RecentSearch, QDistinct> distinctByQuery({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'query', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RecentSearch, RecentSearch, QDistinct> distinctByQueryLower({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'queryLower', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RecentSearch, RecentSearch, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension RecentSearchQueryProperty
    on QueryBuilder<RecentSearch, RecentSearch, QQueryProperty> {
  QueryBuilder<RecentSearch, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<RecentSearch, String, QQueryOperations> queryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'query');
    });
  }

  QueryBuilder<RecentSearch, String, QQueryOperations> queryLowerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'queryLower');
    });
  }

  QueryBuilder<RecentSearch, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
