// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_entitlement.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUserEntitlementCollection on Isar {
  IsarCollection<UserEntitlement> get userEntitlements => this.collection();
}

const UserEntitlementSchema = CollectionSchema(
  name: r'UserEntitlement',
  id: -125264536036046276,
  properties: {
    r'activatedAt': PropertySchema(
      id: 0,
      name: r'activatedAt',
      type: IsarType.dateTime,
    ),
    r'activeProductId': PropertySchema(
      id: 1,
      name: r'activeProductId',
      type: IsarType.string,
    ),
    r'activePurchaseToken': PropertySchema(
      id: 2,
      name: r'activePurchaseToken',
      type: IsarType.string,
    ),
    r'autoRenewing': PropertySchema(
      id: 3,
      name: r'autoRenewing',
      type: IsarType.bool,
    ),
    r'firstInstallAt': PropertySchema(
      id: 4,
      name: r'firstInstallAt',
      type: IsarType.dateTime,
    ),
    r'lastVerifiedAt': PropertySchema(
      id: 5,
      name: r'lastVerifiedAt',
      type: IsarType.dateTime,
    ),
    r'proExpiresAt': PropertySchema(
      id: 6,
      name: r'proExpiresAt',
      type: IsarType.dateTime,
    ),
    r'proTrialEndedNoticeShown': PropertySchema(
      id: 7,
      name: r'proTrialEndedNoticeShown',
      type: IsarType.bool,
    ),
    r'tier': PropertySchema(id: 8, name: r'tier', type: IsarType.string),
    r'trialEndedNoticeShown': PropertySchema(
      id: 9,
      name: r'trialEndedNoticeShown',
      type: IsarType.bool,
    ),
    r'trialEndsAt': PropertySchema(
      id: 10,
      name: r'trialEndsAt',
      type: IsarType.dateTime,
    ),
    r'trialHighWaterAt': PropertySchema(
      id: 11,
      name: r'trialHighWaterAt',
      type: IsarType.dateTime,
    ),
    r'trialHighWaterUptimeMs': PropertySchema(
      id: 12,
      name: r'trialHighWaterUptimeMs',
      type: IsarType.long,
    ),
    r'trialInvalidSeen': PropertySchema(
      id: 13,
      name: r'trialInvalidSeen',
      type: IsarType.bool,
    ),
    r'trialRecordId': PropertySchema(
      id: 14,
      name: r'trialRecordId',
      type: IsarType.string,
    ),
    r'trialSig': PropertySchema(
      id: 15,
      name: r'trialSig',
      type: IsarType.string,
    ),
    r'trialStartAt': PropertySchema(
      id: 16,
      name: r'trialStartAt',
      type: IsarType.dateTime,
    ),
    r'trialVersion': PropertySchema(
      id: 17,
      name: r'trialVersion',
      type: IsarType.long,
    ),
  },

  estimateSize: _userEntitlementEstimateSize,
  serialize: _userEntitlementSerialize,
  deserialize: _userEntitlementDeserialize,
  deserializeProp: _userEntitlementDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _userEntitlementGetId,
  getLinks: _userEntitlementGetLinks,
  attach: _userEntitlementAttach,
  version: '3.3.2',
);

int _userEntitlementEstimateSize(
  UserEntitlement object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.activeProductId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.activePurchaseToken;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.tier.length * 3;
  {
    final value = object.trialRecordId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.trialSig;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _userEntitlementSerialize(
  UserEntitlement object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.activatedAt);
  writer.writeString(offsets[1], object.activeProductId);
  writer.writeString(offsets[2], object.activePurchaseToken);
  writer.writeBool(offsets[3], object.autoRenewing);
  writer.writeDateTime(offsets[4], object.firstInstallAt);
  writer.writeDateTime(offsets[5], object.lastVerifiedAt);
  writer.writeDateTime(offsets[6], object.proExpiresAt);
  writer.writeBool(offsets[7], object.proTrialEndedNoticeShown);
  writer.writeString(offsets[8], object.tier);
  writer.writeBool(offsets[9], object.trialEndedNoticeShown);
  writer.writeDateTime(offsets[10], object.trialEndsAt);
  writer.writeDateTime(offsets[11], object.trialHighWaterAt);
  writer.writeLong(offsets[12], object.trialHighWaterUptimeMs);
  writer.writeBool(offsets[13], object.trialInvalidSeen);
  writer.writeString(offsets[14], object.trialRecordId);
  writer.writeString(offsets[15], object.trialSig);
  writer.writeDateTime(offsets[16], object.trialStartAt);
  writer.writeLong(offsets[17], object.trialVersion);
}

UserEntitlement _userEntitlementDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserEntitlement();
  object.activatedAt = reader.readDateTimeOrNull(offsets[0]);
  object.activeProductId = reader.readStringOrNull(offsets[1]);
  object.activePurchaseToken = reader.readStringOrNull(offsets[2]);
  object.autoRenewing = reader.readBoolOrNull(offsets[3]);
  object.firstInstallAt = reader.readDateTime(offsets[4]);
  object.id = id;
  object.lastVerifiedAt = reader.readDateTimeOrNull(offsets[5]);
  object.proExpiresAt = reader.readDateTimeOrNull(offsets[6]);
  object.proTrialEndedNoticeShown = reader.readBool(offsets[7]);
  object.tier = reader.readString(offsets[8]);
  object.trialEndedNoticeShown = reader.readBool(offsets[9]);
  object.trialEndsAt = reader.readDateTimeOrNull(offsets[10]);
  object.trialHighWaterAt = reader.readDateTimeOrNull(offsets[11]);
  object.trialHighWaterUptimeMs = reader.readLongOrNull(offsets[12]);
  object.trialInvalidSeen = reader.readBool(offsets[13]);
  object.trialRecordId = reader.readStringOrNull(offsets[14]);
  object.trialSig = reader.readStringOrNull(offsets[15]);
  object.trialStartAt = reader.readDateTimeOrNull(offsets[16]);
  object.trialVersion = reader.readLongOrNull(offsets[17]);
  return object;
}

P _userEntitlementDeserializeProp<P>(
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
      return (reader.readBoolOrNull(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readBool(offset)) as P;
    case 10:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 11:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 12:
      return (reader.readLongOrNull(offset)) as P;
    case 13:
      return (reader.readBool(offset)) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    case 15:
      return (reader.readStringOrNull(offset)) as P;
    case 16:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 17:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _userEntitlementGetId(UserEntitlement object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _userEntitlementGetLinks(UserEntitlement object) {
  return [];
}

void _userEntitlementAttach(
  IsarCollection<dynamic> col,
  Id id,
  UserEntitlement object,
) {
  object.id = id;
}

extension UserEntitlementQueryWhereSort
    on QueryBuilder<UserEntitlement, UserEntitlement, QWhere> {
  QueryBuilder<UserEntitlement, UserEntitlement, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UserEntitlementQueryWhere
    on QueryBuilder<UserEntitlement, UserEntitlement, QWhereClause> {
  QueryBuilder<UserEntitlement, UserEntitlement, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterWhereClause>
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

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterWhereClause> idBetween(
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

extension UserEntitlementQueryFilter
    on QueryBuilder<UserEntitlement, UserEntitlement, QFilterCondition> {
  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  activatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'activatedAt'),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  activatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'activatedAt'),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  activatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'activatedAt', value: value),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  activatedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'activatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  activatedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'activatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  activatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'activatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  activeProductIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'activeProductId'),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  activeProductIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'activeProductId'),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  activeProductIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'activeProductId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  activeProductIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'activeProductId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  activeProductIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'activeProductId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  activeProductIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'activeProductId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  activeProductIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'activeProductId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  activeProductIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'activeProductId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  activeProductIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'activeProductId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  activeProductIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'activeProductId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  activeProductIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'activeProductId', value: ''),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  activeProductIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'activeProductId', value: ''),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  activePurchaseTokenIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'activePurchaseToken'),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  activePurchaseTokenIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'activePurchaseToken'),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  activePurchaseTokenEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'activePurchaseToken',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  activePurchaseTokenGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'activePurchaseToken',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  activePurchaseTokenLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'activePurchaseToken',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  activePurchaseTokenBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'activePurchaseToken',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  activePurchaseTokenStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'activePurchaseToken',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  activePurchaseTokenEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'activePurchaseToken',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  activePurchaseTokenContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'activePurchaseToken',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  activePurchaseTokenMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'activePurchaseToken',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  activePurchaseTokenIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'activePurchaseToken', value: ''),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  activePurchaseTokenIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'activePurchaseToken',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  autoRenewingIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'autoRenewing'),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  autoRenewingIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'autoRenewing'),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  autoRenewingEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'autoRenewing', value: value),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  firstInstallAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'firstInstallAt', value: value),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  firstInstallAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'firstInstallAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  firstInstallAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'firstInstallAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  firstInstallAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'firstInstallAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
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

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
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

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
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

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  lastVerifiedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastVerifiedAt'),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  lastVerifiedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastVerifiedAt'),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  lastVerifiedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastVerifiedAt', value: value),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  lastVerifiedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastVerifiedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  lastVerifiedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastVerifiedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  lastVerifiedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastVerifiedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  proExpiresAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'proExpiresAt'),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  proExpiresAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'proExpiresAt'),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  proExpiresAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'proExpiresAt', value: value),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  proExpiresAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'proExpiresAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  proExpiresAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'proExpiresAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  proExpiresAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'proExpiresAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  proTrialEndedNoticeShownEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'proTrialEndedNoticeShown',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  tierEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'tier',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  tierGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'tier',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  tierLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'tier',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  tierBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'tier',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  tierStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'tier',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  tierEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'tier',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  tierContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'tier',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  tierMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'tier',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  tierIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'tier', value: ''),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  tierIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'tier', value: ''),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialEndedNoticeShownEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'trialEndedNoticeShown',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialEndsAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'trialEndsAt'),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialEndsAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'trialEndsAt'),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialEndsAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'trialEndsAt', value: value),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialEndsAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'trialEndsAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialEndsAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'trialEndsAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialEndsAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'trialEndsAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialHighWaterAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'trialHighWaterAt'),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialHighWaterAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'trialHighWaterAt'),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialHighWaterAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'trialHighWaterAt', value: value),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialHighWaterAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'trialHighWaterAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialHighWaterAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'trialHighWaterAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialHighWaterAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'trialHighWaterAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialHighWaterUptimeMsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'trialHighWaterUptimeMs'),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialHighWaterUptimeMsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'trialHighWaterUptimeMs'),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialHighWaterUptimeMsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'trialHighWaterUptimeMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialHighWaterUptimeMsGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'trialHighWaterUptimeMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialHighWaterUptimeMsLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'trialHighWaterUptimeMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialHighWaterUptimeMsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'trialHighWaterUptimeMs',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialInvalidSeenEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'trialInvalidSeen', value: value),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialRecordIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'trialRecordId'),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialRecordIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'trialRecordId'),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialRecordIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'trialRecordId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialRecordIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'trialRecordId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialRecordIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'trialRecordId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialRecordIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'trialRecordId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialRecordIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'trialRecordId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialRecordIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'trialRecordId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialRecordIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'trialRecordId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialRecordIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'trialRecordId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialRecordIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'trialRecordId', value: ''),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialRecordIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'trialRecordId', value: ''),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialSigIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'trialSig'),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialSigIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'trialSig'),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialSigEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'trialSig',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialSigGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'trialSig',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialSigLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'trialSig',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialSigBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'trialSig',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialSigStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'trialSig',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialSigEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'trialSig',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialSigContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'trialSig',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialSigMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'trialSig',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialSigIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'trialSig', value: ''),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialSigIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'trialSig', value: ''),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialStartAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'trialStartAt'),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialStartAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'trialStartAt'),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialStartAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'trialStartAt', value: value),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialStartAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'trialStartAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialStartAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'trialStartAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialStartAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'trialStartAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialVersionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'trialVersion'),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialVersionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'trialVersion'),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialVersionEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'trialVersion', value: value),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialVersionGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'trialVersion',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialVersionLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'trialVersion',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterFilterCondition>
  trialVersionBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'trialVersion',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension UserEntitlementQueryObject
    on QueryBuilder<UserEntitlement, UserEntitlement, QFilterCondition> {}

extension UserEntitlementQueryLinks
    on QueryBuilder<UserEntitlement, UserEntitlement, QFilterCondition> {}

extension UserEntitlementQuerySortBy
    on QueryBuilder<UserEntitlement, UserEntitlement, QSortBy> {
  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  sortByActivatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activatedAt', Sort.asc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  sortByActivatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activatedAt', Sort.desc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  sortByActiveProductId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeProductId', Sort.asc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  sortByActiveProductIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeProductId', Sort.desc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  sortByActivePurchaseToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activePurchaseToken', Sort.asc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  sortByActivePurchaseTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activePurchaseToken', Sort.desc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  sortByAutoRenewing() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoRenewing', Sort.asc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  sortByAutoRenewingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoRenewing', Sort.desc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  sortByFirstInstallAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstInstallAt', Sort.asc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  sortByFirstInstallAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstInstallAt', Sort.desc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  sortByLastVerifiedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastVerifiedAt', Sort.asc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  sortByLastVerifiedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastVerifiedAt', Sort.desc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  sortByProExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proExpiresAt', Sort.asc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  sortByProExpiresAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proExpiresAt', Sort.desc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  sortByProTrialEndedNoticeShown() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proTrialEndedNoticeShown', Sort.asc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  sortByProTrialEndedNoticeShownDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proTrialEndedNoticeShown', Sort.desc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy> sortByTier() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tier', Sort.asc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  sortByTierDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tier', Sort.desc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  sortByTrialEndedNoticeShown() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialEndedNoticeShown', Sort.asc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  sortByTrialEndedNoticeShownDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialEndedNoticeShown', Sort.desc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  sortByTrialEndsAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialEndsAt', Sort.asc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  sortByTrialEndsAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialEndsAt', Sort.desc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  sortByTrialHighWaterAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialHighWaterAt', Sort.asc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  sortByTrialHighWaterAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialHighWaterAt', Sort.desc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  sortByTrialHighWaterUptimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialHighWaterUptimeMs', Sort.asc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  sortByTrialHighWaterUptimeMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialHighWaterUptimeMs', Sort.desc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  sortByTrialInvalidSeen() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialInvalidSeen', Sort.asc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  sortByTrialInvalidSeenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialInvalidSeen', Sort.desc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  sortByTrialRecordId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialRecordId', Sort.asc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  sortByTrialRecordIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialRecordId', Sort.desc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  sortByTrialSig() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialSig', Sort.asc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  sortByTrialSigDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialSig', Sort.desc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  sortByTrialStartAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialStartAt', Sort.asc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  sortByTrialStartAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialStartAt', Sort.desc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  sortByTrialVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialVersion', Sort.asc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  sortByTrialVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialVersion', Sort.desc);
    });
  }
}

extension UserEntitlementQuerySortThenBy
    on QueryBuilder<UserEntitlement, UserEntitlement, QSortThenBy> {
  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  thenByActivatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activatedAt', Sort.asc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  thenByActivatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activatedAt', Sort.desc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  thenByActiveProductId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeProductId', Sort.asc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  thenByActiveProductIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeProductId', Sort.desc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  thenByActivePurchaseToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activePurchaseToken', Sort.asc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  thenByActivePurchaseTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activePurchaseToken', Sort.desc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  thenByAutoRenewing() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoRenewing', Sort.asc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  thenByAutoRenewingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoRenewing', Sort.desc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  thenByFirstInstallAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstInstallAt', Sort.asc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  thenByFirstInstallAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstInstallAt', Sort.desc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  thenByLastVerifiedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastVerifiedAt', Sort.asc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  thenByLastVerifiedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastVerifiedAt', Sort.desc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  thenByProExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proExpiresAt', Sort.asc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  thenByProExpiresAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proExpiresAt', Sort.desc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  thenByProTrialEndedNoticeShown() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proTrialEndedNoticeShown', Sort.asc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  thenByProTrialEndedNoticeShownDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proTrialEndedNoticeShown', Sort.desc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy> thenByTier() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tier', Sort.asc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  thenByTierDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tier', Sort.desc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  thenByTrialEndedNoticeShown() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialEndedNoticeShown', Sort.asc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  thenByTrialEndedNoticeShownDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialEndedNoticeShown', Sort.desc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  thenByTrialEndsAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialEndsAt', Sort.asc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  thenByTrialEndsAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialEndsAt', Sort.desc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  thenByTrialHighWaterAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialHighWaterAt', Sort.asc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  thenByTrialHighWaterAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialHighWaterAt', Sort.desc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  thenByTrialHighWaterUptimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialHighWaterUptimeMs', Sort.asc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  thenByTrialHighWaterUptimeMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialHighWaterUptimeMs', Sort.desc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  thenByTrialInvalidSeen() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialInvalidSeen', Sort.asc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  thenByTrialInvalidSeenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialInvalidSeen', Sort.desc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  thenByTrialRecordId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialRecordId', Sort.asc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  thenByTrialRecordIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialRecordId', Sort.desc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  thenByTrialSig() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialSig', Sort.asc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  thenByTrialSigDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialSig', Sort.desc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  thenByTrialStartAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialStartAt', Sort.asc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  thenByTrialStartAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialStartAt', Sort.desc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  thenByTrialVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialVersion', Sort.asc);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QAfterSortBy>
  thenByTrialVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialVersion', Sort.desc);
    });
  }
}

extension UserEntitlementQueryWhereDistinct
    on QueryBuilder<UserEntitlement, UserEntitlement, QDistinct> {
  QueryBuilder<UserEntitlement, UserEntitlement, QDistinct>
  distinctByActivatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activatedAt');
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QDistinct>
  distinctByActiveProductId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'activeProductId',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QDistinct>
  distinctByActivePurchaseToken({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'activePurchaseToken',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QDistinct>
  distinctByAutoRenewing() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autoRenewing');
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QDistinct>
  distinctByFirstInstallAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'firstInstallAt');
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QDistinct>
  distinctByLastVerifiedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastVerifiedAt');
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QDistinct>
  distinctByProExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'proExpiresAt');
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QDistinct>
  distinctByProTrialEndedNoticeShown() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'proTrialEndedNoticeShown');
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QDistinct> distinctByTier({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tier', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QDistinct>
  distinctByTrialEndedNoticeShown() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trialEndedNoticeShown');
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QDistinct>
  distinctByTrialEndsAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trialEndsAt');
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QDistinct>
  distinctByTrialHighWaterAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trialHighWaterAt');
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QDistinct>
  distinctByTrialHighWaterUptimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trialHighWaterUptimeMs');
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QDistinct>
  distinctByTrialInvalidSeen() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trialInvalidSeen');
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QDistinct>
  distinctByTrialRecordId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'trialRecordId',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QDistinct> distinctByTrialSig({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trialSig', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QDistinct>
  distinctByTrialStartAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trialStartAt');
    });
  }

  QueryBuilder<UserEntitlement, UserEntitlement, QDistinct>
  distinctByTrialVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trialVersion');
    });
  }
}

extension UserEntitlementQueryProperty
    on QueryBuilder<UserEntitlement, UserEntitlement, QQueryProperty> {
  QueryBuilder<UserEntitlement, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UserEntitlement, DateTime?, QQueryOperations>
  activatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activatedAt');
    });
  }

  QueryBuilder<UserEntitlement, String?, QQueryOperations>
  activeProductIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activeProductId');
    });
  }

  QueryBuilder<UserEntitlement, String?, QQueryOperations>
  activePurchaseTokenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activePurchaseToken');
    });
  }

  QueryBuilder<UserEntitlement, bool?, QQueryOperations>
  autoRenewingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autoRenewing');
    });
  }

  QueryBuilder<UserEntitlement, DateTime, QQueryOperations>
  firstInstallAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'firstInstallAt');
    });
  }

  QueryBuilder<UserEntitlement, DateTime?, QQueryOperations>
  lastVerifiedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastVerifiedAt');
    });
  }

  QueryBuilder<UserEntitlement, DateTime?, QQueryOperations>
  proExpiresAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'proExpiresAt');
    });
  }

  QueryBuilder<UserEntitlement, bool, QQueryOperations>
  proTrialEndedNoticeShownProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'proTrialEndedNoticeShown');
    });
  }

  QueryBuilder<UserEntitlement, String, QQueryOperations> tierProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tier');
    });
  }

  QueryBuilder<UserEntitlement, bool, QQueryOperations>
  trialEndedNoticeShownProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trialEndedNoticeShown');
    });
  }

  QueryBuilder<UserEntitlement, DateTime?, QQueryOperations>
  trialEndsAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trialEndsAt');
    });
  }

  QueryBuilder<UserEntitlement, DateTime?, QQueryOperations>
  trialHighWaterAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trialHighWaterAt');
    });
  }

  QueryBuilder<UserEntitlement, int?, QQueryOperations>
  trialHighWaterUptimeMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trialHighWaterUptimeMs');
    });
  }

  QueryBuilder<UserEntitlement, bool, QQueryOperations>
  trialInvalidSeenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trialInvalidSeen');
    });
  }

  QueryBuilder<UserEntitlement, String?, QQueryOperations>
  trialRecordIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trialRecordId');
    });
  }

  QueryBuilder<UserEntitlement, String?, QQueryOperations> trialSigProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trialSig');
    });
  }

  QueryBuilder<UserEntitlement, DateTime?, QQueryOperations>
  trialStartAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trialStartAt');
    });
  }

  QueryBuilder<UserEntitlement, int?, QQueryOperations> trialVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trialVersion');
    });
  }
}
