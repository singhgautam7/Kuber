// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_tag.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTransactionTagCollection on Isar {
  IsarCollection<TransactionTag> get transactionTags => this.collection();
}

const TransactionTagSchema = CollectionSchema(
  name: r'TransactionTag',
  id: 3479730015666336660,
  properties: {
    r'tagId': PropertySchema(id: 0, name: r'tagId', type: IsarType.long),
    r'transactionId': PropertySchema(
      id: 1,
      name: r'transactionId',
      type: IsarType.long,
    ),
  },

  estimateSize: _transactionTagEstimateSize,
  serialize: _transactionTagSerialize,
  deserialize: _transactionTagDeserialize,
  deserializeProp: _transactionTagDeserializeProp,
  idName: r'id',
  indexes: {
    r'transactionId': IndexSchema(
      id: 8561542235958051982,
      name: r'transactionId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'transactionId',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'tagId': IndexSchema(
      id: -2598179288284149414,
      name: r'tagId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'tagId',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _transactionTagGetId,
  getLinks: _transactionTagGetLinks,
  attach: _transactionTagAttach,
  version: '3.3.2',
);

int _transactionTagEstimateSize(
  TransactionTag object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _transactionTagSerialize(
  TransactionTag object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.tagId);
  writer.writeLong(offsets[1], object.transactionId);
}

TransactionTag _transactionTagDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TransactionTag();
  object.id = id;
  object.tagId = reader.readLong(offsets[0]);
  object.transactionId = reader.readLong(offsets[1]);
  return object;
}

P _transactionTagDeserializeProp<P>(
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
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _transactionTagGetId(TransactionTag object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _transactionTagGetLinks(TransactionTag object) {
  return [];
}

void _transactionTagAttach(
  IsarCollection<dynamic> col,
  Id id,
  TransactionTag object,
) {
  object.id = id;
}

extension TransactionTagQueryWhereSort
    on QueryBuilder<TransactionTag, TransactionTag, QWhere> {
  QueryBuilder<TransactionTag, TransactionTag, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<TransactionTag, TransactionTag, QAfterWhere> anyTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'transactionId'),
      );
    });
  }

  QueryBuilder<TransactionTag, TransactionTag, QAfterWhere> anyTagId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'tagId'),
      );
    });
  }
}

extension TransactionTagQueryWhere
    on QueryBuilder<TransactionTag, TransactionTag, QWhereClause> {
  QueryBuilder<TransactionTag, TransactionTag, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<TransactionTag, TransactionTag, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<TransactionTag, TransactionTag, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TransactionTag, TransactionTag, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TransactionTag, TransactionTag, QAfterWhereClause> idBetween(
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

  QueryBuilder<TransactionTag, TransactionTag, QAfterWhereClause>
  transactionIdEqualTo(int transactionId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'transactionId',
          value: [transactionId],
        ),
      );
    });
  }

  QueryBuilder<TransactionTag, TransactionTag, QAfterWhereClause>
  transactionIdNotEqualTo(int transactionId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'transactionId',
                lower: [],
                upper: [transactionId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'transactionId',
                lower: [transactionId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'transactionId',
                lower: [transactionId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'transactionId',
                lower: [],
                upper: [transactionId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<TransactionTag, TransactionTag, QAfterWhereClause>
  transactionIdGreaterThan(int transactionId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'transactionId',
          lower: [transactionId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<TransactionTag, TransactionTag, QAfterWhereClause>
  transactionIdLessThan(int transactionId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'transactionId',
          lower: [],
          upper: [transactionId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<TransactionTag, TransactionTag, QAfterWhereClause>
  transactionIdBetween(
    int lowerTransactionId,
    int upperTransactionId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'transactionId',
          lower: [lowerTransactionId],
          includeLower: includeLower,
          upper: [upperTransactionId],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TransactionTag, TransactionTag, QAfterWhereClause> tagIdEqualTo(
    int tagId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'tagId', value: [tagId]),
      );
    });
  }

  QueryBuilder<TransactionTag, TransactionTag, QAfterWhereClause>
  tagIdNotEqualTo(int tagId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'tagId',
                lower: [],
                upper: [tagId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'tagId',
                lower: [tagId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'tagId',
                lower: [tagId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'tagId',
                lower: [],
                upper: [tagId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<TransactionTag, TransactionTag, QAfterWhereClause>
  tagIdGreaterThan(int tagId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'tagId',
          lower: [tagId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<TransactionTag, TransactionTag, QAfterWhereClause> tagIdLessThan(
    int tagId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'tagId',
          lower: [],
          upper: [tagId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<TransactionTag, TransactionTag, QAfterWhereClause> tagIdBetween(
    int lowerTagId,
    int upperTagId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'tagId',
          lower: [lowerTagId],
          includeLower: includeLower,
          upper: [upperTagId],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension TransactionTagQueryFilter
    on QueryBuilder<TransactionTag, TransactionTag, QFilterCondition> {
  QueryBuilder<TransactionTag, TransactionTag, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<TransactionTag, TransactionTag, QAfterFilterCondition>
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

  QueryBuilder<TransactionTag, TransactionTag, QAfterFilterCondition>
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

  QueryBuilder<TransactionTag, TransactionTag, QAfterFilterCondition> idBetween(
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

  QueryBuilder<TransactionTag, TransactionTag, QAfterFilterCondition>
  tagIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'tagId', value: value),
      );
    });
  }

  QueryBuilder<TransactionTag, TransactionTag, QAfterFilterCondition>
  tagIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'tagId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TransactionTag, TransactionTag, QAfterFilterCondition>
  tagIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'tagId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TransactionTag, TransactionTag, QAfterFilterCondition>
  tagIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'tagId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TransactionTag, TransactionTag, QAfterFilterCondition>
  transactionIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'transactionId', value: value),
      );
    });
  }

  QueryBuilder<TransactionTag, TransactionTag, QAfterFilterCondition>
  transactionIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'transactionId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TransactionTag, TransactionTag, QAfterFilterCondition>
  transactionIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'transactionId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TransactionTag, TransactionTag, QAfterFilterCondition>
  transactionIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'transactionId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension TransactionTagQueryObject
    on QueryBuilder<TransactionTag, TransactionTag, QFilterCondition> {}

extension TransactionTagQueryLinks
    on QueryBuilder<TransactionTag, TransactionTag, QFilterCondition> {}

extension TransactionTagQuerySortBy
    on QueryBuilder<TransactionTag, TransactionTag, QSortBy> {
  QueryBuilder<TransactionTag, TransactionTag, QAfterSortBy> sortByTagId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tagId', Sort.asc);
    });
  }

  QueryBuilder<TransactionTag, TransactionTag, QAfterSortBy> sortByTagIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tagId', Sort.desc);
    });
  }

  QueryBuilder<TransactionTag, TransactionTag, QAfterSortBy>
  sortByTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionId', Sort.asc);
    });
  }

  QueryBuilder<TransactionTag, TransactionTag, QAfterSortBy>
  sortByTransactionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionId', Sort.desc);
    });
  }
}

extension TransactionTagQuerySortThenBy
    on QueryBuilder<TransactionTag, TransactionTag, QSortThenBy> {
  QueryBuilder<TransactionTag, TransactionTag, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TransactionTag, TransactionTag, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TransactionTag, TransactionTag, QAfterSortBy> thenByTagId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tagId', Sort.asc);
    });
  }

  QueryBuilder<TransactionTag, TransactionTag, QAfterSortBy> thenByTagIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tagId', Sort.desc);
    });
  }

  QueryBuilder<TransactionTag, TransactionTag, QAfterSortBy>
  thenByTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionId', Sort.asc);
    });
  }

  QueryBuilder<TransactionTag, TransactionTag, QAfterSortBy>
  thenByTransactionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionId', Sort.desc);
    });
  }
}

extension TransactionTagQueryWhereDistinct
    on QueryBuilder<TransactionTag, TransactionTag, QDistinct> {
  QueryBuilder<TransactionTag, TransactionTag, QDistinct> distinctByTagId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tagId');
    });
  }

  QueryBuilder<TransactionTag, TransactionTag, QDistinct>
  distinctByTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'transactionId');
    });
  }
}

extension TransactionTagQueryProperty
    on QueryBuilder<TransactionTag, TransactionTag, QQueryProperty> {
  QueryBuilder<TransactionTag, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TransactionTag, int, QQueryOperations> tagIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tagId');
    });
  }

  QueryBuilder<TransactionTag, int, QQueryOperations> transactionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'transactionId');
    });
  }
}
