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
    r'firstInstallAt': PropertySchema(
      id: 3,
      name: r'firstInstallAt',
      type: IsarType.dateTime,
    ),
    r'lastVerifiedAt': PropertySchema(
      id: 4,
      name: r'lastVerifiedAt',
      type: IsarType.dateTime,
    ),
    r'proExpiresAt': PropertySchema(
      id: 5,
      name: r'proExpiresAt',
      type: IsarType.dateTime,
    ),
    r'tier': PropertySchema(id: 6, name: r'tier', type: IsarType.string),
    r'trialEndedNoticeShown': PropertySchema(
      id: 7,
      name: r'trialEndedNoticeShown',
      type: IsarType.bool,
    ),
    r'trialEndsAt': PropertySchema(
      id: 8,
      name: r'trialEndsAt',
      type: IsarType.dateTime,
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
  writer.writeDateTime(offsets[3], object.firstInstallAt);
  writer.writeDateTime(offsets[4], object.lastVerifiedAt);
  writer.writeDateTime(offsets[5], object.proExpiresAt);
  writer.writeString(offsets[6], object.tier);
  writer.writeBool(offsets[7], object.trialEndedNoticeShown);
  writer.writeDateTime(offsets[8], object.trialEndsAt);
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
  object.firstInstallAt = reader.readDateTime(offsets[3]);
  object.id = id;
  object.lastVerifiedAt = reader.readDateTimeOrNull(offsets[4]);
  object.proExpiresAt = reader.readDateTimeOrNull(offsets[5]);
  object.tier = reader.readString(offsets[6]);
  object.trialEndedNoticeShown = reader.readBool(offsets[7]);
  object.trialEndsAt = reader.readDateTimeOrNull(offsets[8]);
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
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
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
}
