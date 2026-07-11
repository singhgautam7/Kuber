// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pinned_shortcut_pref.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPinnedShortcutPrefCollection on Isar {
  IsarCollection<PinnedShortcutPref> get pinnedShortcutPrefs =>
      this.collection();
}

const PinnedShortcutPrefSchema = CollectionSchema(
  name: r'PinnedShortcutPref',
  id: 694439473919678483,
  properties: {
    r'colorValue': PropertySchema(
      id: 0,
      name: r'colorValue',
      type: IsarType.long,
    ),
    r'order': PropertySchema(id: 1, name: r'order', type: IsarType.long),
    r'shortcutId': PropertySchema(
      id: 2,
      name: r'shortcutId',
      type: IsarType.string,
    ),
  },

  estimateSize: _pinnedShortcutPrefEstimateSize,
  serialize: _pinnedShortcutPrefSerialize,
  deserialize: _pinnedShortcutPrefDeserialize,
  deserializeProp: _pinnedShortcutPrefDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _pinnedShortcutPrefGetId,
  getLinks: _pinnedShortcutPrefGetLinks,
  attach: _pinnedShortcutPrefAttach,
  version: '3.3.2',
);

int _pinnedShortcutPrefEstimateSize(
  PinnedShortcutPref object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.shortcutId.length * 3;
  return bytesCount;
}

void _pinnedShortcutPrefSerialize(
  PinnedShortcutPref object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.colorValue);
  writer.writeLong(offsets[1], object.order);
  writer.writeString(offsets[2], object.shortcutId);
}

PinnedShortcutPref _pinnedShortcutPrefDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PinnedShortcutPref();
  object.colorValue = reader.readLong(offsets[0]);
  object.id = id;
  object.order = reader.readLong(offsets[1]);
  object.shortcutId = reader.readString(offsets[2]);
  return object;
}

P _pinnedShortcutPrefDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _pinnedShortcutPrefGetId(PinnedShortcutPref object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _pinnedShortcutPrefGetLinks(
  PinnedShortcutPref object,
) {
  return [];
}

void _pinnedShortcutPrefAttach(
  IsarCollection<dynamic> col,
  Id id,
  PinnedShortcutPref object,
) {
  object.id = id;
}

extension PinnedShortcutPrefQueryWhereSort
    on QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QWhere> {
  QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PinnedShortcutPrefQueryWhere
    on QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QWhereClause> {
  QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QAfterWhereClause>
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

  QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QAfterWhereClause>
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
}

extension PinnedShortcutPrefQueryFilter
    on QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QFilterCondition> {
  QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QAfterFilterCondition>
  colorValueEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'colorValue', value: value),
      );
    });
  }

  QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QAfterFilterCondition>
  colorValueGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'colorValue',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QAfterFilterCondition>
  colorValueLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'colorValue',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QAfterFilterCondition>
  colorValueBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'colorValue',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QAfterFilterCondition>
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

  QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QAfterFilterCondition>
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

  QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QAfterFilterCondition>
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

  QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QAfterFilterCondition>
  orderEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'order', value: value),
      );
    });
  }

  QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QAfterFilterCondition>
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

  QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QAfterFilterCondition>
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

  QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QAfterFilterCondition>
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

  QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QAfterFilterCondition>
  shortcutIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'shortcutId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QAfterFilterCondition>
  shortcutIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'shortcutId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QAfterFilterCondition>
  shortcutIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'shortcutId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QAfterFilterCondition>
  shortcutIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'shortcutId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QAfterFilterCondition>
  shortcutIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'shortcutId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QAfterFilterCondition>
  shortcutIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'shortcutId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QAfterFilterCondition>
  shortcutIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'shortcutId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QAfterFilterCondition>
  shortcutIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'shortcutId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QAfterFilterCondition>
  shortcutIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'shortcutId', value: ''),
      );
    });
  }

  QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QAfterFilterCondition>
  shortcutIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'shortcutId', value: ''),
      );
    });
  }
}

extension PinnedShortcutPrefQueryObject
    on QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QFilterCondition> {}

extension PinnedShortcutPrefQueryLinks
    on QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QFilterCondition> {}

extension PinnedShortcutPrefQuerySortBy
    on QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QSortBy> {
  QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QAfterSortBy>
  sortByColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorValue', Sort.asc);
    });
  }

  QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QAfterSortBy>
  sortByColorValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorValue', Sort.desc);
    });
  }

  QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QAfterSortBy>
  sortByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.asc);
    });
  }

  QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QAfterSortBy>
  sortByOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.desc);
    });
  }

  QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QAfterSortBy>
  sortByShortcutId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shortcutId', Sort.asc);
    });
  }

  QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QAfterSortBy>
  sortByShortcutIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shortcutId', Sort.desc);
    });
  }
}

extension PinnedShortcutPrefQuerySortThenBy
    on QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QSortThenBy> {
  QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QAfterSortBy>
  thenByColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorValue', Sort.asc);
    });
  }

  QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QAfterSortBy>
  thenByColorValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorValue', Sort.desc);
    });
  }

  QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QAfterSortBy>
  thenByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.asc);
    });
  }

  QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QAfterSortBy>
  thenByOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.desc);
    });
  }

  QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QAfterSortBy>
  thenByShortcutId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shortcutId', Sort.asc);
    });
  }

  QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QAfterSortBy>
  thenByShortcutIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shortcutId', Sort.desc);
    });
  }
}

extension PinnedShortcutPrefQueryWhereDistinct
    on QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QDistinct> {
  QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QDistinct>
  distinctByColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'colorValue');
    });
  }

  QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QDistinct>
  distinctByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'order');
    });
  }

  QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QDistinct>
  distinctByShortcutId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'shortcutId', caseSensitive: caseSensitive);
    });
  }
}

extension PinnedShortcutPrefQueryProperty
    on QueryBuilder<PinnedShortcutPref, PinnedShortcutPref, QQueryProperty> {
  QueryBuilder<PinnedShortcutPref, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PinnedShortcutPref, int, QQueryOperations> colorValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'colorValue');
    });
  }

  QueryBuilder<PinnedShortcutPref, int, QQueryOperations> orderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'order');
    });
  }

  QueryBuilder<PinnedShortcutPref, String, QQueryOperations>
  shortcutIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'shortcutId');
    });
  }
}
