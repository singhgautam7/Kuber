// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calculator_recent_use.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCalculatorRecentUseCollection on Isar {
  IsarCollection<CalculatorRecentUse> get calculatorRecentUses =>
      this.collection();
}

const CalculatorRecentUseSchema = CollectionSchema(
  name: r'CalculatorRecentUse',
  id: -5324098611014913287,
  properties: {
    r'calculatorType': PropertySchema(
      id: 0,
      name: r'calculatorType',
      type: IsarType.string,
    ),
    r'lastUsed': PropertySchema(
      id: 1,
      name: r'lastUsed',
      type: IsarType.dateTime,
    ),
    r'useCount': PropertySchema(id: 2, name: r'useCount', type: IsarType.long),
  },

  estimateSize: _calculatorRecentUseEstimateSize,
  serialize: _calculatorRecentUseSerialize,
  deserialize: _calculatorRecentUseDeserialize,
  deserializeProp: _calculatorRecentUseDeserializeProp,
  idName: r'id',
  indexes: {
    r'calculatorType': IndexSchema(
      id: 874155525440987050,
      name: r'calculatorType',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'calculatorType',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _calculatorRecentUseGetId,
  getLinks: _calculatorRecentUseGetLinks,
  attach: _calculatorRecentUseAttach,
  version: '3.3.2',
);

int _calculatorRecentUseEstimateSize(
  CalculatorRecentUse object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.calculatorType.length * 3;
  return bytesCount;
}

void _calculatorRecentUseSerialize(
  CalculatorRecentUse object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.calculatorType);
  writer.writeDateTime(offsets[1], object.lastUsed);
  writer.writeLong(offsets[2], object.useCount);
}

CalculatorRecentUse _calculatorRecentUseDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CalculatorRecentUse();
  object.calculatorType = reader.readString(offsets[0]);
  object.id = id;
  object.lastUsed = reader.readDateTime(offsets[1]);
  object.useCount = reader.readLong(offsets[2]);
  return object;
}

P _calculatorRecentUseDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _calculatorRecentUseGetId(CalculatorRecentUse object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _calculatorRecentUseGetLinks(
  CalculatorRecentUse object,
) {
  return [];
}

void _calculatorRecentUseAttach(
  IsarCollection<dynamic> col,
  Id id,
  CalculatorRecentUse object,
) {
  object.id = id;
}

extension CalculatorRecentUseByIndex on IsarCollection<CalculatorRecentUse> {
  Future<CalculatorRecentUse?> getByCalculatorType(String calculatorType) {
    return getByIndex(r'calculatorType', [calculatorType]);
  }

  CalculatorRecentUse? getByCalculatorTypeSync(String calculatorType) {
    return getByIndexSync(r'calculatorType', [calculatorType]);
  }

  Future<bool> deleteByCalculatorType(String calculatorType) {
    return deleteByIndex(r'calculatorType', [calculatorType]);
  }

  bool deleteByCalculatorTypeSync(String calculatorType) {
    return deleteByIndexSync(r'calculatorType', [calculatorType]);
  }

  Future<List<CalculatorRecentUse?>> getAllByCalculatorType(
    List<String> calculatorTypeValues,
  ) {
    final values = calculatorTypeValues.map((e) => [e]).toList();
    return getAllByIndex(r'calculatorType', values);
  }

  List<CalculatorRecentUse?> getAllByCalculatorTypeSync(
    List<String> calculatorTypeValues,
  ) {
    final values = calculatorTypeValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'calculatorType', values);
  }

  Future<int> deleteAllByCalculatorType(List<String> calculatorTypeValues) {
    final values = calculatorTypeValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'calculatorType', values);
  }

  int deleteAllByCalculatorTypeSync(List<String> calculatorTypeValues) {
    final values = calculatorTypeValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'calculatorType', values);
  }

  Future<Id> putByCalculatorType(CalculatorRecentUse object) {
    return putByIndex(r'calculatorType', object);
  }

  Id putByCalculatorTypeSync(
    CalculatorRecentUse object, {
    bool saveLinks = true,
  }) {
    return putByIndexSync(r'calculatorType', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByCalculatorType(List<CalculatorRecentUse> objects) {
    return putAllByIndex(r'calculatorType', objects);
  }

  List<Id> putAllByCalculatorTypeSync(
    List<CalculatorRecentUse> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'calculatorType', objects, saveLinks: saveLinks);
  }
}

extension CalculatorRecentUseQueryWhereSort
    on QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QWhere> {
  QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CalculatorRecentUseQueryWhere
    on QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QWhereClause> {
  QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QAfterWhereClause>
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

  QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QAfterWhereClause>
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

  QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QAfterWhereClause>
  calculatorTypeEqualTo(String calculatorType) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'calculatorType',
          value: [calculatorType],
        ),
      );
    });
  }

  QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QAfterWhereClause>
  calculatorTypeNotEqualTo(String calculatorType) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'calculatorType',
                lower: [],
                upper: [calculatorType],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'calculatorType',
                lower: [calculatorType],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'calculatorType',
                lower: [calculatorType],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'calculatorType',
                lower: [],
                upper: [calculatorType],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension CalculatorRecentUseQueryFilter
    on
        QueryBuilder<
          CalculatorRecentUse,
          CalculatorRecentUse,
          QFilterCondition
        > {
  QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QAfterFilterCondition>
  calculatorTypeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'calculatorType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QAfterFilterCondition>
  calculatorTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'calculatorType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QAfterFilterCondition>
  calculatorTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'calculatorType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QAfterFilterCondition>
  calculatorTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'calculatorType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QAfterFilterCondition>
  calculatorTypeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'calculatorType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QAfterFilterCondition>
  calculatorTypeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'calculatorType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QAfterFilterCondition>
  calculatorTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'calculatorType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QAfterFilterCondition>
  calculatorTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'calculatorType',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QAfterFilterCondition>
  calculatorTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'calculatorType', value: ''),
      );
    });
  }

  QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QAfterFilterCondition>
  calculatorTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'calculatorType', value: ''),
      );
    });
  }

  QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QAfterFilterCondition>
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

  QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QAfterFilterCondition>
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

  QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QAfterFilterCondition>
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

  QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QAfterFilterCondition>
  lastUsedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastUsed', value: value),
      );
    });
  }

  QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QAfterFilterCondition>
  lastUsedGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastUsed',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QAfterFilterCondition>
  lastUsedLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastUsed',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QAfterFilterCondition>
  lastUsedBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastUsed',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QAfterFilterCondition>
  useCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'useCount', value: value),
      );
    });
  }

  QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QAfterFilterCondition>
  useCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'useCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QAfterFilterCondition>
  useCountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'useCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QAfterFilterCondition>
  useCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'useCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension CalculatorRecentUseQueryObject
    on
        QueryBuilder<
          CalculatorRecentUse,
          CalculatorRecentUse,
          QFilterCondition
        > {}

extension CalculatorRecentUseQueryLinks
    on
        QueryBuilder<
          CalculatorRecentUse,
          CalculatorRecentUse,
          QFilterCondition
        > {}

extension CalculatorRecentUseQuerySortBy
    on QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QSortBy> {
  QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QAfterSortBy>
  sortByCalculatorType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calculatorType', Sort.asc);
    });
  }

  QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QAfterSortBy>
  sortByCalculatorTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calculatorType', Sort.desc);
    });
  }

  QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QAfterSortBy>
  sortByLastUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsed', Sort.asc);
    });
  }

  QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QAfterSortBy>
  sortByLastUsedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsed', Sort.desc);
    });
  }

  QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QAfterSortBy>
  sortByUseCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useCount', Sort.asc);
    });
  }

  QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QAfterSortBy>
  sortByUseCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useCount', Sort.desc);
    });
  }
}

extension CalculatorRecentUseQuerySortThenBy
    on QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QSortThenBy> {
  QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QAfterSortBy>
  thenByCalculatorType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calculatorType', Sort.asc);
    });
  }

  QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QAfterSortBy>
  thenByCalculatorTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calculatorType', Sort.desc);
    });
  }

  QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QAfterSortBy>
  thenByLastUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsed', Sort.asc);
    });
  }

  QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QAfterSortBy>
  thenByLastUsedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsed', Sort.desc);
    });
  }

  QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QAfterSortBy>
  thenByUseCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useCount', Sort.asc);
    });
  }

  QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QAfterSortBy>
  thenByUseCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useCount', Sort.desc);
    });
  }
}

extension CalculatorRecentUseQueryWhereDistinct
    on QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QDistinct> {
  QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QDistinct>
  distinctByCalculatorType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'calculatorType',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QDistinct>
  distinctByLastUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUsed');
    });
  }

  QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QDistinct>
  distinctByUseCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'useCount');
    });
  }
}

extension CalculatorRecentUseQueryProperty
    on QueryBuilder<CalculatorRecentUse, CalculatorRecentUse, QQueryProperty> {
  QueryBuilder<CalculatorRecentUse, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CalculatorRecentUse, String, QQueryOperations>
  calculatorTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'calculatorType');
    });
  }

  QueryBuilder<CalculatorRecentUse, DateTime, QQueryOperations>
  lastUsedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUsed');
    });
  }

  QueryBuilder<CalculatorRecentUse, int, QQueryOperations> useCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'useCount');
    });
  }
}
