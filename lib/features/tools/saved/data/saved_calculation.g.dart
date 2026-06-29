// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_calculation.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSavedCalculationCollection on Isar {
  IsarCollection<SavedCalculation> get savedCalculations => this.collection();
}

const SavedCalculationSchema = CollectionSchema(
  name: r'SavedCalculation',
  id: 1903584045666688435,
  properties: {
    r'inputsJson': PropertySchema(
      id: 0,
      name: r'inputsJson',
      type: IsarType.string,
    ),
    r'name': PropertySchema(id: 1, name: r'name', type: IsarType.string),
    r'savedAt': PropertySchema(
      id: 2,
      name: r'savedAt',
      type: IsarType.dateTime,
    ),
    r'summary': PropertySchema(id: 3, name: r'summary', type: IsarType.string),
    r'tool': PropertySchema(id: 4, name: r'tool', type: IsarType.string),
    r'updatedAt': PropertySchema(
      id: 5,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _savedCalculationEstimateSize,
  serialize: _savedCalculationSerialize,
  deserialize: _savedCalculationDeserialize,
  deserializeProp: _savedCalculationDeserializeProp,
  idName: r'id',
  indexes: {
    r'tool': IndexSchema(
      id: -7688352298192954665,
      name: r'tool',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'tool',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _savedCalculationGetId,
  getLinks: _savedCalculationGetLinks,
  attach: _savedCalculationAttach,
  version: '3.3.2',
);

int _savedCalculationEstimateSize(
  SavedCalculation object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.inputsJson.length * 3;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.summary.length * 3;
  bytesCount += 3 + object.tool.length * 3;
  return bytesCount;
}

void _savedCalculationSerialize(
  SavedCalculation object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.inputsJson);
  writer.writeString(offsets[1], object.name);
  writer.writeDateTime(offsets[2], object.savedAt);
  writer.writeString(offsets[3], object.summary);
  writer.writeString(offsets[4], object.tool);
  writer.writeDateTime(offsets[5], object.updatedAt);
}

SavedCalculation _savedCalculationDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SavedCalculation();
  object.id = id;
  object.inputsJson = reader.readString(offsets[0]);
  object.name = reader.readString(offsets[1]);
  object.savedAt = reader.readDateTime(offsets[2]);
  object.summary = reader.readString(offsets[3]);
  object.tool = reader.readString(offsets[4]);
  object.updatedAt = reader.readDateTime(offsets[5]);
  return object;
}

P _savedCalculationDeserializeProp<P>(
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
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _savedCalculationGetId(SavedCalculation object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _savedCalculationGetLinks(SavedCalculation object) {
  return [];
}

void _savedCalculationAttach(
  IsarCollection<dynamic> col,
  Id id,
  SavedCalculation object,
) {
  object.id = id;
}

extension SavedCalculationQueryWhereSort
    on QueryBuilder<SavedCalculation, SavedCalculation, QWhere> {
  QueryBuilder<SavedCalculation, SavedCalculation, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SavedCalculationQueryWhere
    on QueryBuilder<SavedCalculation, SavedCalculation, QWhereClause> {
  QueryBuilder<SavedCalculation, SavedCalculation, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterWhereClause>
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

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterWhereClause> idBetween(
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

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterWhereClause>
  toolEqualTo(String tool) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'tool', value: [tool]),
      );
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterWhereClause>
  toolNotEqualTo(String tool) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'tool',
                lower: [],
                upper: [tool],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'tool',
                lower: [tool],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'tool',
                lower: [tool],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'tool',
                lower: [],
                upper: [tool],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension SavedCalculationQueryFilter
    on QueryBuilder<SavedCalculation, SavedCalculation, QFilterCondition> {
  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
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

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
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

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
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

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
  inputsJsonEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'inputsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
  inputsJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'inputsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
  inputsJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'inputsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
  inputsJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'inputsJson',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
  inputsJsonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'inputsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
  inputsJsonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'inputsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
  inputsJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'inputsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
  inputsJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'inputsJson',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
  inputsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'inputsJson', value: ''),
      );
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
  inputsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'inputsJson', value: ''),
      );
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
  nameEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
  nameGreaterThan(
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

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
  nameLessThan(
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

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
  nameBetween(
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

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
  nameStartsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
  nameEndsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
  nameContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
  nameMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
  nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
  nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
  savedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'savedAt', value: value),
      );
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
  savedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'savedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
  savedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'savedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
  savedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'savedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
  summaryEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'summary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
  summaryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'summary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
  summaryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'summary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
  summaryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'summary',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
  summaryStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'summary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
  summaryEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'summary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
  summaryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'summary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
  summaryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'summary',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
  summaryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'summary', value: ''),
      );
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
  summaryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'summary', value: ''),
      );
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
  toolEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'tool',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
  toolGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'tool',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
  toolLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'tool',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
  toolBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'tool',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
  toolStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'tool',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
  toolEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'tool',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
  toolContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'tool',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
  toolMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'tool',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
  toolIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'tool', value: ''),
      );
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
  toolIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'tool', value: ''),
      );
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
  updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
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

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
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

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterFilterCondition>
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

extension SavedCalculationQueryObject
    on QueryBuilder<SavedCalculation, SavedCalculation, QFilterCondition> {}

extension SavedCalculationQueryLinks
    on QueryBuilder<SavedCalculation, SavedCalculation, QFilterCondition> {}

extension SavedCalculationQuerySortBy
    on QueryBuilder<SavedCalculation, SavedCalculation, QSortBy> {
  QueryBuilder<SavedCalculation, SavedCalculation, QAfterSortBy>
  sortByInputsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputsJson', Sort.asc);
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterSortBy>
  sortByInputsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputsJson', Sort.desc);
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterSortBy>
  sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterSortBy>
  sortBySavedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAt', Sort.asc);
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterSortBy>
  sortBySavedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAt', Sort.desc);
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterSortBy>
  sortBySummary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'summary', Sort.asc);
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterSortBy>
  sortBySummaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'summary', Sort.desc);
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterSortBy> sortByTool() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tool', Sort.asc);
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterSortBy>
  sortByToolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tool', Sort.desc);
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterSortBy>
  sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension SavedCalculationQuerySortThenBy
    on QueryBuilder<SavedCalculation, SavedCalculation, QSortThenBy> {
  QueryBuilder<SavedCalculation, SavedCalculation, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterSortBy>
  thenByInputsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputsJson', Sort.asc);
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterSortBy>
  thenByInputsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputsJson', Sort.desc);
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterSortBy>
  thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterSortBy>
  thenBySavedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAt', Sort.asc);
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterSortBy>
  thenBySavedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAt', Sort.desc);
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterSortBy>
  thenBySummary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'summary', Sort.asc);
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterSortBy>
  thenBySummaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'summary', Sort.desc);
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterSortBy> thenByTool() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tool', Sort.asc);
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterSortBy>
  thenByToolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tool', Sort.desc);
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterSortBy>
  thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension SavedCalculationQueryWhereDistinct
    on QueryBuilder<SavedCalculation, SavedCalculation, QDistinct> {
  QueryBuilder<SavedCalculation, SavedCalculation, QDistinct>
  distinctByInputsJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'inputsJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QDistinct> distinctByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QDistinct>
  distinctBySavedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'savedAt');
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QDistinct>
  distinctBySummary({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'summary', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QDistinct> distinctByTool({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tool', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedCalculation, SavedCalculation, QDistinct>
  distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension SavedCalculationQueryProperty
    on QueryBuilder<SavedCalculation, SavedCalculation, QQueryProperty> {
  QueryBuilder<SavedCalculation, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SavedCalculation, String, QQueryOperations>
  inputsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'inputsJson');
    });
  }

  QueryBuilder<SavedCalculation, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<SavedCalculation, DateTime, QQueryOperations> savedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'savedAt');
    });
  }

  QueryBuilder<SavedCalculation, String, QQueryOperations> summaryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'summary');
    });
  }

  QueryBuilder<SavedCalculation, String, QQueryOperations> toolProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tool');
    });
  }

  QueryBuilder<SavedCalculation, DateTime, QQueryOperations>
  updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
