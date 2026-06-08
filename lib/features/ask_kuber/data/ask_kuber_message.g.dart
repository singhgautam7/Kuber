// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ask_kuber_message.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAskKuberMessageCollection on Isar {
  IsarCollection<AskKuberMessage> get askKuberMessages => this.collection();
}

const AskKuberMessageSchema = CollectionSchema(
  name: r'AskKuberMessage',
  id: 1179371967848722967,
  properties: {
    r'isUser': PropertySchema(id: 0, name: r'isUser', type: IsarType.bool),
    r'metadataJson': PropertySchema(
      id: 1,
      name: r'metadataJson',
      type: IsarType.string,
    ),
    r'text': PropertySchema(id: 2, name: r'text', type: IsarType.string),
    r'thinkingJson': PropertySchema(
      id: 3,
      name: r'thinkingJson',
      type: IsarType.string,
    ),
    r'time': PropertySchema(id: 4, name: r'time', type: IsarType.dateTime),
    r'vizJson': PropertySchema(id: 5, name: r'vizJson', type: IsarType.string),
  },

  estimateSize: _askKuberMessageEstimateSize,
  serialize: _askKuberMessageSerialize,
  deserialize: _askKuberMessageDeserialize,
  deserializeProp: _askKuberMessageDeserializeProp,
  idName: r'id',
  indexes: {
    r'time': IndexSchema(
      id: -2250472054110640942,
      name: r'time',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'time',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _askKuberMessageGetId,
  getLinks: _askKuberMessageGetLinks,
  attach: _askKuberMessageAttach,
  version: '3.3.2',
);

int _askKuberMessageEstimateSize(
  AskKuberMessage object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.metadataJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.text.length * 3;
  {
    final value = object.thinkingJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.vizJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _askKuberMessageSerialize(
  AskKuberMessage object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.isUser);
  writer.writeString(offsets[1], object.metadataJson);
  writer.writeString(offsets[2], object.text);
  writer.writeString(offsets[3], object.thinkingJson);
  writer.writeDateTime(offsets[4], object.time);
  writer.writeString(offsets[5], object.vizJson);
}

AskKuberMessage _askKuberMessageDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AskKuberMessage();
  object.id = id;
  object.isUser = reader.readBool(offsets[0]);
  object.metadataJson = reader.readStringOrNull(offsets[1]);
  object.text = reader.readString(offsets[2]);
  object.thinkingJson = reader.readStringOrNull(offsets[3]);
  object.time = reader.readDateTime(offsets[4]);
  object.vizJson = reader.readStringOrNull(offsets[5]);
  return object;
}

P _askKuberMessageDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _askKuberMessageGetId(AskKuberMessage object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _askKuberMessageGetLinks(AskKuberMessage object) {
  return [];
}

void _askKuberMessageAttach(
  IsarCollection<dynamic> col,
  Id id,
  AskKuberMessage object,
) {
  object.id = id;
}

extension AskKuberMessageQueryWhereSort
    on QueryBuilder<AskKuberMessage, AskKuberMessage, QWhere> {
  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterWhere> anyTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'time'),
      );
    });
  }
}

extension AskKuberMessageQueryWhere
    on QueryBuilder<AskKuberMessage, AskKuberMessage, QWhereClause> {
  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterWhereClause>
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

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterWhereClause> idBetween(
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

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterWhereClause> timeEqualTo(
    DateTime time,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'time', value: [time]),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterWhereClause>
  timeNotEqualTo(DateTime time) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'time',
                lower: [],
                upper: [time],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'time',
                lower: [time],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'time',
                lower: [time],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'time',
                lower: [],
                upper: [time],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterWhereClause>
  timeGreaterThan(DateTime time, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'time',
          lower: [time],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterWhereClause>
  timeLessThan(DateTime time, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'time',
          lower: [],
          upper: [time],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterWhereClause> timeBetween(
    DateTime lowerTime,
    DateTime upperTime, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'time',
          lower: [lowerTime],
          includeLower: includeLower,
          upper: [upperTime],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension AskKuberMessageQueryFilter
    on QueryBuilder<AskKuberMessage, AskKuberMessage, QFilterCondition> {
  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
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

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
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

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
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

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  isUserEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isUser', value: value),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  metadataJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'metadataJson'),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  metadataJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'metadataJson'),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  metadataJsonEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'metadataJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  metadataJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'metadataJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  metadataJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'metadataJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  metadataJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'metadataJson',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  metadataJsonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'metadataJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  metadataJsonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'metadataJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  metadataJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'metadataJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  metadataJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'metadataJson',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  metadataJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'metadataJson', value: ''),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  metadataJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'metadataJson', value: ''),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  textEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'text',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  textGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'text',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  textLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'text',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  textBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'text',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  textStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'text',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  textEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'text',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  textContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'text',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  textMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'text',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  textIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'text', value: ''),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  textIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'text', value: ''),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  thinkingJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'thinkingJson'),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  thinkingJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'thinkingJson'),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  thinkingJsonEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'thinkingJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  thinkingJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'thinkingJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  thinkingJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'thinkingJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  thinkingJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'thinkingJson',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  thinkingJsonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'thinkingJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  thinkingJsonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'thinkingJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  thinkingJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'thinkingJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  thinkingJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'thinkingJson',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  thinkingJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'thinkingJson', value: ''),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  thinkingJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'thinkingJson', value: ''),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  timeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'time', value: value),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  timeGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'time',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  timeLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'time',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  timeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'time',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  vizJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'vizJson'),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  vizJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'vizJson'),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  vizJsonEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'vizJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  vizJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'vizJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  vizJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'vizJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  vizJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'vizJson',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  vizJsonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'vizJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  vizJsonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'vizJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  vizJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'vizJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  vizJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'vizJson',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  vizJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'vizJson', value: ''),
      );
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterFilterCondition>
  vizJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'vizJson', value: ''),
      );
    });
  }
}

extension AskKuberMessageQueryObject
    on QueryBuilder<AskKuberMessage, AskKuberMessage, QFilterCondition> {}

extension AskKuberMessageQueryLinks
    on QueryBuilder<AskKuberMessage, AskKuberMessage, QFilterCondition> {}

extension AskKuberMessageQuerySortBy
    on QueryBuilder<AskKuberMessage, AskKuberMessage, QSortBy> {
  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterSortBy> sortByIsUser() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isUser', Sort.asc);
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterSortBy>
  sortByIsUserDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isUser', Sort.desc);
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterSortBy>
  sortByMetadataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metadataJson', Sort.asc);
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterSortBy>
  sortByMetadataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metadataJson', Sort.desc);
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterSortBy> sortByText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.asc);
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterSortBy>
  sortByTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.desc);
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterSortBy>
  sortByThinkingJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thinkingJson', Sort.asc);
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterSortBy>
  sortByThinkingJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thinkingJson', Sort.desc);
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterSortBy> sortByTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.asc);
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterSortBy>
  sortByTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.desc);
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterSortBy> sortByVizJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vizJson', Sort.asc);
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterSortBy>
  sortByVizJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vizJson', Sort.desc);
    });
  }
}

extension AskKuberMessageQuerySortThenBy
    on QueryBuilder<AskKuberMessage, AskKuberMessage, QSortThenBy> {
  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterSortBy> thenByIsUser() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isUser', Sort.asc);
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterSortBy>
  thenByIsUserDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isUser', Sort.desc);
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterSortBy>
  thenByMetadataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metadataJson', Sort.asc);
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterSortBy>
  thenByMetadataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metadataJson', Sort.desc);
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterSortBy> thenByText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.asc);
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterSortBy>
  thenByTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.desc);
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterSortBy>
  thenByThinkingJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thinkingJson', Sort.asc);
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterSortBy>
  thenByThinkingJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thinkingJson', Sort.desc);
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterSortBy> thenByTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.asc);
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterSortBy>
  thenByTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.desc);
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterSortBy> thenByVizJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vizJson', Sort.asc);
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QAfterSortBy>
  thenByVizJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vizJson', Sort.desc);
    });
  }
}

extension AskKuberMessageQueryWhereDistinct
    on QueryBuilder<AskKuberMessage, AskKuberMessage, QDistinct> {
  QueryBuilder<AskKuberMessage, AskKuberMessage, QDistinct> distinctByIsUser() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isUser');
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QDistinct>
  distinctByMetadataJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'metadataJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QDistinct> distinctByText({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'text', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QDistinct>
  distinctByThinkingJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'thinkingJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QDistinct> distinctByTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'time');
    });
  }

  QueryBuilder<AskKuberMessage, AskKuberMessage, QDistinct> distinctByVizJson({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'vizJson', caseSensitive: caseSensitive);
    });
  }
}

extension AskKuberMessageQueryProperty
    on QueryBuilder<AskKuberMessage, AskKuberMessage, QQueryProperty> {
  QueryBuilder<AskKuberMessage, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AskKuberMessage, bool, QQueryOperations> isUserProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isUser');
    });
  }

  QueryBuilder<AskKuberMessage, String?, QQueryOperations>
  metadataJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'metadataJson');
    });
  }

  QueryBuilder<AskKuberMessage, String, QQueryOperations> textProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'text');
    });
  }

  QueryBuilder<AskKuberMessage, String?, QQueryOperations>
  thinkingJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'thinkingJson');
    });
  }

  QueryBuilder<AskKuberMessage, DateTime, QQueryOperations> timeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'time');
    });
  }

  QueryBuilder<AskKuberMessage, String?, QQueryOperations> vizJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'vizJson');
    });
  }
}
