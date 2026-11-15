// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_filter.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSavedFilterCollection on Isar {
  IsarCollection<SavedFilter> get savedFilters => this.collection();
}

const SavedFilterSchema = CollectionSchema(
  name: r'SavedFilter',
  id: 3669536288723080398,
  properties: {
    r'astJson': PropertySchema(id: 0, name: r'astJson', type: IsarType.string),
    r'charts': PropertySchema(
      id: 1,
      name: r'charts',
      type: IsarType.objectList,

      target: r'SavedChart',
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'groupBy': PropertySchema(
      id: 3,
      name: r'groupBy',
      type: IsarType.string,
      enumMap: _SavedFiltergroupByEnumValueMap,
    ),
    r'kpiSelection': PropertySchema(
      id: 4,
      name: r'kpiSelection',
      type: IsarType.stringList,
    ),
    r'lastUsedAt': PropertySchema(
      id: 5,
      name: r'lastUsedAt',
      type: IsarType.dateTime,
    ),
    r'name': PropertySchema(id: 6, name: r'name', type: IsarType.string),
    r'queryText': PropertySchema(
      id: 7,
      name: r'queryText',
      type: IsarType.string,
    ),
    r'sortDescending': PropertySchema(
      id: 8,
      name: r'sortDescending',
      type: IsarType.bool,
    ),
    r'sortField': PropertySchema(
      id: 9,
      name: r'sortField',
      type: IsarType.string,
      enumMap: _SavedFiltersortFieldEnumValueMap,
    ),
    r'updatedAt': PropertySchema(
      id: 10,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _savedFilterEstimateSize,
  serialize: _savedFilterSerialize,
  deserialize: _savedFilterDeserialize,
  deserializeProp: _savedFilterDeserializeProp,
  idName: r'id',
  indexes: {
    r'name': IndexSchema(
      id: 879695947855722453,
      name: r'name',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'name',
          type: IndexType.hash,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {r'SavedChart': SavedChartSchema},

  getId: _savedFilterGetId,
  getLinks: _savedFilterGetLinks,
  attach: _savedFilterAttach,
  version: '3.3.2',
);

int _savedFilterEstimateSize(
  SavedFilter object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.astJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.charts.length * 3;
  {
    final offsets = allOffsets[SavedChart]!;
    for (var i = 0; i < object.charts.length; i++) {
      final value = object.charts[i];
      bytesCount += SavedChartSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.groupBy.name.length * 3;
  bytesCount += 3 + object.kpiSelection.length * 3;
  {
    for (var i = 0; i < object.kpiSelection.length; i++) {
      final value = object.kpiSelection[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.queryText.length * 3;
  bytesCount += 3 + object.sortField.name.length * 3;
  return bytesCount;
}

void _savedFilterSerialize(
  SavedFilter object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.astJson);
  writer.writeObjectList<SavedChart>(
    offsets[1],
    allOffsets,
    SavedChartSchema.serialize,
    object.charts,
  );
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeString(offsets[3], object.groupBy.name);
  writer.writeStringList(offsets[4], object.kpiSelection);
  writer.writeDateTime(offsets[5], object.lastUsedAt);
  writer.writeString(offsets[6], object.name);
  writer.writeString(offsets[7], object.queryText);
  writer.writeBool(offsets[8], object.sortDescending);
  writer.writeString(offsets[9], object.sortField.name);
  writer.writeDateTime(offsets[10], object.updatedAt);
}

SavedFilter _savedFilterDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SavedFilter();
  object.astJson = reader.readStringOrNull(offsets[0]);
  object.charts =
      reader.readObjectList<SavedChart>(
        offsets[1],
        SavedChartSchema.deserialize,
        allOffsets,
        SavedChart(),
      ) ??
      [];
  object.createdAt = reader.readDateTime(offsets[2]);
  object.groupBy =
      _SavedFiltergroupByValueEnumMap[reader.readStringOrNull(offsets[3])] ??
      AhGroupBy.none;
  object.id = id;
  object.kpiSelection = reader.readStringList(offsets[4]) ?? [];
  object.lastUsedAt = reader.readDateTimeOrNull(offsets[5]);
  object.name = reader.readString(offsets[6]);
  object.queryText = reader.readString(offsets[7]);
  object.sortDescending = reader.readBool(offsets[8]);
  object.sortField =
      _SavedFiltersortFieldValueEnumMap[reader.readStringOrNull(offsets[9])] ??
      AhSortField.date;
  object.updatedAt = reader.readDateTime(offsets[10]);
  return object;
}

P _savedFilterDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readObjectList<SavedChart>(
                offset,
                SavedChartSchema.deserialize,
                allOffsets,
                SavedChart(),
              ) ??
              [])
          as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (_SavedFiltergroupByValueEnumMap[reader.readStringOrNull(
                offset,
              )] ??
              AhGroupBy.none)
          as P;
    case 4:
      return (reader.readStringList(offset) ?? []) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (_SavedFiltersortFieldValueEnumMap[reader.readStringOrNull(
                offset,
              )] ??
              AhSortField.date)
          as P;
    case 10:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _SavedFiltergroupByEnumValueMap = {
  r'none': r'none',
  r'category': r'category',
  r'account': r'account',
  r'tag': r'tag',
  r'type': r'type',
  r'source': r'source',
  r'month': r'month',
  r'year': r'year',
};
const _SavedFiltergroupByValueEnumMap = {
  r'none': AhGroupBy.none,
  r'category': AhGroupBy.category,
  r'account': AhGroupBy.account,
  r'tag': AhGroupBy.tag,
  r'type': AhGroupBy.type,
  r'source': AhGroupBy.source,
  r'month': AhGroupBy.month,
  r'year': AhGroupBy.year,
};
const _SavedFiltersortFieldEnumValueMap = {
  r'date': r'date',
  r'amount': r'amount',
  r'category': r'category',
  r'account': r'account',
  r'total': r'total',
  r'count': r'count',
  r'name': r'name',
};
const _SavedFiltersortFieldValueEnumMap = {
  r'date': AhSortField.date,
  r'amount': AhSortField.amount,
  r'category': AhSortField.category,
  r'account': AhSortField.account,
  r'total': AhSortField.total,
  r'count': AhSortField.count,
  r'name': AhSortField.name,
};

Id _savedFilterGetId(SavedFilter object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _savedFilterGetLinks(SavedFilter object) {
  return [];
}

void _savedFilterAttach(
  IsarCollection<dynamic> col,
  Id id,
  SavedFilter object,
) {
  object.id = id;
}

extension SavedFilterByIndex on IsarCollection<SavedFilter> {
  Future<SavedFilter?> getByName(String name) {
    return getByIndex(r'name', [name]);
  }

  SavedFilter? getByNameSync(String name) {
    return getByIndexSync(r'name', [name]);
  }

  Future<bool> deleteByName(String name) {
    return deleteByIndex(r'name', [name]);
  }

  bool deleteByNameSync(String name) {
    return deleteByIndexSync(r'name', [name]);
  }

  Future<List<SavedFilter?>> getAllByName(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return getAllByIndex(r'name', values);
  }

  List<SavedFilter?> getAllByNameSync(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'name', values);
  }

  Future<int> deleteAllByName(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'name', values);
  }

  int deleteAllByNameSync(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'name', values);
  }

  Future<Id> putByName(SavedFilter object) {
    return putByIndex(r'name', object);
  }

  Id putByNameSync(SavedFilter object, {bool saveLinks = true}) {
    return putByIndexSync(r'name', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByName(List<SavedFilter> objects) {
    return putAllByIndex(r'name', objects);
  }

  List<Id> putAllByNameSync(
    List<SavedFilter> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'name', objects, saveLinks: saveLinks);
  }
}

extension SavedFilterQueryWhereSort
    on QueryBuilder<SavedFilter, SavedFilter, QWhere> {
  QueryBuilder<SavedFilter, SavedFilter, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SavedFilterQueryWhere
    on QueryBuilder<SavedFilter, SavedFilter, QWhereClause> {
  QueryBuilder<SavedFilter, SavedFilter, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<SavedFilter, SavedFilter, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterWhereClause> idBetween(
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

  QueryBuilder<SavedFilter, SavedFilter, QAfterWhereClause> nameEqualTo(
    String name,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'name', value: [name]),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterWhereClause> nameNotEqualTo(
    String name,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'name',
                lower: [],
                upper: [name],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'name',
                lower: [name],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'name',
                lower: [name],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'name',
                lower: [],
                upper: [name],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension SavedFilterQueryFilter
    on QueryBuilder<SavedFilter, SavedFilter, QFilterCondition> {
  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  astJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'astJson'),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  astJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'astJson'),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition> astJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'astJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  astJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'astJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition> astJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'astJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition> astJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'astJson',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  astJsonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'astJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition> astJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'astJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition> astJsonContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'astJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition> astJsonMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'astJson',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  astJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'astJson', value: ''),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  astJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'astJson', value: ''),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  chartsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'charts', length, true, length, true);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  chartsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'charts', 0, true, 0, true);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  chartsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'charts', 0, false, 999999, true);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  chartsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'charts', 0, true, length, include);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  chartsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'charts', length, include, 999999, true);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  chartsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'charts',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
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

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
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

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
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

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition> groupByEqualTo(
    AhGroupBy value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'groupBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  groupByGreaterThan(
    AhGroupBy value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'groupBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition> groupByLessThan(
    AhGroupBy value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'groupBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition> groupByBetween(
    AhGroupBy lower,
    AhGroupBy upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'groupBy',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  groupByStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'groupBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition> groupByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'groupBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition> groupByContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'groupBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition> groupByMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'groupBy',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  groupByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'groupBy', value: ''),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  groupByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'groupBy', value: ''),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  kpiSelectionElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'kpiSelection',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  kpiSelectionElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'kpiSelection',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  kpiSelectionElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'kpiSelection',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  kpiSelectionElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'kpiSelection',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  kpiSelectionElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'kpiSelection',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  kpiSelectionElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'kpiSelection',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  kpiSelectionElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'kpiSelection',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  kpiSelectionElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'kpiSelection',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  kpiSelectionElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'kpiSelection', value: ''),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  kpiSelectionElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'kpiSelection', value: ''),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  kpiSelectionLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'kpiSelection', length, true, length, true);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  kpiSelectionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'kpiSelection', 0, true, 0, true);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  kpiSelectionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'kpiSelection', 0, false, 999999, true);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  kpiSelectionLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'kpiSelection', 0, true, length, include);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  kpiSelectionLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'kpiSelection', length, include, 999999, true);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  kpiSelectionLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'kpiSelection',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  lastUsedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastUsedAt'),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  lastUsedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastUsedAt'),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  lastUsedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastUsedAt', value: value),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  lastUsedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastUsedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  lastUsedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastUsedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  lastUsedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastUsedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'name',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition> nameContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition> nameMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'name',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  queryTextEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'queryText',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  queryTextGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'queryText',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  queryTextLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'queryText',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  queryTextBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'queryText',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  queryTextStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'queryText',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  queryTextEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'queryText',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  queryTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'queryText',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  queryTextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'queryText',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  queryTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'queryText', value: ''),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  queryTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'queryText', value: ''),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  sortDescendingEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sortDescending', value: value),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  sortFieldEqualTo(AhSortField value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'sortField',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  sortFieldGreaterThan(
    AhSortField value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sortField',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  sortFieldLessThan(
    AhSortField value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sortField',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  sortFieldBetween(
    AhSortField lower,
    AhSortField upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sortField',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  sortFieldStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'sortField',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  sortFieldEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'sortField',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  sortFieldContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'sortField',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  sortFieldMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'sortField',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  sortFieldIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sortField', value: ''),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  sortFieldIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'sortField', value: ''),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
  updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
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

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
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

  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition>
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

extension SavedFilterQueryObject
    on QueryBuilder<SavedFilter, SavedFilter, QFilterCondition> {
  QueryBuilder<SavedFilter, SavedFilter, QAfterFilterCondition> chartsElement(
    FilterQuery<SavedChart> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'charts');
    });
  }
}

extension SavedFilterQueryLinks
    on QueryBuilder<SavedFilter, SavedFilter, QFilterCondition> {}

extension SavedFilterQuerySortBy
    on QueryBuilder<SavedFilter, SavedFilter, QSortBy> {
  QueryBuilder<SavedFilter, SavedFilter, QAfterSortBy> sortByAstJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'astJson', Sort.asc);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterSortBy> sortByAstJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'astJson', Sort.desc);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterSortBy> sortByGroupBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupBy', Sort.asc);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterSortBy> sortByGroupByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupBy', Sort.desc);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterSortBy> sortByLastUsedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsedAt', Sort.asc);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterSortBy> sortByLastUsedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsedAt', Sort.desc);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterSortBy> sortByQueryText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'queryText', Sort.asc);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterSortBy> sortByQueryTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'queryText', Sort.desc);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterSortBy> sortBySortDescending() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortDescending', Sort.asc);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterSortBy>
  sortBySortDescendingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortDescending', Sort.desc);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterSortBy> sortBySortField() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortField', Sort.asc);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterSortBy> sortBySortFieldDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortField', Sort.desc);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension SavedFilterQuerySortThenBy
    on QueryBuilder<SavedFilter, SavedFilter, QSortThenBy> {
  QueryBuilder<SavedFilter, SavedFilter, QAfterSortBy> thenByAstJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'astJson', Sort.asc);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterSortBy> thenByAstJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'astJson', Sort.desc);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterSortBy> thenByGroupBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupBy', Sort.asc);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterSortBy> thenByGroupByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupBy', Sort.desc);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterSortBy> thenByLastUsedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsedAt', Sort.asc);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterSortBy> thenByLastUsedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsedAt', Sort.desc);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterSortBy> thenByQueryText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'queryText', Sort.asc);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterSortBy> thenByQueryTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'queryText', Sort.desc);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterSortBy> thenBySortDescending() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortDescending', Sort.asc);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterSortBy>
  thenBySortDescendingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortDescending', Sort.desc);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterSortBy> thenBySortField() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortField', Sort.asc);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterSortBy> thenBySortFieldDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortField', Sort.desc);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension SavedFilterQueryWhereDistinct
    on QueryBuilder<SavedFilter, SavedFilter, QDistinct> {
  QueryBuilder<SavedFilter, SavedFilter, QDistinct> distinctByAstJson({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'astJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QDistinct> distinctByGroupBy({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'groupBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QDistinct> distinctByKpiSelection() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kpiSelection');
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QDistinct> distinctByLastUsedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUsedAt');
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QDistinct> distinctByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QDistinct> distinctByQueryText({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'queryText', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QDistinct> distinctBySortDescending() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sortDescending');
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QDistinct> distinctBySortField({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sortField', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedFilter, SavedFilter, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension SavedFilterQueryProperty
    on QueryBuilder<SavedFilter, SavedFilter, QQueryProperty> {
  QueryBuilder<SavedFilter, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SavedFilter, String?, QQueryOperations> astJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'astJson');
    });
  }

  QueryBuilder<SavedFilter, List<SavedChart>, QQueryOperations>
  chartsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'charts');
    });
  }

  QueryBuilder<SavedFilter, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<SavedFilter, AhGroupBy, QQueryOperations> groupByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'groupBy');
    });
  }

  QueryBuilder<SavedFilter, List<String>, QQueryOperations>
  kpiSelectionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kpiSelection');
    });
  }

  QueryBuilder<SavedFilter, DateTime?, QQueryOperations> lastUsedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUsedAt');
    });
  }

  QueryBuilder<SavedFilter, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<SavedFilter, String, QQueryOperations> queryTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'queryText');
    });
  }

  QueryBuilder<SavedFilter, bool, QQueryOperations> sortDescendingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sortDescending');
    });
  }

  QueryBuilder<SavedFilter, AhSortField, QQueryOperations> sortFieldProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sortField');
    });
  }

  QueryBuilder<SavedFilter, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const SavedChartSchema = Schema(
  name: r'SavedChart',
  id: 3709656862381672542,
  properties: {
    r'measure': PropertySchema(
      id: 0,
      name: r'measure',
      type: IsarType.string,
      enumMap: _SavedChartmeasureEnumValueMap,
    ),
    r'order': PropertySchema(id: 1, name: r'order', type: IsarType.long),
    r'split': PropertySchema(
      id: 2,
      name: r'split',
      type: IsarType.string,
      enumMap: _SavedChartsplitEnumValueMap,
    ),
    r'type': PropertySchema(
      id: 3,
      name: r'type',
      type: IsarType.string,
      enumMap: _SavedCharttypeEnumValueMap,
    ),
  },

  estimateSize: _savedChartEstimateSize,
  serialize: _savedChartSerialize,
  deserialize: _savedChartDeserialize,
  deserializeProp: _savedChartDeserializeProp,
);

int _savedChartEstimateSize(
  SavedChart object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.measure.name.length * 3;
  bytesCount += 3 + object.split.name.length * 3;
  bytesCount += 3 + object.type.name.length * 3;
  return bytesCount;
}

void _savedChartSerialize(
  SavedChart object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.measure.name);
  writer.writeLong(offsets[1], object.order);
  writer.writeString(offsets[2], object.split.name);
  writer.writeString(offsets[3], object.type.name);
}

SavedChart _savedChartDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SavedChart();
  object.measure =
      _SavedChartmeasureValueEnumMap[reader.readStringOrNull(offsets[0])] ??
      AhChartMeasure.total;
  object.order = reader.readLong(offsets[1]);
  object.split =
      _SavedChartsplitValueEnumMap[reader.readStringOrNull(offsets[2])] ??
      AhChartSplit.category;
  object.type =
      _SavedCharttypeValueEnumMap[reader.readStringOrNull(offsets[3])] ??
      AhChartType.donut;
  return object;
}

P _savedChartDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (_SavedChartmeasureValueEnumMap[reader.readStringOrNull(offset)] ??
              AhChartMeasure.total)
          as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (_SavedChartsplitValueEnumMap[reader.readStringOrNull(offset)] ??
              AhChartSplit.category)
          as P;
    case 3:
      return (_SavedCharttypeValueEnumMap[reader.readStringOrNull(offset)] ??
              AhChartType.donut)
          as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _SavedChartmeasureEnumValueMap = {
  r'total': r'total',
  r'count': r'count',
  r'average': r'average',
};
const _SavedChartmeasureValueEnumMap = {
  r'total': AhChartMeasure.total,
  r'count': AhChartMeasure.count,
  r'average': AhChartMeasure.average,
};
const _SavedChartsplitEnumValueMap = {
  r'category': r'category',
  r'account': r'account',
  r'tag': r'tag',
  r'type': r'type',
  r'source': r'source',
  r'month': r'month',
  r'year': r'year',
};
const _SavedChartsplitValueEnumMap = {
  r'category': AhChartSplit.category,
  r'account': AhChartSplit.account,
  r'tag': AhChartSplit.tag,
  r'type': AhChartSplit.type,
  r'source': AhChartSplit.source,
  r'month': AhChartSplit.month,
  r'year': AhChartSplit.year,
};
const _SavedCharttypeEnumValueMap = {
  r'donut': r'donut',
  r'bars': r'bars',
  r'line': r'line',
};
const _SavedCharttypeValueEnumMap = {
  r'donut': AhChartType.donut,
  r'bars': AhChartType.bars,
  r'line': AhChartType.line,
};

extension SavedChartQueryFilter
    on QueryBuilder<SavedChart, SavedChart, QFilterCondition> {
  QueryBuilder<SavedChart, SavedChart, QAfterFilterCondition> measureEqualTo(
    AhChartMeasure value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'measure',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedChart, SavedChart, QAfterFilterCondition>
  measureGreaterThan(
    AhChartMeasure value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'measure',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedChart, SavedChart, QAfterFilterCondition> measureLessThan(
    AhChartMeasure value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'measure',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedChart, SavedChart, QAfterFilterCondition> measureBetween(
    AhChartMeasure lower,
    AhChartMeasure upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'measure',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedChart, SavedChart, QAfterFilterCondition> measureStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'measure',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedChart, SavedChart, QAfterFilterCondition> measureEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'measure',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedChart, SavedChart, QAfterFilterCondition> measureContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'measure',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedChart, SavedChart, QAfterFilterCondition> measureMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'measure',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedChart, SavedChart, QAfterFilterCondition> measureIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'measure', value: ''),
      );
    });
  }

  QueryBuilder<SavedChart, SavedChart, QAfterFilterCondition>
  measureIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'measure', value: ''),
      );
    });
  }

  QueryBuilder<SavedChart, SavedChart, QAfterFilterCondition> orderEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'order', value: value),
      );
    });
  }

  QueryBuilder<SavedChart, SavedChart, QAfterFilterCondition> orderGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'order',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SavedChart, SavedChart, QAfterFilterCondition> orderLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'order',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SavedChart, SavedChart, QAfterFilterCondition> orderBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'order',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SavedChart, SavedChart, QAfterFilterCondition> splitEqualTo(
    AhChartSplit value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'split',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedChart, SavedChart, QAfterFilterCondition> splitGreaterThan(
    AhChartSplit value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'split',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedChart, SavedChart, QAfterFilterCondition> splitLessThan(
    AhChartSplit value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'split',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedChart, SavedChart, QAfterFilterCondition> splitBetween(
    AhChartSplit lower,
    AhChartSplit upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'split',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedChart, SavedChart, QAfterFilterCondition> splitStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'split',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedChart, SavedChart, QAfterFilterCondition> splitEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'split',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedChart, SavedChart, QAfterFilterCondition> splitContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'split',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedChart, SavedChart, QAfterFilterCondition> splitMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'split',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedChart, SavedChart, QAfterFilterCondition> splitIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'split', value: ''),
      );
    });
  }

  QueryBuilder<SavedChart, SavedChart, QAfterFilterCondition>
  splitIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'split', value: ''),
      );
    });
  }

  QueryBuilder<SavedChart, SavedChart, QAfterFilterCondition> typeEqualTo(
    AhChartType value, {
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

  QueryBuilder<SavedChart, SavedChart, QAfterFilterCondition> typeGreaterThan(
    AhChartType value, {
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

  QueryBuilder<SavedChart, SavedChart, QAfterFilterCondition> typeLessThan(
    AhChartType value, {
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

  QueryBuilder<SavedChart, SavedChart, QAfterFilterCondition> typeBetween(
    AhChartType lower,
    AhChartType upper, {
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

  QueryBuilder<SavedChart, SavedChart, QAfterFilterCondition> typeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<SavedChart, SavedChart, QAfterFilterCondition> typeEndsWith(
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

  QueryBuilder<SavedChart, SavedChart, QAfterFilterCondition> typeContains(
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

  QueryBuilder<SavedChart, SavedChart, QAfterFilterCondition> typeMatches(
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

  QueryBuilder<SavedChart, SavedChart, QAfterFilterCondition> typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'type', value: ''),
      );
    });
  }

  QueryBuilder<SavedChart, SavedChart, QAfterFilterCondition> typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'type', value: ''),
      );
    });
  }
}

extension SavedChartQueryObject
    on QueryBuilder<SavedChart, SavedChart, QFilterCondition> {}
