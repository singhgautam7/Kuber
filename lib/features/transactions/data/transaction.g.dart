// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTransactionCollection on Isar {
  IsarCollection<Transaction> get transactions => this.collection();
}

const TransactionSchema = CollectionSchema(
  name: r'Transaction',
  id: 5320225499417954855,
  properties: {
    r'accountId': PropertySchema(
      id: 0,
      name: r'accountId',
      type: IsarType.string,
    ),
    r'amount': PropertySchema(id: 1, name: r'amount', type: IsarType.double),
    r'attachmentPaths': PropertySchema(
      id: 2,
      name: r'attachmentPaths',
      type: IsarType.stringList,
    ),
    r'categoryId': PropertySchema(
      id: 3,
      name: r'categoryId',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 4,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'isBalanceAdjustment': PropertySchema(
      id: 5,
      name: r'isBalanceAdjustment',
      type: IsarType.bool,
    ),
    r'isTransfer': PropertySchema(
      id: 6,
      name: r'isTransfer',
      type: IsarType.bool,
    ),
    r'linkedRuleId': PropertySchema(
      id: 7,
      name: r'linkedRuleId',
      type: IsarType.string,
    ),
    r'linkedRuleType': PropertySchema(
      id: 8,
      name: r'linkedRuleType',
      type: IsarType.string,
    ),
    r'name': PropertySchema(id: 9, name: r'name', type: IsarType.string),
    r'nameLower': PropertySchema(
      id: 10,
      name: r'nameLower',
      type: IsarType.string,
    ),
    r'notes': PropertySchema(id: 11, name: r'notes', type: IsarType.string),
    r'quickAddNote': PropertySchema(
      id: 12,
      name: r'quickAddNote',
      type: IsarType.string,
    ),
    r'transferId': PropertySchema(
      id: 13,
      name: r'transferId',
      type: IsarType.string,
    ),
    r'type': PropertySchema(id: 14, name: r'type', type: IsarType.string),
    r'updatedAt': PropertySchema(
      id: 15,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _transactionEstimateSize,
  serialize: _transactionSerialize,
  deserialize: _transactionDeserialize,
  deserializeProp: _transactionDeserializeProp,
  idName: r'id',
  indexes: {
    r'categoryId_createdAt': IndexSchema(
      id: -8908735139631551607,
      name: r'categoryId_createdAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'categoryId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'createdAt',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'accountId': IndexSchema(
      id: -1591555361937770434,
      name: r'accountId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'accountId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'linkedRuleType': IndexSchema(
      id: -3570016789092828114,
      name: r'linkedRuleType',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'linkedRuleType',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
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
    r'nameLower_updatedAt': IndexSchema(
      id: -8438358242916586077,
      name: r'nameLower_updatedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'nameLower',
          type: IndexType.hash,
          caseSensitive: true,
        ),
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

  getId: _transactionGetId,
  getLinks: _transactionGetLinks,
  attach: _transactionAttach,
  version: '3.3.2',
);

int _transactionEstimateSize(
  Transaction object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.accountId.length * 3;
  bytesCount += 3 + object.attachmentPaths.length * 3;
  {
    for (var i = 0; i < object.attachmentPaths.length; i++) {
      final value = object.attachmentPaths[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.categoryId.length * 3;
  {
    final value = object.linkedRuleId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.linkedRuleType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.nameLower.length * 3;
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.quickAddNote;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.transferId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.type.length * 3;
  return bytesCount;
}

void _transactionSerialize(
  Transaction object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.accountId);
  writer.writeDouble(offsets[1], object.amount);
  writer.writeStringList(offsets[2], object.attachmentPaths);
  writer.writeString(offsets[3], object.categoryId);
  writer.writeDateTime(offsets[4], object.createdAt);
  writer.writeBool(offsets[5], object.isBalanceAdjustment);
  writer.writeBool(offsets[6], object.isTransfer);
  writer.writeString(offsets[7], object.linkedRuleId);
  writer.writeString(offsets[8], object.linkedRuleType);
  writer.writeString(offsets[9], object.name);
  writer.writeString(offsets[10], object.nameLower);
  writer.writeString(offsets[11], object.notes);
  writer.writeString(offsets[12], object.quickAddNote);
  writer.writeString(offsets[13], object.transferId);
  writer.writeString(offsets[14], object.type);
  writer.writeDateTime(offsets[15], object.updatedAt);
}

Transaction _transactionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Transaction();
  object.accountId = reader.readString(offsets[0]);
  object.amount = reader.readDouble(offsets[1]);
  object.attachmentPaths = reader.readStringList(offsets[2]) ?? [];
  object.categoryId = reader.readString(offsets[3]);
  object.createdAt = reader.readDateTime(offsets[4]);
  object.id = id;
  object.isBalanceAdjustment = reader.readBool(offsets[5]);
  object.isTransfer = reader.readBool(offsets[6]);
  object.linkedRuleId = reader.readStringOrNull(offsets[7]);
  object.linkedRuleType = reader.readStringOrNull(offsets[8]);
  object.name = reader.readString(offsets[9]);
  object.nameLower = reader.readString(offsets[10]);
  object.notes = reader.readStringOrNull(offsets[11]);
  object.quickAddNote = reader.readStringOrNull(offsets[12]);
  object.transferId = reader.readStringOrNull(offsets[13]);
  object.type = reader.readString(offsets[14]);
  object.updatedAt = reader.readDateTime(offsets[15]);
  return object;
}

P _transactionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readStringList(offset) ?? []) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _transactionGetId(Transaction object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _transactionGetLinks(Transaction object) {
  return [];
}

void _transactionAttach(
  IsarCollection<dynamic> col,
  Id id,
  Transaction object,
) {
  object.id = id;
}

extension TransactionQueryWhereSort
    on QueryBuilder<Transaction, Transaction, QWhere> {
  QueryBuilder<Transaction, Transaction, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterWhere> anyCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'createdAt'),
      );
    });
  }
}

extension TransactionQueryWhere
    on QueryBuilder<Transaction, Transaction, QWhereClause> {
  QueryBuilder<Transaction, Transaction, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<Transaction, Transaction, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterWhereClause> idBetween(
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

  QueryBuilder<Transaction, Transaction, QAfterWhereClause>
  categoryIdEqualToAnyCreatedAt(String categoryId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'categoryId_createdAt',
          value: [categoryId],
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterWhereClause>
  categoryIdNotEqualToAnyCreatedAt(String categoryId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'categoryId_createdAt',
                lower: [],
                upper: [categoryId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'categoryId_createdAt',
                lower: [categoryId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'categoryId_createdAt',
                lower: [categoryId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'categoryId_createdAt',
                lower: [],
                upper: [categoryId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterWhereClause>
  categoryIdCreatedAtEqualTo(String categoryId, DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'categoryId_createdAt',
          value: [categoryId, createdAt],
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterWhereClause>
  categoryIdEqualToCreatedAtNotEqualTo(String categoryId, DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'categoryId_createdAt',
                lower: [categoryId],
                upper: [categoryId, createdAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'categoryId_createdAt',
                lower: [categoryId, createdAt],
                includeLower: false,
                upper: [categoryId],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'categoryId_createdAt',
                lower: [categoryId, createdAt],
                includeLower: false,
                upper: [categoryId],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'categoryId_createdAt',
                lower: [categoryId],
                upper: [categoryId, createdAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterWhereClause>
  categoryIdEqualToCreatedAtGreaterThan(
    String categoryId,
    DateTime createdAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'categoryId_createdAt',
          lower: [categoryId, createdAt],
          includeLower: include,
          upper: [categoryId],
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterWhereClause>
  categoryIdEqualToCreatedAtLessThan(
    String categoryId,
    DateTime createdAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'categoryId_createdAt',
          lower: [categoryId],
          upper: [categoryId, createdAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterWhereClause>
  categoryIdEqualToCreatedAtBetween(
    String categoryId,
    DateTime lowerCreatedAt,
    DateTime upperCreatedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'categoryId_createdAt',
          lower: [categoryId, lowerCreatedAt],
          includeLower: includeLower,
          upper: [categoryId, upperCreatedAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterWhereClause> accountIdEqualTo(
    String accountId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'accountId', value: [accountId]),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterWhereClause> accountIdNotEqualTo(
    String accountId,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'accountId',
                lower: [],
                upper: [accountId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'accountId',
                lower: [accountId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'accountId',
                lower: [accountId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'accountId',
                lower: [],
                upper: [accountId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterWhereClause>
  linkedRuleTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'linkedRuleType', value: [null]),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterWhereClause>
  linkedRuleTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'linkedRuleType',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterWhereClause>
  linkedRuleTypeEqualTo(String? linkedRuleType) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'linkedRuleType',
          value: [linkedRuleType],
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterWhereClause>
  linkedRuleTypeNotEqualTo(String? linkedRuleType) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'linkedRuleType',
                lower: [],
                upper: [linkedRuleType],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'linkedRuleType',
                lower: [linkedRuleType],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'linkedRuleType',
                lower: [linkedRuleType],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'linkedRuleType',
                lower: [],
                upper: [linkedRuleType],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterWhereClause> createdAtEqualTo(
    DateTime createdAt,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'createdAt', value: [createdAt]),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterWhereClause> createdAtNotEqualTo(
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

  QueryBuilder<Transaction, Transaction, QAfterWhereClause>
  createdAtGreaterThan(DateTime createdAt, {bool include = false}) {
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

  QueryBuilder<Transaction, Transaction, QAfterWhereClause> createdAtLessThan(
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

  QueryBuilder<Transaction, Transaction, QAfterWhereClause> createdAtBetween(
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

  QueryBuilder<Transaction, Transaction, QAfterWhereClause>
  nameLowerEqualToAnyUpdatedAt(String nameLower) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'nameLower_updatedAt',
          value: [nameLower],
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterWhereClause>
  nameLowerNotEqualToAnyUpdatedAt(String nameLower) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'nameLower_updatedAt',
                lower: [],
                upper: [nameLower],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'nameLower_updatedAt',
                lower: [nameLower],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'nameLower_updatedAt',
                lower: [nameLower],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'nameLower_updatedAt',
                lower: [],
                upper: [nameLower],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterWhereClause>
  nameLowerUpdatedAtEqualTo(String nameLower, DateTime updatedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'nameLower_updatedAt',
          value: [nameLower, updatedAt],
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterWhereClause>
  nameLowerEqualToUpdatedAtNotEqualTo(String nameLower, DateTime updatedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'nameLower_updatedAt',
                lower: [nameLower],
                upper: [nameLower, updatedAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'nameLower_updatedAt',
                lower: [nameLower, updatedAt],
                includeLower: false,
                upper: [nameLower],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'nameLower_updatedAt',
                lower: [nameLower, updatedAt],
                includeLower: false,
                upper: [nameLower],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'nameLower_updatedAt',
                lower: [nameLower],
                upper: [nameLower, updatedAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterWhereClause>
  nameLowerEqualToUpdatedAtGreaterThan(
    String nameLower,
    DateTime updatedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'nameLower_updatedAt',
          lower: [nameLower, updatedAt],
          includeLower: include,
          upper: [nameLower],
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterWhereClause>
  nameLowerEqualToUpdatedAtLessThan(
    String nameLower,
    DateTime updatedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'nameLower_updatedAt',
          lower: [nameLower],
          upper: [nameLower, updatedAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterWhereClause>
  nameLowerEqualToUpdatedAtBetween(
    String nameLower,
    DateTime lowerUpdatedAt,
    DateTime upperUpdatedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'nameLower_updatedAt',
          lower: [nameLower, lowerUpdatedAt],
          includeLower: includeLower,
          upper: [nameLower, upperUpdatedAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension TransactionQueryFilter
    on QueryBuilder<Transaction, Transaction, QFilterCondition> {
  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  accountIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'accountId', value: ''),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  accountIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'accountId', value: ''),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition> amountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  amountGreaterThan(
    double value, {
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition> amountLessThan(
    double value, {
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition> amountBetween(
    double lower,
    double upper, {
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  attachmentPathsElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'attachmentPaths',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  attachmentPathsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'attachmentPaths',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  attachmentPathsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'attachmentPaths',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  attachmentPathsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'attachmentPaths',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  attachmentPathsElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'attachmentPaths',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  attachmentPathsElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'attachmentPaths',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  attachmentPathsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'attachmentPaths',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  attachmentPathsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'attachmentPaths',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  attachmentPathsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'attachmentPaths', value: ''),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  attachmentPathsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'attachmentPaths', value: ''),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  attachmentPathsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'attachmentPaths', length, true, length, true);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  attachmentPathsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'attachmentPaths', 0, true, 0, true);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  attachmentPathsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'attachmentPaths', 0, false, 999999, true);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  attachmentPathsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'attachmentPaths', 0, true, length, include);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  attachmentPathsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'attachmentPaths',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  attachmentPathsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'attachmentPaths',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  categoryIdEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  categoryIdGreaterThan(
    String value, {
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  categoryIdLessThan(
    String value, {
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  categoryIdBetween(
    String lower,
    String upper, {
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  categoryIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'categoryId', value: ''),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  categoryIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'categoryId', value: ''),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  isBalanceAdjustmentEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isBalanceAdjustment', value: value),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  isTransferEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isTransfer', value: value),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  linkedRuleIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'linkedRuleId'),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  linkedRuleIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'linkedRuleId'),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  linkedRuleIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'linkedRuleId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  linkedRuleIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'linkedRuleId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  linkedRuleIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'linkedRuleId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  linkedRuleIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'linkedRuleId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  linkedRuleIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'linkedRuleId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  linkedRuleIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'linkedRuleId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  linkedRuleIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'linkedRuleId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  linkedRuleIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'linkedRuleId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  linkedRuleIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'linkedRuleId', value: ''),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  linkedRuleIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'linkedRuleId', value: ''),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  linkedRuleTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'linkedRuleType'),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  linkedRuleTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'linkedRuleType'),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  linkedRuleTypeEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'linkedRuleType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  linkedRuleTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'linkedRuleType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  linkedRuleTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'linkedRuleType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  linkedRuleTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'linkedRuleType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  linkedRuleTypeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'linkedRuleType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  linkedRuleTypeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'linkedRuleType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  linkedRuleTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'linkedRuleType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  linkedRuleTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'linkedRuleType',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  linkedRuleTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'linkedRuleType', value: ''),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  linkedRuleTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'linkedRuleType', value: ''),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition> nameEqualTo(
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition> nameGreaterThan(
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition> nameLessThan(
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition> nameBetween(
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition> nameStartsWith(
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition> nameEndsWith(
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition> nameContains(
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition> nameMatches(
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  nameLowerIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'nameLower', value: ''),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  nameLowerIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'nameLower', value: ''),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition> notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition> notesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  notesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition> notesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition> notesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'notes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition> notesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition> notesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition> notesContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition> notesMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'notes',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition> notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  quickAddNoteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'quickAddNote'),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  quickAddNoteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'quickAddNote'),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  quickAddNoteEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'quickAddNote',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  quickAddNoteGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'quickAddNote',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  quickAddNoteLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'quickAddNote',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  quickAddNoteBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'quickAddNote',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  quickAddNoteStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'quickAddNote',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  quickAddNoteEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'quickAddNote',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  quickAddNoteContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'quickAddNote',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  quickAddNoteMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'quickAddNote',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  quickAddNoteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'quickAddNote', value: ''),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  quickAddNoteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'quickAddNote', value: ''),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  transferIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'transferId'),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  transferIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'transferId'),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  transferIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'transferId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  transferIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'transferId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  transferIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'transferId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  transferIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'transferId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  transferIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'transferId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  transferIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'transferId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  transferIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'transferId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  transferIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'transferId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  transferIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'transferId', value: ''),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  transferIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'transferId', value: ''),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition> typeEqualTo(
    String value, {
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition> typeGreaterThan(
    String value, {
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition> typeLessThan(
    String value, {
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition> typeBetween(
    String lower,
    String upper, {
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition> typeStartsWith(
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition> typeEndsWith(
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition> typeContains(
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition> typeMatches(
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition> typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'type', value: ''),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'type', value: ''),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
  updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
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

  QueryBuilder<Transaction, Transaction, QAfterFilterCondition>
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

extension TransactionQueryObject
    on QueryBuilder<Transaction, Transaction, QFilterCondition> {}

extension TransactionQueryLinks
    on QueryBuilder<Transaction, Transaction, QFilterCondition> {}

extension TransactionQuerySortBy
    on QueryBuilder<Transaction, Transaction, QSortBy> {
  QueryBuilder<Transaction, Transaction, QAfterSortBy> sortByAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountId', Sort.asc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> sortByAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountId', Sort.desc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> sortByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> sortByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> sortByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.asc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> sortByCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.desc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy>
  sortByIsBalanceAdjustment() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBalanceAdjustment', Sort.asc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy>
  sortByIsBalanceAdjustmentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBalanceAdjustment', Sort.desc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> sortByIsTransfer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTransfer', Sort.asc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> sortByIsTransferDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTransfer', Sort.desc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> sortByLinkedRuleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedRuleId', Sort.asc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy>
  sortByLinkedRuleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedRuleId', Sort.desc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> sortByLinkedRuleType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedRuleType', Sort.asc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy>
  sortByLinkedRuleTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedRuleType', Sort.desc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> sortByNameLower() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameLower', Sort.asc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> sortByNameLowerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameLower', Sort.desc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> sortByQuickAddNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quickAddNote', Sort.asc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy>
  sortByQuickAddNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quickAddNote', Sort.desc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> sortByTransferId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transferId', Sort.asc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> sortByTransferIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transferId', Sort.desc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension TransactionQuerySortThenBy
    on QueryBuilder<Transaction, Transaction, QSortThenBy> {
  QueryBuilder<Transaction, Transaction, QAfterSortBy> thenByAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountId', Sort.asc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> thenByAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountId', Sort.desc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> thenByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> thenByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> thenByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.asc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> thenByCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.desc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy>
  thenByIsBalanceAdjustment() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBalanceAdjustment', Sort.asc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy>
  thenByIsBalanceAdjustmentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBalanceAdjustment', Sort.desc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> thenByIsTransfer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTransfer', Sort.asc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> thenByIsTransferDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTransfer', Sort.desc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> thenByLinkedRuleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedRuleId', Sort.asc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy>
  thenByLinkedRuleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedRuleId', Sort.desc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> thenByLinkedRuleType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedRuleType', Sort.asc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy>
  thenByLinkedRuleTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedRuleType', Sort.desc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> thenByNameLower() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameLower', Sort.asc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> thenByNameLowerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameLower', Sort.desc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> thenByQuickAddNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quickAddNote', Sort.asc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy>
  thenByQuickAddNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quickAddNote', Sort.desc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> thenByTransferId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transferId', Sort.asc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> thenByTransferIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transferId', Sort.desc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<Transaction, Transaction, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension TransactionQueryWhereDistinct
    on QueryBuilder<Transaction, Transaction, QDistinct> {
  QueryBuilder<Transaction, Transaction, QDistinct> distinctByAccountId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'accountId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Transaction, Transaction, QDistinct> distinctByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amount');
    });
  }

  QueryBuilder<Transaction, Transaction, QDistinct>
  distinctByAttachmentPaths() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'attachmentPaths');
    });
  }

  QueryBuilder<Transaction, Transaction, QDistinct> distinctByCategoryId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'categoryId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Transaction, Transaction, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<Transaction, Transaction, QDistinct>
  distinctByIsBalanceAdjustment() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isBalanceAdjustment');
    });
  }

  QueryBuilder<Transaction, Transaction, QDistinct> distinctByIsTransfer() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isTransfer');
    });
  }

  QueryBuilder<Transaction, Transaction, QDistinct> distinctByLinkedRuleId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'linkedRuleId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Transaction, Transaction, QDistinct> distinctByLinkedRuleType({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'linkedRuleType',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Transaction, Transaction, QDistinct> distinctByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Transaction, Transaction, QDistinct> distinctByNameLower({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nameLower', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Transaction, Transaction, QDistinct> distinctByNotes({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Transaction, Transaction, QDistinct> distinctByQuickAddNote({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quickAddNote', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Transaction, Transaction, QDistinct> distinctByTransferId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'transferId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Transaction, Transaction, QDistinct> distinctByType({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Transaction, Transaction, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension TransactionQueryProperty
    on QueryBuilder<Transaction, Transaction, QQueryProperty> {
  QueryBuilder<Transaction, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Transaction, String, QQueryOperations> accountIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'accountId');
    });
  }

  QueryBuilder<Transaction, double, QQueryOperations> amountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amount');
    });
  }

  QueryBuilder<Transaction, List<String>, QQueryOperations>
  attachmentPathsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'attachmentPaths');
    });
  }

  QueryBuilder<Transaction, String, QQueryOperations> categoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'categoryId');
    });
  }

  QueryBuilder<Transaction, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<Transaction, bool, QQueryOperations>
  isBalanceAdjustmentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isBalanceAdjustment');
    });
  }

  QueryBuilder<Transaction, bool, QQueryOperations> isTransferProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isTransfer');
    });
  }

  QueryBuilder<Transaction, String?, QQueryOperations> linkedRuleIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'linkedRuleId');
    });
  }

  QueryBuilder<Transaction, String?, QQueryOperations>
  linkedRuleTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'linkedRuleType');
    });
  }

  QueryBuilder<Transaction, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<Transaction, String, QQueryOperations> nameLowerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nameLower');
    });
  }

  QueryBuilder<Transaction, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<Transaction, String?, QQueryOperations> quickAddNoteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quickAddNote');
    });
  }

  QueryBuilder<Transaction, String?, QQueryOperations> transferIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'transferId');
    });
  }

  QueryBuilder<Transaction, String, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }

  QueryBuilder<Transaction, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
