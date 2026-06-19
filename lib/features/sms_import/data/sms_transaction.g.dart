// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sms_transaction.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSmsTransactionCollection on Isar {
  IsarCollection<SmsTransaction> get smsTransactions => this.collection();
}

const SmsTransactionSchema = CollectionSchema(
  name: r'SmsTransaction',
  id: -7210165314188519138,
  properties: {
    r'importedAt': PropertySchema(
      id: 0,
      name: r'importedAt',
      type: IsarType.dateTime,
    ),
    r'importedTransactionId': PropertySchema(
      id: 1,
      name: r'importedTransactionId',
      type: IsarType.string,
    ),
    r'parsedAccountSuffix': PropertySchema(
      id: 2,
      name: r'parsedAccountSuffix',
      type: IsarType.string,
    ),
    r'parsedAmount': PropertySchema(
      id: 3,
      name: r'parsedAmount',
      type: IsarType.double,
    ),
    r'parsedDate': PropertySchema(
      id: 4,
      name: r'parsedDate',
      type: IsarType.dateTime,
    ),
    r'parsedMerchant': PropertySchema(
      id: 5,
      name: r'parsedMerchant',
      type: IsarType.string,
    ),
    r'parsedType': PropertySchema(
      id: 6,
      name: r'parsedType',
      type: IsarType.string,
    ),
    r'patternMatched': PropertySchema(
      id: 7,
      name: r'patternMatched',
      type: IsarType.string,
    ),
    r'rawSms': PropertySchema(id: 8, name: r'rawSms', type: IsarType.string),
    r'rawSmsHash': PropertySchema(
      id: 9,
      name: r'rawSmsHash',
      type: IsarType.string,
    ),
    r'reviewStatus': PropertySchema(
      id: 10,
      name: r'reviewStatus',
      type: IsarType.string,
    ),
    r'senderId': PropertySchema(
      id: 11,
      name: r'senderId',
      type: IsarType.string,
    ),
    r'smsDate': PropertySchema(
      id: 12,
      name: r'smsDate',
      type: IsarType.dateTime,
    ),
    r'suggestedAccountId': PropertySchema(
      id: 13,
      name: r'suggestedAccountId',
      type: IsarType.string,
    ),
    r'suggestedCategoryId': PropertySchema(
      id: 14,
      name: r'suggestedCategoryId',
      type: IsarType.string,
    ),
  },

  estimateSize: _smsTransactionEstimateSize,
  serialize: _smsTransactionSerialize,
  deserialize: _smsTransactionDeserialize,
  deserializeProp: _smsTransactionDeserializeProp,
  idName: r'id',
  indexes: {
    r'rawSmsHash': IndexSchema(
      id: 9025822756451959395,
      name: r'rawSmsHash',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'rawSmsHash',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'reviewStatus': IndexSchema(
      id: -8918604983176032830,
      name: r'reviewStatus',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'reviewStatus',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _smsTransactionGetId,
  getLinks: _smsTransactionGetLinks,
  attach: _smsTransactionAttach,
  version: '3.3.2',
);

int _smsTransactionEstimateSize(
  SmsTransaction object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.importedTransactionId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.parsedAccountSuffix;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.parsedMerchant;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.parsedType.length * 3;
  {
    final value = object.patternMatched;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.rawSms.length * 3;
  bytesCount += 3 + object.rawSmsHash.length * 3;
  bytesCount += 3 + object.reviewStatus.length * 3;
  bytesCount += 3 + object.senderId.length * 3;
  {
    final value = object.suggestedAccountId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.suggestedCategoryId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _smsTransactionSerialize(
  SmsTransaction object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.importedAt);
  writer.writeString(offsets[1], object.importedTransactionId);
  writer.writeString(offsets[2], object.parsedAccountSuffix);
  writer.writeDouble(offsets[3], object.parsedAmount);
  writer.writeDateTime(offsets[4], object.parsedDate);
  writer.writeString(offsets[5], object.parsedMerchant);
  writer.writeString(offsets[6], object.parsedType);
  writer.writeString(offsets[7], object.patternMatched);
  writer.writeString(offsets[8], object.rawSms);
  writer.writeString(offsets[9], object.rawSmsHash);
  writer.writeString(offsets[10], object.reviewStatus);
  writer.writeString(offsets[11], object.senderId);
  writer.writeDateTime(offsets[12], object.smsDate);
  writer.writeString(offsets[13], object.suggestedAccountId);
  writer.writeString(offsets[14], object.suggestedCategoryId);
}

SmsTransaction _smsTransactionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SmsTransaction();
  object.id = id;
  object.importedAt = reader.readDateTimeOrNull(offsets[0]);
  object.importedTransactionId = reader.readStringOrNull(offsets[1]);
  object.parsedAccountSuffix = reader.readStringOrNull(offsets[2]);
  object.parsedAmount = reader.readDouble(offsets[3]);
  object.parsedDate = reader.readDateTime(offsets[4]);
  object.parsedMerchant = reader.readStringOrNull(offsets[5]);
  object.parsedType = reader.readString(offsets[6]);
  object.patternMatched = reader.readStringOrNull(offsets[7]);
  object.rawSms = reader.readString(offsets[8]);
  object.rawSmsHash = reader.readString(offsets[9]);
  object.reviewStatus = reader.readString(offsets[10]);
  object.senderId = reader.readString(offsets[11]);
  object.smsDate = reader.readDateTime(offsets[12]);
  object.suggestedAccountId = reader.readStringOrNull(offsets[13]);
  object.suggestedCategoryId = reader.readStringOrNull(offsets[14]);
  return object;
}

P _smsTransactionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readDateTime(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _smsTransactionGetId(SmsTransaction object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _smsTransactionGetLinks(SmsTransaction object) {
  return [];
}

void _smsTransactionAttach(
  IsarCollection<dynamic> col,
  Id id,
  SmsTransaction object,
) {
  object.id = id;
}

extension SmsTransactionByIndex on IsarCollection<SmsTransaction> {
  Future<SmsTransaction?> getByRawSmsHash(String rawSmsHash) {
    return getByIndex(r'rawSmsHash', [rawSmsHash]);
  }

  SmsTransaction? getByRawSmsHashSync(String rawSmsHash) {
    return getByIndexSync(r'rawSmsHash', [rawSmsHash]);
  }

  Future<bool> deleteByRawSmsHash(String rawSmsHash) {
    return deleteByIndex(r'rawSmsHash', [rawSmsHash]);
  }

  bool deleteByRawSmsHashSync(String rawSmsHash) {
    return deleteByIndexSync(r'rawSmsHash', [rawSmsHash]);
  }

  Future<List<SmsTransaction?>> getAllByRawSmsHash(
    List<String> rawSmsHashValues,
  ) {
    final values = rawSmsHashValues.map((e) => [e]).toList();
    return getAllByIndex(r'rawSmsHash', values);
  }

  List<SmsTransaction?> getAllByRawSmsHashSync(List<String> rawSmsHashValues) {
    final values = rawSmsHashValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'rawSmsHash', values);
  }

  Future<int> deleteAllByRawSmsHash(List<String> rawSmsHashValues) {
    final values = rawSmsHashValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'rawSmsHash', values);
  }

  int deleteAllByRawSmsHashSync(List<String> rawSmsHashValues) {
    final values = rawSmsHashValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'rawSmsHash', values);
  }

  Future<Id> putByRawSmsHash(SmsTransaction object) {
    return putByIndex(r'rawSmsHash', object);
  }

  Id putByRawSmsHashSync(SmsTransaction object, {bool saveLinks = true}) {
    return putByIndexSync(r'rawSmsHash', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByRawSmsHash(List<SmsTransaction> objects) {
    return putAllByIndex(r'rawSmsHash', objects);
  }

  List<Id> putAllByRawSmsHashSync(
    List<SmsTransaction> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'rawSmsHash', objects, saveLinks: saveLinks);
  }
}

extension SmsTransactionQueryWhereSort
    on QueryBuilder<SmsTransaction, SmsTransaction, QWhere> {
  QueryBuilder<SmsTransaction, SmsTransaction, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SmsTransactionQueryWhere
    on QueryBuilder<SmsTransaction, SmsTransaction, QWhereClause> {
  QueryBuilder<SmsTransaction, SmsTransaction, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterWhereClause> idBetween(
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

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterWhereClause>
  rawSmsHashEqualTo(String rawSmsHash) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'rawSmsHash', value: [rawSmsHash]),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterWhereClause>
  rawSmsHashNotEqualTo(String rawSmsHash) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'rawSmsHash',
                lower: [],
                upper: [rawSmsHash],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'rawSmsHash',
                lower: [rawSmsHash],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'rawSmsHash',
                lower: [rawSmsHash],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'rawSmsHash',
                lower: [],
                upper: [rawSmsHash],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterWhereClause>
  reviewStatusEqualTo(String reviewStatus) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'reviewStatus',
          value: [reviewStatus],
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterWhereClause>
  reviewStatusNotEqualTo(String reviewStatus) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'reviewStatus',
                lower: [],
                upper: [reviewStatus],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'reviewStatus',
                lower: [reviewStatus],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'reviewStatus',
                lower: [reviewStatus],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'reviewStatus',
                lower: [],
                upper: [reviewStatus],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension SmsTransactionQueryFilter
    on QueryBuilder<SmsTransaction, SmsTransaction, QFilterCondition> {
  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
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

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
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

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  importedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'importedAt'),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  importedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'importedAt'),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  importedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'importedAt', value: value),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  importedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'importedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  importedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'importedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  importedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'importedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  importedTransactionIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'importedTransactionId'),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  importedTransactionIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'importedTransactionId'),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  importedTransactionIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'importedTransactionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  importedTransactionIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'importedTransactionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  importedTransactionIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'importedTransactionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  importedTransactionIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'importedTransactionId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  importedTransactionIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'importedTransactionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  importedTransactionIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'importedTransactionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  importedTransactionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'importedTransactionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  importedTransactionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'importedTransactionId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  importedTransactionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'importedTransactionId', value: ''),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  importedTransactionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'importedTransactionId',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  parsedAccountSuffixIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'parsedAccountSuffix'),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  parsedAccountSuffixIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'parsedAccountSuffix'),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  parsedAccountSuffixEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'parsedAccountSuffix',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  parsedAccountSuffixGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'parsedAccountSuffix',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  parsedAccountSuffixLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'parsedAccountSuffix',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  parsedAccountSuffixBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'parsedAccountSuffix',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  parsedAccountSuffixStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'parsedAccountSuffix',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  parsedAccountSuffixEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'parsedAccountSuffix',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  parsedAccountSuffixContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'parsedAccountSuffix',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  parsedAccountSuffixMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'parsedAccountSuffix',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  parsedAccountSuffixIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'parsedAccountSuffix', value: ''),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  parsedAccountSuffixIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'parsedAccountSuffix',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  parsedAmountEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'parsedAmount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  parsedAmountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'parsedAmount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  parsedAmountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'parsedAmount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  parsedAmountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'parsedAmount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  parsedDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'parsedDate', value: value),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  parsedDateGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'parsedDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  parsedDateLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'parsedDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  parsedDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'parsedDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  parsedMerchantIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'parsedMerchant'),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  parsedMerchantIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'parsedMerchant'),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  parsedMerchantEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'parsedMerchant',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  parsedMerchantGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'parsedMerchant',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  parsedMerchantLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'parsedMerchant',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  parsedMerchantBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'parsedMerchant',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  parsedMerchantStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'parsedMerchant',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  parsedMerchantEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'parsedMerchant',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  parsedMerchantContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'parsedMerchant',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  parsedMerchantMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'parsedMerchant',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  parsedMerchantIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'parsedMerchant', value: ''),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  parsedMerchantIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'parsedMerchant', value: ''),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  parsedTypeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'parsedType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  parsedTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'parsedType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  parsedTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'parsedType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  parsedTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'parsedType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  parsedTypeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'parsedType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  parsedTypeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'parsedType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  parsedTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'parsedType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  parsedTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'parsedType',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  parsedTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'parsedType', value: ''),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  parsedTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'parsedType', value: ''),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  patternMatchedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'patternMatched'),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  patternMatchedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'patternMatched'),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  patternMatchedEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'patternMatched',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  patternMatchedGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'patternMatched',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  patternMatchedLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'patternMatched',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  patternMatchedBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'patternMatched',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  patternMatchedStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'patternMatched',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  patternMatchedEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'patternMatched',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  patternMatchedContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'patternMatched',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  patternMatchedMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'patternMatched',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  patternMatchedIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'patternMatched', value: ''),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  patternMatchedIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'patternMatched', value: ''),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  rawSmsEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'rawSms',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  rawSmsGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'rawSms',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  rawSmsLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'rawSms',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  rawSmsBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'rawSms',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  rawSmsStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'rawSms',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  rawSmsEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'rawSms',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  rawSmsContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'rawSms',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  rawSmsMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'rawSms',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  rawSmsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'rawSms', value: ''),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  rawSmsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'rawSms', value: ''),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  rawSmsHashEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'rawSmsHash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  rawSmsHashGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'rawSmsHash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  rawSmsHashLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'rawSmsHash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  rawSmsHashBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'rawSmsHash',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  rawSmsHashStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'rawSmsHash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  rawSmsHashEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'rawSmsHash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  rawSmsHashContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'rawSmsHash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  rawSmsHashMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'rawSmsHash',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  rawSmsHashIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'rawSmsHash', value: ''),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  rawSmsHashIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'rawSmsHash', value: ''),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  reviewStatusEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'reviewStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  reviewStatusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'reviewStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  reviewStatusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'reviewStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  reviewStatusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'reviewStatus',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  reviewStatusStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'reviewStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  reviewStatusEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'reviewStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  reviewStatusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'reviewStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  reviewStatusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'reviewStatus',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  reviewStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'reviewStatus', value: ''),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  reviewStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'reviewStatus', value: ''),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  senderIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'senderId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  senderIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'senderId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  senderIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'senderId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  senderIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'senderId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  senderIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'senderId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  senderIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'senderId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  senderIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'senderId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  senderIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'senderId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  senderIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'senderId', value: ''),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  senderIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'senderId', value: ''),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  smsDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'smsDate', value: value),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  smsDateGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'smsDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  smsDateLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'smsDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  smsDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'smsDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  suggestedAccountIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'suggestedAccountId'),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  suggestedAccountIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'suggestedAccountId'),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  suggestedAccountIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'suggestedAccountId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  suggestedAccountIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'suggestedAccountId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  suggestedAccountIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'suggestedAccountId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  suggestedAccountIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'suggestedAccountId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  suggestedAccountIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'suggestedAccountId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  suggestedAccountIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'suggestedAccountId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  suggestedAccountIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'suggestedAccountId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  suggestedAccountIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'suggestedAccountId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  suggestedAccountIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'suggestedAccountId', value: ''),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  suggestedAccountIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'suggestedAccountId', value: ''),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  suggestedCategoryIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'suggestedCategoryId'),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  suggestedCategoryIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'suggestedCategoryId'),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  suggestedCategoryIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'suggestedCategoryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  suggestedCategoryIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'suggestedCategoryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  suggestedCategoryIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'suggestedCategoryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  suggestedCategoryIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'suggestedCategoryId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  suggestedCategoryIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'suggestedCategoryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  suggestedCategoryIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'suggestedCategoryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  suggestedCategoryIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'suggestedCategoryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  suggestedCategoryIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'suggestedCategoryId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  suggestedCategoryIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'suggestedCategoryId', value: ''),
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterFilterCondition>
  suggestedCategoryIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'suggestedCategoryId',
          value: '',
        ),
      );
    });
  }
}

extension SmsTransactionQueryObject
    on QueryBuilder<SmsTransaction, SmsTransaction, QFilterCondition> {}

extension SmsTransactionQueryLinks
    on QueryBuilder<SmsTransaction, SmsTransaction, QFilterCondition> {}

extension SmsTransactionQuerySortBy
    on QueryBuilder<SmsTransaction, SmsTransaction, QSortBy> {
  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  sortByImportedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importedAt', Sort.asc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  sortByImportedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importedAt', Sort.desc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  sortByImportedTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importedTransactionId', Sort.asc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  sortByImportedTransactionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importedTransactionId', Sort.desc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  sortByParsedAccountSuffix() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parsedAccountSuffix', Sort.asc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  sortByParsedAccountSuffixDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parsedAccountSuffix', Sort.desc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  sortByParsedAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parsedAmount', Sort.asc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  sortByParsedAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parsedAmount', Sort.desc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  sortByParsedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parsedDate', Sort.asc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  sortByParsedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parsedDate', Sort.desc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  sortByParsedMerchant() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parsedMerchant', Sort.asc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  sortByParsedMerchantDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parsedMerchant', Sort.desc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  sortByParsedType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parsedType', Sort.asc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  sortByParsedTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parsedType', Sort.desc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  sortByPatternMatched() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'patternMatched', Sort.asc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  sortByPatternMatchedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'patternMatched', Sort.desc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy> sortByRawSms() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawSms', Sort.asc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  sortByRawSmsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawSms', Sort.desc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  sortByRawSmsHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawSmsHash', Sort.asc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  sortByRawSmsHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawSmsHash', Sort.desc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  sortByReviewStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewStatus', Sort.asc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  sortByReviewStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewStatus', Sort.desc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy> sortBySenderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.asc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  sortBySenderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.desc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy> sortBySmsDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'smsDate', Sort.asc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  sortBySmsDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'smsDate', Sort.desc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  sortBySuggestedAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suggestedAccountId', Sort.asc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  sortBySuggestedAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suggestedAccountId', Sort.desc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  sortBySuggestedCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suggestedCategoryId', Sort.asc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  sortBySuggestedCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suggestedCategoryId', Sort.desc);
    });
  }
}

extension SmsTransactionQuerySortThenBy
    on QueryBuilder<SmsTransaction, SmsTransaction, QSortThenBy> {
  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  thenByImportedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importedAt', Sort.asc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  thenByImportedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importedAt', Sort.desc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  thenByImportedTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importedTransactionId', Sort.asc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  thenByImportedTransactionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importedTransactionId', Sort.desc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  thenByParsedAccountSuffix() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parsedAccountSuffix', Sort.asc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  thenByParsedAccountSuffixDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parsedAccountSuffix', Sort.desc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  thenByParsedAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parsedAmount', Sort.asc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  thenByParsedAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parsedAmount', Sort.desc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  thenByParsedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parsedDate', Sort.asc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  thenByParsedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parsedDate', Sort.desc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  thenByParsedMerchant() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parsedMerchant', Sort.asc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  thenByParsedMerchantDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parsedMerchant', Sort.desc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  thenByParsedType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parsedType', Sort.asc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  thenByParsedTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parsedType', Sort.desc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  thenByPatternMatched() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'patternMatched', Sort.asc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  thenByPatternMatchedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'patternMatched', Sort.desc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy> thenByRawSms() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawSms', Sort.asc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  thenByRawSmsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawSms', Sort.desc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  thenByRawSmsHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawSmsHash', Sort.asc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  thenByRawSmsHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawSmsHash', Sort.desc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  thenByReviewStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewStatus', Sort.asc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  thenByReviewStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewStatus', Sort.desc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy> thenBySenderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.asc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  thenBySenderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.desc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy> thenBySmsDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'smsDate', Sort.asc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  thenBySmsDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'smsDate', Sort.desc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  thenBySuggestedAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suggestedAccountId', Sort.asc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  thenBySuggestedAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suggestedAccountId', Sort.desc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  thenBySuggestedCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suggestedCategoryId', Sort.asc);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QAfterSortBy>
  thenBySuggestedCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suggestedCategoryId', Sort.desc);
    });
  }
}

extension SmsTransactionQueryWhereDistinct
    on QueryBuilder<SmsTransaction, SmsTransaction, QDistinct> {
  QueryBuilder<SmsTransaction, SmsTransaction, QDistinct>
  distinctByImportedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'importedAt');
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QDistinct>
  distinctByImportedTransactionId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'importedTransactionId',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QDistinct>
  distinctByParsedAccountSuffix({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'parsedAccountSuffix',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QDistinct>
  distinctByParsedAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'parsedAmount');
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QDistinct>
  distinctByParsedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'parsedDate');
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QDistinct>
  distinctByParsedMerchant({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'parsedMerchant',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QDistinct> distinctByParsedType({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'parsedType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QDistinct>
  distinctByPatternMatched({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'patternMatched',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QDistinct> distinctByRawSms({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rawSms', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QDistinct> distinctByRawSmsHash({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rawSmsHash', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QDistinct>
  distinctByReviewStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reviewStatus', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QDistinct> distinctBySenderId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'senderId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QDistinct> distinctBySmsDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'smsDate');
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QDistinct>
  distinctBySuggestedAccountId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'suggestedAccountId',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<SmsTransaction, SmsTransaction, QDistinct>
  distinctBySuggestedCategoryId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'suggestedCategoryId',
        caseSensitive: caseSensitive,
      );
    });
  }
}

extension SmsTransactionQueryProperty
    on QueryBuilder<SmsTransaction, SmsTransaction, QQueryProperty> {
  QueryBuilder<SmsTransaction, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SmsTransaction, DateTime?, QQueryOperations>
  importedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'importedAt');
    });
  }

  QueryBuilder<SmsTransaction, String?, QQueryOperations>
  importedTransactionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'importedTransactionId');
    });
  }

  QueryBuilder<SmsTransaction, String?, QQueryOperations>
  parsedAccountSuffixProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'parsedAccountSuffix');
    });
  }

  QueryBuilder<SmsTransaction, double, QQueryOperations>
  parsedAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'parsedAmount');
    });
  }

  QueryBuilder<SmsTransaction, DateTime, QQueryOperations>
  parsedDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'parsedDate');
    });
  }

  QueryBuilder<SmsTransaction, String?, QQueryOperations>
  parsedMerchantProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'parsedMerchant');
    });
  }

  QueryBuilder<SmsTransaction, String, QQueryOperations> parsedTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'parsedType');
    });
  }

  QueryBuilder<SmsTransaction, String?, QQueryOperations>
  patternMatchedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'patternMatched');
    });
  }

  QueryBuilder<SmsTransaction, String, QQueryOperations> rawSmsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rawSms');
    });
  }

  QueryBuilder<SmsTransaction, String, QQueryOperations> rawSmsHashProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rawSmsHash');
    });
  }

  QueryBuilder<SmsTransaction, String, QQueryOperations>
  reviewStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reviewStatus');
    });
  }

  QueryBuilder<SmsTransaction, String, QQueryOperations> senderIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'senderId');
    });
  }

  QueryBuilder<SmsTransaction, DateTime, QQueryOperations> smsDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'smsDate');
    });
  }

  QueryBuilder<SmsTransaction, String?, QQueryOperations>
  suggestedAccountIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'suggestedAccountId');
    });
  }

  QueryBuilder<SmsTransaction, String?, QQueryOperations>
  suggestedCategoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'suggestedCategoryId');
    });
  }
}
