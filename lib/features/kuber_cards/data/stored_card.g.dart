// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stored_card.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetStoredCardCollection on Isar {
  IsarCollection<StoredCard> get storedCards => this.collection();
}

const StoredCardSchema = CollectionSchema(
  name: r'StoredCard',
  id: -5476903234549932915,
  properties: {
    r'bankIcon': PropertySchema(
      id: 0,
      name: r'bankIcon',
      type: IsarType.string,
    ),
    r'cardType': PropertySchema(
      id: 1,
      name: r'cardType',
      type: IsarType.string,
    ),
    r'cardholderEnc': PropertySchema(
      id: 2,
      name: r'cardholderEnc',
      type: IsarType.string,
    ),
    r'colorValue': PropertySchema(
      id: 3,
      name: r'colorValue',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 4,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'customFieldsEnc': PropertySchema(
      id: 5,
      name: r'customFieldsEnc',
      type: IsarType.stringList,
    ),
    r'expiryEnc': PropertySchema(
      id: 6,
      name: r'expiryEnc',
      type: IsarType.string,
    ),
    r'isGradient': PropertySchema(
      id: 7,
      name: r'isGradient',
      type: IsarType.bool,
    ),
    r'last4': PropertySchema(id: 8, name: r'last4', type: IsarType.string),
    r'linkedAccountId': PropertySchema(
      id: 9,
      name: r'linkedAccountId',
      type: IsarType.string,
    ),
    r'network': PropertySchema(id: 10, name: r'network', type: IsarType.string),
    r'nickname': PropertySchema(
      id: 11,
      name: r'nickname',
      type: IsarType.string,
    ),
    r'numberEnc': PropertySchema(
      id: 12,
      name: r'numberEnc',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 13,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _storedCardEstimateSize,
  serialize: _storedCardSerialize,
  deserialize: _storedCardDeserialize,
  deserializeProp: _storedCardDeserializeProp,
  idName: r'id',
  indexes: {
    r'createdAt': IndexSchema(
      id: -3433535483987302584,
      name: r'createdAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'createdAt',
          type: IndexType.value,
          caseSensitive: false,
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

  getId: _storedCardGetId,
  getLinks: _storedCardGetLinks,
  attach: _storedCardAttach,
  version: '3.3.2',
);

int _storedCardEstimateSize(
  StoredCard object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.bankIcon;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.cardType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.cardholderEnc;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.customFieldsEnc.length * 3;
  {
    for (var i = 0; i < object.customFieldsEnc.length; i++) {
      final value = object.customFieldsEnc[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.expiryEnc;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.last4;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.linkedAccountId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.network;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.nickname.length * 3;
  {
    final value = object.numberEnc;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _storedCardSerialize(
  StoredCard object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.bankIcon);
  writer.writeString(offsets[1], object.cardType);
  writer.writeString(offsets[2], object.cardholderEnc);
  writer.writeLong(offsets[3], object.colorValue);
  writer.writeDateTime(offsets[4], object.createdAt);
  writer.writeStringList(offsets[5], object.customFieldsEnc);
  writer.writeString(offsets[6], object.expiryEnc);
  writer.writeBool(offsets[7], object.isGradient);
  writer.writeString(offsets[8], object.last4);
  writer.writeString(offsets[9], object.linkedAccountId);
  writer.writeString(offsets[10], object.network);
  writer.writeString(offsets[11], object.nickname);
  writer.writeString(offsets[12], object.numberEnc);
  writer.writeDateTime(offsets[13], object.updatedAt);
}

StoredCard _storedCardDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = StoredCard();
  object.bankIcon = reader.readStringOrNull(offsets[0]);
  object.cardType = reader.readStringOrNull(offsets[1]);
  object.cardholderEnc = reader.readStringOrNull(offsets[2]);
  object.colorValue = reader.readLong(offsets[3]);
  object.createdAt = reader.readDateTime(offsets[4]);
  object.customFieldsEnc = reader.readStringList(offsets[5]) ?? [];
  object.expiryEnc = reader.readStringOrNull(offsets[6]);
  object.id = id;
  object.isGradient = reader.readBool(offsets[7]);
  object.last4 = reader.readStringOrNull(offsets[8]);
  object.linkedAccountId = reader.readStringOrNull(offsets[9]);
  object.network = reader.readStringOrNull(offsets[10]);
  object.nickname = reader.readString(offsets[11]);
  object.numberEnc = reader.readStringOrNull(offsets[12]);
  object.updatedAt = reader.readDateTime(offsets[13]);
  return object;
}

P _storedCardDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readStringList(offset) ?? []) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _storedCardGetId(StoredCard object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _storedCardGetLinks(StoredCard object) {
  return [];
}

void _storedCardAttach(IsarCollection<dynamic> col, Id id, StoredCard object) {
  object.id = id;
}

extension StoredCardQueryWhereSort
    on QueryBuilder<StoredCard, StoredCard, QWhere> {
  QueryBuilder<StoredCard, StoredCard, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterWhere> anyCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'createdAt'),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterWhere> anyUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'updatedAt'),
      );
    });
  }
}

extension StoredCardQueryWhere
    on QueryBuilder<StoredCard, StoredCard, QWhereClause> {
  QueryBuilder<StoredCard, StoredCard, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<StoredCard, StoredCard, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterWhereClause> idBetween(
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

  QueryBuilder<StoredCard, StoredCard, QAfterWhereClause> createdAtEqualTo(
    DateTime createdAt,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'createdAt', value: [createdAt]),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterWhereClause> createdAtNotEqualTo(
    DateTime createdAt,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'createdAt',
                lower: [],
                upper: [createdAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'createdAt',
                lower: [createdAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'createdAt',
                lower: [createdAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'createdAt',
                lower: [],
                upper: [createdAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterWhereClause> createdAtGreaterThan(
    DateTime createdAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'createdAt',
          lower: [createdAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterWhereClause> createdAtLessThan(
    DateTime createdAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'createdAt',
          lower: [],
          upper: [createdAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterWhereClause> createdAtBetween(
    DateTime lowerCreatedAt,
    DateTime upperCreatedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'createdAt',
          lower: [lowerCreatedAt],
          includeLower: includeLower,
          upper: [upperCreatedAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterWhereClause> updatedAtEqualTo(
    DateTime updatedAt,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'updatedAt', value: [updatedAt]),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterWhereClause> updatedAtNotEqualTo(
    DateTime updatedAt,
  ) {
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

  QueryBuilder<StoredCard, StoredCard, QAfterWhereClause> updatedAtGreaterThan(
    DateTime updatedAt, {
    bool include = false,
  }) {
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

  QueryBuilder<StoredCard, StoredCard, QAfterWhereClause> updatedAtLessThan(
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

  QueryBuilder<StoredCard, StoredCard, QAfterWhereClause> updatedAtBetween(
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

extension StoredCardQueryFilter
    on QueryBuilder<StoredCard, StoredCard, QFilterCondition> {
  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> bankIconIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'bankIcon'),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  bankIconIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'bankIcon'),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> bankIconEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'bankIcon',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  bankIconGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'bankIcon',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> bankIconLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'bankIcon',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> bankIconBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'bankIcon',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  bankIconStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'bankIcon',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> bankIconEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'bankIcon',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> bankIconContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'bankIcon',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> bankIconMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'bankIcon',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  bankIconIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'bankIcon', value: ''),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  bankIconIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'bankIcon', value: ''),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> cardTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'cardType'),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  cardTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'cardType'),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> cardTypeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'cardType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  cardTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'cardType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> cardTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'cardType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> cardTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'cardType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  cardTypeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'cardType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> cardTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'cardType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> cardTypeContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'cardType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> cardTypeMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'cardType',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  cardTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'cardType', value: ''),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  cardTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'cardType', value: ''),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  cardholderEncIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'cardholderEnc'),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  cardholderEncIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'cardholderEnc'),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  cardholderEncEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'cardholderEnc',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  cardholderEncGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'cardholderEnc',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  cardholderEncLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'cardholderEnc',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  cardholderEncBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'cardholderEnc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  cardholderEncStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'cardholderEnc',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  cardholderEncEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'cardholderEnc',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  cardholderEncContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'cardholderEnc',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  cardholderEncMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'cardholderEnc',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  cardholderEncIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'cardholderEnc', value: ''),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  cardholderEncIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'cardholderEnc', value: ''),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> colorValueEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'colorValue', value: value),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
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

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
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

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> colorValueBetween(
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

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> createdAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
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

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
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

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  customFieldsEncElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'customFieldsEnc',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  customFieldsEncElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'customFieldsEnc',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  customFieldsEncElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'customFieldsEnc',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  customFieldsEncElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'customFieldsEnc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  customFieldsEncElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'customFieldsEnc',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  customFieldsEncElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'customFieldsEnc',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  customFieldsEncElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'customFieldsEnc',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  customFieldsEncElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'customFieldsEnc',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  customFieldsEncElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'customFieldsEnc', value: ''),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  customFieldsEncElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'customFieldsEnc', value: ''),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  customFieldsEncLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'customFieldsEnc', length, true, length, true);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  customFieldsEncIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'customFieldsEnc', 0, true, 0, true);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  customFieldsEncIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'customFieldsEnc', 0, false, 999999, true);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  customFieldsEncLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'customFieldsEnc', 0, true, length, include);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  customFieldsEncLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'customFieldsEnc',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  customFieldsEncLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'customFieldsEnc',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  expiryEncIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'expiryEnc'),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  expiryEncIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'expiryEnc'),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> expiryEncEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'expiryEnc',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  expiryEncGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'expiryEnc',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> expiryEncLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'expiryEnc',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> expiryEncBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'expiryEnc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  expiryEncStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'expiryEnc',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> expiryEncEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'expiryEnc',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> expiryEncContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'expiryEnc',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> expiryEncMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'expiryEnc',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  expiryEncIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'expiryEnc', value: ''),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  expiryEncIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'expiryEnc', value: ''),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> idBetween(
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

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> isGradientEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isGradient', value: value),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> last4IsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'last4'),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> last4IsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'last4'),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> last4EqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'last4',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> last4GreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'last4',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> last4LessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'last4',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> last4Between(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'last4',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> last4StartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'last4',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> last4EndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'last4',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> last4Contains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'last4',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> last4Matches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'last4',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> last4IsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'last4', value: ''),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  last4IsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'last4', value: ''),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  linkedAccountIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'linkedAccountId'),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  linkedAccountIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'linkedAccountId'),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  linkedAccountIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'linkedAccountId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  linkedAccountIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'linkedAccountId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  linkedAccountIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'linkedAccountId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  linkedAccountIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'linkedAccountId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  linkedAccountIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'linkedAccountId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  linkedAccountIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'linkedAccountId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  linkedAccountIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'linkedAccountId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  linkedAccountIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'linkedAccountId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  linkedAccountIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'linkedAccountId', value: ''),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  linkedAccountIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'linkedAccountId', value: ''),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> networkIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'network'),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  networkIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'network'),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> networkEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'network',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  networkGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'network',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> networkLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'network',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> networkBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'network',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> networkStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'network',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> networkEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'network',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> networkContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'network',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> networkMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'network',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> networkIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'network', value: ''),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  networkIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'network', value: ''),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> nicknameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'nickname',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  nicknameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'nickname',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> nicknameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'nickname',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> nicknameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'nickname',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  nicknameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'nickname',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> nicknameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'nickname',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> nicknameContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'nickname',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> nicknameMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'nickname',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  nicknameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'nickname', value: ''),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  nicknameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'nickname', value: ''),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  numberEncIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'numberEnc'),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  numberEncIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'numberEnc'),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> numberEncEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'numberEnc',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  numberEncGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'numberEnc',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> numberEncLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'numberEnc',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> numberEncBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'numberEnc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  numberEncStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'numberEnc',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> numberEncEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'numberEnc',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> numberEncContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'numberEnc',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> numberEncMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'numberEnc',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  numberEncIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'numberEnc', value: ''),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
  numberEncIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'numberEnc', value: ''),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> updatedAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition>
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

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
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

  QueryBuilder<StoredCard, StoredCard, QAfterFilterCondition> updatedAtBetween(
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

extension StoredCardQueryObject
    on QueryBuilder<StoredCard, StoredCard, QFilterCondition> {}

extension StoredCardQueryLinks
    on QueryBuilder<StoredCard, StoredCard, QFilterCondition> {}

extension StoredCardQuerySortBy
    on QueryBuilder<StoredCard, StoredCard, QSortBy> {
  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> sortByBankIcon() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bankIcon', Sort.asc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> sortByBankIconDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bankIcon', Sort.desc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> sortByCardType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardType', Sort.asc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> sortByCardTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardType', Sort.desc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> sortByCardholderEnc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardholderEnc', Sort.asc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> sortByCardholderEncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardholderEnc', Sort.desc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> sortByColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorValue', Sort.asc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> sortByColorValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorValue', Sort.desc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> sortByExpiryEnc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiryEnc', Sort.asc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> sortByExpiryEncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiryEnc', Sort.desc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> sortByIsGradient() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isGradient', Sort.asc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> sortByIsGradientDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isGradient', Sort.desc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> sortByLast4() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'last4', Sort.asc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> sortByLast4Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'last4', Sort.desc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> sortByLinkedAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedAccountId', Sort.asc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy>
  sortByLinkedAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedAccountId', Sort.desc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> sortByNetwork() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'network', Sort.asc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> sortByNetworkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'network', Sort.desc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> sortByNickname() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nickname', Sort.asc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> sortByNicknameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nickname', Sort.desc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> sortByNumberEnc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numberEnc', Sort.asc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> sortByNumberEncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numberEnc', Sort.desc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension StoredCardQuerySortThenBy
    on QueryBuilder<StoredCard, StoredCard, QSortThenBy> {
  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> thenByBankIcon() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bankIcon', Sort.asc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> thenByBankIconDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bankIcon', Sort.desc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> thenByCardType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardType', Sort.asc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> thenByCardTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardType', Sort.desc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> thenByCardholderEnc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardholderEnc', Sort.asc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> thenByCardholderEncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardholderEnc', Sort.desc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> thenByColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorValue', Sort.asc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> thenByColorValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorValue', Sort.desc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> thenByExpiryEnc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiryEnc', Sort.asc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> thenByExpiryEncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiryEnc', Sort.desc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> thenByIsGradient() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isGradient', Sort.asc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> thenByIsGradientDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isGradient', Sort.desc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> thenByLast4() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'last4', Sort.asc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> thenByLast4Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'last4', Sort.desc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> thenByLinkedAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedAccountId', Sort.asc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy>
  thenByLinkedAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedAccountId', Sort.desc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> thenByNetwork() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'network', Sort.asc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> thenByNetworkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'network', Sort.desc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> thenByNickname() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nickname', Sort.asc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> thenByNicknameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nickname', Sort.desc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> thenByNumberEnc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numberEnc', Sort.asc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> thenByNumberEncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numberEnc', Sort.desc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension StoredCardQueryWhereDistinct
    on QueryBuilder<StoredCard, StoredCard, QDistinct> {
  QueryBuilder<StoredCard, StoredCard, QDistinct> distinctByBankIcon({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bankIcon', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QDistinct> distinctByCardType({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cardType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QDistinct> distinctByCardholderEnc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'cardholderEnc',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QDistinct> distinctByColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'colorValue');
    });
  }

  QueryBuilder<StoredCard, StoredCard, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<StoredCard, StoredCard, QDistinct> distinctByCustomFieldsEnc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'customFieldsEnc');
    });
  }

  QueryBuilder<StoredCard, StoredCard, QDistinct> distinctByExpiryEnc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expiryEnc', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QDistinct> distinctByIsGradient() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isGradient');
    });
  }

  QueryBuilder<StoredCard, StoredCard, QDistinct> distinctByLast4({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'last4', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QDistinct> distinctByLinkedAccountId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'linkedAccountId',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<StoredCard, StoredCard, QDistinct> distinctByNetwork({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'network', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QDistinct> distinctByNickname({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nickname', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QDistinct> distinctByNumberEnc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'numberEnc', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StoredCard, StoredCard, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension StoredCardQueryProperty
    on QueryBuilder<StoredCard, StoredCard, QQueryProperty> {
  QueryBuilder<StoredCard, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<StoredCard, String?, QQueryOperations> bankIconProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bankIcon');
    });
  }

  QueryBuilder<StoredCard, String?, QQueryOperations> cardTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cardType');
    });
  }

  QueryBuilder<StoredCard, String?, QQueryOperations> cardholderEncProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cardholderEnc');
    });
  }

  QueryBuilder<StoredCard, int, QQueryOperations> colorValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'colorValue');
    });
  }

  QueryBuilder<StoredCard, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<StoredCard, List<String>, QQueryOperations>
  customFieldsEncProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'customFieldsEnc');
    });
  }

  QueryBuilder<StoredCard, String?, QQueryOperations> expiryEncProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expiryEnc');
    });
  }

  QueryBuilder<StoredCard, bool, QQueryOperations> isGradientProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isGradient');
    });
  }

  QueryBuilder<StoredCard, String?, QQueryOperations> last4Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'last4');
    });
  }

  QueryBuilder<StoredCard, String?, QQueryOperations>
  linkedAccountIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'linkedAccountId');
    });
  }

  QueryBuilder<StoredCard, String?, QQueryOperations> networkProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'network');
    });
  }

  QueryBuilder<StoredCard, String, QQueryOperations> nicknameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nickname');
    });
  }

  QueryBuilder<StoredCard, String?, QQueryOperations> numberEncProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'numberEnc');
    });
  }

  QueryBuilder<StoredCard, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
