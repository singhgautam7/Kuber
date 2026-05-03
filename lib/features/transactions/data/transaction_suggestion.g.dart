// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_suggestion.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTransactionSuggestionCollection on Isar {
  IsarCollection<TransactionSuggestion> get transactionSuggestions =>
      this.collection();
}

const TransactionSuggestionSchema = CollectionSchema(
  name: r'TransactionSuggestion',
  id: 7947617564229633739,
  properties: {
    r'accountId': PropertySchema(
      id: 0,
      name: r'accountId',
      type: IsarType.string,
    ),
    r'amount': PropertySchema(id: 1, name: r'amount', type: IsarType.double),
    r'categoryId': PropertySchema(
      id: 2,
      name: r'categoryId',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 3,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'displayName': PropertySchema(
      id: 4,
      name: r'displayName',
      type: IsarType.string,
    ),
    r'nameLower': PropertySchema(
      id: 5,
      name: r'nameLower',
      type: IsarType.string,
    ),
    r'type': PropertySchema(id: 6, name: r'type', type: IsarType.string),
    r'updatedAt': PropertySchema(
      id: 7,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _transactionSuggestionEstimateSize,
  serialize: _transactionSuggestionSerialize,
  deserialize: _transactionSuggestionDeserialize,
  deserializeProp: _transactionSuggestionDeserializeProp,
  idName: r'id',
  indexes: {
    r'nameLower': IndexSchema(
      id: 3656088067429520345,
      name: r'nameLower',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'nameLower',
          type: IndexType.hash,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _transactionSuggestionGetId,
  getLinks: _transactionSuggestionGetLinks,
  attach: _transactionSuggestionAttach,
  version: '3.3.2',
);

int _transactionSuggestionEstimateSize(
  TransactionSuggestion object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.accountId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.categoryId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.displayName.length * 3;
  bytesCount += 3 + object.nameLower.length * 3;
  {
    final value = object.type;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _transactionSuggestionSerialize(
  TransactionSuggestion object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.accountId);
  writer.writeDouble(offsets[1], object.amount);
  writer.writeString(offsets[2], object.categoryId);
  writer.writeDateTime(offsets[3], object.createdAt);
  writer.writeString(offsets[4], object.displayName);
  writer.writeString(offsets[5], object.nameLower);
  writer.writeString(offsets[6], object.type);
  writer.writeDateTime(offsets[7], object.updatedAt);
}

TransactionSuggestion _transactionSuggestionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TransactionSuggestion();
  object.accountId = reader.readStringOrNull(offsets[0]);
  object.amount = reader.readDoubleOrNull(offsets[1]);
  object.categoryId = reader.readStringOrNull(offsets[2]);
  object.createdAt = reader.readDateTime(offsets[3]);
  object.displayName = reader.readString(offsets[4]);
  object.id = id;
  object.nameLower = reader.readString(offsets[5]);
  object.type = reader.readStringOrNull(offsets[6]);
  object.updatedAt = reader.readDateTime(offsets[7]);
  return object;
}

P _transactionSuggestionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readDoubleOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _transactionSuggestionGetId(TransactionSuggestion object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _transactionSuggestionGetLinks(
  TransactionSuggestion object,
) {
  return [];
}

void _transactionSuggestionAttach(
  IsarCollection<dynamic> col,
  Id id,
  TransactionSuggestion object,
) {
  object.id = id;
}

extension TransactionSuggestionByIndex
    on IsarCollection<TransactionSuggestion> {
  Future<TransactionSuggestion?> getByNameLower(String nameLower) {
    return getByIndex(r'nameLower', [nameLower]);
  }

  TransactionSuggestion? getByNameLowerSync(String nameLower) {
    return getByIndexSync(r'nameLower', [nameLower]);
  }

  Future<bool> deleteByNameLower(String nameLower) {
    return deleteByIndex(r'nameLower', [nameLower]);
  }

  bool deleteByNameLowerSync(String nameLower) {
    return deleteByIndexSync(r'nameLower', [nameLower]);
  }

  Future<List<TransactionSuggestion?>> getAllByNameLower(
    List<String> nameLowerValues,
  ) {
    final values = nameLowerValues.map((e) => [e]).toList();
    return getAllByIndex(r'nameLower', values);
  }

  List<TransactionSuggestion?> getAllByNameLowerSync(
    List<String> nameLowerValues,
  ) {
    final values = nameLowerValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'nameLower', values);
  }

  Future<int> deleteAllByNameLower(List<String> nameLowerValues) {
    final values = nameLowerValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'nameLower', values);
  }

  int deleteAllByNameLowerSync(List<String> nameLowerValues) {
    final values = nameLowerValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'nameLower', values);
  }

  Future<Id> putByNameLower(TransactionSuggestion object) {
    return putByIndex(r'nameLower', object);
  }

  Id putByNameLowerSync(TransactionSuggestion object, {bool saveLinks = true}) {
    return putByIndexSync(r'nameLower', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByNameLower(List<TransactionSuggestion> objects) {
    return putAllByIndex(r'nameLower', objects);
  }

  List<Id> putAllByNameLowerSync(
    List<TransactionSuggestion> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'nameLower', objects, saveLinks: saveLinks);
  }
}

extension TransactionSuggestionQueryWhereSort
    on QueryBuilder<TransactionSuggestion, TransactionSuggestion, QWhere> {
  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TransactionSuggestionQueryWhere
    on
        QueryBuilder<
          TransactionSuggestion,
          TransactionSuggestion,
          QWhereClause
        > {
  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QAfterWhereClause>
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

  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QAfterWhereClause>
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

  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QAfterWhereClause>
  nameLowerEqualTo(String nameLower) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'nameLower', value: [nameLower]),
      );
    });
  }

  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QAfterWhereClause>
  nameLowerNotEqualTo(String nameLower) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'nameLower',
                lower: [],
                upper: [nameLower],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'nameLower',
                lower: [nameLower],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'nameLower',
                lower: [nameLower],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'nameLower',
                lower: [],
                upper: [nameLower],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension TransactionSuggestionQueryFilter
    on
        QueryBuilder<
          TransactionSuggestion,
          TransactionSuggestion,
          QFilterCondition
        > {
  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  accountIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'accountId'),
      );
    });
  }

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  accountIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'accountId'),
      );
    });
  }

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  accountIdEqualTo(String? value, {bool caseSensitive = true}) {
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

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  accountIdGreaterThan(
    String? value, {
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

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  accountIdLessThan(
    String? value, {
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

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  accountIdBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  accountIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'accountId', value: ''),
      );
    });
  }

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  accountIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'accountId', value: ''),
      );
    });
  }

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  amountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'amount'),
      );
    });
  }

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  amountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'amount'),
      );
    });
  }

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  amountEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'amount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  amountGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'amount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  amountLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'amount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  amountBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'amount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  categoryIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'categoryId'),
      );
    });
  }

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  categoryIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'categoryId'),
      );
    });
  }

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  categoryIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'categoryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  categoryIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'categoryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  categoryIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'categoryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  categoryIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'categoryId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  categoryIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'categoryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  categoryIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'categoryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  categoryIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'categoryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  categoryIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'categoryId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  categoryIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'categoryId', value: ''),
      );
    });
  }

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  categoryIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'categoryId', value: ''),
      );
    });
  }

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  displayNameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'displayName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  displayNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'displayName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  displayNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'displayName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  displayNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'displayName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  displayNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'displayName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  displayNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'displayName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  displayNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'displayName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  displayNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'displayName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  displayNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'displayName', value: ''),
      );
    });
  }

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  displayNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'displayName', value: ''),
      );
    });
  }

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  nameLowerEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'nameLower',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  nameLowerGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'nameLower',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  nameLowerLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'nameLower',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  nameLowerBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'nameLower',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  nameLowerStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'nameLower',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  nameLowerEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'nameLower',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  nameLowerContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'nameLower',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  nameLowerMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'nameLower',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  nameLowerIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'nameLower', value: ''),
      );
    });
  }

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  nameLowerIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'nameLower', value: ''),
      );
    });
  }

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  typeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'type'),
      );
    });
  }

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  typeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'type'),
      );
    });
  }

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  typeEqualTo(String? value, {bool caseSensitive = true}) {
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

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  typeGreaterThan(
    String? value, {
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

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  typeLessThan(
    String? value, {
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

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  typeBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  typeStartsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  typeEndsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  typeContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  typeMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'type', value: ''),
      );
    });
  }

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'type', value: ''),
      );
    });
  }

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
  updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    TransactionSuggestion,
    TransactionSuggestion,
    QAfterFilterCondition
  >
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

extension TransactionSuggestionQueryObject
    on
        QueryBuilder<
          TransactionSuggestion,
          TransactionSuggestion,
          QFilterCondition
        > {}

extension TransactionSuggestionQueryLinks
    on
        QueryBuilder<
          TransactionSuggestion,
          TransactionSuggestion,
          QFilterCondition
        > {}

extension TransactionSuggestionQuerySortBy
    on QueryBuilder<TransactionSuggestion, TransactionSuggestion, QSortBy> {
  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QAfterSortBy>
  sortByAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountId', Sort.asc);
    });
  }

  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QAfterSortBy>
  sortByAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountId', Sort.desc);
    });
  }

  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QAfterSortBy>
  sortByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QAfterSortBy>
  sortByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QAfterSortBy>
  sortByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.asc);
    });
  }

  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QAfterSortBy>
  sortByCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.desc);
    });
  }

  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QAfterSortBy>
  sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QAfterSortBy>
  sortByDisplayName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.asc);
    });
  }

  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QAfterSortBy>
  sortByDisplayNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.desc);
    });
  }

  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QAfterSortBy>
  sortByNameLower() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameLower', Sort.asc);
    });
  }

  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QAfterSortBy>
  sortByNameLowerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameLower', Sort.desc);
    });
  }

  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QAfterSortBy>
  sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QAfterSortBy>
  sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QAfterSortBy>
  sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension TransactionSuggestionQuerySortThenBy
    on QueryBuilder<TransactionSuggestion, TransactionSuggestion, QSortThenBy> {
  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QAfterSortBy>
  thenByAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountId', Sort.asc);
    });
  }

  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QAfterSortBy>
  thenByAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountId', Sort.desc);
    });
  }

  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QAfterSortBy>
  thenByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QAfterSortBy>
  thenByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QAfterSortBy>
  thenByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.asc);
    });
  }

  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QAfterSortBy>
  thenByCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.desc);
    });
  }

  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QAfterSortBy>
  thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QAfterSortBy>
  thenByDisplayName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.asc);
    });
  }

  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QAfterSortBy>
  thenByDisplayNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.desc);
    });
  }

  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QAfterSortBy>
  thenByNameLower() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameLower', Sort.asc);
    });
  }

  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QAfterSortBy>
  thenByNameLowerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameLower', Sort.desc);
    });
  }

  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QAfterSortBy>
  thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QAfterSortBy>
  thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QAfterSortBy>
  thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension TransactionSuggestionQueryWhereDistinct
    on QueryBuilder<TransactionSuggestion, TransactionSuggestion, QDistinct> {
  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QDistinct>
  distinctByAccountId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'accountId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QDistinct>
  distinctByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amount');
    });
  }

  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QDistinct>
  distinctByCategoryId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'categoryId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QDistinct>
  distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QDistinct>
  distinctByDisplayName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'displayName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QDistinct>
  distinctByNameLower({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nameLower', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QDistinct>
  distinctByType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TransactionSuggestion, TransactionSuggestion, QDistinct>
  distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension TransactionSuggestionQueryProperty
    on
        QueryBuilder<
          TransactionSuggestion,
          TransactionSuggestion,
          QQueryProperty
        > {
  QueryBuilder<TransactionSuggestion, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TransactionSuggestion, String?, QQueryOperations>
  accountIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'accountId');
    });
  }

  QueryBuilder<TransactionSuggestion, double?, QQueryOperations>
  amountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amount');
    });
  }

  QueryBuilder<TransactionSuggestion, String?, QQueryOperations>
  categoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'categoryId');
    });
  }

  QueryBuilder<TransactionSuggestion, DateTime, QQueryOperations>
  createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<TransactionSuggestion, String, QQueryOperations>
  displayNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'displayName');
    });
  }

  QueryBuilder<TransactionSuggestion, String, QQueryOperations>
  nameLowerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nameLower');
    });
  }

  QueryBuilder<TransactionSuggestion, String?, QQueryOperations>
  typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }

  QueryBuilder<TransactionSuggestion, DateTime, QQueryOperations>
  updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
