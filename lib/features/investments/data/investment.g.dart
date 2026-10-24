// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'investment.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetInvestmentCollection on Isar {
  IsarCollection<Investment> get investments => this.collection();
}

const InvestmentSchema = CollectionSchema(
  name: r'Investment',
  id: 7879499270061128774,
  properties: {
    r'accountId': PropertySchema(
      id: 0,
      name: r'accountId',
      type: IsarType.string,
    ),
    r'alreadyRunning': PropertySchema(
      id: 1,
      name: r'alreadyRunning',
      type: IsarType.bool,
    ),
    r'autoDebit': PropertySchema(
      id: 2,
      name: r'autoDebit',
      type: IsarType.bool,
    ),
    r'behaviour': PropertySchema(
      id: 3,
      name: r'behaviour',
      type: IsarType.string,
      enumMap: _InvestmentbehaviourEnumValueMap,
    ),
    r'categoryId': PropertySchema(
      id: 4,
      name: r'categoryId',
      type: IsarType.string,
    ),
    r'closedAt': PropertySchema(
      id: 5,
      name: r'closedAt',
      type: IsarType.dateTime,
    ),
    r'compounding': PropertySchema(
      id: 6,
      name: r'compounding',
      type: IsarType.string,
      enumMap: _InvestmentcompoundingEnumValueMap,
    ),
    r'createdAt': PropertySchema(
      id: 7,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'currentValue': PropertySchema(
      id: 8,
      name: r'currentValue',
      type: IsarType.double,
    ),
    r'dataVersion': PropertySchema(
      id: 9,
      name: r'dataVersion',
      type: IsarType.long,
    ),
    r'deductedFromAccount': PropertySchema(
      id: 10,
      name: r'deductedFromAccount',
      type: IsarType.bool,
    ),
    r'fixedPrincipal': PropertySchema(
      id: 11,
      name: r'fixedPrincipal',
      type: IsarType.double,
    ),
    r'fixedRate': PropertySchema(
      id: 12,
      name: r'fixedRate',
      type: IsarType.double,
    ),
    r'fixedStart': PropertySchema(
      id: 13,
      name: r'fixedStart',
      type: IsarType.dateTime,
    ),
    r'fixedTenureMonths': PropertySchema(
      id: 14,
      name: r'fixedTenureMonths',
      type: IsarType.long,
    ),
    r'installment': PropertySchema(
      id: 15,
      name: r'installment',
      type: IsarType.double,
    ),
    r'investedAmount': PropertySchema(
      id: 16,
      name: r'investedAmount',
      type: IsarType.double,
    ),
    r'investmentType': PropertySchema(
      id: 17,
      name: r'investmentType',
      type: IsarType.string,
    ),
    r'maturityDate': PropertySchema(
      id: 18,
      name: r'maturityDate',
      type: IsarType.dateTime,
    ),
    r'maturityHandled': PropertySchema(
      id: 19,
      name: r'maturityHandled',
      type: IsarType.bool,
    ),
    r'name': PropertySchema(id: 20, name: r'name', type: IsarType.string),
    r'notes': PropertySchema(id: 21, name: r'notes', type: IsarType.string),
    r'openingDate': PropertySchema(
      id: 22,
      name: r'openingDate',
      type: IsarType.dateTime,
    ),
    r'openingInvested': PropertySchema(
      id: 23,
      name: r'openingInvested',
      type: IsarType.double,
    ),
    r'openingValue': PropertySchema(
      id: 24,
      name: r'openingValue',
      type: IsarType.double,
    ),
    r'payout': PropertySchema(
      id: 25,
      name: r'payout',
      type: IsarType.string,
      enumMap: _InvestmentpayoutEnumValueMap,
    ),
    r'sip': PropertySchema(
      id: 26,
      name: r'sip',
      type: IsarType.object,

      target: r'Schedule',
    ),
    r'sipAmount': PropertySchema(
      id: 27,
      name: r'sipAmount',
      type: IsarType.double,
    ),
    r'sipDate': PropertySchema(id: 28, name: r'sipDate', type: IsarType.long),
    r'snapshots': PropertySchema(
      id: 29,
      name: r'snapshots',
      type: IsarType.objectList,

      target: r'ValueSnapshot',
    ),
    r'status': PropertySchema(
      id: 30,
      name: r'status',
      type: IsarType.string,
      enumMap: _InvestmentstatusEnumValueMap,
    ),
    r'stepUpKind': PropertySchema(
      id: 31,
      name: r'stepUpKind',
      type: IsarType.string,
      enumMap: _InvestmentstepUpKindEnumValueMap,
    ),
    r'stepUpValue': PropertySchema(
      id: 32,
      name: r'stepUpValue',
      type: IsarType.double,
    ),
    r'uid': PropertySchema(id: 33, name: r'uid', type: IsarType.string),
    r'units': PropertySchema(id: 34, name: r'units', type: IsarType.double),
    r'updatedAt': PropertySchema(
      id: 35,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'withdrawals': PropertySchema(
      id: 36,
      name: r'withdrawals',
      type: IsarType.objectList,

      target: r'Withdrawal',
    ),
  },

  estimateSize: _investmentEstimateSize,
  serialize: _investmentSerialize,
  deserialize: _investmentDeserialize,
  deserializeProp: _investmentDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {
    r'Schedule': ScheduleSchema,
    r'ValueSnapshot': ValueSnapshotSchema,
    r'Withdrawal': WithdrawalSchema,
  },

  getId: _investmentGetId,
  getLinks: _investmentGetLinks,
  attach: _investmentAttach,
  version: '3.3.2',
);

int _investmentEstimateSize(
  Investment object,
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
  bytesCount += 3 + object.behaviour.name.length * 3;
  bytesCount += 3 + object.categoryId.length * 3;
  bytesCount += 3 + object.compounding.name.length * 3;
  bytesCount += 3 + object.investmentType.length * 3;
  bytesCount += 3 + object.name.length * 3;
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.payout.name.length * 3;
  {
    final value = object.sip;
    if (value != null) {
      bytesCount +=
          3 +
          ScheduleSchema.estimateSize(value, allOffsets[Schedule]!, allOffsets);
    }
  }
  bytesCount += 3 + object.snapshots.length * 3;
  {
    final offsets = allOffsets[ValueSnapshot]!;
    for (var i = 0; i < object.snapshots.length; i++) {
      final value = object.snapshots[i];
      bytesCount += ValueSnapshotSchema.estimateSize(
        value,
        offsets,
        allOffsets,
      );
    }
  }
  bytesCount += 3 + object.status.name.length * 3;
  bytesCount += 3 + object.stepUpKind.name.length * 3;
  bytesCount += 3 + object.uid.length * 3;
  bytesCount += 3 + object.withdrawals.length * 3;
  {
    final offsets = allOffsets[Withdrawal]!;
    for (var i = 0; i < object.withdrawals.length; i++) {
      final value = object.withdrawals[i];
      bytesCount += WithdrawalSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  return bytesCount;
}

void _investmentSerialize(
  Investment object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.accountId);
  writer.writeBool(offsets[1], object.alreadyRunning);
  writer.writeBool(offsets[2], object.autoDebit);
  writer.writeString(offsets[3], object.behaviour.name);
  writer.writeString(offsets[4], object.categoryId);
  writer.writeDateTime(offsets[5], object.closedAt);
  writer.writeString(offsets[6], object.compounding.name);
  writer.writeDateTime(offsets[7], object.createdAt);
  writer.writeDouble(offsets[8], object.currentValue);
  writer.writeLong(offsets[9], object.dataVersion);
  writer.writeBool(offsets[10], object.deductedFromAccount);
  writer.writeDouble(offsets[11], object.fixedPrincipal);
  writer.writeDouble(offsets[12], object.fixedRate);
  writer.writeDateTime(offsets[13], object.fixedStart);
  writer.writeLong(offsets[14], object.fixedTenureMonths);
  writer.writeDouble(offsets[15], object.installment);
  writer.writeDouble(offsets[16], object.investedAmount);
  writer.writeString(offsets[17], object.investmentType);
  writer.writeDateTime(offsets[18], object.maturityDate);
  writer.writeBool(offsets[19], object.maturityHandled);
  writer.writeString(offsets[20], object.name);
  writer.writeString(offsets[21], object.notes);
  writer.writeDateTime(offsets[22], object.openingDate);
  writer.writeDouble(offsets[23], object.openingInvested);
  writer.writeDouble(offsets[24], object.openingValue);
  writer.writeString(offsets[25], object.payout.name);
  writer.writeObject<Schedule>(
    offsets[26],
    allOffsets,
    ScheduleSchema.serialize,
    object.sip,
  );
  writer.writeDouble(offsets[27], object.sipAmount);
  writer.writeLong(offsets[28], object.sipDate);
  writer.writeObjectList<ValueSnapshot>(
    offsets[29],
    allOffsets,
    ValueSnapshotSchema.serialize,
    object.snapshots,
  );
  writer.writeString(offsets[30], object.status.name);
  writer.writeString(offsets[31], object.stepUpKind.name);
  writer.writeDouble(offsets[32], object.stepUpValue);
  writer.writeString(offsets[33], object.uid);
  writer.writeDouble(offsets[34], object.units);
  writer.writeDateTime(offsets[35], object.updatedAt);
  writer.writeObjectList<Withdrawal>(
    offsets[36],
    allOffsets,
    WithdrawalSchema.serialize,
    object.withdrawals,
  );
}

Investment _investmentDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Investment();
  object.accountId = reader.readStringOrNull(offsets[0]);
  object.alreadyRunning = reader.readBool(offsets[1]);
  object.autoDebit = reader.readBool(offsets[2]);
  object.behaviour =
      _InvestmentbehaviourValueEnumMap[reader.readStringOrNull(offsets[3])] ??
      InvestmentBehaviour.market;
  object.categoryId = reader.readString(offsets[4]);
  object.closedAt = reader.readDateTimeOrNull(offsets[5]);
  object.compounding =
      _InvestmentcompoundingValueEnumMap[reader.readStringOrNull(offsets[6])] ??
      CompoundingFrequency.yearly;
  object.createdAt = reader.readDateTime(offsets[7]);
  object.currentValue = reader.readDoubleOrNull(offsets[8]);
  object.dataVersion = reader.readLong(offsets[9]);
  object.deductedFromAccount = reader.readBool(offsets[10]);
  object.fixedPrincipal = reader.readDoubleOrNull(offsets[11]);
  object.fixedRate = reader.readDoubleOrNull(offsets[12]);
  object.fixedStart = reader.readDateTimeOrNull(offsets[13]);
  object.fixedTenureMonths = reader.readLongOrNull(offsets[14]);
  object.id = id;
  object.installment = reader.readDoubleOrNull(offsets[15]);
  object.investedAmount = reader.readDoubleOrNull(offsets[16]);
  object.investmentType = reader.readString(offsets[17]);
  object.maturityDate = reader.readDateTimeOrNull(offsets[18]);
  object.maturityHandled = reader.readBool(offsets[19]);
  object.name = reader.readString(offsets[20]);
  object.notes = reader.readStringOrNull(offsets[21]);
  object.openingDate = reader.readDateTimeOrNull(offsets[22]);
  object.openingInvested = reader.readDouble(offsets[23]);
  object.openingValue = reader.readDoubleOrNull(offsets[24]);
  object.payout =
      _InvestmentpayoutValueEnumMap[reader.readStringOrNull(offsets[25])] ??
      PayoutType.cumulative;
  object.sip = reader.readObjectOrNull<Schedule>(
    offsets[26],
    ScheduleSchema.deserialize,
    allOffsets,
  );
  object.sipAmount = reader.readDoubleOrNull(offsets[27]);
  object.sipDate = reader.readLongOrNull(offsets[28]);
  object.snapshots =
      reader.readObjectList<ValueSnapshot>(
        offsets[29],
        ValueSnapshotSchema.deserialize,
        allOffsets,
        ValueSnapshot(),
      ) ??
      [];
  object.status =
      _InvestmentstatusValueEnumMap[reader.readStringOrNull(offsets[30])] ??
      InvestmentStatus.active;
  object.stepUpKind =
      _InvestmentstepUpKindValueEnumMap[reader.readStringOrNull(offsets[31])] ??
      StepUpKind.percent;
  object.stepUpValue = reader.readDouble(offsets[32]);
  object.uid = reader.readString(offsets[33]);
  object.units = reader.readDoubleOrNull(offsets[34]);
  object.updatedAt = reader.readDateTime(offsets[35]);
  object.withdrawals =
      reader.readObjectList<Withdrawal>(
        offsets[36],
        WithdrawalSchema.deserialize,
        allOffsets,
        Withdrawal(),
      ) ??
      [];
  return object;
}

P _investmentDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (_InvestmentbehaviourValueEnumMap[reader.readStringOrNull(
                offset,
              )] ??
              InvestmentBehaviour.market)
          as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (_InvestmentcompoundingValueEnumMap[reader.readStringOrNull(
                offset,
              )] ??
              CompoundingFrequency.yearly)
          as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    case 8:
      return (reader.readDoubleOrNull(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readBool(offset)) as P;
    case 11:
      return (reader.readDoubleOrNull(offset)) as P;
    case 12:
      return (reader.readDoubleOrNull(offset)) as P;
    case 13:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 14:
      return (reader.readLongOrNull(offset)) as P;
    case 15:
      return (reader.readDoubleOrNull(offset)) as P;
    case 16:
      return (reader.readDoubleOrNull(offset)) as P;
    case 17:
      return (reader.readString(offset)) as P;
    case 18:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 19:
      return (reader.readBool(offset)) as P;
    case 20:
      return (reader.readString(offset)) as P;
    case 21:
      return (reader.readStringOrNull(offset)) as P;
    case 22:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 23:
      return (reader.readDouble(offset)) as P;
    case 24:
      return (reader.readDoubleOrNull(offset)) as P;
    case 25:
      return (_InvestmentpayoutValueEnumMap[reader.readStringOrNull(offset)] ??
              PayoutType.cumulative)
          as P;
    case 26:
      return (reader.readObjectOrNull<Schedule>(
            offset,
            ScheduleSchema.deserialize,
            allOffsets,
          ))
          as P;
    case 27:
      return (reader.readDoubleOrNull(offset)) as P;
    case 28:
      return (reader.readLongOrNull(offset)) as P;
    case 29:
      return (reader.readObjectList<ValueSnapshot>(
                offset,
                ValueSnapshotSchema.deserialize,
                allOffsets,
                ValueSnapshot(),
              ) ??
              [])
          as P;
    case 30:
      return (_InvestmentstatusValueEnumMap[reader.readStringOrNull(offset)] ??
              InvestmentStatus.active)
          as P;
    case 31:
      return (_InvestmentstepUpKindValueEnumMap[reader.readStringOrNull(
                offset,
              )] ??
              StepUpKind.percent)
          as P;
    case 32:
      return (reader.readDouble(offset)) as P;
    case 33:
      return (reader.readString(offset)) as P;
    case 34:
      return (reader.readDoubleOrNull(offset)) as P;
    case 35:
      return (reader.readDateTime(offset)) as P;
    case 36:
      return (reader.readObjectList<Withdrawal>(
                offset,
                WithdrawalSchema.deserialize,
                allOffsets,
                Withdrawal(),
              ) ??
              [])
          as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _InvestmentbehaviourEnumValueMap = {
  r'market': r'market',
  r'fixedReturn': r'fixedReturn',
  r'other': r'other',
};
const _InvestmentbehaviourValueEnumMap = {
  r'market': InvestmentBehaviour.market,
  r'fixedReturn': InvestmentBehaviour.fixedReturn,
  r'other': InvestmentBehaviour.other,
};
const _InvestmentcompoundingEnumValueMap = {
  r'yearly': r'yearly',
  r'halfYearly': r'halfYearly',
  r'quarterly': r'quarterly',
  r'monthly': r'monthly',
};
const _InvestmentcompoundingValueEnumMap = {
  r'yearly': CompoundingFrequency.yearly,
  r'halfYearly': CompoundingFrequency.halfYearly,
  r'quarterly': CompoundingFrequency.quarterly,
  r'monthly': CompoundingFrequency.monthly,
};
const _InvestmentpayoutEnumValueMap = {
  r'cumulative': r'cumulative',
  r'monthly': r'monthly',
  r'quarterly': r'quarterly',
  r'yearly': r'yearly',
};
const _InvestmentpayoutValueEnumMap = {
  r'cumulative': PayoutType.cumulative,
  r'monthly': PayoutType.monthly,
  r'quarterly': PayoutType.quarterly,
  r'yearly': PayoutType.yearly,
};
const _InvestmentstatusEnumValueMap = {
  r'active': r'active',
  r'closed': r'closed',
};
const _InvestmentstatusValueEnumMap = {
  r'active': InvestmentStatus.active,
  r'closed': InvestmentStatus.closed,
};
const _InvestmentstepUpKindEnumValueMap = {
  r'percent': r'percent',
  r'amount': r'amount',
};
const _InvestmentstepUpKindValueEnumMap = {
  r'percent': StepUpKind.percent,
  r'amount': StepUpKind.amount,
};

Id _investmentGetId(Investment object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _investmentGetLinks(Investment object) {
  return [];
}

void _investmentAttach(IsarCollection<dynamic> col, Id id, Investment object) {
  object.id = id;
}

extension InvestmentQueryWhereSort
    on QueryBuilder<Investment, Investment, QWhere> {
  QueryBuilder<Investment, Investment, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension InvestmentQueryWhere
    on QueryBuilder<Investment, Investment, QWhereClause> {
  QueryBuilder<Investment, Investment, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<Investment, Investment, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Investment, Investment, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterWhereClause> idBetween(
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

extension InvestmentQueryFilter
    on QueryBuilder<Investment, Investment, QFilterCondition> {
  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  accountIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'accountId'),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  accountIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'accountId'),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> accountIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
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

  QueryBuilder<Investment, Investment, QAfterFilterCondition> accountIdLessThan(
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

  QueryBuilder<Investment, Investment, QAfterFilterCondition> accountIdBetween(
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

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
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

  QueryBuilder<Investment, Investment, QAfterFilterCondition> accountIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<Investment, Investment, QAfterFilterCondition> accountIdContains(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<Investment, Investment, QAfterFilterCondition> accountIdMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  accountIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'accountId', value: ''),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  accountIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'accountId', value: ''),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  alreadyRunningEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'alreadyRunning', value: value),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> autoDebitEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'autoDebit', value: value),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> behaviourEqualTo(
    InvestmentBehaviour value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'behaviour',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  behaviourGreaterThan(
    InvestmentBehaviour value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'behaviour',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> behaviourLessThan(
    InvestmentBehaviour value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'behaviour',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> behaviourBetween(
    InvestmentBehaviour lower,
    InvestmentBehaviour upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'behaviour',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  behaviourStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'behaviour',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> behaviourEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'behaviour',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> behaviourContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'behaviour',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> behaviourMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'behaviour',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  behaviourIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'behaviour', value: ''),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  behaviourIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'behaviour', value: ''),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> categoryIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
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

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
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

  QueryBuilder<Investment, Investment, QAfterFilterCondition> categoryIdBetween(
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

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
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

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
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

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
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

  QueryBuilder<Investment, Investment, QAfterFilterCondition> categoryIdMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  categoryIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'categoryId', value: ''),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  categoryIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'categoryId', value: ''),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> closedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'closedAt'),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  closedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'closedAt'),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> closedAtEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'closedAt', value: value),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  closedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'closedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> closedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'closedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> closedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'closedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  compoundingEqualTo(CompoundingFrequency value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'compounding',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  compoundingGreaterThan(
    CompoundingFrequency value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'compounding',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  compoundingLessThan(
    CompoundingFrequency value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'compounding',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  compoundingBetween(
    CompoundingFrequency lower,
    CompoundingFrequency upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'compounding',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  compoundingStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'compounding',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  compoundingEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'compounding',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  compoundingContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'compounding',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  compoundingMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'compounding',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  compoundingIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'compounding', value: ''),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  compoundingIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'compounding', value: ''),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> createdAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
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

  QueryBuilder<Investment, Investment, QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<Investment, Investment, QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  currentValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'currentValue'),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  currentValueIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'currentValue'),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  currentValueEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'currentValue',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  currentValueGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'currentValue',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  currentValueLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'currentValue',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  currentValueBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'currentValue',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  dataVersionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'dataVersion', value: value),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  dataVersionGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'dataVersion',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  dataVersionLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'dataVersion',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  dataVersionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'dataVersion',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  deductedFromAccountEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'deductedFromAccount', value: value),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  fixedPrincipalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'fixedPrincipal'),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  fixedPrincipalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'fixedPrincipal'),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  fixedPrincipalEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'fixedPrincipal',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  fixedPrincipalGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'fixedPrincipal',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  fixedPrincipalLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'fixedPrincipal',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  fixedPrincipalBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fixedPrincipal',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  fixedRateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'fixedRate'),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  fixedRateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'fixedRate'),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> fixedRateEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'fixedRate',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  fixedRateGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'fixedRate',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> fixedRateLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'fixedRate',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> fixedRateBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fixedRate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  fixedStartIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'fixedStart'),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  fixedStartIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'fixedStart'),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> fixedStartEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'fixedStart', value: value),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  fixedStartGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'fixedStart',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  fixedStartLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'fixedStart',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> fixedStartBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fixedStart',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  fixedTenureMonthsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'fixedTenureMonths'),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  fixedTenureMonthsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'fixedTenureMonths'),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  fixedTenureMonthsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'fixedTenureMonths', value: value),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  fixedTenureMonthsGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'fixedTenureMonths',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  fixedTenureMonthsLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'fixedTenureMonths',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  fixedTenureMonthsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fixedTenureMonths',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Investment, Investment, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Investment, Investment, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  installmentIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'installment'),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  installmentIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'installment'),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  installmentEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'installment',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  installmentGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'installment',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  installmentLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'installment',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  installmentBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'installment',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  investedAmountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'investedAmount'),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  investedAmountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'investedAmount'),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  investedAmountEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'investedAmount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  investedAmountGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'investedAmount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  investedAmountLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'investedAmount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  investedAmountBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'investedAmount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  investmentTypeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'investmentType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  investmentTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'investmentType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  investmentTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'investmentType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  investmentTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'investmentType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  investmentTypeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'investmentType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  investmentTypeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'investmentType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  investmentTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'investmentType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  investmentTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'investmentType',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  investmentTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'investmentType', value: ''),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  investmentTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'investmentType', value: ''),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  maturityDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'maturityDate'),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  maturityDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'maturityDate'),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  maturityDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'maturityDate', value: value),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  maturityDateGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'maturityDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  maturityDateLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'maturityDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  maturityDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'maturityDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  maturityHandledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'maturityHandled', value: value),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> nameEqualTo(
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

  QueryBuilder<Investment, Investment, QAfterFilterCondition> nameGreaterThan(
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

  QueryBuilder<Investment, Investment, QAfterFilterCondition> nameLessThan(
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

  QueryBuilder<Investment, Investment, QAfterFilterCondition> nameBetween(
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

  QueryBuilder<Investment, Investment, QAfterFilterCondition> nameStartsWith(
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

  QueryBuilder<Investment, Investment, QAfterFilterCondition> nameEndsWith(
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

  QueryBuilder<Investment, Investment, QAfterFilterCondition> nameContains(
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

  QueryBuilder<Investment, Investment, QAfterFilterCondition> nameMatches(
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

  QueryBuilder<Investment, Investment, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> notesEqualTo(
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

  QueryBuilder<Investment, Investment, QAfterFilterCondition> notesGreaterThan(
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

  QueryBuilder<Investment, Investment, QAfterFilterCondition> notesLessThan(
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

  QueryBuilder<Investment, Investment, QAfterFilterCondition> notesBetween(
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

  QueryBuilder<Investment, Investment, QAfterFilterCondition> notesStartsWith(
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

  QueryBuilder<Investment, Investment, QAfterFilterCondition> notesEndsWith(
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

  QueryBuilder<Investment, Investment, QAfterFilterCondition> notesContains(
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

  QueryBuilder<Investment, Investment, QAfterFilterCondition> notesMatches(
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

  QueryBuilder<Investment, Investment, QAfterFilterCondition> notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  openingDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'openingDate'),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  openingDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'openingDate'),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  openingDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'openingDate', value: value),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  openingDateGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'openingDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  openingDateLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'openingDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  openingDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'openingDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  openingInvestedEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'openingInvested',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  openingInvestedGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'openingInvested',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  openingInvestedLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'openingInvested',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  openingInvestedBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'openingInvested',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  openingValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'openingValue'),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  openingValueIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'openingValue'),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  openingValueEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'openingValue',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  openingValueGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'openingValue',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  openingValueLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'openingValue',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  openingValueBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'openingValue',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> payoutEqualTo(
    PayoutType value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'payout',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> payoutGreaterThan(
    PayoutType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'payout',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> payoutLessThan(
    PayoutType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'payout',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> payoutBetween(
    PayoutType lower,
    PayoutType upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'payout',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> payoutStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'payout',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> payoutEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'payout',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> payoutContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'payout',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> payoutMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'payout',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> payoutIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'payout', value: ''),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  payoutIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'payout', value: ''),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> sipIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'sip'),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> sipIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'sip'),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  sipAmountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'sipAmount'),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  sipAmountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'sipAmount'),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> sipAmountEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'sipAmount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  sipAmountGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sipAmount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> sipAmountLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sipAmount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> sipAmountBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sipAmount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> sipDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'sipDate'),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  sipDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'sipDate'),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> sipDateEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sipDate', value: value),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  sipDateGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sipDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> sipDateLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sipDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> sipDateBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sipDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  snapshotsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'snapshots', length, true, length, true);
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  snapshotsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'snapshots', 0, true, 0, true);
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  snapshotsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'snapshots', 0, false, 999999, true);
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  snapshotsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'snapshots', 0, true, length, include);
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  snapshotsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'snapshots', length, include, 999999, true);
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  snapshotsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'snapshots',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> statusEqualTo(
    InvestmentStatus value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> statusGreaterThan(
    InvestmentStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> statusLessThan(
    InvestmentStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> statusBetween(
    InvestmentStatus lower,
    InvestmentStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'status',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> statusContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> statusMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'status',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> stepUpKindEqualTo(
    StepUpKind value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'stepUpKind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  stepUpKindGreaterThan(
    StepUpKind value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'stepUpKind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  stepUpKindLessThan(
    StepUpKind value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'stepUpKind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> stepUpKindBetween(
    StepUpKind lower,
    StepUpKind upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'stepUpKind',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  stepUpKindStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'stepUpKind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  stepUpKindEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'stepUpKind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  stepUpKindContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'stepUpKind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> stepUpKindMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'stepUpKind',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  stepUpKindIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'stepUpKind', value: ''),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  stepUpKindIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'stepUpKind', value: ''),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  stepUpValueEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'stepUpValue',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  stepUpValueGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'stepUpValue',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  stepUpValueLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'stepUpValue',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  stepUpValueBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'stepUpValue',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> uidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> uidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> uidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> uidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'uid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> uidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> uidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> uidContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> uidMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'uid',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> uidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'uid', value: ''),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> uidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'uid', value: ''),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> unitsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'units'),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> unitsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'units'),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> unitsEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'units',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> unitsGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'units',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> unitsLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'units',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> unitsBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'units',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> updatedAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
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

  QueryBuilder<Investment, Investment, QAfterFilterCondition> updatedAtLessThan(
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

  QueryBuilder<Investment, Investment, QAfterFilterCondition> updatedAtBetween(
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

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  withdrawalsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'withdrawals', length, true, length, true);
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  withdrawalsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'withdrawals', 0, true, 0, true);
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  withdrawalsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'withdrawals', 0, false, 999999, true);
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  withdrawalsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'withdrawals', 0, true, length, include);
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  withdrawalsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'withdrawals', length, include, 999999, true);
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  withdrawalsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'withdrawals',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension InvestmentQueryObject
    on QueryBuilder<Investment, Investment, QFilterCondition> {
  QueryBuilder<Investment, Investment, QAfterFilterCondition> sip(
    FilterQuery<Schedule> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'sip');
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition> snapshotsElement(
    FilterQuery<ValueSnapshot> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'snapshots');
    });
  }

  QueryBuilder<Investment, Investment, QAfterFilterCondition>
  withdrawalsElement(FilterQuery<Withdrawal> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'withdrawals');
    });
  }
}

extension InvestmentQueryLinks
    on QueryBuilder<Investment, Investment, QFilterCondition> {}

extension InvestmentQuerySortBy
    on QueryBuilder<Investment, Investment, QSortBy> {
  QueryBuilder<Investment, Investment, QAfterSortBy> sortByAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountId', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountId', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByAlreadyRunning() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alreadyRunning', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy>
  sortByAlreadyRunningDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alreadyRunning', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByAutoDebit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoDebit', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByAutoDebitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoDebit', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByBehaviour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'behaviour', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByBehaviourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'behaviour', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByClosedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'closedAt', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByClosedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'closedAt', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByCompounding() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'compounding', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByCompoundingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'compounding', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByCurrentValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentValue', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByCurrentValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentValue', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByDataVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataVersion', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByDataVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataVersion', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy>
  sortByDeductedFromAccount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deductedFromAccount', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy>
  sortByDeductedFromAccountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deductedFromAccount', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByFixedPrincipal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fixedPrincipal', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy>
  sortByFixedPrincipalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fixedPrincipal', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByFixedRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fixedRate', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByFixedRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fixedRate', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByFixedStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fixedStart', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByFixedStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fixedStart', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByFixedTenureMonths() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fixedTenureMonths', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy>
  sortByFixedTenureMonthsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fixedTenureMonths', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByInstallment() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'installment', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByInstallmentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'installment', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByInvestedAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'investedAmount', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy>
  sortByInvestedAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'investedAmount', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByInvestmentType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'investmentType', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy>
  sortByInvestmentTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'investmentType', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByMaturityDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maturityDate', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByMaturityDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maturityDate', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByMaturityHandled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maturityHandled', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy>
  sortByMaturityHandledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maturityHandled', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByOpeningDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'openingDate', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByOpeningDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'openingDate', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByOpeningInvested() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'openingInvested', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy>
  sortByOpeningInvestedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'openingInvested', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByOpeningValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'openingValue', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByOpeningValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'openingValue', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByPayout() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payout', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByPayoutDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payout', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortBySipAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sipAmount', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortBySipAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sipAmount', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortBySipDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sipDate', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortBySipDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sipDate', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByStepUpKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stepUpKind', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByStepUpKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stepUpKind', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByStepUpValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stepUpValue', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByStepUpValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stepUpValue', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByUnits() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'units', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByUnitsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'units', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension InvestmentQuerySortThenBy
    on QueryBuilder<Investment, Investment, QSortThenBy> {
  QueryBuilder<Investment, Investment, QAfterSortBy> thenByAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountId', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountId', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByAlreadyRunning() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alreadyRunning', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy>
  thenByAlreadyRunningDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alreadyRunning', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByAutoDebit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoDebit', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByAutoDebitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoDebit', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByBehaviour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'behaviour', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByBehaviourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'behaviour', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByClosedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'closedAt', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByClosedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'closedAt', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByCompounding() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'compounding', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByCompoundingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'compounding', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByCurrentValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentValue', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByCurrentValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentValue', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByDataVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataVersion', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByDataVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataVersion', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy>
  thenByDeductedFromAccount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deductedFromAccount', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy>
  thenByDeductedFromAccountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deductedFromAccount', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByFixedPrincipal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fixedPrincipal', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy>
  thenByFixedPrincipalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fixedPrincipal', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByFixedRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fixedRate', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByFixedRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fixedRate', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByFixedStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fixedStart', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByFixedStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fixedStart', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByFixedTenureMonths() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fixedTenureMonths', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy>
  thenByFixedTenureMonthsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fixedTenureMonths', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByInstallment() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'installment', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByInstallmentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'installment', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByInvestedAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'investedAmount', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy>
  thenByInvestedAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'investedAmount', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByInvestmentType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'investmentType', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy>
  thenByInvestmentTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'investmentType', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByMaturityDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maturityDate', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByMaturityDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maturityDate', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByMaturityHandled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maturityHandled', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy>
  thenByMaturityHandledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maturityHandled', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByOpeningDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'openingDate', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByOpeningDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'openingDate', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByOpeningInvested() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'openingInvested', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy>
  thenByOpeningInvestedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'openingInvested', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByOpeningValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'openingValue', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByOpeningValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'openingValue', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByPayout() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payout', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByPayoutDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payout', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenBySipAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sipAmount', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenBySipAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sipAmount', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenBySipDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sipDate', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenBySipDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sipDate', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByStepUpKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stepUpKind', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByStepUpKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stepUpKind', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByStepUpValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stepUpValue', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByStepUpValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stepUpValue', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByUnits() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'units', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByUnitsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'units', Sort.desc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<Investment, Investment, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension InvestmentQueryWhereDistinct
    on QueryBuilder<Investment, Investment, QDistinct> {
  QueryBuilder<Investment, Investment, QDistinct> distinctByAccountId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'accountId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Investment, Investment, QDistinct> distinctByAlreadyRunning() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'alreadyRunning');
    });
  }

  QueryBuilder<Investment, Investment, QDistinct> distinctByAutoDebit() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autoDebit');
    });
  }

  QueryBuilder<Investment, Investment, QDistinct> distinctByBehaviour({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'behaviour', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Investment, Investment, QDistinct> distinctByCategoryId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'categoryId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Investment, Investment, QDistinct> distinctByClosedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'closedAt');
    });
  }

  QueryBuilder<Investment, Investment, QDistinct> distinctByCompounding({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'compounding', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Investment, Investment, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<Investment, Investment, QDistinct> distinctByCurrentValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentValue');
    });
  }

  QueryBuilder<Investment, Investment, QDistinct> distinctByDataVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dataVersion');
    });
  }

  QueryBuilder<Investment, Investment, QDistinct>
  distinctByDeductedFromAccount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deductedFromAccount');
    });
  }

  QueryBuilder<Investment, Investment, QDistinct> distinctByFixedPrincipal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fixedPrincipal');
    });
  }

  QueryBuilder<Investment, Investment, QDistinct> distinctByFixedRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fixedRate');
    });
  }

  QueryBuilder<Investment, Investment, QDistinct> distinctByFixedStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fixedStart');
    });
  }

  QueryBuilder<Investment, Investment, QDistinct>
  distinctByFixedTenureMonths() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fixedTenureMonths');
    });
  }

  QueryBuilder<Investment, Investment, QDistinct> distinctByInstallment() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'installment');
    });
  }

  QueryBuilder<Investment, Investment, QDistinct> distinctByInvestedAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'investedAmount');
    });
  }

  QueryBuilder<Investment, Investment, QDistinct> distinctByInvestmentType({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'investmentType',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Investment, Investment, QDistinct> distinctByMaturityDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maturityDate');
    });
  }

  QueryBuilder<Investment, Investment, QDistinct> distinctByMaturityHandled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maturityHandled');
    });
  }

  QueryBuilder<Investment, Investment, QDistinct> distinctByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Investment, Investment, QDistinct> distinctByNotes({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Investment, Investment, QDistinct> distinctByOpeningDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'openingDate');
    });
  }

  QueryBuilder<Investment, Investment, QDistinct> distinctByOpeningInvested() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'openingInvested');
    });
  }

  QueryBuilder<Investment, Investment, QDistinct> distinctByOpeningValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'openingValue');
    });
  }

  QueryBuilder<Investment, Investment, QDistinct> distinctByPayout({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'payout', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Investment, Investment, QDistinct> distinctBySipAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sipAmount');
    });
  }

  QueryBuilder<Investment, Investment, QDistinct> distinctBySipDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sipDate');
    });
  }

  QueryBuilder<Investment, Investment, QDistinct> distinctByStatus({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Investment, Investment, QDistinct> distinctByStepUpKind({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stepUpKind', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Investment, Investment, QDistinct> distinctByStepUpValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stepUpValue');
    });
  }

  QueryBuilder<Investment, Investment, QDistinct> distinctByUid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Investment, Investment, QDistinct> distinctByUnits() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'units');
    });
  }

  QueryBuilder<Investment, Investment, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension InvestmentQueryProperty
    on QueryBuilder<Investment, Investment, QQueryProperty> {
  QueryBuilder<Investment, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Investment, String?, QQueryOperations> accountIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'accountId');
    });
  }

  QueryBuilder<Investment, bool, QQueryOperations> alreadyRunningProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'alreadyRunning');
    });
  }

  QueryBuilder<Investment, bool, QQueryOperations> autoDebitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autoDebit');
    });
  }

  QueryBuilder<Investment, InvestmentBehaviour, QQueryOperations>
  behaviourProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'behaviour');
    });
  }

  QueryBuilder<Investment, String, QQueryOperations> categoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'categoryId');
    });
  }

  QueryBuilder<Investment, DateTime?, QQueryOperations> closedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'closedAt');
    });
  }

  QueryBuilder<Investment, CompoundingFrequency, QQueryOperations>
  compoundingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'compounding');
    });
  }

  QueryBuilder<Investment, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<Investment, double?, QQueryOperations> currentValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentValue');
    });
  }

  QueryBuilder<Investment, int, QQueryOperations> dataVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dataVersion');
    });
  }

  QueryBuilder<Investment, bool, QQueryOperations>
  deductedFromAccountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deductedFromAccount');
    });
  }

  QueryBuilder<Investment, double?, QQueryOperations> fixedPrincipalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fixedPrincipal');
    });
  }

  QueryBuilder<Investment, double?, QQueryOperations> fixedRateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fixedRate');
    });
  }

  QueryBuilder<Investment, DateTime?, QQueryOperations> fixedStartProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fixedStart');
    });
  }

  QueryBuilder<Investment, int?, QQueryOperations> fixedTenureMonthsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fixedTenureMonths');
    });
  }

  QueryBuilder<Investment, double?, QQueryOperations> installmentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'installment');
    });
  }

  QueryBuilder<Investment, double?, QQueryOperations> investedAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'investedAmount');
    });
  }

  QueryBuilder<Investment, String, QQueryOperations> investmentTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'investmentType');
    });
  }

  QueryBuilder<Investment, DateTime?, QQueryOperations> maturityDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maturityDate');
    });
  }

  QueryBuilder<Investment, bool, QQueryOperations> maturityHandledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maturityHandled');
    });
  }

  QueryBuilder<Investment, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<Investment, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<Investment, DateTime?, QQueryOperations> openingDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'openingDate');
    });
  }

  QueryBuilder<Investment, double, QQueryOperations> openingInvestedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'openingInvested');
    });
  }

  QueryBuilder<Investment, double?, QQueryOperations> openingValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'openingValue');
    });
  }

  QueryBuilder<Investment, PayoutType, QQueryOperations> payoutProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'payout');
    });
  }

  QueryBuilder<Investment, Schedule?, QQueryOperations> sipProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sip');
    });
  }

  QueryBuilder<Investment, double?, QQueryOperations> sipAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sipAmount');
    });
  }

  QueryBuilder<Investment, int?, QQueryOperations> sipDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sipDate');
    });
  }

  QueryBuilder<Investment, List<ValueSnapshot>, QQueryOperations>
  snapshotsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'snapshots');
    });
  }

  QueryBuilder<Investment, InvestmentStatus, QQueryOperations>
  statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<Investment, StepUpKind, QQueryOperations> stepUpKindProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stepUpKind');
    });
  }

  QueryBuilder<Investment, double, QQueryOperations> stepUpValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stepUpValue');
    });
  }

  QueryBuilder<Investment, String, QQueryOperations> uidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uid');
    });
  }

  QueryBuilder<Investment, double?, QQueryOperations> unitsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'units');
    });
  }

  QueryBuilder<Investment, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<Investment, List<Withdrawal>, QQueryOperations>
  withdrawalsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'withdrawals');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const ValueSnapshotSchema = Schema(
  name: r'ValueSnapshot',
  id: 6321547962994393003,
  properties: {
    r'date': PropertySchema(id: 0, name: r'date', type: IsarType.dateTime),
    r'value': PropertySchema(id: 1, name: r'value', type: IsarType.double),
  },

  estimateSize: _valueSnapshotEstimateSize,
  serialize: _valueSnapshotSerialize,
  deserialize: _valueSnapshotDeserialize,
  deserializeProp: _valueSnapshotDeserializeProp,
);

int _valueSnapshotEstimateSize(
  ValueSnapshot object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _valueSnapshotSerialize(
  ValueSnapshot object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.date);
  writer.writeDouble(offsets[1], object.value);
}

ValueSnapshot _valueSnapshotDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ValueSnapshot();
  object.date = reader.readDateTimeOrNull(offsets[0]);
  object.value = reader.readDouble(offsets[1]);
  return object;
}

P _valueSnapshotDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension ValueSnapshotQueryFilter
    on QueryBuilder<ValueSnapshot, ValueSnapshot, QFilterCondition> {
  QueryBuilder<ValueSnapshot, ValueSnapshot, QAfterFilterCondition>
  dateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'date'),
      );
    });
  }

  QueryBuilder<ValueSnapshot, ValueSnapshot, QAfterFilterCondition>
  dateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'date'),
      );
    });
  }

  QueryBuilder<ValueSnapshot, ValueSnapshot, QAfterFilterCondition> dateEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'date', value: value),
      );
    });
  }

  QueryBuilder<ValueSnapshot, ValueSnapshot, QAfterFilterCondition>
  dateGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'date',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ValueSnapshot, ValueSnapshot, QAfterFilterCondition>
  dateLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'date',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ValueSnapshot, ValueSnapshot, QAfterFilterCondition> dateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'date',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ValueSnapshot, ValueSnapshot, QAfterFilterCondition>
  valueEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'value',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<ValueSnapshot, ValueSnapshot, QAfterFilterCondition>
  valueGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'value',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<ValueSnapshot, ValueSnapshot, QAfterFilterCondition>
  valueLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'value',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<ValueSnapshot, ValueSnapshot, QAfterFilterCondition>
  valueBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'value',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }
}

extension ValueSnapshotQueryObject
    on QueryBuilder<ValueSnapshot, ValueSnapshot, QFilterCondition> {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const WithdrawalSchema = Schema(
  name: r'Withdrawal',
  id: -5917806868690933003,
  properties: {
    r'accountId': PropertySchema(
      id: 0,
      name: r'accountId',
      type: IsarType.string,
    ),
    r'charges': PropertySchema(id: 1, name: r'charges', type: IsarType.double),
    r'date': PropertySchema(id: 2, name: r'date', type: IsarType.dateTime),
    r'investedReduction': PropertySchema(
      id: 3,
      name: r'investedReduction',
      type: IsarType.double,
    ),
    r'realizedGain': PropertySchema(
      id: 4,
      name: r'realizedGain',
      type: IsarType.double,
    ),
    r'received': PropertySchema(
      id: 5,
      name: r'received',
      type: IsarType.double,
    ),
    r'redeemed': PropertySchema(
      id: 6,
      name: r'redeemed',
      type: IsarType.double,
    ),
    r'transactionId': PropertySchema(
      id: 7,
      name: r'transactionId',
      type: IsarType.long,
    ),
  },

  estimateSize: _withdrawalEstimateSize,
  serialize: _withdrawalSerialize,
  deserialize: _withdrawalDeserialize,
  deserializeProp: _withdrawalDeserializeProp,
);

int _withdrawalEstimateSize(
  Withdrawal object,
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
  return bytesCount;
}

void _withdrawalSerialize(
  Withdrawal object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.accountId);
  writer.writeDouble(offsets[1], object.charges);
  writer.writeDateTime(offsets[2], object.date);
  writer.writeDouble(offsets[3], object.investedReduction);
  writer.writeDouble(offsets[4], object.realizedGain);
  writer.writeDouble(offsets[5], object.received);
  writer.writeDouble(offsets[6], object.redeemed);
  writer.writeLong(offsets[7], object.transactionId);
}

Withdrawal _withdrawalDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Withdrawal();
  object.accountId = reader.readStringOrNull(offsets[0]);
  object.charges = reader.readDouble(offsets[1]);
  object.date = reader.readDateTimeOrNull(offsets[2]);
  object.investedReduction = reader.readDouble(offsets[3]);
  object.realizedGain = reader.readDouble(offsets[4]);
  object.received = reader.readDouble(offsets[5]);
  object.redeemed = reader.readDouble(offsets[6]);
  object.transactionId = reader.readLongOrNull(offsets[7]);
  return object;
}

P _withdrawalDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readDouble(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension WithdrawalQueryFilter
    on QueryBuilder<Withdrawal, Withdrawal, QFilterCondition> {
  QueryBuilder<Withdrawal, Withdrawal, QAfterFilterCondition>
  accountIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'accountId'),
      );
    });
  }

  QueryBuilder<Withdrawal, Withdrawal, QAfterFilterCondition>
  accountIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'accountId'),
      );
    });
  }

  QueryBuilder<Withdrawal, Withdrawal, QAfterFilterCondition> accountIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<Withdrawal, Withdrawal, QAfterFilterCondition>
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

  QueryBuilder<Withdrawal, Withdrawal, QAfterFilterCondition> accountIdLessThan(
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

  QueryBuilder<Withdrawal, Withdrawal, QAfterFilterCondition> accountIdBetween(
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

  QueryBuilder<Withdrawal, Withdrawal, QAfterFilterCondition>
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

  QueryBuilder<Withdrawal, Withdrawal, QAfterFilterCondition> accountIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<Withdrawal, Withdrawal, QAfterFilterCondition> accountIdContains(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<Withdrawal, Withdrawal, QAfterFilterCondition> accountIdMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<Withdrawal, Withdrawal, QAfterFilterCondition>
  accountIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'accountId', value: ''),
      );
    });
  }

  QueryBuilder<Withdrawal, Withdrawal, QAfterFilterCondition>
  accountIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'accountId', value: ''),
      );
    });
  }

  QueryBuilder<Withdrawal, Withdrawal, QAfterFilterCondition> chargesEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'charges',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Withdrawal, Withdrawal, QAfterFilterCondition>
  chargesGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'charges',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Withdrawal, Withdrawal, QAfterFilterCondition> chargesLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'charges',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Withdrawal, Withdrawal, QAfterFilterCondition> chargesBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'charges',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Withdrawal, Withdrawal, QAfterFilterCondition> dateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'date'),
      );
    });
  }

  QueryBuilder<Withdrawal, Withdrawal, QAfterFilterCondition> dateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'date'),
      );
    });
  }

  QueryBuilder<Withdrawal, Withdrawal, QAfterFilterCondition> dateEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'date', value: value),
      );
    });
  }

  QueryBuilder<Withdrawal, Withdrawal, QAfterFilterCondition> dateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'date',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Withdrawal, Withdrawal, QAfterFilterCondition> dateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'date',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Withdrawal, Withdrawal, QAfterFilterCondition> dateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'date',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Withdrawal, Withdrawal, QAfterFilterCondition>
  investedReductionEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'investedReduction',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Withdrawal, Withdrawal, QAfterFilterCondition>
  investedReductionGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'investedReduction',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Withdrawal, Withdrawal, QAfterFilterCondition>
  investedReductionLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'investedReduction',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Withdrawal, Withdrawal, QAfterFilterCondition>
  investedReductionBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'investedReduction',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Withdrawal, Withdrawal, QAfterFilterCondition>
  realizedGainEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'realizedGain',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Withdrawal, Withdrawal, QAfterFilterCondition>
  realizedGainGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'realizedGain',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Withdrawal, Withdrawal, QAfterFilterCondition>
  realizedGainLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'realizedGain',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Withdrawal, Withdrawal, QAfterFilterCondition>
  realizedGainBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'realizedGain',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Withdrawal, Withdrawal, QAfterFilterCondition> receivedEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'received',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Withdrawal, Withdrawal, QAfterFilterCondition>
  receivedGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'received',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Withdrawal, Withdrawal, QAfterFilterCondition> receivedLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'received',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Withdrawal, Withdrawal, QAfterFilterCondition> receivedBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'received',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Withdrawal, Withdrawal, QAfterFilterCondition> redeemedEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'redeemed',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Withdrawal, Withdrawal, QAfterFilterCondition>
  redeemedGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'redeemed',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Withdrawal, Withdrawal, QAfterFilterCondition> redeemedLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'redeemed',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Withdrawal, Withdrawal, QAfterFilterCondition> redeemedBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'redeemed',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Withdrawal, Withdrawal, QAfterFilterCondition>
  transactionIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'transactionId'),
      );
    });
  }

  QueryBuilder<Withdrawal, Withdrawal, QAfterFilterCondition>
  transactionIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'transactionId'),
      );
    });
  }

  QueryBuilder<Withdrawal, Withdrawal, QAfterFilterCondition>
  transactionIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'transactionId', value: value),
      );
    });
  }

  QueryBuilder<Withdrawal, Withdrawal, QAfterFilterCondition>
  transactionIdGreaterThan(int? value, {bool include = false}) {
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

  QueryBuilder<Withdrawal, Withdrawal, QAfterFilterCondition>
  transactionIdLessThan(int? value, {bool include = false}) {
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

  QueryBuilder<Withdrawal, Withdrawal, QAfterFilterCondition>
  transactionIdBetween(
    int? lower,
    int? upper, {
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

extension WithdrawalQueryObject
    on QueryBuilder<Withdrawal, Withdrawal, QFilterCondition> {}
