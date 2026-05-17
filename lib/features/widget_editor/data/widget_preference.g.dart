// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'widget_preference.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetWidgetPreferenceCollection on Isar {
  IsarCollection<WidgetPreference> get widgetPreferences => this.collection();
}

const WidgetPreferenceSchema = CollectionSchema(
  name: r'WidgetPreference',
  id: 8437055771455405580,
  properties: {
    r'enabled': PropertySchema(id: 0, name: r'enabled', type: IsarType.bool),
    r'order': PropertySchema(id: 1, name: r'order', type: IsarType.long),
    r'scope': PropertySchema(id: 2, name: r'scope', type: IsarType.string),
    r'widgetKey': PropertySchema(
      id: 3,
      name: r'widgetKey',
      type: IsarType.string,
    ),
  },

  estimateSize: _widgetPreferenceEstimateSize,
  serialize: _widgetPreferenceSerialize,
  deserialize: _widgetPreferenceDeserialize,
  deserializeProp: _widgetPreferenceDeserializeProp,
  idName: r'id',
  indexes: {
    r'scope': IndexSchema(
      id: 152078781581678656,
      name: r'scope',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'scope',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _widgetPreferenceGetId,
  getLinks: _widgetPreferenceGetLinks,
  attach: _widgetPreferenceAttach,
  version: '3.3.2',
);

int _widgetPreferenceEstimateSize(
  WidgetPreference object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.scope.length * 3;
  bytesCount += 3 + object.widgetKey.length * 3;
  return bytesCount;
}

void _widgetPreferenceSerialize(
  WidgetPreference object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.enabled);
  writer.writeLong(offsets[1], object.order);
  writer.writeString(offsets[2], object.scope);
  writer.writeString(offsets[3], object.widgetKey);
}

WidgetPreference _widgetPreferenceDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WidgetPreference();
  object.enabled = reader.readBool(offsets[0]);
  object.id = id;
  object.order = reader.readLong(offsets[1]);
  object.scope = reader.readString(offsets[2]);
  object.widgetKey = reader.readString(offsets[3]);
  return object;
}

P _widgetPreferenceDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _widgetPreferenceGetId(WidgetPreference object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _widgetPreferenceGetLinks(WidgetPreference object) {
  return [];
}

void _widgetPreferenceAttach(
  IsarCollection<dynamic> col,
  Id id,
  WidgetPreference object,
) {
  object.id = id;
}

extension WidgetPreferenceQueryWhereSort
    on QueryBuilder<WidgetPreference, WidgetPreference, QWhere> {
  QueryBuilder<WidgetPreference, WidgetPreference, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension WidgetPreferenceQueryWhere
    on QueryBuilder<WidgetPreference, WidgetPreference, QWhereClause> {
  QueryBuilder<WidgetPreference, WidgetPreference, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterWhereClause>
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

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterWhereClause> idBetween(
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

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterWhereClause>
  scopeEqualTo(String scope) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'scope', value: [scope]),
      );
    });
  }

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterWhereClause>
  scopeNotEqualTo(String scope) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'scope',
                lower: [],
                upper: [scope],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'scope',
                lower: [scope],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'scope',
                lower: [scope],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'scope',
                lower: [],
                upper: [scope],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension WidgetPreferenceQueryFilter
    on QueryBuilder<WidgetPreference, WidgetPreference, QFilterCondition> {
  QueryBuilder<WidgetPreference, WidgetPreference, QAfterFilterCondition>
  enabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'enabled', value: value),
      );
    });
  }

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterFilterCondition>
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

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterFilterCondition>
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

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterFilterCondition>
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

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterFilterCondition>
  orderEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'order', value: value),
      );
    });
  }

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterFilterCondition>
  orderGreaterThan(int value, {bool include = false}) {
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

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterFilterCondition>
  orderLessThan(int value, {bool include = false}) {
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

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterFilterCondition>
  orderBetween(
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

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterFilterCondition>
  scopeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'scope',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterFilterCondition>
  scopeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'scope',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterFilterCondition>
  scopeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'scope',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterFilterCondition>
  scopeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'scope',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterFilterCondition>
  scopeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'scope',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterFilterCondition>
  scopeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'scope',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterFilterCondition>
  scopeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'scope',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterFilterCondition>
  scopeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'scope',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterFilterCondition>
  scopeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'scope', value: ''),
      );
    });
  }

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterFilterCondition>
  scopeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'scope', value: ''),
      );
    });
  }

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterFilterCondition>
  widgetKeyEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'widgetKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterFilterCondition>
  widgetKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'widgetKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterFilterCondition>
  widgetKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'widgetKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterFilterCondition>
  widgetKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'widgetKey',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterFilterCondition>
  widgetKeyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'widgetKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterFilterCondition>
  widgetKeyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'widgetKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterFilterCondition>
  widgetKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'widgetKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterFilterCondition>
  widgetKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'widgetKey',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterFilterCondition>
  widgetKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'widgetKey', value: ''),
      );
    });
  }

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterFilterCondition>
  widgetKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'widgetKey', value: ''),
      );
    });
  }
}

extension WidgetPreferenceQueryObject
    on QueryBuilder<WidgetPreference, WidgetPreference, QFilterCondition> {}

extension WidgetPreferenceQueryLinks
    on QueryBuilder<WidgetPreference, WidgetPreference, QFilterCondition> {}

extension WidgetPreferenceQuerySortBy
    on QueryBuilder<WidgetPreference, WidgetPreference, QSortBy> {
  QueryBuilder<WidgetPreference, WidgetPreference, QAfterSortBy>
  sortByEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.asc);
    });
  }

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterSortBy>
  sortByEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.desc);
    });
  }

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterSortBy> sortByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.asc);
    });
  }

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterSortBy>
  sortByOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.desc);
    });
  }

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterSortBy> sortByScope() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scope', Sort.asc);
    });
  }

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterSortBy>
  sortByScopeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scope', Sort.desc);
    });
  }

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterSortBy>
  sortByWidgetKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'widgetKey', Sort.asc);
    });
  }

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterSortBy>
  sortByWidgetKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'widgetKey', Sort.desc);
    });
  }
}

extension WidgetPreferenceQuerySortThenBy
    on QueryBuilder<WidgetPreference, WidgetPreference, QSortThenBy> {
  QueryBuilder<WidgetPreference, WidgetPreference, QAfterSortBy>
  thenByEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.asc);
    });
  }

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterSortBy>
  thenByEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.desc);
    });
  }

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterSortBy> thenByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.asc);
    });
  }

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterSortBy>
  thenByOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.desc);
    });
  }

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterSortBy> thenByScope() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scope', Sort.asc);
    });
  }

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterSortBy>
  thenByScopeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scope', Sort.desc);
    });
  }

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterSortBy>
  thenByWidgetKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'widgetKey', Sort.asc);
    });
  }

  QueryBuilder<WidgetPreference, WidgetPreference, QAfterSortBy>
  thenByWidgetKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'widgetKey', Sort.desc);
    });
  }
}

extension WidgetPreferenceQueryWhereDistinct
    on QueryBuilder<WidgetPreference, WidgetPreference, QDistinct> {
  QueryBuilder<WidgetPreference, WidgetPreference, QDistinct>
  distinctByEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enabled');
    });
  }

  QueryBuilder<WidgetPreference, WidgetPreference, QDistinct>
  distinctByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'order');
    });
  }

  QueryBuilder<WidgetPreference, WidgetPreference, QDistinct> distinctByScope({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scope', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WidgetPreference, WidgetPreference, QDistinct>
  distinctByWidgetKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'widgetKey', caseSensitive: caseSensitive);
    });
  }
}

extension WidgetPreferenceQueryProperty
    on QueryBuilder<WidgetPreference, WidgetPreference, QQueryProperty> {
  QueryBuilder<WidgetPreference, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<WidgetPreference, bool, QQueryOperations> enabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enabled');
    });
  }

  QueryBuilder<WidgetPreference, int, QQueryOperations> orderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'order');
    });
  }

  QueryBuilder<WidgetPreference, String, QQueryOperations> scopeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scope');
    });
  }

  QueryBuilder<WidgetPreference, String, QQueryOperations> widgetKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'widgetKey');
    });
  }
}
