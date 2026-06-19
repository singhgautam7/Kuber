// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sms_account_mapping.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSmsAccountMappingCollection on Isar {
  IsarCollection<SmsAccountMapping> get smsAccountMappings => this.collection();
}

const SmsAccountMappingSchema = CollectionSchema(
  name: r'SmsAccountMapping',
  id: 4506085938018179108,
  properties: {
    r'accountId': PropertySchema(
      id: 0,
      name: r'accountId',
      type: IsarType.string,
    ),
    r'lastUsed': PropertySchema(
      id: 1,
      name: r'lastUsed',
      type: IsarType.dateTime,
    ),
    r'senderId': PropertySchema(
      id: 2,
      name: r'senderId',
      type: IsarType.string,
    ),
    r'usageCount': PropertySchema(
      id: 3,
      name: r'usageCount',
      type: IsarType.long,
    ),
  },

  estimateSize: _smsAccountMappingEstimateSize,
  serialize: _smsAccountMappingSerialize,
  deserialize: _smsAccountMappingDeserialize,
  deserializeProp: _smsAccountMappingDeserializeProp,
  idName: r'id',
  indexes: {
    r'senderId': IndexSchema(
      id: -1619654757968658561,
      name: r'senderId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'senderId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _smsAccountMappingGetId,
  getLinks: _smsAccountMappingGetLinks,
  attach: _smsAccountMappingAttach,
  version: '3.3.2',
);

int _smsAccountMappingEstimateSize(
  SmsAccountMapping object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.accountId.length * 3;
  bytesCount += 3 + object.senderId.length * 3;
  return bytesCount;
}

void _smsAccountMappingSerialize(
  SmsAccountMapping object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.accountId);
  writer.writeDateTime(offsets[1], object.lastUsed);
  writer.writeString(offsets[2], object.senderId);
  writer.writeLong(offsets[3], object.usageCount);
}

SmsAccountMapping _smsAccountMappingDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SmsAccountMapping();
  object.accountId = reader.readString(offsets[0]);
  object.id = id;
  object.lastUsed = reader.readDateTime(offsets[1]);
  object.senderId = reader.readString(offsets[2]);
  object.usageCount = reader.readLong(offsets[3]);
  return object;
}

P _smsAccountMappingDeserializeProp<P>(
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
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _smsAccountMappingGetId(SmsAccountMapping object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _smsAccountMappingGetLinks(
  SmsAccountMapping object,
) {
  return [];
}

void _smsAccountMappingAttach(
  IsarCollection<dynamic> col,
  Id id,
  SmsAccountMapping object,
) {
  object.id = id;
}

extension SmsAccountMappingByIndex on IsarCollection<SmsAccountMapping> {
  Future<SmsAccountMapping?> getBySenderId(String senderId) {
    return getByIndex(r'senderId', [senderId]);
  }

  SmsAccountMapping? getBySenderIdSync(String senderId) {
    return getByIndexSync(r'senderId', [senderId]);
  }

  Future<bool> deleteBySenderId(String senderId) {
    return deleteByIndex(r'senderId', [senderId]);
  }

  bool deleteBySenderIdSync(String senderId) {
    return deleteByIndexSync(r'senderId', [senderId]);
  }

  Future<List<SmsAccountMapping?>> getAllBySenderId(
    List<String> senderIdValues,
  ) {
    final values = senderIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'senderId', values);
  }

  List<SmsAccountMapping?> getAllBySenderIdSync(List<String> senderIdValues) {
    final values = senderIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'senderId', values);
  }

  Future<int> deleteAllBySenderId(List<String> senderIdValues) {
    final values = senderIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'senderId', values);
  }

  int deleteAllBySenderIdSync(List<String> senderIdValues) {
    final values = senderIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'senderId', values);
  }

  Future<Id> putBySenderId(SmsAccountMapping object) {
    return putByIndex(r'senderId', object);
  }

  Id putBySenderIdSync(SmsAccountMapping object, {bool saveLinks = true}) {
    return putByIndexSync(r'senderId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySenderId(List<SmsAccountMapping> objects) {
    return putAllByIndex(r'senderId', objects);
  }

  List<Id> putAllBySenderIdSync(
    List<SmsAccountMapping> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'senderId', objects, saveLinks: saveLinks);
  }
}

extension SmsAccountMappingQueryWhereSort
    on QueryBuilder<SmsAccountMapping, SmsAccountMapping, QWhere> {
  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SmsAccountMappingQueryWhere
    on QueryBuilder<SmsAccountMapping, SmsAccountMapping, QWhereClause> {
  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterWhereClause>
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

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterWhereClause>
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

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterWhereClause>
  senderIdEqualTo(String senderId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'senderId', value: [senderId]),
      );
    });
  }

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterWhereClause>
  senderIdNotEqualTo(String senderId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'senderId',
                lower: [],
                upper: [senderId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'senderId',
                lower: [senderId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'senderId',
                lower: [senderId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'senderId',
                lower: [],
                upper: [senderId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension SmsAccountMappingQueryFilter
    on QueryBuilder<SmsAccountMapping, SmsAccountMapping, QFilterCondition> {
  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterFilterCondition>
  accountIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'accountId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterFilterCondition>
  accountIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'accountId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterFilterCondition>
  accountIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'accountId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterFilterCondition>
  accountIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'accountId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterFilterCondition>
  accountIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'accountId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterFilterCondition>
  accountIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'accountId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterFilterCondition>
  accountIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'accountId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterFilterCondition>
  accountIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'accountId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterFilterCondition>
  accountIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'accountId', value: ''),
      );
    });
  }

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterFilterCondition>
  accountIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'accountId', value: ''),
      );
    });
  }

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterFilterCondition>
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

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterFilterCondition>
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

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterFilterCondition>
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

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterFilterCondition>
  lastUsedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastUsed', value: value),
      );
    });
  }

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterFilterCondition>
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

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterFilterCondition>
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

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterFilterCondition>
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

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterFilterCondition>
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

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterFilterCondition>
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

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterFilterCondition>
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

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterFilterCondition>
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

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterFilterCondition>
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

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterFilterCondition>
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

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterFilterCondition>
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

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterFilterCondition>
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

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterFilterCondition>
  senderIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'senderId', value: ''),
      );
    });
  }

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterFilterCondition>
  senderIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'senderId', value: ''),
      );
    });
  }

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterFilterCondition>
  usageCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'usageCount', value: value),
      );
    });
  }

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterFilterCondition>
  usageCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'usageCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterFilterCondition>
  usageCountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'usageCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterFilterCondition>
  usageCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'usageCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension SmsAccountMappingQueryObject
    on QueryBuilder<SmsAccountMapping, SmsAccountMapping, QFilterCondition> {}

extension SmsAccountMappingQueryLinks
    on QueryBuilder<SmsAccountMapping, SmsAccountMapping, QFilterCondition> {}

extension SmsAccountMappingQuerySortBy
    on QueryBuilder<SmsAccountMapping, SmsAccountMapping, QSortBy> {
  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterSortBy>
  sortByAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountId', Sort.asc);
    });
  }

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterSortBy>
  sortByAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountId', Sort.desc);
    });
  }

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterSortBy>
  sortByLastUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsed', Sort.asc);
    });
  }

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterSortBy>
  sortByLastUsedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsed', Sort.desc);
    });
  }

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterSortBy>
  sortBySenderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.asc);
    });
  }

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterSortBy>
  sortBySenderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.desc);
    });
  }

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterSortBy>
  sortByUsageCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usageCount', Sort.asc);
    });
  }

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterSortBy>
  sortByUsageCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usageCount', Sort.desc);
    });
  }
}

extension SmsAccountMappingQuerySortThenBy
    on QueryBuilder<SmsAccountMapping, SmsAccountMapping, QSortThenBy> {
  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterSortBy>
  thenByAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountId', Sort.asc);
    });
  }

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterSortBy>
  thenByAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountId', Sort.desc);
    });
  }

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterSortBy>
  thenByLastUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsed', Sort.asc);
    });
  }

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterSortBy>
  thenByLastUsedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsed', Sort.desc);
    });
  }

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterSortBy>
  thenBySenderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.asc);
    });
  }

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterSortBy>
  thenBySenderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.desc);
    });
  }

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterSortBy>
  thenByUsageCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usageCount', Sort.asc);
    });
  }

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QAfterSortBy>
  thenByUsageCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usageCount', Sort.desc);
    });
  }
}

extension SmsAccountMappingQueryWhereDistinct
    on QueryBuilder<SmsAccountMapping, SmsAccountMapping, QDistinct> {
  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QDistinct>
  distinctByAccountId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'accountId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QDistinct>
  distinctByLastUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUsed');
    });
  }

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QDistinct>
  distinctBySenderId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'senderId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmsAccountMapping, SmsAccountMapping, QDistinct>
  distinctByUsageCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'usageCount');
    });
  }
}

extension SmsAccountMappingQueryProperty
    on QueryBuilder<SmsAccountMapping, SmsAccountMapping, QQueryProperty> {
  QueryBuilder<SmsAccountMapping, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SmsAccountMapping, String, QQueryOperations>
  accountIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'accountId');
    });
  }

  QueryBuilder<SmsAccountMapping, DateTime, QQueryOperations>
  lastUsedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUsed');
    });
  }

  QueryBuilder<SmsAccountMapping, String, QQueryOperations> senderIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'senderId');
    });
  }

  QueryBuilder<SmsAccountMapping, int, QQueryOperations> usageCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'usageCount');
    });
  }
}
