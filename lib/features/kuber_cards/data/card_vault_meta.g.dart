// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_vault_meta.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCardVaultMetaCollection on Isar {
  IsarCollection<CardVaultMeta> get cardVaultMetas => this.collection();
}

const CardVaultMetaSchema = CollectionSchema(
  name: r'CardVaultMeta',
  id: -5757178666945431297,
  properties: {
    r'biometricEnabled': PropertySchema(
      id: 0,
      name: r'biometricEnabled',
      type: IsarType.bool,
    ),
    r'cooldownUntil': PropertySchema(
      id: 1,
      name: r'cooldownUntil',
      type: IsarType.dateTime,
    ),
    r'dayLockedUntil': PropertySchema(
      id: 2,
      name: r'dayLockedUntil',
      type: IsarType.dateTime,
    ),
    r'encVersion': PropertySchema(
      id: 3,
      name: r'encVersion',
      type: IsarType.long,
    ),
    r'failedStreak': PropertySchema(
      id: 4,
      name: r'failedStreak',
      type: IsarType.long,
    ),
    r'failedTimestamps': PropertySchema(
      id: 5,
      name: r'failedTimestamps',
      type: IsarType.dateTimeList,
    ),
    r'hasLockedImport': PropertySchema(
      id: 6,
      name: r'hasLockedImport',
      type: IsarType.bool,
    ),
    r'importBannerDismissed': PropertySchema(
      id: 7,
      name: r'importBannerDismissed',
      type: IsarType.bool,
    ),
    r'importEncVersion': PropertySchema(
      id: 8,
      name: r'importEncVersion',
      type: IsarType.long,
    ),
    r'importIterations': PropertySchema(
      id: 9,
      name: r'importIterations',
      type: IsarType.long,
    ),
    r'importKdf': PropertySchema(
      id: 10,
      name: r'importKdf',
      type: IsarType.string,
    ),
    r'importMemoryKb': PropertySchema(
      id: 11,
      name: r'importMemoryKb',
      type: IsarType.long,
    ),
    r'importParallelism': PropertySchema(
      id: 12,
      name: r'importParallelism',
      type: IsarType.long,
    ),
    r'importPinLength': PropertySchema(
      id: 13,
      name: r'importPinLength',
      type: IsarType.long,
    ),
    r'importSalt': PropertySchema(
      id: 14,
      name: r'importSalt',
      type: IsarType.longList,
    ),
    r'importVerifierEnc': PropertySchema(
      id: 15,
      name: r'importVerifierEnc',
      type: IsarType.string,
    ),
    r'kdf': PropertySchema(id: 16, name: r'kdf', type: IsarType.string),
    r'kdfIterations': PropertySchema(
      id: 17,
      name: r'kdfIterations',
      type: IsarType.long,
    ),
    r'kdfMemoryKb': PropertySchema(
      id: 18,
      name: r'kdfMemoryKb',
      type: IsarType.long,
    ),
    r'kdfParallelism': PropertySchema(
      id: 19,
      name: r'kdfParallelism',
      type: IsarType.long,
    ),
    r'pinLength': PropertySchema(
      id: 20,
      name: r'pinLength',
      type: IsarType.long,
    ),
    r'salt': PropertySchema(id: 21, name: r'salt', type: IsarType.longList),
    r'verifierEnc': PropertySchema(
      id: 22,
      name: r'verifierEnc',
      type: IsarType.string,
    ),
  },

  estimateSize: _cardVaultMetaEstimateSize,
  serialize: _cardVaultMetaSerialize,
  deserialize: _cardVaultMetaDeserialize,
  deserializeProp: _cardVaultMetaDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _cardVaultMetaGetId,
  getLinks: _cardVaultMetaGetLinks,
  attach: _cardVaultMetaAttach,
  version: '3.3.2',
);

int _cardVaultMetaEstimateSize(
  CardVaultMeta object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.failedTimestamps.length * 8;
  {
    final value = object.importKdf;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.importSalt;
    if (value != null) {
      bytesCount += 3 + value.length * 8;
    }
  }
  {
    final value = object.importVerifierEnc;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.kdf.length * 3;
  bytesCount += 3 + object.salt.length * 8;
  {
    final value = object.verifierEnc;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _cardVaultMetaSerialize(
  CardVaultMeta object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.biometricEnabled);
  writer.writeDateTime(offsets[1], object.cooldownUntil);
  writer.writeDateTime(offsets[2], object.dayLockedUntil);
  writer.writeLong(offsets[3], object.encVersion);
  writer.writeLong(offsets[4], object.failedStreak);
  writer.writeDateTimeList(offsets[5], object.failedTimestamps);
  writer.writeBool(offsets[6], object.hasLockedImport);
  writer.writeBool(offsets[7], object.importBannerDismissed);
  writer.writeLong(offsets[8], object.importEncVersion);
  writer.writeLong(offsets[9], object.importIterations);
  writer.writeString(offsets[10], object.importKdf);
  writer.writeLong(offsets[11], object.importMemoryKb);
  writer.writeLong(offsets[12], object.importParallelism);
  writer.writeLong(offsets[13], object.importPinLength);
  writer.writeLongList(offsets[14], object.importSalt);
  writer.writeString(offsets[15], object.importVerifierEnc);
  writer.writeString(offsets[16], object.kdf);
  writer.writeLong(offsets[17], object.kdfIterations);
  writer.writeLong(offsets[18], object.kdfMemoryKb);
  writer.writeLong(offsets[19], object.kdfParallelism);
  writer.writeLong(offsets[20], object.pinLength);
  writer.writeLongList(offsets[21], object.salt);
  writer.writeString(offsets[22], object.verifierEnc);
}

CardVaultMeta _cardVaultMetaDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CardVaultMeta();
  object.biometricEnabled = reader.readBool(offsets[0]);
  object.cooldownUntil = reader.readDateTimeOrNull(offsets[1]);
  object.dayLockedUntil = reader.readDateTimeOrNull(offsets[2]);
  object.encVersion = reader.readLong(offsets[3]);
  object.failedStreak = reader.readLong(offsets[4]);
  object.failedTimestamps = reader.readDateTimeList(offsets[5]) ?? [];
  object.hasLockedImport = reader.readBool(offsets[6]);
  object.id = id;
  object.importBannerDismissed = reader.readBool(offsets[7]);
  object.importEncVersion = reader.readLongOrNull(offsets[8]);
  object.importIterations = reader.readLongOrNull(offsets[9]);
  object.importKdf = reader.readStringOrNull(offsets[10]);
  object.importMemoryKb = reader.readLongOrNull(offsets[11]);
  object.importParallelism = reader.readLongOrNull(offsets[12]);
  object.importPinLength = reader.readLongOrNull(offsets[13]);
  object.importSalt = reader.readLongList(offsets[14]);
  object.importVerifierEnc = reader.readStringOrNull(offsets[15]);
  object.kdf = reader.readString(offsets[16]);
  object.kdfIterations = reader.readLong(offsets[17]);
  object.kdfMemoryKb = reader.readLong(offsets[18]);
  object.kdfParallelism = reader.readLong(offsets[19]);
  object.pinLength = reader.readLong(offsets[20]);
  object.salt = reader.readLongList(offsets[21]) ?? [];
  object.verifierEnc = reader.readStringOrNull(offsets[22]);
  return object;
}

P _cardVaultMetaDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readDateTimeList(offset) ?? []) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readLongOrNull(offset)) as P;
    case 9:
      return (reader.readLongOrNull(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readLongOrNull(offset)) as P;
    case 12:
      return (reader.readLongOrNull(offset)) as P;
    case 13:
      return (reader.readLongOrNull(offset)) as P;
    case 14:
      return (reader.readLongList(offset)) as P;
    case 15:
      return (reader.readStringOrNull(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    case 17:
      return (reader.readLong(offset)) as P;
    case 18:
      return (reader.readLong(offset)) as P;
    case 19:
      return (reader.readLong(offset)) as P;
    case 20:
      return (reader.readLong(offset)) as P;
    case 21:
      return (reader.readLongList(offset) ?? []) as P;
    case 22:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _cardVaultMetaGetId(CardVaultMeta object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _cardVaultMetaGetLinks(CardVaultMeta object) {
  return [];
}

void _cardVaultMetaAttach(
  IsarCollection<dynamic> col,
  Id id,
  CardVaultMeta object,
) {
  object.id = id;
}

extension CardVaultMetaQueryWhereSort
    on QueryBuilder<CardVaultMeta, CardVaultMeta, QWhere> {
  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CardVaultMetaQueryWhere
    on QueryBuilder<CardVaultMeta, CardVaultMeta, QWhereClause> {
  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterWhereClause> idBetween(
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

extension CardVaultMetaQueryFilter
    on QueryBuilder<CardVaultMeta, CardVaultMeta, QFilterCondition> {
  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  biometricEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'biometricEnabled', value: value),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  cooldownUntilIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'cooldownUntil'),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  cooldownUntilIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'cooldownUntil'),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  cooldownUntilEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'cooldownUntil', value: value),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  cooldownUntilGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'cooldownUntil',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  cooldownUntilLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'cooldownUntil',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  cooldownUntilBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'cooldownUntil',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  dayLockedUntilIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'dayLockedUntil'),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  dayLockedUntilIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'dayLockedUntil'),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  dayLockedUntilEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'dayLockedUntil', value: value),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  dayLockedUntilGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'dayLockedUntil',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  dayLockedUntilLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'dayLockedUntil',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  dayLockedUntilBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'dayLockedUntil',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  encVersionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'encVersion', value: value),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  encVersionGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'encVersion',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  encVersionLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'encVersion',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  encVersionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'encVersion',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  failedStreakEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'failedStreak', value: value),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  failedStreakGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'failedStreak',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  failedStreakLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'failedStreak',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  failedStreakBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'failedStreak',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  failedTimestampsElementEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'failedTimestamps', value: value),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  failedTimestampsElementGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'failedTimestamps',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  failedTimestampsElementLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'failedTimestamps',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  failedTimestampsElementBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'failedTimestamps',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  failedTimestampsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'failedTimestamps', length, true, length, true);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  failedTimestampsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'failedTimestamps', 0, true, 0, true);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  failedTimestampsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'failedTimestamps', 0, false, 999999, true);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  failedTimestampsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'failedTimestamps', 0, true, length, include);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  failedTimestampsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'failedTimestamps',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  failedTimestampsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'failedTimestamps',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  hasLockedImportEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hasLockedImport', value: value),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
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

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition> idBetween(
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

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importBannerDismissedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'importBannerDismissed',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importEncVersionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'importEncVersion'),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importEncVersionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'importEncVersion'),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importEncVersionEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'importEncVersion', value: value),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importEncVersionGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'importEncVersion',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importEncVersionLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'importEncVersion',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importEncVersionBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'importEncVersion',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importIterationsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'importIterations'),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importIterationsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'importIterations'),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importIterationsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'importIterations', value: value),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importIterationsGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'importIterations',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importIterationsLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'importIterations',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importIterationsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'importIterations',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importKdfIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'importKdf'),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importKdfIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'importKdf'),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importKdfEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'importKdf',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importKdfGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'importKdf',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importKdfLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'importKdf',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importKdfBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'importKdf',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importKdfStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'importKdf',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importKdfEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'importKdf',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importKdfContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'importKdf',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importKdfMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'importKdf',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importKdfIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'importKdf', value: ''),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importKdfIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'importKdf', value: ''),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importMemoryKbIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'importMemoryKb'),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importMemoryKbIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'importMemoryKb'),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importMemoryKbEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'importMemoryKb', value: value),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importMemoryKbGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'importMemoryKb',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importMemoryKbLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'importMemoryKb',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importMemoryKbBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'importMemoryKb',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importParallelismIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'importParallelism'),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importParallelismIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'importParallelism'),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importParallelismEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'importParallelism', value: value),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importParallelismGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'importParallelism',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importParallelismLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'importParallelism',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importParallelismBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'importParallelism',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importPinLengthIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'importPinLength'),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importPinLengthIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'importPinLength'),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importPinLengthEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'importPinLength', value: value),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importPinLengthGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'importPinLength',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importPinLengthLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'importPinLength',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importPinLengthBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'importPinLength',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importSaltIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'importSalt'),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importSaltIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'importSalt'),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importSaltElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'importSalt', value: value),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importSaltElementGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'importSalt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importSaltElementLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'importSalt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importSaltElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'importSalt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importSaltLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'importSalt', length, true, length, true);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importSaltIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'importSalt', 0, true, 0, true);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importSaltIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'importSalt', 0, false, 999999, true);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importSaltLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'importSalt', 0, true, length, include);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importSaltLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'importSalt', length, include, 999999, true);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importSaltLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'importSalt',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importVerifierEncIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'importVerifierEnc'),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importVerifierEncIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'importVerifierEnc'),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importVerifierEncEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'importVerifierEnc',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importVerifierEncGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'importVerifierEnc',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importVerifierEncLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'importVerifierEnc',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importVerifierEncBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'importVerifierEnc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importVerifierEncStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'importVerifierEnc',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importVerifierEncEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'importVerifierEnc',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importVerifierEncContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'importVerifierEnc',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importVerifierEncMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'importVerifierEnc',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importVerifierEncIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'importVerifierEnc', value: ''),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  importVerifierEncIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'importVerifierEnc', value: ''),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition> kdfEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'kdf',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  kdfGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'kdf',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition> kdfLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'kdf',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition> kdfBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'kdf',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  kdfStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'kdf',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition> kdfEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'kdf',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition> kdfContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'kdf',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition> kdfMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'kdf',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  kdfIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'kdf', value: ''),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  kdfIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'kdf', value: ''),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  kdfIterationsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'kdfIterations', value: value),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  kdfIterationsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'kdfIterations',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  kdfIterationsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'kdfIterations',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  kdfIterationsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'kdfIterations',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  kdfMemoryKbEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'kdfMemoryKb', value: value),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  kdfMemoryKbGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'kdfMemoryKb',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  kdfMemoryKbLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'kdfMemoryKb',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  kdfMemoryKbBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'kdfMemoryKb',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  kdfParallelismEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'kdfParallelism', value: value),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  kdfParallelismGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'kdfParallelism',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  kdfParallelismLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'kdfParallelism',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  kdfParallelismBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'kdfParallelism',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  pinLengthEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'pinLength', value: value),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  pinLengthGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'pinLength',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  pinLengthLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'pinLength',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  pinLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'pinLength',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  saltElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'salt', value: value),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  saltElementGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'salt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  saltElementLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'salt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  saltElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'salt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  saltLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'salt', length, true, length, true);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  saltIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'salt', 0, true, 0, true);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  saltIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'salt', 0, false, 999999, true);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  saltLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'salt', 0, true, length, include);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  saltLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'salt', length, include, 999999, true);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  saltLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'salt',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  verifierEncIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'verifierEnc'),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  verifierEncIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'verifierEnc'),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  verifierEncEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'verifierEnc',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  verifierEncGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'verifierEnc',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  verifierEncLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'verifierEnc',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  verifierEncBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'verifierEnc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  verifierEncStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'verifierEnc',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  verifierEncEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'verifierEnc',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  verifierEncContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'verifierEnc',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  verifierEncMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'verifierEnc',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  verifierEncIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'verifierEnc', value: ''),
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterFilterCondition>
  verifierEncIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'verifierEnc', value: ''),
      );
    });
  }
}

extension CardVaultMetaQueryObject
    on QueryBuilder<CardVaultMeta, CardVaultMeta, QFilterCondition> {}

extension CardVaultMetaQueryLinks
    on QueryBuilder<CardVaultMeta, CardVaultMeta, QFilterCondition> {}

extension CardVaultMetaQuerySortBy
    on QueryBuilder<CardVaultMeta, CardVaultMeta, QSortBy> {
  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  sortByBiometricEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'biometricEnabled', Sort.asc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  sortByBiometricEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'biometricEnabled', Sort.desc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  sortByCooldownUntil() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cooldownUntil', Sort.asc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  sortByCooldownUntilDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cooldownUntil', Sort.desc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  sortByDayLockedUntil() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dayLockedUntil', Sort.asc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  sortByDayLockedUntilDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dayLockedUntil', Sort.desc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy> sortByEncVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encVersion', Sort.asc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  sortByEncVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encVersion', Sort.desc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  sortByFailedStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failedStreak', Sort.asc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  sortByFailedStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failedStreak', Sort.desc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  sortByHasLockedImport() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasLockedImport', Sort.asc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  sortByHasLockedImportDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasLockedImport', Sort.desc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  sortByImportBannerDismissed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importBannerDismissed', Sort.asc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  sortByImportBannerDismissedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importBannerDismissed', Sort.desc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  sortByImportEncVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importEncVersion', Sort.asc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  sortByImportEncVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importEncVersion', Sort.desc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  sortByImportIterations() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importIterations', Sort.asc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  sortByImportIterationsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importIterations', Sort.desc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy> sortByImportKdf() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importKdf', Sort.asc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  sortByImportKdfDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importKdf', Sort.desc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  sortByImportMemoryKb() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importMemoryKb', Sort.asc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  sortByImportMemoryKbDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importMemoryKb', Sort.desc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  sortByImportParallelism() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importParallelism', Sort.asc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  sortByImportParallelismDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importParallelism', Sort.desc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  sortByImportPinLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importPinLength', Sort.asc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  sortByImportPinLengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importPinLength', Sort.desc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  sortByImportVerifierEnc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importVerifierEnc', Sort.asc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  sortByImportVerifierEncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importVerifierEnc', Sort.desc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy> sortByKdf() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kdf', Sort.asc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy> sortByKdfDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kdf', Sort.desc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  sortByKdfIterations() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kdfIterations', Sort.asc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  sortByKdfIterationsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kdfIterations', Sort.desc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy> sortByKdfMemoryKb() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kdfMemoryKb', Sort.asc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  sortByKdfMemoryKbDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kdfMemoryKb', Sort.desc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  sortByKdfParallelism() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kdfParallelism', Sort.asc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  sortByKdfParallelismDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kdfParallelism', Sort.desc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy> sortByPinLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pinLength', Sort.asc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  sortByPinLengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pinLength', Sort.desc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy> sortByVerifierEnc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verifierEnc', Sort.asc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  sortByVerifierEncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verifierEnc', Sort.desc);
    });
  }
}

extension CardVaultMetaQuerySortThenBy
    on QueryBuilder<CardVaultMeta, CardVaultMeta, QSortThenBy> {
  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  thenByBiometricEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'biometricEnabled', Sort.asc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  thenByBiometricEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'biometricEnabled', Sort.desc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  thenByCooldownUntil() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cooldownUntil', Sort.asc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  thenByCooldownUntilDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cooldownUntil', Sort.desc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  thenByDayLockedUntil() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dayLockedUntil', Sort.asc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  thenByDayLockedUntilDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dayLockedUntil', Sort.desc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy> thenByEncVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encVersion', Sort.asc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  thenByEncVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encVersion', Sort.desc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  thenByFailedStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failedStreak', Sort.asc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  thenByFailedStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failedStreak', Sort.desc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  thenByHasLockedImport() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasLockedImport', Sort.asc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  thenByHasLockedImportDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasLockedImport', Sort.desc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  thenByImportBannerDismissed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importBannerDismissed', Sort.asc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  thenByImportBannerDismissedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importBannerDismissed', Sort.desc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  thenByImportEncVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importEncVersion', Sort.asc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  thenByImportEncVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importEncVersion', Sort.desc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  thenByImportIterations() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importIterations', Sort.asc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  thenByImportIterationsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importIterations', Sort.desc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy> thenByImportKdf() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importKdf', Sort.asc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  thenByImportKdfDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importKdf', Sort.desc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  thenByImportMemoryKb() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importMemoryKb', Sort.asc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  thenByImportMemoryKbDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importMemoryKb', Sort.desc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  thenByImportParallelism() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importParallelism', Sort.asc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  thenByImportParallelismDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importParallelism', Sort.desc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  thenByImportPinLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importPinLength', Sort.asc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  thenByImportPinLengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importPinLength', Sort.desc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  thenByImportVerifierEnc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importVerifierEnc', Sort.asc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  thenByImportVerifierEncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importVerifierEnc', Sort.desc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy> thenByKdf() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kdf', Sort.asc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy> thenByKdfDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kdf', Sort.desc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  thenByKdfIterations() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kdfIterations', Sort.asc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  thenByKdfIterationsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kdfIterations', Sort.desc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy> thenByKdfMemoryKb() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kdfMemoryKb', Sort.asc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  thenByKdfMemoryKbDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kdfMemoryKb', Sort.desc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  thenByKdfParallelism() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kdfParallelism', Sort.asc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  thenByKdfParallelismDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kdfParallelism', Sort.desc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy> thenByPinLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pinLength', Sort.asc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  thenByPinLengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pinLength', Sort.desc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy> thenByVerifierEnc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verifierEnc', Sort.asc);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QAfterSortBy>
  thenByVerifierEncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verifierEnc', Sort.desc);
    });
  }
}

extension CardVaultMetaQueryWhereDistinct
    on QueryBuilder<CardVaultMeta, CardVaultMeta, QDistinct> {
  QueryBuilder<CardVaultMeta, CardVaultMeta, QDistinct>
  distinctByBiometricEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'biometricEnabled');
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QDistinct>
  distinctByCooldownUntil() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cooldownUntil');
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QDistinct>
  distinctByDayLockedUntil() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dayLockedUntil');
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QDistinct> distinctByEncVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'encVersion');
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QDistinct>
  distinctByFailedStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'failedStreak');
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QDistinct>
  distinctByFailedTimestamps() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'failedTimestamps');
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QDistinct>
  distinctByHasLockedImport() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasLockedImport');
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QDistinct>
  distinctByImportBannerDismissed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'importBannerDismissed');
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QDistinct>
  distinctByImportEncVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'importEncVersion');
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QDistinct>
  distinctByImportIterations() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'importIterations');
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QDistinct> distinctByImportKdf({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'importKdf', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QDistinct>
  distinctByImportMemoryKb() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'importMemoryKb');
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QDistinct>
  distinctByImportParallelism() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'importParallelism');
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QDistinct>
  distinctByImportPinLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'importPinLength');
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QDistinct> distinctByImportSalt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'importSalt');
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QDistinct>
  distinctByImportVerifierEnc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'importVerifierEnc',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QDistinct> distinctByKdf({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kdf', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QDistinct>
  distinctByKdfIterations() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kdfIterations');
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QDistinct>
  distinctByKdfMemoryKb() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kdfMemoryKb');
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QDistinct>
  distinctByKdfParallelism() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kdfParallelism');
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QDistinct> distinctByPinLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pinLength');
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QDistinct> distinctBySalt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'salt');
    });
  }

  QueryBuilder<CardVaultMeta, CardVaultMeta, QDistinct> distinctByVerifierEnc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'verifierEnc', caseSensitive: caseSensitive);
    });
  }
}

extension CardVaultMetaQueryProperty
    on QueryBuilder<CardVaultMeta, CardVaultMeta, QQueryProperty> {
  QueryBuilder<CardVaultMeta, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CardVaultMeta, bool, QQueryOperations>
  biometricEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'biometricEnabled');
    });
  }

  QueryBuilder<CardVaultMeta, DateTime?, QQueryOperations>
  cooldownUntilProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cooldownUntil');
    });
  }

  QueryBuilder<CardVaultMeta, DateTime?, QQueryOperations>
  dayLockedUntilProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dayLockedUntil');
    });
  }

  QueryBuilder<CardVaultMeta, int, QQueryOperations> encVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'encVersion');
    });
  }

  QueryBuilder<CardVaultMeta, int, QQueryOperations> failedStreakProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'failedStreak');
    });
  }

  QueryBuilder<CardVaultMeta, List<DateTime>, QQueryOperations>
  failedTimestampsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'failedTimestamps');
    });
  }

  QueryBuilder<CardVaultMeta, bool, QQueryOperations>
  hasLockedImportProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasLockedImport');
    });
  }

  QueryBuilder<CardVaultMeta, bool, QQueryOperations>
  importBannerDismissedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'importBannerDismissed');
    });
  }

  QueryBuilder<CardVaultMeta, int?, QQueryOperations>
  importEncVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'importEncVersion');
    });
  }

  QueryBuilder<CardVaultMeta, int?, QQueryOperations>
  importIterationsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'importIterations');
    });
  }

  QueryBuilder<CardVaultMeta, String?, QQueryOperations> importKdfProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'importKdf');
    });
  }

  QueryBuilder<CardVaultMeta, int?, QQueryOperations> importMemoryKbProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'importMemoryKb');
    });
  }

  QueryBuilder<CardVaultMeta, int?, QQueryOperations>
  importParallelismProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'importParallelism');
    });
  }

  QueryBuilder<CardVaultMeta, int?, QQueryOperations>
  importPinLengthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'importPinLength');
    });
  }

  QueryBuilder<CardVaultMeta, List<int>?, QQueryOperations>
  importSaltProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'importSalt');
    });
  }

  QueryBuilder<CardVaultMeta, String?, QQueryOperations>
  importVerifierEncProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'importVerifierEnc');
    });
  }

  QueryBuilder<CardVaultMeta, String, QQueryOperations> kdfProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kdf');
    });
  }

  QueryBuilder<CardVaultMeta, int, QQueryOperations> kdfIterationsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kdfIterations');
    });
  }

  QueryBuilder<CardVaultMeta, int, QQueryOperations> kdfMemoryKbProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kdfMemoryKb');
    });
  }

  QueryBuilder<CardVaultMeta, int, QQueryOperations> kdfParallelismProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kdfParallelism');
    });
  }

  QueryBuilder<CardVaultMeta, int, QQueryOperations> pinLengthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pinLength');
    });
  }

  QueryBuilder<CardVaultMeta, List<int>, QQueryOperations> saltProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'salt');
    });
  }

  QueryBuilder<CardVaultMeta, String?, QQueryOperations> verifierEncProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'verifierEnc');
    });
  }
}
