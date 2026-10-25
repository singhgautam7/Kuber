// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loan.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLoanCollection on Isar {
  IsarCollection<Loan> get loans => this.collection();
}

const LoanSchema = CollectionSchema(
  name: r'Loan',
  id: 3165146227223573679,
  properties: {
    r'accountId': PropertySchema(
      id: 0,
      name: r'accountId',
      type: IsarType.string,
    ),
    r'adjustment': PropertySchema(
      id: 1,
      name: r'adjustment',
      type: IsarType.double,
    ),
    r'alreadyRunning': PropertySchema(
      id: 2,
      name: r'alreadyRunning',
      type: IsarType.bool,
    ),
    r'annualRate': PropertySchema(
      id: 3,
      name: r'annualRate',
      type: IsarType.double,
    ),
    r'autoAddTransaction': PropertySchema(
      id: 4,
      name: r'autoAddTransaction',
      type: IsarType.bool,
    ),
    r'billDate': PropertySchema(id: 5, name: r'billDate', type: IsarType.long),
    r'categoryId': PropertySchema(
      id: 6,
      name: r'categoryId',
      type: IsarType.string,
    ),
    r'closedAt': PropertySchema(
      id: 7,
      name: r'closedAt',
      type: IsarType.dateTime,
    ),
    r'countOnlyInterest': PropertySchema(
      id: 8,
      name: r'countOnlyInterest',
      type: IsarType.bool,
    ),
    r'countOnlyInterestFrom': PropertySchema(
      id: 9,
      name: r'countOnlyInterestFrom',
      type: IsarType.dateTime,
    ),
    r'createdAt': PropertySchema(
      id: 10,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'dataVersion': PropertySchema(
      id: 11,
      name: r'dataVersion',
      type: IsarType.long,
    ),
    r'emiAmount': PropertySchema(
      id: 12,
      name: r'emiAmount',
      type: IsarType.double,
    ),
    r'emisPaidBefore': PropertySchema(
      id: 13,
      name: r'emisPaidBefore',
      type: IsarType.long,
    ),
    r'endDate': PropertySchema(
      id: 14,
      name: r'endDate',
      type: IsarType.dateTime,
    ),
    r'events': PropertySchema(
      id: 15,
      name: r'events',
      type: IsarType.objectList,

      target: r'LoanEvent',
    ),
    r'interestOnlyMonths': PropertySchema(
      id: 16,
      name: r'interestOnlyMonths',
      type: IsarType.long,
    ),
    r'interestPaidBefore': PropertySchema(
      id: 17,
      name: r'interestPaidBefore',
      type: IsarType.double,
    ),
    r'interestRate': PropertySchema(
      id: 18,
      name: r'interestRate',
      type: IsarType.double,
    ),
    r'interestType': PropertySchema(
      id: 19,
      name: r'interestType',
      type: IsarType.string,
      enumMap: _LoaninterestTypeEnumValueMap,
    ),
    r'isCompleted': PropertySchema(
      id: 20,
      name: r'isCompleted',
      type: IsarType.bool,
    ),
    r'lenderName': PropertySchema(
      id: 21,
      name: r'lenderName',
      type: IsarType.string,
    ),
    r'loanStartDate': PropertySchema(
      id: 22,
      name: r'loanStartDate',
      type: IsarType.dateTime,
    ),
    r'loanType': PropertySchema(
      id: 23,
      name: r'loanType',
      type: IsarType.string,
    ),
    r'mode': PropertySchema(
      id: 24,
      name: r'mode',
      type: IsarType.string,
      enumMap: _LoanmodeEnumValueMap,
    ),
    r'name': PropertySchema(id: 25, name: r'name', type: IsarType.string),
    r'notes': PropertySchema(id: 26, name: r'notes', type: IsarType.string),
    r'outstandingAtStart': PropertySchema(
      id: 27,
      name: r'outstandingAtStart',
      type: IsarType.double,
    ),
    r'principalAmount': PropertySchema(
      id: 28,
      name: r'principalAmount',
      type: IsarType.double,
    ),
    r'principalPaidBefore': PropertySchema(
      id: 29,
      name: r'principalPaidBefore',
      type: IsarType.double,
    ),
    r'rateType': PropertySchema(
      id: 30,
      name: r'rateType',
      type: IsarType.string,
    ),
    r'referenceNumber': PropertySchema(
      id: 31,
      name: r'referenceNumber',
      type: IsarType.string,
    ),
    r'schedule': PropertySchema(
      id: 32,
      name: r'schedule',
      type: IsarType.object,

      target: r'Schedule',
    ),
    r'startDate': PropertySchema(
      id: 33,
      name: r'startDate',
      type: IsarType.dateTime,
    ),
    r'startingPoint': PropertySchema(
      id: 34,
      name: r'startingPoint',
      type: IsarType.string,
      enumMap: _LoanstartingPointEnumValueMap,
    ),
    r'tenureMonths': PropertySchema(
      id: 35,
      name: r'tenureMonths',
      type: IsarType.long,
    ),
    r'uid': PropertySchema(id: 36, name: r'uid', type: IsarType.string),
    r'updatedAt': PropertySchema(
      id: 37,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _loanEstimateSize,
  serialize: _loanSerialize,
  deserialize: _loanDeserialize,
  deserializeProp: _loanDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {r'Schedule': ScheduleSchema, r'LoanEvent': LoanEventSchema},

  getId: _loanGetId,
  getLinks: _loanGetLinks,
  attach: _loanAttach,
  version: '3.3.2',
);

int _loanEstimateSize(
  Loan object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.accountId.length * 3;
  bytesCount += 3 + object.categoryId.length * 3;
  bytesCount += 3 + object.events.length * 3;
  {
    final offsets = allOffsets[LoanEvent]!;
    for (var i = 0; i < object.events.length; i++) {
      final value = object.events[i];
      bytesCount += LoanEventSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.interestType.name.length * 3;
  bytesCount += 3 + object.lenderName.length * 3;
  bytesCount += 3 + object.loanType.length * 3;
  bytesCount += 3 + object.mode.name.length * 3;
  bytesCount += 3 + object.name.length * 3;
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.rateType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.referenceNumber;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.schedule;
    if (value != null) {
      bytesCount +=
          3 +
          ScheduleSchema.estimateSize(value, allOffsets[Schedule]!, allOffsets);
    }
  }
  bytesCount += 3 + object.startingPoint.name.length * 3;
  bytesCount += 3 + object.uid.length * 3;
  return bytesCount;
}

void _loanSerialize(
  Loan object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.accountId);
  writer.writeDouble(offsets[1], object.adjustment);
  writer.writeBool(offsets[2], object.alreadyRunning);
  writer.writeDouble(offsets[3], object.annualRate);
  writer.writeBool(offsets[4], object.autoAddTransaction);
  writer.writeLong(offsets[5], object.billDate);
  writer.writeString(offsets[6], object.categoryId);
  writer.writeDateTime(offsets[7], object.closedAt);
  writer.writeBool(offsets[8], object.countOnlyInterest);
  writer.writeDateTime(offsets[9], object.countOnlyInterestFrom);
  writer.writeDateTime(offsets[10], object.createdAt);
  writer.writeLong(offsets[11], object.dataVersion);
  writer.writeDouble(offsets[12], object.emiAmount);
  writer.writeLong(offsets[13], object.emisPaidBefore);
  writer.writeDateTime(offsets[14], object.endDate);
  writer.writeObjectList<LoanEvent>(
    offsets[15],
    allOffsets,
    LoanEventSchema.serialize,
    object.events,
  );
  writer.writeLong(offsets[16], object.interestOnlyMonths);
  writer.writeDouble(offsets[17], object.interestPaidBefore);
  writer.writeDouble(offsets[18], object.interestRate);
  writer.writeString(offsets[19], object.interestType.name);
  writer.writeBool(offsets[20], object.isCompleted);
  writer.writeString(offsets[21], object.lenderName);
  writer.writeDateTime(offsets[22], object.loanStartDate);
  writer.writeString(offsets[23], object.loanType);
  writer.writeString(offsets[24], object.mode.name);
  writer.writeString(offsets[25], object.name);
  writer.writeString(offsets[26], object.notes);
  writer.writeDouble(offsets[27], object.outstandingAtStart);
  writer.writeDouble(offsets[28], object.principalAmount);
  writer.writeDouble(offsets[29], object.principalPaidBefore);
  writer.writeString(offsets[30], object.rateType);
  writer.writeString(offsets[31], object.referenceNumber);
  writer.writeObject<Schedule>(
    offsets[32],
    allOffsets,
    ScheduleSchema.serialize,
    object.schedule,
  );
  writer.writeDateTime(offsets[33], object.startDate);
  writer.writeString(offsets[34], object.startingPoint.name);
  writer.writeLong(offsets[35], object.tenureMonths);
  writer.writeString(offsets[36], object.uid);
  writer.writeDateTime(offsets[37], object.updatedAt);
}

Loan _loanDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Loan();
  object.accountId = reader.readString(offsets[0]);
  object.adjustment = reader.readDouble(offsets[1]);
  object.alreadyRunning = reader.readBool(offsets[2]);
  object.annualRate = reader.readDoubleOrNull(offsets[3]);
  object.autoAddTransaction = reader.readBool(offsets[4]);
  object.billDate = reader.readLong(offsets[5]);
  object.categoryId = reader.readString(offsets[6]);
  object.closedAt = reader.readDateTimeOrNull(offsets[7]);
  object.countOnlyInterest = reader.readBool(offsets[8]);
  object.countOnlyInterestFrom = reader.readDateTimeOrNull(offsets[9]);
  object.createdAt = reader.readDateTime(offsets[10]);
  object.dataVersion = reader.readLong(offsets[11]);
  object.emiAmount = reader.readDouble(offsets[12]);
  object.emisPaidBefore = reader.readLong(offsets[13]);
  object.endDate = reader.readDateTimeOrNull(offsets[14]);
  object.events =
      reader.readObjectList<LoanEvent>(
        offsets[15],
        LoanEventSchema.deserialize,
        allOffsets,
        LoanEvent(),
      ) ??
      [];
  object.id = id;
  object.interestOnlyMonths = reader.readLong(offsets[16]);
  object.interestPaidBefore = reader.readDouble(offsets[17]);
  object.interestRate = reader.readDoubleOrNull(offsets[18]);
  object.interestType =
      _LoaninterestTypeValueEnumMap[reader.readStringOrNull(offsets[19])] ??
      LoanInterestType.reducingBalance;
  object.isCompleted = reader.readBool(offsets[20]);
  object.lenderName = reader.readString(offsets[21]);
  object.loanStartDate = reader.readDateTimeOrNull(offsets[22]);
  object.loanType = reader.readString(offsets[23]);
  object.mode =
      _LoanmodeValueEnumMap[reader.readStringOrNull(offsets[24])] ??
      LoanMode.simple;
  object.name = reader.readString(offsets[25]);
  object.notes = reader.readStringOrNull(offsets[26]);
  object.outstandingAtStart = reader.readDoubleOrNull(offsets[27]);
  object.principalAmount = reader.readDouble(offsets[28]);
  object.principalPaidBefore = reader.readDouble(offsets[29]);
  object.rateType = reader.readStringOrNull(offsets[30]);
  object.referenceNumber = reader.readStringOrNull(offsets[31]);
  object.schedule = reader.readObjectOrNull<Schedule>(
    offsets[32],
    ScheduleSchema.deserialize,
    allOffsets,
  );
  object.startDate = reader.readDateTime(offsets[33]);
  object.startingPoint =
      _LoanstartingPointValueEnumMap[reader.readStringOrNull(offsets[34])] ??
      LoanStartingPoint.originalDetails;
  object.tenureMonths = reader.readLongOrNull(offsets[35]);
  object.uid = reader.readString(offsets[36]);
  object.updatedAt = reader.readDateTime(offsets[37]);
  return object;
}

P _loanDeserializeProp<P>(
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
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readDoubleOrNull(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 10:
      return (reader.readDateTime(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (reader.readDouble(offset)) as P;
    case 13:
      return (reader.readLong(offset)) as P;
    case 14:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 15:
      return (reader.readObjectList<LoanEvent>(
                offset,
                LoanEventSchema.deserialize,
                allOffsets,
                LoanEvent(),
              ) ??
              [])
          as P;
    case 16:
      return (reader.readLong(offset)) as P;
    case 17:
      return (reader.readDouble(offset)) as P;
    case 18:
      return (reader.readDoubleOrNull(offset)) as P;
    case 19:
      return (_LoaninterestTypeValueEnumMap[reader.readStringOrNull(offset)] ??
              LoanInterestType.reducingBalance)
          as P;
    case 20:
      return (reader.readBool(offset)) as P;
    case 21:
      return (reader.readString(offset)) as P;
    case 22:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 23:
      return (reader.readString(offset)) as P;
    case 24:
      return (_LoanmodeValueEnumMap[reader.readStringOrNull(offset)] ??
              LoanMode.simple)
          as P;
    case 25:
      return (reader.readString(offset)) as P;
    case 26:
      return (reader.readStringOrNull(offset)) as P;
    case 27:
      return (reader.readDoubleOrNull(offset)) as P;
    case 28:
      return (reader.readDouble(offset)) as P;
    case 29:
      return (reader.readDouble(offset)) as P;
    case 30:
      return (reader.readStringOrNull(offset)) as P;
    case 31:
      return (reader.readStringOrNull(offset)) as P;
    case 32:
      return (reader.readObjectOrNull<Schedule>(
            offset,
            ScheduleSchema.deserialize,
            allOffsets,
          ))
          as P;
    case 33:
      return (reader.readDateTime(offset)) as P;
    case 34:
      return (_LoanstartingPointValueEnumMap[reader.readStringOrNull(offset)] ??
              LoanStartingPoint.originalDetails)
          as P;
    case 35:
      return (reader.readLongOrNull(offset)) as P;
    case 36:
      return (reader.readString(offset)) as P;
    case 37:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _LoaninterestTypeEnumValueMap = {
  r'reducingBalance': r'reducingBalance',
  r'flatRate': r'flatRate',
  r'interestOnlyFirst': r'interestOnlyFirst',
};
const _LoaninterestTypeValueEnumMap = {
  r'reducingBalance': LoanInterestType.reducingBalance,
  r'flatRate': LoanInterestType.flatRate,
  r'interestOnlyFirst': LoanInterestType.interestOnlyFirst,
};
const _LoanmodeEnumValueMap = {r'simple': r'simple', r'advanced': r'advanced'};
const _LoanmodeValueEnumMap = {
  r'simple': LoanMode.simple,
  r'advanced': LoanMode.advanced,
};
const _LoanstartingPointEnumValueMap = {
  r'originalDetails': r'originalDetails',
  r'outstandingToday': r'outstandingToday',
  r'trackEmiOnly': r'trackEmiOnly',
};
const _LoanstartingPointValueEnumMap = {
  r'originalDetails': LoanStartingPoint.originalDetails,
  r'outstandingToday': LoanStartingPoint.outstandingToday,
  r'trackEmiOnly': LoanStartingPoint.trackEmiOnly,
};

Id _loanGetId(Loan object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _loanGetLinks(Loan object) {
  return [];
}

void _loanAttach(IsarCollection<dynamic> col, Id id, Loan object) {
  object.id = id;
}

extension LoanQueryWhereSort on QueryBuilder<Loan, Loan, QWhere> {
  QueryBuilder<Loan, Loan, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LoanQueryWhere on QueryBuilder<Loan, Loan, QWhereClause> {
  QueryBuilder<Loan, Loan, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<Loan, Loan, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Loan, Loan, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterWhereClause> idBetween(
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

extension LoanQueryFilter on QueryBuilder<Loan, Loan, QFilterCondition> {
  QueryBuilder<Loan, Loan, QAfterFilterCondition> accountIdEqualTo(
    String value, {
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> accountIdGreaterThan(
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> accountIdLessThan(
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> accountIdBetween(
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> accountIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> accountIdEndsWith(
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> accountIdContains(
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> accountIdMatches(
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> accountIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'accountId', value: ''),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> accountIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'accountId', value: ''),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> adjustmentEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'adjustment',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> adjustmentGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'adjustment',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> adjustmentLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'adjustment',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> adjustmentBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'adjustment',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> alreadyRunningEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'alreadyRunning', value: value),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> annualRateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'annualRate'),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> annualRateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'annualRate'),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> annualRateEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'annualRate',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> annualRateGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'annualRate',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> annualRateLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'annualRate',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> annualRateBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'annualRate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> autoAddTransactionEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'autoAddTransaction', value: value),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> billDateEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'billDate', value: value),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> billDateGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'billDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> billDateLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'billDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> billDateBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'billDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> categoryIdEqualTo(
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> categoryIdGreaterThan(
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> categoryIdLessThan(
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> categoryIdBetween(
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> categoryIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> categoryIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> categoryIdContains(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> categoryIdMatches(
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> categoryIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'categoryId', value: ''),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> categoryIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'categoryId', value: ''),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> closedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'closedAt'),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> closedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'closedAt'),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> closedAtEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'closedAt', value: value),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> closedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> closedAtLessThan(
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> closedAtBetween(
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> countOnlyInterestEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'countOnlyInterest', value: value),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition>
  countOnlyInterestFromIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'countOnlyInterestFrom'),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition>
  countOnlyInterestFromIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'countOnlyInterestFrom'),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> countOnlyInterestFromEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'countOnlyInterestFrom',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition>
  countOnlyInterestFromGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'countOnlyInterestFrom',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> countOnlyInterestFromLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'countOnlyInterestFrom',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> countOnlyInterestFromBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'countOnlyInterestFrom',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> createdAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> dataVersionEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'dataVersion', value: value),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> dataVersionGreaterThan(
    int value, {
    bool include = false,
  }) {
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> dataVersionLessThan(
    int value, {
    bool include = false,
  }) {
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> dataVersionBetween(
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> emiAmountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'emiAmount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> emiAmountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'emiAmount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> emiAmountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'emiAmount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> emiAmountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'emiAmount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> emisPaidBeforeEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'emisPaidBefore', value: value),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> emisPaidBeforeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'emisPaidBefore',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> emisPaidBeforeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'emisPaidBefore',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> emisPaidBeforeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'emisPaidBefore',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> endDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'endDate'),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> endDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'endDate'),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> endDateEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'endDate', value: value),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> endDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'endDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> endDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'endDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> endDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'endDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> eventsLengthEqualTo(
    int length,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'events', length, true, length, true);
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> eventsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'events', 0, true, 0, true);
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> eventsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'events', 0, false, 999999, true);
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> eventsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'events', 0, true, length, include);
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> eventsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'events', length, include, 999999, true);
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> eventsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'events',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> interestOnlyMonthsEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'interestOnlyMonths', value: value),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> interestOnlyMonthsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'interestOnlyMonths',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> interestOnlyMonthsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'interestOnlyMonths',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> interestOnlyMonthsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'interestOnlyMonths',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> interestPaidBeforeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'interestPaidBefore',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> interestPaidBeforeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'interestPaidBefore',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> interestPaidBeforeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'interestPaidBefore',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> interestPaidBeforeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'interestPaidBefore',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> interestRateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'interestRate'),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> interestRateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'interestRate'),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> interestRateEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'interestRate',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> interestRateGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'interestRate',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> interestRateLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'interestRate',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> interestRateBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'interestRate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> interestTypeEqualTo(
    LoanInterestType value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'interestType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> interestTypeGreaterThan(
    LoanInterestType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'interestType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> interestTypeLessThan(
    LoanInterestType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'interestType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> interestTypeBetween(
    LoanInterestType lower,
    LoanInterestType upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'interestType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> interestTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'interestType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> interestTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'interestType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> interestTypeContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'interestType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> interestTypeMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'interestType',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> interestTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'interestType', value: ''),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> interestTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'interestType', value: ''),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> isCompletedEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isCompleted', value: value),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> lenderNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'lenderName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> lenderNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lenderName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> lenderNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lenderName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> lenderNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lenderName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> lenderNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'lenderName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> lenderNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'lenderName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> lenderNameContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'lenderName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> lenderNameMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'lenderName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> lenderNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lenderName', value: ''),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> lenderNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'lenderName', value: ''),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> loanStartDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'loanStartDate'),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> loanStartDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'loanStartDate'),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> loanStartDateEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'loanStartDate', value: value),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> loanStartDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'loanStartDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> loanStartDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'loanStartDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> loanStartDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'loanStartDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> loanTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'loanType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> loanTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'loanType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> loanTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'loanType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> loanTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'loanType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> loanTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'loanType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> loanTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'loanType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> loanTypeContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'loanType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> loanTypeMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'loanType',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> loanTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'loanType', value: ''),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> loanTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'loanType', value: ''),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> modeEqualTo(
    LoanMode value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'mode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> modeGreaterThan(
    LoanMode value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'mode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> modeLessThan(
    LoanMode value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'mode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> modeBetween(
    LoanMode lower,
    LoanMode upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'mode',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> modeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'mode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> modeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'mode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> modeContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'mode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> modeMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'mode',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> modeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'mode', value: ''),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> modeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'mode', value: ''),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> nameEqualTo(
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> nameGreaterThan(
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> nameLessThan(
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> nameBetween(
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> nameStartsWith(
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> nameEndsWith(
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> nameContains(
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> nameMatches(
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> notesEqualTo(
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> notesGreaterThan(
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> notesLessThan(
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> notesBetween(
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> notesStartsWith(
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> notesEndsWith(
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> notesContains(
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> notesMatches(
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> outstandingAtStartIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'outstandingAtStart'),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition>
  outstandingAtStartIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'outstandingAtStart'),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> outstandingAtStartEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'outstandingAtStart',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> outstandingAtStartGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'outstandingAtStart',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> outstandingAtStartLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'outstandingAtStart',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> outstandingAtStartBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'outstandingAtStart',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> principalAmountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'principalAmount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> principalAmountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'principalAmount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> principalAmountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'principalAmount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> principalAmountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'principalAmount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> principalPaidBeforeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'principalPaidBefore',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition>
  principalPaidBeforeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'principalPaidBefore',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> principalPaidBeforeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'principalPaidBefore',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> principalPaidBeforeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'principalPaidBefore',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> rateTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'rateType'),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> rateTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'rateType'),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> rateTypeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'rateType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> rateTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'rateType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> rateTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'rateType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> rateTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'rateType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> rateTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'rateType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> rateTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'rateType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> rateTypeContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'rateType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> rateTypeMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'rateType',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> rateTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'rateType', value: ''),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> rateTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'rateType', value: ''),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> referenceNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'referenceNumber'),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> referenceNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'referenceNumber'),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> referenceNumberEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'referenceNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> referenceNumberGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'referenceNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> referenceNumberLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'referenceNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> referenceNumberBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'referenceNumber',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> referenceNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'referenceNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> referenceNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'referenceNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> referenceNumberContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'referenceNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> referenceNumberMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'referenceNumber',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> referenceNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'referenceNumber', value: ''),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> referenceNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'referenceNumber', value: ''),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> scheduleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'schedule'),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> scheduleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'schedule'),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> startDateEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'startDate', value: value),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> startDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'startDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> startDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'startDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> startDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'startDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> startingPointEqualTo(
    LoanStartingPoint value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'startingPoint',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> startingPointGreaterThan(
    LoanStartingPoint value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'startingPoint',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> startingPointLessThan(
    LoanStartingPoint value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'startingPoint',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> startingPointBetween(
    LoanStartingPoint lower,
    LoanStartingPoint upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'startingPoint',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> startingPointStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'startingPoint',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> startingPointEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'startingPoint',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> startingPointContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'startingPoint',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> startingPointMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'startingPoint',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> startingPointIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'startingPoint', value: ''),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> startingPointIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'startingPoint', value: ''),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> tenureMonthsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'tenureMonths'),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> tenureMonthsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'tenureMonths'),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> tenureMonthsEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'tenureMonths', value: value),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> tenureMonthsGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'tenureMonths',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> tenureMonthsLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'tenureMonths',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> tenureMonthsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'tenureMonths',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> uidEqualTo(
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> uidGreaterThan(
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> uidLessThan(
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> uidBetween(
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> uidStartsWith(
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> uidEndsWith(
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> uidContains(
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> uidMatches(
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> uidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'uid', value: ''),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> uidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'uid', value: ''),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> updatedAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> updatedAtLessThan(
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

  QueryBuilder<Loan, Loan, QAfterFilterCondition> updatedAtBetween(
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

extension LoanQueryObject on QueryBuilder<Loan, Loan, QFilterCondition> {
  QueryBuilder<Loan, Loan, QAfterFilterCondition> eventsElement(
    FilterQuery<LoanEvent> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'events');
    });
  }

  QueryBuilder<Loan, Loan, QAfterFilterCondition> schedule(
    FilterQuery<Schedule> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'schedule');
    });
  }
}

extension LoanQueryLinks on QueryBuilder<Loan, Loan, QFilterCondition> {}

extension LoanQuerySortBy on QueryBuilder<Loan, Loan, QSortBy> {
  QueryBuilder<Loan, Loan, QAfterSortBy> sortByAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountId', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountId', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByAdjustment() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'adjustment', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByAdjustmentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'adjustment', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByAlreadyRunning() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alreadyRunning', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByAlreadyRunningDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alreadyRunning', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByAnnualRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'annualRate', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByAnnualRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'annualRate', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByAutoAddTransaction() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoAddTransaction', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByAutoAddTransactionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoAddTransaction', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByBillDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billDate', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByBillDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billDate', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByClosedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'closedAt', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByClosedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'closedAt', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByCountOnlyInterest() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'countOnlyInterest', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByCountOnlyInterestDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'countOnlyInterest', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByCountOnlyInterestFrom() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'countOnlyInterestFrom', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByCountOnlyInterestFromDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'countOnlyInterestFrom', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByDataVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataVersion', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByDataVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataVersion', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByEmiAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emiAmount', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByEmiAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emiAmount', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByEmisPaidBefore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emisPaidBefore', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByEmisPaidBeforeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emisPaidBefore', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByInterestOnlyMonths() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interestOnlyMonths', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByInterestOnlyMonthsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interestOnlyMonths', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByInterestPaidBefore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interestPaidBefore', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByInterestPaidBeforeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interestPaidBefore', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByInterestRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interestRate', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByInterestRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interestRate', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByInterestType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interestType', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByInterestTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interestType', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByLenderName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lenderName', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByLenderNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lenderName', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByLoanStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loanStartDate', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByLoanStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loanStartDate', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByLoanType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loanType', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByLoanTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loanType', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mode', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mode', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByOutstandingAtStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outstandingAtStart', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByOutstandingAtStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outstandingAtStart', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByPrincipalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'principalAmount', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByPrincipalAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'principalAmount', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByPrincipalPaidBefore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'principalPaidBefore', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByPrincipalPaidBeforeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'principalPaidBefore', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByRateType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rateType', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByRateTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rateType', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByReferenceNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenceNumber', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByReferenceNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenceNumber', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByStartingPoint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startingPoint', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByStartingPointDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startingPoint', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByTenureMonths() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tenureMonths', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByTenureMonthsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tenureMonths', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension LoanQuerySortThenBy on QueryBuilder<Loan, Loan, QSortThenBy> {
  QueryBuilder<Loan, Loan, QAfterSortBy> thenByAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountId', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountId', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByAdjustment() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'adjustment', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByAdjustmentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'adjustment', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByAlreadyRunning() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alreadyRunning', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByAlreadyRunningDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alreadyRunning', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByAnnualRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'annualRate', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByAnnualRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'annualRate', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByAutoAddTransaction() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoAddTransaction', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByAutoAddTransactionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoAddTransaction', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByBillDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billDate', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByBillDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billDate', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByClosedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'closedAt', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByClosedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'closedAt', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByCountOnlyInterest() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'countOnlyInterest', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByCountOnlyInterestDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'countOnlyInterest', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByCountOnlyInterestFrom() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'countOnlyInterestFrom', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByCountOnlyInterestFromDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'countOnlyInterestFrom', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByDataVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataVersion', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByDataVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataVersion', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByEmiAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emiAmount', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByEmiAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emiAmount', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByEmisPaidBefore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emisPaidBefore', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByEmisPaidBeforeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emisPaidBefore', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByInterestOnlyMonths() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interestOnlyMonths', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByInterestOnlyMonthsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interestOnlyMonths', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByInterestPaidBefore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interestPaidBefore', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByInterestPaidBeforeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interestPaidBefore', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByInterestRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interestRate', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByInterestRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interestRate', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByInterestType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interestType', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByInterestTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interestType', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByLenderName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lenderName', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByLenderNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lenderName', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByLoanStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loanStartDate', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByLoanStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loanStartDate', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByLoanType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loanType', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByLoanTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loanType', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mode', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mode', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByOutstandingAtStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outstandingAtStart', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByOutstandingAtStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outstandingAtStart', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByPrincipalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'principalAmount', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByPrincipalAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'principalAmount', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByPrincipalPaidBefore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'principalPaidBefore', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByPrincipalPaidBeforeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'principalPaidBefore', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByRateType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rateType', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByRateTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rateType', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByReferenceNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenceNumber', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByReferenceNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenceNumber', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByStartingPoint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startingPoint', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByStartingPointDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startingPoint', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByTenureMonths() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tenureMonths', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByTenureMonthsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tenureMonths', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<Loan, Loan, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension LoanQueryWhereDistinct on QueryBuilder<Loan, Loan, QDistinct> {
  QueryBuilder<Loan, Loan, QDistinct> distinctByAccountId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'accountId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Loan, Loan, QDistinct> distinctByAdjustment() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'adjustment');
    });
  }

  QueryBuilder<Loan, Loan, QDistinct> distinctByAlreadyRunning() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'alreadyRunning');
    });
  }

  QueryBuilder<Loan, Loan, QDistinct> distinctByAnnualRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'annualRate');
    });
  }

  QueryBuilder<Loan, Loan, QDistinct> distinctByAutoAddTransaction() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autoAddTransaction');
    });
  }

  QueryBuilder<Loan, Loan, QDistinct> distinctByBillDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'billDate');
    });
  }

  QueryBuilder<Loan, Loan, QDistinct> distinctByCategoryId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'categoryId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Loan, Loan, QDistinct> distinctByClosedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'closedAt');
    });
  }

  QueryBuilder<Loan, Loan, QDistinct> distinctByCountOnlyInterest() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'countOnlyInterest');
    });
  }

  QueryBuilder<Loan, Loan, QDistinct> distinctByCountOnlyInterestFrom() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'countOnlyInterestFrom');
    });
  }

  QueryBuilder<Loan, Loan, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<Loan, Loan, QDistinct> distinctByDataVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dataVersion');
    });
  }

  QueryBuilder<Loan, Loan, QDistinct> distinctByEmiAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'emiAmount');
    });
  }

  QueryBuilder<Loan, Loan, QDistinct> distinctByEmisPaidBefore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'emisPaidBefore');
    });
  }

  QueryBuilder<Loan, Loan, QDistinct> distinctByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endDate');
    });
  }

  QueryBuilder<Loan, Loan, QDistinct> distinctByInterestOnlyMonths() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'interestOnlyMonths');
    });
  }

  QueryBuilder<Loan, Loan, QDistinct> distinctByInterestPaidBefore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'interestPaidBefore');
    });
  }

  QueryBuilder<Loan, Loan, QDistinct> distinctByInterestRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'interestRate');
    });
  }

  QueryBuilder<Loan, Loan, QDistinct> distinctByInterestType({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'interestType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Loan, Loan, QDistinct> distinctByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCompleted');
    });
  }

  QueryBuilder<Loan, Loan, QDistinct> distinctByLenderName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lenderName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Loan, Loan, QDistinct> distinctByLoanStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'loanStartDate');
    });
  }

  QueryBuilder<Loan, Loan, QDistinct> distinctByLoanType({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'loanType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Loan, Loan, QDistinct> distinctByMode({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Loan, Loan, QDistinct> distinctByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Loan, Loan, QDistinct> distinctByNotes({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Loan, Loan, QDistinct> distinctByOutstandingAtStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'outstandingAtStart');
    });
  }

  QueryBuilder<Loan, Loan, QDistinct> distinctByPrincipalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'principalAmount');
    });
  }

  QueryBuilder<Loan, Loan, QDistinct> distinctByPrincipalPaidBefore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'principalPaidBefore');
    });
  }

  QueryBuilder<Loan, Loan, QDistinct> distinctByRateType({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rateType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Loan, Loan, QDistinct> distinctByReferenceNumber({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'referenceNumber',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Loan, Loan, QDistinct> distinctByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startDate');
    });
  }

  QueryBuilder<Loan, Loan, QDistinct> distinctByStartingPoint({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'startingPoint',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Loan, Loan, QDistinct> distinctByTenureMonths() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tenureMonths');
    });
  }

  QueryBuilder<Loan, Loan, QDistinct> distinctByUid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Loan, Loan, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension LoanQueryProperty on QueryBuilder<Loan, Loan, QQueryProperty> {
  QueryBuilder<Loan, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Loan, String, QQueryOperations> accountIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'accountId');
    });
  }

  QueryBuilder<Loan, double, QQueryOperations> adjustmentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'adjustment');
    });
  }

  QueryBuilder<Loan, bool, QQueryOperations> alreadyRunningProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'alreadyRunning');
    });
  }

  QueryBuilder<Loan, double?, QQueryOperations> annualRateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'annualRate');
    });
  }

  QueryBuilder<Loan, bool, QQueryOperations> autoAddTransactionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autoAddTransaction');
    });
  }

  QueryBuilder<Loan, int, QQueryOperations> billDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'billDate');
    });
  }

  QueryBuilder<Loan, String, QQueryOperations> categoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'categoryId');
    });
  }

  QueryBuilder<Loan, DateTime?, QQueryOperations> closedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'closedAt');
    });
  }

  QueryBuilder<Loan, bool, QQueryOperations> countOnlyInterestProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'countOnlyInterest');
    });
  }

  QueryBuilder<Loan, DateTime?, QQueryOperations>
  countOnlyInterestFromProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'countOnlyInterestFrom');
    });
  }

  QueryBuilder<Loan, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<Loan, int, QQueryOperations> dataVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dataVersion');
    });
  }

  QueryBuilder<Loan, double, QQueryOperations> emiAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'emiAmount');
    });
  }

  QueryBuilder<Loan, int, QQueryOperations> emisPaidBeforeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'emisPaidBefore');
    });
  }

  QueryBuilder<Loan, DateTime?, QQueryOperations> endDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endDate');
    });
  }

  QueryBuilder<Loan, List<LoanEvent>, QQueryOperations> eventsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'events');
    });
  }

  QueryBuilder<Loan, int, QQueryOperations> interestOnlyMonthsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'interestOnlyMonths');
    });
  }

  QueryBuilder<Loan, double, QQueryOperations> interestPaidBeforeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'interestPaidBefore');
    });
  }

  QueryBuilder<Loan, double?, QQueryOperations> interestRateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'interestRate');
    });
  }

  QueryBuilder<Loan, LoanInterestType, QQueryOperations>
  interestTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'interestType');
    });
  }

  QueryBuilder<Loan, bool, QQueryOperations> isCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCompleted');
    });
  }

  QueryBuilder<Loan, String, QQueryOperations> lenderNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lenderName');
    });
  }

  QueryBuilder<Loan, DateTime?, QQueryOperations> loanStartDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'loanStartDate');
    });
  }

  QueryBuilder<Loan, String, QQueryOperations> loanTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'loanType');
    });
  }

  QueryBuilder<Loan, LoanMode, QQueryOperations> modeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mode');
    });
  }

  QueryBuilder<Loan, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<Loan, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<Loan, double?, QQueryOperations> outstandingAtStartProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'outstandingAtStart');
    });
  }

  QueryBuilder<Loan, double, QQueryOperations> principalAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'principalAmount');
    });
  }

  QueryBuilder<Loan, double, QQueryOperations> principalPaidBeforeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'principalPaidBefore');
    });
  }

  QueryBuilder<Loan, String?, QQueryOperations> rateTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rateType');
    });
  }

  QueryBuilder<Loan, String?, QQueryOperations> referenceNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'referenceNumber');
    });
  }

  QueryBuilder<Loan, Schedule?, QQueryOperations> scheduleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schedule');
    });
  }

  QueryBuilder<Loan, DateTime, QQueryOperations> startDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startDate');
    });
  }

  QueryBuilder<Loan, LoanStartingPoint, QQueryOperations>
  startingPointProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startingPoint');
    });
  }

  QueryBuilder<Loan, int?, QQueryOperations> tenureMonthsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tenureMonths');
    });
  }

  QueryBuilder<Loan, String, QQueryOperations> uidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uid');
    });
  }

  QueryBuilder<Loan, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const LoanEventSchema = Schema(
  name: r'LoanEvent',
  id: 5429893548129368131,
  properties: {
    r'adjust': PropertySchema(
      id: 0,
      name: r'adjust',
      type: IsarType.string,
      enumMap: _LoanEventadjustEnumValueMap,
    ),
    r'amount': PropertySchema(id: 1, name: r'amount', type: IsarType.double),
    r'charge': PropertySchema(id: 2, name: r'charge', type: IsarType.double),
    r'chargeTransactionId': PropertySchema(
      id: 3,
      name: r'chargeTransactionId',
      type: IsarType.long,
    ),
    r'date': PropertySchema(id: 4, name: r'date', type: IsarType.dateTime),
    r'kind': PropertySchema(
      id: 5,
      name: r'kind',
      type: IsarType.string,
      enumMap: _LoanEventkindEnumValueMap,
    ),
    r'newRate': PropertySchema(id: 6, name: r'newRate', type: IsarType.double),
    r'transactionId': PropertySchema(
      id: 7,
      name: r'transactionId',
      type: IsarType.long,
    ),
  },

  estimateSize: _loanEventEstimateSize,
  serialize: _loanEventSerialize,
  deserialize: _loanEventDeserialize,
  deserializeProp: _loanEventDeserializeProp,
);

int _loanEventEstimateSize(
  LoanEvent object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.adjust.name.length * 3;
  bytesCount += 3 + object.kind.name.length * 3;
  return bytesCount;
}

void _loanEventSerialize(
  LoanEvent object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.adjust.name);
  writer.writeDouble(offsets[1], object.amount);
  writer.writeDouble(offsets[2], object.charge);
  writer.writeLong(offsets[3], object.chargeTransactionId);
  writer.writeDateTime(offsets[4], object.date);
  writer.writeString(offsets[5], object.kind.name);
  writer.writeDouble(offsets[6], object.newRate);
  writer.writeLong(offsets[7], object.transactionId);
}

LoanEvent _loanEventDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LoanEvent();
  object.adjust =
      _LoanEventadjustValueEnumMap[reader.readStringOrNull(offsets[0])] ??
      LoanAdjust.tenure;
  object.amount = reader.readDouble(offsets[1]);
  object.charge = reader.readDouble(offsets[2]);
  object.chargeTransactionId = reader.readLongOrNull(offsets[3]);
  object.date = reader.readDateTimeOrNull(offsets[4]);
  object.kind =
      _LoanEventkindValueEnumMap[reader.readStringOrNull(offsets[5])] ??
      LoanEventKind.rateChange;
  object.newRate = reader.readDoubleOrNull(offsets[6]);
  object.transactionId = reader.readLongOrNull(offsets[7]);
  return object;
}

P _loanEventDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (_LoanEventadjustValueEnumMap[reader.readStringOrNull(offset)] ??
              LoanAdjust.tenure)
          as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (_LoanEventkindValueEnumMap[reader.readStringOrNull(offset)] ??
              LoanEventKind.rateChange)
          as P;
    case 6:
      return (reader.readDoubleOrNull(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _LoanEventadjustEnumValueMap = {r'tenure': r'tenure', r'emi': r'emi'};
const _LoanEventadjustValueEnumMap = {
  r'tenure': LoanAdjust.tenure,
  r'emi': LoanAdjust.emi,
};
const _LoanEventkindEnumValueMap = {
  r'rateChange': r'rateChange',
  r'prepayment': r'prepayment',
  r'charge': r'charge',
};
const _LoanEventkindValueEnumMap = {
  r'rateChange': LoanEventKind.rateChange,
  r'prepayment': LoanEventKind.prepayment,
  r'charge': LoanEventKind.charge,
};

extension LoanEventQueryFilter
    on QueryBuilder<LoanEvent, LoanEvent, QFilterCondition> {
  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition> adjustEqualTo(
    LoanAdjust value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'adjust',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition> adjustGreaterThan(
    LoanAdjust value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'adjust',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition> adjustLessThan(
    LoanAdjust value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'adjust',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition> adjustBetween(
    LoanAdjust lower,
    LoanAdjust upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'adjust',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition> adjustStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'adjust',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition> adjustEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'adjust',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition> adjustContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'adjust',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition> adjustMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'adjust',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition> adjustIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'adjust', value: ''),
      );
    });
  }

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition> adjustIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'adjust', value: ''),
      );
    });
  }

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition> amountEqualTo(
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

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition> amountGreaterThan(
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

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition> amountLessThan(
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

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition> amountBetween(
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

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition> chargeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'charge',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition> chargeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'charge',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition> chargeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'charge',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition> chargeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'charge',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition>
  chargeTransactionIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'chargeTransactionId'),
      );
    });
  }

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition>
  chargeTransactionIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'chargeTransactionId'),
      );
    });
  }

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition>
  chargeTransactionIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'chargeTransactionId', value: value),
      );
    });
  }

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition>
  chargeTransactionIdGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'chargeTransactionId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition>
  chargeTransactionIdLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'chargeTransactionId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition>
  chargeTransactionIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'chargeTransactionId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition> dateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'date'),
      );
    });
  }

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition> dateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'date'),
      );
    });
  }

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition> dateEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'date', value: value),
      );
    });
  }

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition> dateGreaterThan(
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

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition> dateLessThan(
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

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition> dateBetween(
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

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition> kindEqualTo(
    LoanEventKind value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'kind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition> kindGreaterThan(
    LoanEventKind value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'kind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition> kindLessThan(
    LoanEventKind value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'kind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition> kindBetween(
    LoanEventKind lower,
    LoanEventKind upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'kind',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition> kindStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'kind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition> kindEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'kind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition> kindContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'kind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition> kindMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'kind',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition> kindIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'kind', value: ''),
      );
    });
  }

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition> kindIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'kind', value: ''),
      );
    });
  }

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition> newRateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'newRate'),
      );
    });
  }

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition> newRateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'newRate'),
      );
    });
  }

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition> newRateEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'newRate',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition> newRateGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'newRate',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition> newRateLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'newRate',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition> newRateBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'newRate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition>
  transactionIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'transactionId'),
      );
    });
  }

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition>
  transactionIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'transactionId'),
      );
    });
  }

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition>
  transactionIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'transactionId', value: value),
      );
    });
  }

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition>
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

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition>
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

  QueryBuilder<LoanEvent, LoanEvent, QAfterFilterCondition>
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

extension LoanEventQueryObject
    on QueryBuilder<LoanEvent, LoanEvent, QFilterCondition> {}
